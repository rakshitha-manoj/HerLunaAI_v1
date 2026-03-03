"""
Travel Risk Agent
Calculates overlap probability between travel dates and
high-phase probability windows (e.g., menstrual, ovulatory).
"""
from datetime import datetime, date, timedelta
import numpy as np


class TravelAgent:
    """
    Computes travel risk as the probability that a travel period
    overlaps with physiologically demanding phases.
    """

    # Phases considered high-impact during travel
    HIGH_IMPACT_PHASES = ["menstrual", "ovulatory"]

    def analyze(self, shared_state: dict) -> dict:
        """
        Calculate travel risk from overlap with high-phase windows.

        Returns:
            {
                "travel_risk": float,
                "overlapping_phases": list,
                "travel_periods_analyzed": int,
                "top_features": list
            }
        """
        travel_data = shared_state.get("travel_data", [])
        physio = shared_state.get("physio_result", {})

        if not travel_data:
            return {
                "travel_risk": 0.0,
                "overlapping_phases": [],
                "travel_periods_analyzed": 0,
                "top_features": ["No upcoming travel data"],
            }

        phase_probs = physio.get("phase_probability", {})
        mean_length = physio.get("mean_cycle_length", 28)
        day_in_cycle = physio.get("estimated_day_in_cycle", 1)

        # ── Analyze each travel period ───────────────────────────────────
        max_risk = 0.0
        overlapping_phases = []
        today = date.today()

        for travel in travel_data:
            start = self._parse_date(travel["start_date"])
            end = self._parse_date(travel["end_date"])

            # Only analyze future or current travel
            if end < today:
                continue

            travel_days = (end - start).days + 1
            risk = self._compute_overlap_risk(
                start, end, today, day_in_cycle, mean_length, phase_probs
            )

            if risk > max_risk:
                max_risk = risk

            # Identify which phases overlap
            for phase in self.HIGH_IMPACT_PHASES:
                if phase_probs.get(phase, 0) > 0.3:
                    overlapping_phases.append(phase)

        overlapping_phases = list(set(overlapping_phases))
        travel_risk = round(max_risk, 4)

        return {
            "travel_risk": travel_risk,
            "overlapping_phases": overlapping_phases,
            "travel_periods_analyzed": len(travel_data),
            "top_features": [
                f"Travel risk: {round(travel_risk * 100, 1)}%",
                f"Overlapping phases: {', '.join(overlapping_phases) if overlapping_phases else 'none'}",
            ],
        }

    def _compute_overlap_risk(
        self,
        travel_start: date,
        travel_end: date,
        today: date,
        day_in_cycle: int,
        mean_length: float,
        phase_probs: dict,
    ) -> float:
        """
        Compute the probability of overlap between travel and
        high-impact phases across the travel duration.
        """
        if mean_length <= 0:
            return 0.0

        risk_scores = []
        travel_days = (travel_end - travel_start).days + 1

        for offset in range(travel_days):
            future_date = travel_start + timedelta(days=offset)
            future_day_offset = (future_date - today).days
            future_cycle_day = (day_in_cycle + future_day_offset) % max(int(mean_length), 1)

            # Estimate phase probabilities for this future day
            fraction = future_cycle_day / mean_length
            phase_risk = 0.0

            for phase in self.HIGH_IMPACT_PHASES:
                # Simple Gaussian check for each high-impact phase
                if phase == "menstrual":
                    center = 0.085  # ~day 2-3 of cycle
                elif phase == "ovulatory":
                    center = 0.5  # mid-cycle
                else:
                    continue

                dist = abs(fraction - center)
                phase_risk += np.exp(-0.5 * (dist / 0.15) ** 2)

            risk_scores.append(min(1.0, phase_risk))

        return float(np.mean(risk_scores)) if risk_scores else 0.0

    def _parse_date(self, date_str: str) -> date:
        """Parse date string to date object."""
        if isinstance(date_str, date):
            return date_str
        return datetime.strptime(str(date_str), "%Y-%m-%d").date()
