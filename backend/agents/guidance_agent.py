"""
Adaptive Guidance Agent
Generates dynamic suggestions based on combined probabilities
from all other agents. Never returns static/canned advice.
"""


class GuidanceAgent:
    """
    Context-aware guidance engine that combines outputs from
    all agents to produce personalized, dynamic suggestions.
    """

    def generate(self, all_results: dict) -> dict:
        """
        Generate dynamic guidance from combined agent outputs.

        Args:
            all_results: dict with keys: physio, fertility, fatigue,
                        stress, travel, anomaly, is_young_girl_mode

        Returns:
            {"suggestions": [{"category": str, "suggestion": str, "reason": str}]}
        """
        suggestions = []
        is_young = all_results.get("is_young_girl_mode", False)

        # ── Phase-based guidance ─────────────────────────────────────────
        physio = all_results.get("physio", {})
        phase_probs = physio.get("phase_probability", {})
        dominant_phase = max(phase_probs, key=phase_probs.get) if phase_probs else None

        if dominant_phase:
            suggestions.append(self._phase_guidance(dominant_phase, phase_probs, is_young))

        # ── Fatigue guidance ─────────────────────────────────────────────
        fatigue = all_results.get("fatigue", {})
        fatigue_prob = fatigue.get("fatigue_probability", 0)
        readiness = fatigue.get("readiness_score", 0.5)

        if fatigue_prob > 0.6:
            suggestions.append({
                "category": "Energy",
                "suggestion": (
                    "Your fatigue indicators are elevated. Consider lighter activities today, "
                    "prioritize rest breaks every 90 minutes, and ensure adequate hydration."
                ),
                "reason": f"Fatigue probability at {round(fatigue_prob * 100)}% — "
                          f"readiness score {round(readiness * 100)}%",
            })
        elif fatigue_prob < 0.3:
            suggestions.append({
                "category": "Energy",
                "suggestion": (
                    "Your energy levels appear optimal. This could be a good day for "
                    "challenging tasks, workouts, or creative projects."
                ),
                "reason": f"Low fatigue ({round(fatigue_prob * 100)}%) with "
                          f"readiness at {round(readiness * 100)}%",
            })

        # ── Stress guidance ──────────────────────────────────────────────
        stress = all_results.get("stress", {})
        stress_prob = stress.get("stress_probability", 0)
        burnout_risk = stress.get("burnout_risk", "low")

        if burnout_risk == "high":
            suggestions.append({
                "category": "Wellbeing",
                "suggestion": (
                    "Burnout risk is high. Consider reducing screen time, delegating tasks, "
                    "and scheduling intentional downtime. Short walks or breathing exercises "
                    "can help regulate stress hormones."
                ),
                "reason": f"Stress at {round(stress_prob * 100)}%, "
                          f"screen time deviation: {stress.get('screen_time_deviation', 0):.1f}σ above baseline",
            })
        elif burnout_risk == "moderate":
            suggestions.append({
                "category": "Wellbeing",
                "suggestion": (
                    "Moderate stress detected. Try to balance demanding tasks with "
                    "restorative activities. Consider limiting screen time in the evening."
                ),
                "reason": f"Stress probability at {round(stress_prob * 100)}%",
            })

        # ── Travel guidance ──────────────────────────────────────────────
        travel = all_results.get("travel", {})
        travel_risk = travel.get("travel_risk", 0)

        if travel_risk > 0.5:
            overlapping = travel.get("overlapping_phases", [])
            suggestions.append({
                "category": "Travel",
                "suggestion": (
                    f"Your upcoming travel may overlap with {', '.join(overlapping)} phase(s). "
                    "Consider packing accordingly and planning for potential discomfort. "
                    "Stay hydrated and maintain regular sleep patterns."
                ),
                "reason": f"Travel risk: {round(travel_risk * 100)}% overlap probability",
            })

        # ── Anomaly guidance ─────────────────────────────────────────────
        anomaly = all_results.get("anomaly", {})
        if anomaly.get("anomaly_flag", False):
            suggestions.append({
                "category": "Attention",
                "suggestion": (
                    "An unusual pattern has been detected in your recent data. "
                    "This could be due to lifestyle changes, stress, or other factors. "
                    "If this persists, consider consulting a healthcare professional."
                ),
                "reason": "Anomaly detected — deviation from your personal baseline",
            })

        # ── Fertility guidance (not in young girl mode) ──────────────────
        if not is_young:
            fertility = all_results.get("fertility", {})
            fert_prob = fertility.get("fertility_probability", 0)
            if fert_prob > 0.5:
                suggestions.append({
                    "category": "Cycle Awareness",
                    "suggestion": (
                        "You are likely in a high-fertility window based on cycle patterns. "
                        "This is a statistical estimate, not a medical assessment."
                    ),
                    "reason": f"Fertility probability: {round(fert_prob * 100)}%",
                })

        # ── Educational guidance for young girl mode ─────────────────────
        if is_young:
            suggestions.append({
                "category": "Education",
                "suggestion": (
                    "Understanding your cycle helps you plan activities and take care "
                    "of your health. Your body is unique, and cycle lengths can vary — "
                    "this is completely normal!"
                ),
                "reason": "Educational content for cycle awareness",
            })

        # Ensure at least one suggestion
        if not suggestions:
            suggestions.append({
                "category": "General",
                "suggestion": (
                    "Continue tracking your daily data for more personalized insights. "
                    "The more data available, the more accurate the predictions become."
                ),
                "reason": "Building your personalized baseline",
            })

        return {"suggestions": suggestions}

    def _phase_guidance(self, phase: str, probs: dict, is_young: bool) -> dict:
        """Generate phase-specific dynamic guidance."""
        confidence = probs.get(phase, 0)

        phase_advice = {
            "menstrual": {
                "suggestion": (
                    "You are most likely in the menstrual phase. Gentle exercise like yoga "
                    "or walking, iron-rich foods, and adequate rest can help manage "
                    "this phase effectively."
                ),
                "reason": f"Menstrual phase probability: {round(confidence * 100)}%",
            },
            "follicular": {
                "suggestion": (
                    "You appear to be in the follicular phase — energy levels tend to rise. "
                    "This is often a good time for starting new projects, social activities, "
                    "and higher-intensity exercise."
                ),
                "reason": f"Follicular phase probability: {round(confidence * 100)}%",
            },
            "ovulatory": {
                "suggestion": (
                    "Ovulatory phase indicators are elevated. Energy and communication "
                    "skills tend to peak. Consider scheduling important meetings "
                    "or collaborative work."
                ),
                "reason": f"Ovulatory phase probability: {round(confidence * 100)}%",
            },
            "luteal": {
                "suggestion": (
                    "You are likely in the luteal phase. Focus and detail-oriented work "
                    "may come easier, but watch for energy dips. Prioritize magnesium-rich "
                    "foods and consistent sleep."
                ),
                "reason": f"Luteal phase probability: {round(confidence * 100)}%",
            },
        }

        advice = phase_advice.get(phase, {
            "suggestion": "Continue monitoring your cycle patterns.",
            "reason": "Phase analysis in progress",
        })

        return {
            "category": "Cycle Phase",
            **advice,
        }
