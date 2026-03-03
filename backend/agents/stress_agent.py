"""
Stress & Burnout Agent
Classifies burnout risk using screen time deviation from personal baseline.
Applies personal_model.stress_weight for adaptive calibration.
Uses ML model when available, heuristic fallback otherwise.
"""
import os
import numpy as np
import joblib
from config import settings


class StressAgent:
    """
    Computes stress probability and burnout risk classification.
    Applies personal_model.stress_weight for adaptive calibration.
    """

    def __init__(self):
        self.model = None
        self._load_model()

    def _load_model(self):
        """Load the trained stress classifier if available."""
        try:
            if os.path.exists(settings.STRESS_MODEL_PATH):
                self.model = joblib.load(settings.STRESS_MODEL_PATH)
        except Exception:
            self.model = None

    def analyze(self, shared_state: dict) -> dict:
        """
        Classify stress/burnout risk from behavioral data.
        Applies stress_weight from PersonalModel for adaptive calibration.

        Returns:
            {
                "stress_probability": float,
                "burnout_risk": str,
                "screen_time_deviation": float,
                "top_features": list
            }
        """
        behavioral_data = shared_state.get("behavioral_data", [])

        if not behavioral_data:
            return {
                "stress_probability": 0.5,
                "burnout_risk": "unknown",
                "screen_time_deviation": 0.0,
                "top_features": ["No behavioral data available"],
            }

        latest = behavioral_data[0]
        screen_time = latest.get("screen_time", 4.0)
        calendar_load = latest.get("calendar_load", 3)
        step_count = latest.get("step_count", 5000)

        # Consume screen deviation from behavioral_baseline
        behavioral_baseline = shared_state.get("behavioral_baseline", {})
        screen_deviation = behavioral_baseline.get("screen_deviation", 0.0) or 0.0

        # ── ML prediction ────────────────────────────────────────────────
        if self.model is not None:
            result = self._ml_predict(screen_time, calendar_load, step_count, screen_deviation)
        else:
            result = self._heuristic_predict(screen_time, calendar_load, step_count, screen_deviation)

        # ── Apply adaptive stress_weight ──────────────────────────────────
        personal_model = shared_state.get("personal_model")
        if personal_model:
            weight = getattr(personal_model, "stress_weight", 1.0)
            raw = result["stress_probability"] * weight
            result["stress_probability"] = round(max(0.0, min(1.0, raw)), 4)
            result["burnout_risk"] = self._classify_burnout(result["stress_probability"])

        return result

    def _ml_predict(
        self, screen_time: float, calendar_load: int, step_count: int, screen_deviation: float
    ) -> dict:
        """Use trained ML model for stress classification."""
        features = np.array([[screen_time, calendar_load, step_count, screen_deviation]])

        try:
            stress_prob = float(self.model.predict_proba(features)[0][1])
        except Exception:
            stress_prob = float(self.model.predict(features)[0])

        stress_prob = max(0.0, min(1.0, stress_prob))
        burnout_risk = self._classify_burnout(stress_prob)

        return {
            "stress_probability": round(stress_prob, 4),
            "burnout_risk": burnout_risk,
            "screen_time_deviation": round(screen_deviation, 3),
            "top_features": self._get_features(screen_time, calendar_load, screen_deviation),
        }

    def _heuristic_predict(
        self, screen_time: float, calendar_load: int, step_count: int, screen_deviation: float
    ) -> dict:
        """Heuristic-based stress estimation."""
        screen_factor = min(1.0, screen_time / 14.0)
        calendar_factor = min(1.0, calendar_load / 10.0)
        activity_factor = max(0.0, 1.0 - (step_count / 10000.0))
        deviation_factor = max(0.0, min(1.0, (screen_deviation + 1) / 4))

        stress_prob = (
            screen_factor * 0.3
            + calendar_factor * 0.25
            + activity_factor * 0.15
            + deviation_factor * 0.3
        )
        stress_prob = round(max(0.0, min(1.0, stress_prob)), 4)
        burnout_risk = self._classify_burnout(stress_prob)

        return {
            "stress_probability": stress_prob,
            "burnout_risk": burnout_risk,
            "screen_time_deviation": round(screen_deviation, 3),
            "top_features": self._get_features(screen_time, calendar_load, screen_deviation),
        }

    def _classify_burnout(self, stress_prob: float) -> str:
        """Classify burnout risk level from stress probability."""
        if stress_prob >= 0.7:
            return "high"
        elif stress_prob >= 0.4:
            return "moderate"
        return "low"

    def _get_features(self, screen_time: float, calendar_load: int, deviation: float) -> list:
        """Return top contributing features."""
        return [
            f"Screen time: {screen_time}h",
            f"Screen time deviation: {round(deviation, 2)} σ",
            f"Calendar load: {calendar_load} events",
        ]
