"""
Trend Detection Agent (Longitudinal Intelligence)
Detects long-term drift patterns over time.

Architectural role:
  - Analyzes cycle and behavioral trends from historical data
  - Does NOT override anomaly_flag (complementary, not competing)
  - Consumes raw logs and baselines from shared_state
  - Returns trend_flags and trend_score for meta
"""


class TrendAgent:
    """
    Detects long-term drift in cycle patterns and behavioral data.
    Compares recent windows against historical windows.
    """

    def analyze(self, shared_state: dict) -> dict:
        """
        Detect longitudinal trends.

        Returns:
            {
                "trend_flags": list[str],
                "trend_score": float,
            }
        """
        trend_flags = []
        scores = []

        # ── Cycle drift detection ────────────────────────────────────────
        cycle_drift = self._detect_cycle_drift(shared_state.get("cycle_logs", []))
        if cycle_drift:
            trend_flags.append(cycle_drift["flag"])
            scores.append(cycle_drift["score"])

        # ── Behavioral trend shift detection ─────────────────────────────
        behavioral_shifts = self._detect_behavioral_shift(
            shared_state.get("behavioral_data", []),
            shared_state.get("behavioral_baseline", {}),
        )
        for shift in behavioral_shifts:
            trend_flags.append(shift["flag"])
            scores.append(shift["score"])

        trend_score = sum(scores) / len(scores) if scores else 0.0

        return {
            "trend_flags": trend_flags,
            "trend_score": round(min(1.0, trend_score), 4),
        }

    def _detect_cycle_drift(self, cycle_logs: list) -> dict | None:
        """
        Compare mean of last 3 cycles vs previous 3 cycles.
        If difference > 20% → flag "cycle drift".
        """
        # Extract positive cycle lengths, sorted by date desc
        sorted_logs = sorted(
            cycle_logs,
            key=lambda x: str(x.get("period_start", "")),
            reverse=True,
        )
        lengths = [
            log["cycle_length"]
            for log in sorted_logs
            if log.get("cycle_length") and log["cycle_length"] > 0
        ]

        if len(lengths) < 6:
            return None

        recent_3 = lengths[:3]
        prev_3 = lengths[3:6]

        mean_recent = sum(recent_3) / 3
        mean_prev = sum(prev_3) / 3

        if mean_prev == 0:
            return None

        pct_change = abs(mean_recent - mean_prev) / mean_prev

        if pct_change > 0.20:
            direction = "lengthening" if mean_recent > mean_prev else "shortening"
            return {
                "flag": (
                    f"Cycle drift detected: {direction} "
                    f"({round(mean_prev, 1)} → {round(mean_recent, 1)} days, "
                    f"{round(pct_change * 100, 1)}% change)"
                ),
                "score": min(1.0, pct_change),
            }

        return None

    def _detect_behavioral_shift(self, behavioral_data: list, behavioral_baseline: dict) -> list:
        """
        Compute 7-day average vs 30-day average for key metrics.
        If sustained deviation > 1.5 std → flag "behavioral trend shift".
        """
        shifts = []

        if len(behavioral_data) < 14:
            return shifts

        # Sort descending by date
        sorted_data = sorted(
            behavioral_data,
            key=lambda x: str(x.get("date", "")),
            reverse=True,
        )

        metrics = [
            ("step_count", "Step count"),
            ("screen_time", "Screen time"),
            ("calendar_load", "Calendar load"),
        ]

        for key, name in metrics:
            recent_7 = [d.get(key, 0) for d in sorted_data[:7]]
            older = [d.get(key, 0) for d in sorted_data[7:30]]

            if not older or len(older) < 7:
                continue

            mean_recent = sum(recent_7) / len(recent_7)
            mean_older = sum(older) / len(older)

            # Compute std from older window
            variance = sum((v - mean_older) ** 2 for v in older) / len(older)
            std_older = variance ** 0.5

            if std_older == 0:
                continue

            shift_z = abs(mean_recent - mean_older) / std_older

            if shift_z > 1.5:
                direction = "increasing" if mean_recent > mean_older else "decreasing"
                shifts.append({
                    "flag": (
                        f"{name} trend shift: {direction} "
                        f"(7-day avg {round(mean_recent, 1)} vs "
                        f"30-day avg {round(mean_older, 1)}, Z: {round(shift_z, 2)})"
                    ),
                    "score": min(1.0, shift_z / 3.0),
                })

        return shifts
