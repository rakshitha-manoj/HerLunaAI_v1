"""
Physiological Variability Agent
Produces a probability distribution over menstrual phases using
Gaussian estimation on PRECOMPUTED personalized baselines.

Architectural role:
  - CONSUMES cycle_baseline from shared_state (computed by baseline.py)
  - Does NOT recompute mean/std/variability (no cross-layer duplication)
  - Does NOT filter cycle intervals (no 15-60 filter)
  - Does NOT inject artificial std (no std=5.0)
  - Does NOT compute confidence (inference service handles it)
  - Only models phase probabilities & estimated day-in-cycle
"""
import numpy as np
from datetime import datetime, date


class PhysiologicalAgent:
    """
    Produces a probability distribution over menstrual phases.
    Handles irregular cycles through personalized statistical modeling.
    """

    # Phase priors expressed as fractional cycle positions.
    # These are biological phase windows that SCALE with the personalized
    # mean cycle length — they do NOT assume a 28-day cycle.
    # Example: for a 35-day cycle, ovulatory is ~day 16-20 (0.46*35 to 0.57*35)
    PHASE_RANGES = {
        "menstrual": (0.0, 0.17),      # ~first 17% of cycle
        "follicular": (0.17, 0.46),     # ~17-46% of cycle
        "ovulatory": (0.46, 0.57),      # ~46-57% of cycle
        "luteal": (0.57, 1.0),          # ~57-100% of cycle
    }

    def analyze(self, shared_state: dict) -> dict:
        """
        Compute phase probability distribution from precomputed baselines.

        Reads cycle_baseline from shared_state (populated by baseline.py).
        Does NOT recompute statistics — single source of truth.

        Returns:
            {
                "phase_probability": {menstrual, follicular, ovulatory, luteal},
                "estimated_day_in_cycle": int,
                "top_features": list,
            }
        """
        # ── Consume precomputed baseline ─────────────────────────────────
        cycle_baseline = shared_state.get("cycle_baseline", {})
        mean_length = cycle_baseline.get("mean_cycle_length")
        std_length = cycle_baseline.get("std_cycle_length", 0.0)
        data_points = cycle_baseline.get("data_points", 0)

        # Insufficient data → uniform distribution
        if not mean_length or mean_length <= 0 or data_points < 1:
            return self._insufficient_data_response()

        # ── Estimate current day in cycle ────────────────────────────────
        cycle_logs = shared_state.get("cycle_logs", [])
        day_in_cycle = self._estimate_day_in_cycle(cycle_logs)

        # ── Compute phase probabilities using Gaussian estimation ────────
        personal_model = shared_state.get("personal_model")
        puf = getattr(personal_model, "phase_uncertainty_factor", 1.0) if personal_model else 1.0
        phase_probs = self._compute_phase_probabilities(
            day_in_cycle, mean_length, std_length, phase_uncertainty_factor=puf,
        )

        return {
            "phase_probability": phase_probs,
            "estimated_day_in_cycle": day_in_cycle,
            "top_features": [
                f"Mean cycle length: {round(mean_length, 1)} days",
                f"Day {day_in_cycle} of current cycle",
            ],
        }

    def _estimate_day_in_cycle(self, cycle_logs: list) -> int:
        """
        Estimate current day in cycle from most recent period_start.
        Sorts by date descending — never assumes input order.
        Returns 0 if no valid date found.
        """
        if not cycle_logs:
            return 0

        # Sort descending by period_start
        sorted_logs = sorted(
            cycle_logs,
            key=lambda x: str(x.get("period_start", "")),
            reverse=True,
        )

        for log in sorted_logs:
            try:
                last_period = self._parse_date(log["period_start"])
                today = date.today()
                day = (today - last_period).days + 1
                return max(1, day)  # At least day 1
            except (ValueError, TypeError, KeyError):
                continue

        return 0

    def _compute_phase_probabilities(
        self, day_in_cycle: int, mean_length: float, std_length: float,
        phase_uncertainty_factor: float = 1.0,
    ) -> dict:
        """
        Compute phase probabilities using Gaussian-weighted estimation.

        The probability reflects how likely the user is in each phase,
        given their personalized cycle statistics and current day.
        Wider Gaussian spread = more variability = more uncertainty.
        phase_uncertainty_factor from PersonalModel scales the spread.
        """
        if mean_length <= 0:
            return {"menstrual": 0.25, "follicular": 0.25, "ovulatory": 0.25, "luteal": 0.25}

        # Normalize day into fraction of expected cycle
        fraction = day_in_cycle / mean_length
        fraction = max(0.0, min(fraction, 1.3))

        probs = {}
        for phase, (low, high) in self.PHASE_RANGES.items():
            center = (low + high) / 2
            spread = (high - low) / 2

            # Adjust spread by variability (more variable = wider Gaussian)
            # phase_uncertainty_factor from PersonalModel scales the adaptation
            variability_ratio = std_length / mean_length if mean_length > 0 else 0.0
            adjusted_spread = spread + variability_ratio * 0.15 * phase_uncertainty_factor

            # Gaussian probability
            prob = np.exp(-0.5 * ((fraction - center) / max(adjusted_spread, 0.01)) ** 2)
            probs[phase] = float(prob)

        # Normalize to sum to 1 (inference layer also enforces this)
        total = sum(probs.values())
        if total > 0:
            probs = {k: round(v / total, 4) for k, v in probs.items()}

        return probs

    def _parse_date(self, date_str) -> date:
        """Parse date string or date object."""
        if isinstance(date_str, date):
            return date_str
        return datetime.strptime(str(date_str), "%Y-%m-%d").date()

    def _insufficient_data_response(self) -> dict:
        """Return uniform distribution when baseline data is insufficient."""
        return {
            "phase_probability": {
                "menstrual": 0.25,
                "follicular": 0.25,
                "ovulatory": 0.25,
                "luteal": 0.25,
            },
            "estimated_day_in_cycle": 0,
            "top_features": ["Insufficient cycle data for personalized analysis"],
        }
