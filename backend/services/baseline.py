"""
HerLuna Baseline Computation Service
Computes personalized baselines from user data — NOT population averages.
Used by inference to generate personalized deviations and confidence scores.

Philosophical guarantees:
  - No hardcoded biological normal ranges (no 15-60 day filter)
  - No artificial variability injection (no std=5.0 fallback)
  - No normative sleep priors (no 7.0 default)
  - variability_index = None means "no data", not "high variability"
  - Anomaly detection handles outliers — baseline does not filter them
"""
import numpy as np
from typing import List, Optional


def compute_cycle_variability(cycle_logs: List[dict]) -> dict:
    """
    Compute personalized cycle statistics from observed data.

    - Accepts ANY positive cycle interval (no 15-60 day filter)
    - Single data point → std = 0.0 (not injected 5.0)
    - No data → variability_index = None (not 1.0)

    Returns:
        {
            "mean_cycle_length": float | 0.0,
            "std_cycle_length": float | 0.0,
            "variability_index": float | None,
            "data_points": int,
        }
    """
    lengths = []
    for log in cycle_logs:
        cl = log.get("cycle_length")
        if cl and cl > 0:
            lengths.append(cl)

    # Fallback: compute from adjacent period_start dates
    # Accept any positive diff — anomaly detection handles outliers
    if not lengths and len(cycle_logs) >= 2:
        sorted_logs = sorted(cycle_logs, key=lambda x: str(x.get("period_start", "")))
        for i in range(1, len(sorted_logs)):
            try:
                d1 = _parse_date(sorted_logs[i - 1]["period_start"])
                d2 = _parse_date(sorted_logs[i]["period_start"])
                diff = (d2 - d1).days
                if diff > 0:  # Only reject zero or negative
                    lengths.append(diff)
            except (ValueError, TypeError):
                continue

    if not lengths:
        return {
            "mean_cycle_length": 0.0,
            "std_cycle_length": 0.0,
            "variability_index": None,  # None = no data, NOT high variability
            "data_points": 0,
        }

    mean_len = max(0.0, float(np.mean(lengths)))  # Cannot be negative

    # Single data point → zero variability (no artificial injection)
    std_len = float(np.std(lengths)) if len(lengths) > 1 else 0.0

    # Clamp variability_index to reasonable upper bound (max 10.0)
    if mean_len > 0:
        var_index = min(std_len / mean_len, 10.0)
    else:
        var_index = 0.0

    return {
        "mean_cycle_length": round(mean_len, 1),
        "std_cycle_length": round(std_len, 1),
        "variability_index": round(var_index, 4),
        "data_points": len(lengths),
    }


def compute_behavioral_deviation(behavioral_data: List[dict]) -> dict:
    """
    Compute z-score deviations from the user's personal rolling averages.
    Uses individual baseline, NOT population averages.

    - Sorts by date descending (never assumes input order)
    - Missing sleep_hours excluded, NOT substituted with 7.0
    - Division-safe z-score computation

    Returns:
        {
            "step_deviation": float,   # z-score
            "screen_deviation": float,
            "calendar_deviation": float,
            "sleep_deviation": float | None,
            "rolling_avg_steps": float,
            "rolling_avg_screen": float,
            "rolling_avg_calendar": float,
            "rolling_avg_sleep": float | None,
        }
    """
    if not behavioral_data or len(behavioral_data) < 2:
        return {
            "step_deviation": 0.0,
            "screen_deviation": 0.0,
            "calendar_deviation": 0.0,
            "sleep_deviation": None,  # No data, not "no deviation"
            "rolling_avg_steps": 0.0,
            "rolling_avg_screen": 0.0,
            "rolling_avg_calendar": 0.0,
            "rolling_avg_sleep": None,
        }

    # Sort by date descending — never assume input order
    sorted_data = sorted(
        behavioral_data,
        key=lambda x: str(x.get("date", "")),
        reverse=True,
    )

    # Latest entry vs rolling 14-day history
    latest = sorted_data[0]
    history = sorted_data[1:15]

    steps = [d.get("step_count", 0) for d in history]
    screens = [d.get("screen_time", 0.0) for d in history]
    calendars = [d.get("calendar_load", 0) for d in history]
    # Only include entries where sleep_hours actually exists — no normative default
    sleeps = [d["sleep_hours"] for d in history if d.get("sleep_hours") is not None]

    def _zscore(value, data):
        """Division-safe z-score. Returns (z_score, mean)."""
        if value is None or not data or len(data) < 2:
            return None, (float(np.mean(data)) if data else None)
        mean = float(np.mean(data))
        std = float(np.std(data))
        if std == 0:
            return 0.0, round(mean, 1)
        return round((value - mean) / std, 3), round(mean, 1)

    step_dev, avg_steps = _zscore(latest.get("step_count", 0), steps)
    screen_dev, avg_screen = _zscore(latest.get("screen_time", 0.0), screens)
    cal_dev, avg_cal = _zscore(latest.get("calendar_load", 0), calendars)

    # Sleep: only compute if user has reported sleep_hours
    latest_sleep = latest.get("sleep_hours")
    sleep_dev, avg_sleep = _zscore(latest_sleep, sleeps)

    return {
        "step_deviation": step_dev if step_dev is not None else 0.0,
        "screen_deviation": screen_dev if screen_dev is not None else 0.0,
        "calendar_deviation": cal_dev if cal_dev is not None else 0.0,
        "sleep_deviation": sleep_dev,  # None if no sleep data
        "rolling_avg_steps": avg_steps if avg_steps is not None else 0.0,
        "rolling_avg_screen": avg_screen if avg_screen is not None else 0.0,
        "rolling_avg_calendar": avg_cal if avg_cal is not None else 0.0,
        "rolling_avg_sleep": avg_sleep,  # None if no sleep data
    }


def compute_confidence_score(
    cycle_data_points: int,
    behavioral_data_points: int,
    variability_index: Optional[float],
) -> float:
    """
    Compute confidence score based on data volume and consistency.
    More data + lower variability = higher confidence.

    Volume caps reflect diminishing returns assumptions:
      - 6 cycle data points: represents ~6 months of cycle data.
        Beyond this, additional cycle logs add marginal value
        because the baseline mean/std stabilize.
      - 7 behavioral data points: represents ~1 week of daily logs.
        A full week captures weekday/weekend patterns, beyond which
        the rolling average stabilizes.

    Weights:
      - Cycle volume: 40% — most critical for physiological inference
      - Behavioral volume: 30% — supports fatigue/stress modeling
      - Consistency: 30% — lower variability increases predictability

    Returns: float between 0.1 and 1.0
    """
    # Data volume factor (saturates via diminishing returns)
    cycle_factor = min(1.0, cycle_data_points / 6.0) * 0.4
    behavioral_factor = min(1.0, behavioral_data_points / 7.0) * 0.3

    # Consistency factor (lower variability = higher score)
    # None variability_index means no data → no consistency bonus
    if variability_index is not None:
        clamped_vi = min(variability_index, 10.0)
        consistency_factor = max(0.0, 1.0 - clamped_vi) * 0.3
    else:
        consistency_factor = 0.0

    confidence = cycle_factor + behavioral_factor + consistency_factor
    return round(max(0.1, min(1.0, confidence)), 3)


def _parse_date(date_str):
    """Parse date string or date object."""
    from datetime import datetime, date
    if isinstance(date_str, date):
        return date_str
    return datetime.strptime(str(date_str), "%Y-%m-%d").date()
