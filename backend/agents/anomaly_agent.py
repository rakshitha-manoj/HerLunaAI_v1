"""
Anomaly Detection Agent
Detects deviations from PRECOMPUTED personal baselines using Z-score thresholds.

Architectural role:
  - CONSUMES cycle_baseline and behavioral_baseline from shared_state
  - Uses personal_model.anomaly_sensitivity to adjust threshold
  - Does NOT recompute mean/std (baseline.py owns that)
  - Detection is purely personal-baseline-driven
"""


class AnomalyAgent:
    """
    Detects anomalous patterns by comparing latest data against
    precomputed personal baselines. No population-level thresholds.
    """

    # Base Z-score threshold — scaled by personal_model.anomaly_sensitivity
    BASE_Z_THRESHOLD = 2.0

    def analyze(self, shared_state: dict) -> dict:
        """
        Detect anomalies from precomputed baselines in shared_state.
        Threshold adapts via personal_model.anomaly_sensitivity.

        Returns:
            {
                "anomaly_flag": bool,
                "anomaly_details": list,
                "anomaly_score": float,
            }
        """
        # Adaptive threshold from PersonalModel
        personal_model = shared_state.get("personal_model")
        sensitivity = getattr(personal_model, "anomaly_sensitivity", 1.0) if personal_model else 1.0
        z_threshold = self.BASE_Z_THRESHOLD * sensitivity

        anomalies = []
        anomaly_scores = []

        # ── Check cycle anomalies ────────────────────────────────────────
        cycle_anomaly = self._check_cycle_anomaly(shared_state, z_threshold)
        if cycle_anomaly["is_anomaly"]:
            anomalies.append(cycle_anomaly["detail"])
            anomaly_scores.append(cycle_anomaly["score"])

        # ── Check behavioral anomalies ───────────────────────────────────
        behavioral_anomalies = self._check_behavioral_anomalies(shared_state, z_threshold)
        for ba in behavioral_anomalies:
            if ba["is_anomaly"]:
                anomalies.append(ba["detail"])
                anomaly_scores.append(ba["score"])

        overall_score = (
            sum(anomaly_scores) / len(anomaly_scores) if anomaly_scores else 0.0
        )

        return {
            "anomaly_flag": len(anomalies) > 0,
            "anomaly_details": anomalies,
            "anomaly_score": round(overall_score, 4),
        }

    def _check_cycle_anomaly(self, shared_state: dict, z_threshold: float) -> dict:
        """Check most recent cycle against personal baseline."""
        no_anomaly = {"is_anomaly": False, "detail": "", "score": 0.0}

        cycle_baseline = shared_state.get("cycle_baseline", {})
        mean_val = cycle_baseline.get("mean_cycle_length")
        std_val = cycle_baseline.get("std_cycle_length", 0.0)
        data_points = cycle_baseline.get("data_points", 0)

        if not mean_val or mean_val <= 0 or data_points < 2:
            return no_anomaly

        cycle_logs = shared_state.get("cycle_logs", [])
        recent = self._get_most_recent_cycle_length(cycle_logs)
        if recent is None or recent <= 0:
            return no_anomaly

        if std_val == 0:
            is_anomaly = (recent != mean_val)
            z_score = abs(recent - mean_val) if is_anomaly else 0.0
        else:
            z_score = abs(recent - mean_val) / std_val
            is_anomaly = (z_score > z_threshold)

        if is_anomaly:
            return {
                "is_anomaly": True,
                "detail": (
                    f"Cycle anomaly: {recent} days vs "
                    f"personal baseline {round(mean_val, 1)} ± {round(std_val, 1)} days "
                    f"(Z: {round(z_score, 2)}, threshold: {round(z_threshold, 2)})"
                ),
                "score": min(1.0, z_score / 4.0),
            }

        return no_anomaly

    def _check_behavioral_anomalies(self, shared_state: dict, z_threshold: float) -> list:
        """Check behavioral deviations from precomputed baselines."""
        results = []
        behavioral_baseline = shared_state.get("behavioral_baseline", {})

        metrics = [
            ("step_deviation", "Step count"),
            ("screen_deviation", "Screen time"),
            ("calendar_deviation", "Calendar load"),
            ("sleep_deviation", "Sleep hours"),
        ]

        for deviation_key, metric_name in metrics:
            z_score = behavioral_baseline.get(deviation_key)
            if z_score is None:
                continue

            abs_z = abs(z_score)
            is_anomaly = abs_z > z_threshold

            if is_anomaly:
                results.append({
                    "is_anomaly": True,
                    "detail": (
                        f"{metric_name} anomaly: "
                        f"Z-score {round(z_score, 2)} exceeds threshold {round(z_threshold, 2)}"
                    ),
                    "score": min(1.0, abs_z / 4.0),
                })

        return results

    def _get_most_recent_cycle_length(self, cycle_logs: list):
        """Get most recent cycle_length, sorted descending."""
        if not cycle_logs:
            return None

        sorted_logs = sorted(
            cycle_logs,
            key=lambda x: str(x.get("period_start", "")),
            reverse=True,
        )

        for log in sorted_logs:
            cl = log.get("cycle_length")
            if cl and cl > 0:
                return cl

        return None
