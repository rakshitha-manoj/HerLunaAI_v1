"""
Young Girl Mode Logic
Disables fertility modeling, broadens uncertainty ranges,
and provides educational explanations.
"""


class YoungGirlModeAgent:
    """
    Adjusts agent outputs for young girl mode:
    - Disables fertility modeling
    - Broadens phase probability uncertainty
    - Adds educational context
    """

    def adjust(
        self,
        physio_result: dict,
        fertility_result: dict,
        fatigue_result: dict,
        stress_result: dict,
    ) -> dict:
        """
        Apply young girl mode adjustments to agent outputs.

        Returns adjusted physio and fertility results.
        """
        # ── Disable fertility modeling ───────────────────────────────────
        adjusted_fertility = {
            "fertility_probability": 0.0,
            "fertile_window_start_day": 0,
            "fertile_window_end_day": 0,
            "disclaimer": (
                "Fertility analysis is not available in this mode. "
                "This mode is designed for young users learning about their cycles."
            ),
            "top_features": [],
        }

        # ── Broaden uncertainty in phase probabilities ───────────────────
        adjusted_physio = physio_result.copy()
        phase_probs = adjusted_physio.get("phase_probability", {})

        if phase_probs:
            # Move probabilities toward uniform (add more uncertainty)
            uniform_weight = 0.3
            uniform_prob = 0.25
            broadened = {}
            for phase, prob in phase_probs.items():
                broadened[phase] = round(
                    prob * (1 - uniform_weight) + uniform_prob * uniform_weight, 4
                )
            # Renormalize
            total = sum(broadened.values())
            if total > 0:
                broadened = {k: round(v / total, 4) for k, v in broadened.items()}
            adjusted_physio["phase_probability"] = broadened

        # Lower confidence to reflect broader uncertainty
        confidence = adjusted_physio.get("confidence_score", 0.5)
        adjusted_physio["confidence_score"] = round(confidence * 0.7, 3)

        # Add educational top features
        adjusted_physio["top_features"] = [
            "Your cycle is still developing — variations are normal!",
            f"Estimated cycle day: {adjusted_physio.get('estimated_day_in_cycle', '?')}",
            "Tracking helps you understand your unique pattern over time.",
        ]

        return {
            "physio_result": adjusted_physio,
            "fertility_result": adjusted_fertility,
        }
