"""
Fertility Probability Agent
Estimates fertile window as a probability range, adjusted by
cycle variability. Never outputs fixed dates or pregnancy predictions.
"""
import numpy as np


class FertilityAgent:
    """
    Produces fertility probability as a range, not a fixed date.
    Always includes a disclaimer. Disabled in young girl mode.
    """

    # Ovulation typically occurs ~14 days before next period
    OVULATION_OFFSET_FROM_END = 14
    # Fertile window: typically 5 days before ovulation + ovulation day
    FERTILE_WINDOW_DAYS = 6

    def analyze(self, shared_state: dict) -> dict:
        """
        Estimate fertility probability based on physiological state.

        Returns:
            {
                "fertility_probability": float,
                "fertile_window_start_day": int,
                "fertile_window_end_day": int,
                "disclaimer": str,
                "top_features": list
            }
        """
        if shared_state.get("is_young_girl_mode", False):
            return self._young_girl_response()

        physio = shared_state.get("physio_result", {})
        phase_probs = physio.get("phase_probability", {})
        mean_length = physio.get("mean_cycle_length", 0)
        std_length = physio.get("std_cycle_length", 0)
        day_in_cycle = physio.get("estimated_day_in_cycle", 0)
        variability = physio.get("variability_index", 1.0)

        if mean_length <= 0:
            return self._insufficient_data_response()

        # ── Estimate ovulation day range ─────────────────────────────────
        estimated_ovulation = mean_length - self.OVULATION_OFFSET_FROM_END
        ovulation_uncertainty = max(1.0, std_length * 1.5)

        # Fertile window range (probability-based)
        fertile_start = max(1, int(estimated_ovulation - self.FERTILE_WINDOW_DAYS - ovulation_uncertainty))
        fertile_end = min(int(mean_length), int(estimated_ovulation + ovulation_uncertainty))

        # ── Compute fertility probability for current day ────────────────
        if fertile_start <= day_in_cycle <= fertile_end:
            # Gaussian centered on estimated ovulation day
            dist_from_ovulation = abs(day_in_cycle - estimated_ovulation)
            sigma = max(1.0, ovulation_uncertainty)
            fertility_prob = float(np.exp(-0.5 * (dist_from_ovulation / sigma) ** 2))
        else:
            fertility_prob = 0.05  # Base probability (never exactly 0)

        # Reduce confidence if high variability
        fertility_prob *= max(0.3, 1.0 - variability)
        fertility_prob = round(min(fertility_prob, 0.95), 4)  # Cap at 95%

        return {
            "fertility_probability": fertility_prob,
            "fertile_window_start_day": fertile_start,
            "fertile_window_end_day": fertile_end,
            "disclaimer": (
                "Fertility probability is a statistical estimate based on cycle history. "
                "It is NOT a pregnancy prediction and should NOT be used as contraception. "
                "Consult a healthcare professional for family planning advice."
            ),
            "top_features": [
                f"Estimated ovulation: day ~{round(estimated_ovulation)}",
                f"Fertile window: days {fertile_start}–{fertile_end}",
                f"Ovulation uncertainty: ±{round(ovulation_uncertainty, 1)} days",
            ],
        }

    def _young_girl_response(self) -> dict:
        """Fertility modeling disabled for young girl mode."""
        return {
            "fertility_probability": 0.0,
            "fertile_window_start_day": 0,
            "fertile_window_end_day": 0,
            "disclaimer": "Fertility analysis is not available in this mode.",
            "top_features": [],
        }

    def _insufficient_data_response(self) -> dict:
        """Not enough cycle data for fertility estimation."""
        return {
            "fertility_probability": 0.0,
            "fertile_window_start_day": 0,
            "fertile_window_end_day": 0,
            "disclaimer": "Insufficient cycle data for fertility estimation.",
            "top_features": ["Need more cycle data for fertility analysis"],
        }
