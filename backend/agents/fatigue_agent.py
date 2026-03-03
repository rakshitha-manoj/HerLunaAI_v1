"""
Fatigue & Performance Agent
Uses behavioral features to compute fatigue probability and readiness score.
Applies personal_model.fatigue_weight for adaptive calibration.
Attempts trained ML model; falls back to heuristic.
"""
import os
import numpy as np
import joblib
from config import settings


class FatigueAgent:
    """
    Computes fatigue probability and readiness score from behavioral data.
    Uses ML model when available, heuristic fallback otherwise.
    Applies personal_model.fatigue_weight for adaptive calibration.
    """

    def __init__(self):
        self.model = None
        self._load_model()

    def _load_model(self):
        """Load the trained fatigue model if available."""
        try:
            if os.path.exists(settings.FATIGUE_MODEL_PATH):
                self.model = joblib.load(settings.FATIGUE_MODEL_PATH)
        except Exception:
            self.model = None

    def analyze(self, shared_state: dict) -> dict:
        """
        Compute fatigue probability and readiness score.
        Applies fatigue_weight from PersonalModel for adaptive calibration.

        Returns:
            {
                "fatigue_probability": float,
                "readiness_score": float,  (0-100 scale)
                "top_features": list
            }
        """
        behavioral_data = shared_state.get("behavioral_data", [])

        if not behavioral_data:
            return {
                "fatigue_probability": 0.5,
                "readiness_score": 50,
                "top_features": ["No behavioral data available"],
            }

        # Use most recent behavioral entry
        latest = behavioral_data[0]
        step_count = latest.get("step_count", 5000)
        screen_time = latest.get("screen_time", 4.0)
        calendar_load = latest.get("calendar_load", 3)

        # Consume behavioral baseline from shared_state
        behavioral_baseline = shared_state.get("behavioral_baseline", {})
        baselines = {
            "step_deviation": behavioral_baseline.get("step_deviation", 0.0) or 0.0,
            "screen_deviation": behavioral_baseline.get("screen_deviation", 0.0) or 0.0,
            "calendar_deviation": behavioral_baseline.get("calendar_deviation", 0.0) or 0.0,
        }

        # ── Attempt ML prediction ────────────────────────────────────────
        if self.model is not None:
            result = self._ml_predict(step_count, screen_time, calendar_load, baselines)
        else:
            result = self._heuristic_predict(step_count, screen_time, calendar_load, baselines)

        # ── Apply adaptive fatigue_weight ─────────────────────────────────
        personal_model = shared_state.get("personal_model")
        if personal_model:
            weight = getattr(personal_model, "fatigue_weight", 1.0)
            raw = result["fatigue_probability"] * weight
            result["fatigue_probability"] = round(max(0.0, min(1.0, raw)), 4)
            result["readiness_score"] = round((1.0 - result["fatigue_probability"]) * 100, 2)

        return result

    def _ml_predict(
        self, step_count: int, screen_time: float, calendar_load: int, baselines: dict
    ) -> dict:
        """Use trained ML model for fatigue prediction."""
        features = np.array([[
            step_count,
            screen_time,
            calendar_load,
            baselines["step_deviation"],
            baselines["screen_deviation"],
            baselines["calendar_deviation"],
        ]])

        try:
            fatigue_prob = float(self.model.predict_proba(features)[0][1])
        except Exception:
            fatigue_prob = float(self.model.predict(features)[0])

        fatigue_prob = max(0.0, min(1.0, fatigue_prob))
        readiness_score = round((1.0 - fatigue_prob) * 100, 2)

        return {
            "fatigue_probability": round(fatigue_prob, 4),
            "readiness_score": readiness_score,
            "top_features": self._rank_features(step_count, screen_time, calendar_load, baselines),
        }

    def _heuristic_predict(
        self, step_count: int, screen_time: float, calendar_load: int, baselines: dict
    ) -> dict:
        """Heuristic-based fatigue estimation when no ML model is available."""
        step_factor = max(0.0, 1.0 - (step_count / 10000.0))
        screen_factor = min(1.0, screen_time / 12.0)
        calendar_factor = min(1.0, calendar_load / 10.0)

        deviation_penalty = (
            abs(baselines["step_deviation"]) * 0.1
            + abs(baselines["screen_deviation"]) * 0.1
            + abs(baselines["calendar_deviation"]) * 0.05
        )

        fatigue_prob = (step_factor * 0.3 + screen_factor * 0.35 + calendar_factor * 0.2 + deviation_penalty * 0.15)
        fatigue_prob = round(max(0.0, min(1.0, fatigue_prob)), 4)
        readiness_score = round((1.0 - fatigue_prob) * 100, 2)

        return {
            "fatigue_probability": fatigue_prob,
            "readiness_score": readiness_score,
            "top_features": self._rank_features(step_count, screen_time, calendar_load, baselines),
        }

    def _rank_features(
        self, step_count: int, screen_time: float, calendar_load: int, baselines: dict
    ) -> list:
        """Rank features by their contribution to the prediction."""
        features = [
            (f"Step count: {step_count}", abs(baselines.get("step_deviation", 0))),
            (f"Screen time: {screen_time}h", abs(baselines.get("screen_deviation", 0))),
            (f"Calendar load: {calendar_load} events", abs(baselines.get("calendar_deviation", 0))),
        ]
        features.sort(key=lambda x: x[1], reverse=True)
        return [f[0] for f in features]
