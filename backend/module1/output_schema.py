from module1.baseline import build_baseline, get_confidence_state
from module1.anomaly_iforest import CycleAnomalyDetector
from module1.deviation_logic import compute_z_score, z_band, fuse_deviation
from module1.persistence import DeviationTracker
from module1.prediction import predict_cycle_window
from module1.heavy_flow import compute_heavy_flow_insight
from module1.feature_extraction import encode_flow

# In-memory tracker for persistence across requests
deviation_tracker = DeviationTracker()


def analyze_user(payload):
    # ---- Parse input ----
    cycle_lengths = payload["cycle_lengths"]
    period_durations = payload["period_durations"]
    flow_logs = payload["flow_logs"]

    # ---- Split history and latest ----
    history_cycles = cycle_lengths[:-1]
    latest_cycle = cycle_lengths[-1]

    baseline = build_baseline(
        history_cycles,
        period_durations[:-1],
        flow_logs[:-1]
    )

    cycle_mean = baseline["cycle"]["mean"]
    cycle_std = baseline["cycle"]["std"]

    # ---- Confidence state ----
    confidence = get_confidence_state(len(cycle_lengths))

    # ---- Heavy flow insight ----
    encoded_flows = encode_flow(flow_logs)
    heavy_flow = compute_heavy_flow_insight(
        encoded_flows=encoded_flows,
        confidence=confidence
    )

    # 🛑 COLD-START SAFETY: no deviation before personalization
    if confidence != "personalized":
        deviation_type = "none"

        cycle_window = predict_cycle_window(
            mean=cycle_mean,
            std=cycle_std,
            confidence=confidence,
            deviation=deviation_type
        )

        return {
            "deviation_type": deviation_type,
            "confidence": confidence,
            "cycle_window": cycle_window,
            "heavy_flow_risk": heavy_flow
        }

    # ---- Isolation Forest ----
    detector = CycleAnomalyDetector()
    detector.fit(history_cycles)
    score, _ = detector.score(latest_cycle)

    if_result = "anomaly" if score < 0.05 else "normal"

    # ---- Statistical deviation ----
    z = compute_z_score(latest_cycle, cycle_mean, cycle_std)
    band = z_band(z)

    # ---- Fusion + persistence ----
    temp_dev = fuse_deviation(if_result, band)
    is_persistent = deviation_tracker.update(temp_dev)

    deviation_type = fuse_deviation(
        if_result,
        band,
        persistent=is_persistent
    )

    # ---- Cycle window ----
    cycle_window = predict_cycle_window(
        mean=cycle_mean,
        std=cycle_std,
        confidence=confidence,
        deviation=deviation_type
    )

    return {
        "deviation_type": deviation_type,
        "confidence": confidence,
        "cycle_window": cycle_window,
        "heavy_flow_risk": heavy_flow
    }
