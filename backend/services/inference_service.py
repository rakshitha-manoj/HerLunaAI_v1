"""
HerLuna Inference Service
Orchestrates all agents into the nested InferenceResponse.

Safety guarantees:
  - All probabilities ∈ [0, 1] and normalized (sum = 1.0 for phases)
  - readiness_score ∈ [0, 100] (percentage scale, never probability scale)
  - No NaN / inf in any numeric output
  - confidence = 0.0 when no data, ≥ 0.1 when any data exists
  - Young Girl Mode cannot override baselines or anomaly_flag
  - No population-level assumptions (no hardcoded 28-day cycles)
  - ModelOutput persistence wrapped in safe transaction
  - No personal data in logs
"""
import math
import time
import logging
from sqlalchemy.orm import Session

from schemas import (
    InferenceRequestLocal,
    InferenceResponse,
    PhysiologicalState,
    PerformanceState,
    RiskState,
    InferenceMeta,
    BaselineMetrics,
    PhaseProbability,
    GuidanceSuggestion,
)
from services.storage_service import get_cloud_data, get_local_data, get_personal_model
from services.baseline import (
    compute_cycle_variability,
    compute_behavioral_deviation,
    compute_confidence_score,
)
from config import settings

# Import all agents
from agents.physiological_agent import PhysiologicalAgent
from agents.fertility_agent import FertilityAgent
from agents.fatigue_agent import FatigueAgent
from agents.stress_agent import StressAgent
from agents.travel_agent import TravelAgent
from agents.guidance_agent import GuidanceAgent
from agents.anomaly_agent import AnomalyAgent
from agents.trend_agent import TrendAgent
from agents.young_girl_mode import YoungGirlModeAgent

logger = logging.getLogger("herluna.inference")

# ── Constants ────────────────────────────────────────────────────────────────
PIPELINE_VERSION = "2.0.0"


# ── Numeric Safety Helpers ───────────────────────────────────────────────────

def _safe_float(value, min_val: float, max_val: float, default: float = 0.0) -> float:
    """
    Ensure a numeric value is finite and within [min_val, max_val].
    Returns default if value is None, NaN, or inf.
    """
    if value is None:
        return default
    try:
        v = float(value)
    except (TypeError, ValueError):
        return default
    if math.isnan(v) or math.isinf(v):
        return default
    return max(min_val, min(max_val, v))


def _normalize_phase_probabilities(raw: dict, has_cycle_data: bool) -> dict:
    """
    Normalize phase probabilities so they sum to 1.0.
    - Clamp each value to [0, 1]
    - If total > 0, normalize by dividing each by total
    - If total = 0 AND no cycle data → uniform (0.25 each)
    - If total = 0 AND cycle data exists → uniform (should not happen, but safe)
    Prevents silent probability drift from agents.
    """
    phases = ["menstrual", "follicular", "ovulatory", "luteal"]
    values = {p: _safe_float(raw.get(p), 0.0, 1.0, 0.0) for p in phases}

    total = sum(values.values())
    if total > 0:
        return {p: round(v / total, 4) for p, v in values.items()}

    # Fallback: uniform only when no data to infer from
    return {p: 0.25 for p in phases}


# ── Public API ───────────────────────────────────────────────────────────────

def run_inference_cloud(user_id: int, is_young_girl_mode: bool, db: Session) -> InferenceResponse:
    """Cloud mode: fetch data from DB, run full pipeline, persist results."""
    logger.info("Inference started | mode=cloud user_id=%d", user_id)
    user_data = get_cloud_data(user_id, db)
    personal_model = get_personal_model(user_id, db)
    is_young = user_data.get("is_young_girl_mode", False) or is_young_girl_mode
    result = _run_pipeline(user_data, is_young, persist_output=True, personal_model=personal_model)

    # Persist to ModelOutputs (safe transaction)
    _persist_output(user_id, result, db)

    logger.info(
        "Inference complete | mode=cloud user_id=%d confidence=%.3f time_ms=%d",
        user_id, result.meta.confidence_score, result.meta.inference_time_ms,
    )
    return result


def run_inference_local(request: InferenceRequestLocal) -> InferenceResponse:
    """
    Local mode: use snapshot data, nothing persisted.
    persist_output is ALWAYS False — prevents accidental DB writes.
    """
    logger.info("Inference started | mode=local")
    user_data = get_local_data(request)
    result = _run_pipeline(user_data, request.is_young_girl_mode, persist_output=False)
    logger.info(
        "Inference complete | mode=local confidence=%.3f time_ms=%d",
        result.meta.confidence_score, result.meta.inference_time_ms,
    )
    return result


# ── Core Pipeline ────────────────────────────────────────────────────────────

def _run_pipeline(
    user_data: dict,
    is_young_girl_mode: bool,
    persist_output: bool = False,
    personal_model=None,
) -> InferenceResponse:
    """
    Execute the full multi-agent inference pipeline.

    1. Compute personalized baselines (not population averages)
    2. Run each agent with baseline-enriched shared state
    3. Apply Young Girl Mode (restricted: no baseline/anomaly override)
    4. Normalize and validate ALL numeric outputs
    5. Compose nested InferenceResponse

    No fixed cycle length references. No hardcoded biological thresholds.
    All fallbacks use personal baselines or uniform distributions.
    """
    start_time = time.time()

    # ── Step 1: Compute personalized baselines ───────────────────────────
    cycle_baseline = compute_cycle_variability(user_data["cycle_logs"])
    behavioral_baseline = compute_behavioral_deviation(user_data["behavioral_data"])

    behavioral_deviation_score = _composite_deviation(behavioral_baseline)
    has_cycle_data = cycle_baseline["data_points"] > 0
    has_behavioral_data = len(user_data["behavioral_data"]) > 0

    # ── Step 2: Build shared state with baselines + personal model ────────
    shared_state = {
        "cycle_logs": user_data["cycle_logs"],
        "behavioral_data": user_data["behavioral_data"],
        "travel_data": user_data["travel_data"],
        "is_young_girl_mode": is_young_girl_mode,
        "activity_level": user_data.get("activity_level", "moderate"),
        "cycle_baseline": cycle_baseline,
        "behavioral_baseline": behavioral_baseline,
        "personal_model": personal_model,
    }

    # ── Step 3: Run Physiological Agent ──────────────────────────────────
    physio_agent = PhysiologicalAgent()
    physio_result = physio_agent.analyze(shared_state)
    shared_state["physio_result"] = physio_result

    # ── Step 4: Run Fertility Agent ──────────────────────────────────────
    fertility_agent = FertilityAgent()
    fertility_result = fertility_agent.analyze(shared_state)

    # ── Step 5: Run Fatigue Agent ────────────────────────────────────────
    fatigue_agent = FatigueAgent()
    fatigue_result = fatigue_agent.analyze(shared_state)

    # ── Step 6: Run Stress Agent ─────────────────────────────────────────
    stress_agent = StressAgent()
    stress_result = stress_agent.analyze(shared_state)

    # ── Step 7: Run Travel Agent ─────────────────────────────────────────
    travel_agent = TravelAgent()
    travel_result = travel_agent.analyze(shared_state)

    # ── Step 8: Run Anomaly Agent ────────────────────────────────────────
    anomaly_agent = AnomalyAgent()
    anomaly_result = anomaly_agent.analyze(shared_state)

    if anomaly_result.get("anomaly_flag"):
        logger.warning("Anomaly detected | deviation exceeded personal threshold")

    # ── Step 8b: Run Trend Agent ─────────────────────────────────────────
    trend_agent = TrendAgent()
    trend_result = trend_agent.analyze(shared_state)

    # ── Step 9: Apply Young Girl Mode (RESTRICTED) ───────────────────────
    # Adjustments may ONLY modify:
    #   - physio_result (phase probabilities)
    #   - fertility_result (suppression)
    # Adjustments MUST NOT modify:
    #   - baseline_metrics
    #   - anomaly_flag
    #   - behavioral baselines
    if is_young_girl_mode:
        young_girl_agent = YoungGirlModeAgent()
        adjustments = young_girl_agent.adjust(
            physio_result, fertility_result, fatigue_result, stress_result
        )
        # Only accept allowed overrides
        physio_result = adjustments.get("physio_result", physio_result)
        fertility_result = adjustments.get("fertility_result", fertility_result)
        # Explicitly DO NOT accept: anomaly_result, cycle_baseline, behavioral_baseline

    # ── Step 10: Run Guidance Agent ──────────────────────────────────────
    guidance_agent = GuidanceAgent()
    all_results = {
        "physio": physio_result,
        "fertility": fertility_result,
        "fatigue": fatigue_result,
        "stress": stress_result,
        "travel": travel_result,
        "anomaly": anomaly_result,
        "is_young_girl_mode": is_young_girl_mode,
    }
    guidance_result = guidance_agent.generate(all_results)

    # ── Step 11: Compute & enforce confidence ────────────────────────────
    raw_confidence = compute_confidence_score(
        cycle_data_points=cycle_baseline["data_points"],
        behavioral_data_points=len(user_data["behavioral_data"]),
        variability_index=cycle_baseline["variability_index"],
    )
    # Enforce: 0.0 = no data at all, ≥ 0.1 if any data exists
    if not has_cycle_data and not has_behavioral_data:
        confidence = 0.0
    else:
        confidence = max(0.1, _safe_float(raw_confidence, 0.0, 1.0, 0.1))

    # ── Step 12: Collect top features ────────────────────────────────────
    top_features = _collect_top_features(
        fatigue_result, stress_result, physio_result, behavioral_baseline
    )

    # ── Step 13: Build disclaimers ───────────────────────────────────────
    disclaimers = [
        "All outputs are probabilistic estimates and not medical diagnoses.",
        "This system does not predict pregnancy.",
        "Consult a healthcare professional for medical advice.",
    ]
    if fertility_result.get("disclaimer"):
        disclaimers.append(fertility_result["disclaimer"])

    # ── Step 14: Timing ──────────────────────────────────────────────────
    inference_time_ms = int((time.time() - start_time) * 1000)

    # ── Step 15: Normalize & validate all numeric outputs ────────────────
    raw_phase = physio_result.get("phase_probability", {})
    normalized_phase = _normalize_phase_probabilities(raw_phase, has_cycle_data)

    # readiness_score: percentage scale [0, 100], NOT probability scale
    raw_readiness = fatigue_result.get("readiness_score", 0)
    readiness = _safe_float(raw_readiness, 0, 100, 0.0)

    # ── Step 15b: Compute estimated day in cycle ─────────────────────────
    estimated_day = 0
    cycle_logs = user_data.get("cycle_logs", [])
    if cycle_logs:
        from datetime import date as _date
        latest_start = None
        for log in cycle_logs:
            ps = log.get("period_start") if isinstance(log, dict) else getattr(log, "period_start", None)
            if ps is not None:
                if isinstance(ps, str):
                    ps = _date.fromisoformat(ps)
                if latest_start is None or ps > latest_start:
                    latest_start = ps
        if latest_start is not None:
            delta = (_date.today() - latest_start).days
            estimated_day = max(1, delta + 1)  # Day 1 = period_start day

    # ── Step 16: Compose nested response ─────────────────────────────────
    return InferenceResponse(
        physiological_state=PhysiologicalState(
            phase_probability=PhaseProbability(
                menstrual=normalized_phase["menstrual"],
                follicular=normalized_phase["follicular"],
                ovulatory=normalized_phase["ovulatory"],
                luteal=normalized_phase["luteal"],
            ),
            fertility_probability=_safe_float(
                fertility_result.get("fertility_probability"), 0, 1, 0.0
            ),
            estimated_day_in_cycle=estimated_day,
        ),
        performance_state=PerformanceState(
            fatigue_probability=_safe_float(
                fatigue_result.get("fatigue_probability"), 0, 1, 0.0
            ),
            readiness_score=readiness,
        ),
        risk_state=RiskState(
            stress_probability=_safe_float(
                stress_result.get("stress_probability"), 0, 1, 0.0
            ),
            travel_risk=_safe_float(
                travel_result.get("travel_risk"), 0, 1, 0.0
            ),
            anomaly_flag=bool(anomaly_result.get("anomaly_flag", False)),
        ),
        meta=InferenceMeta(
            confidence_score=confidence,
            baseline_metrics=BaselineMetrics(
                mean_cycle_length=(
                    round(cycle_baseline["mean_cycle_length"], 2)
                    if cycle_baseline["mean_cycle_length"] and has_cycle_data
                    else None
                ),
                cycle_variability_index=(
                    round(cycle_baseline["variability_index"], 4)
                    if cycle_baseline["variability_index"] is not None and has_cycle_data
                    else None
                ),
                behavioral_deviation_score=(
                    behavioral_deviation_score if has_behavioral_data else None
                ),
            ),
            model_version=settings.MODEL_VERSION,
            inference_time_ms=inference_time_ms,
            top_features=top_features,
            trend_flags=trend_result.get("trend_flags", []),
            guidance=[
                GuidanceSuggestion(**g) for g in guidance_result.get("suggestions", [])
            ],
            disclaimers=disclaimers,
        ),
    )


# ── Persistence (Cloud Mode Only) ───────────────────────────────────────────

def _persist_output(user_id: int, result: InferenceResponse, db: Session):
    """
    Persist inference results to ModelOutputs.
    Safe transaction: rollback on failure, never swallow errors silently.
    """
    try:
        from models import ModelOutput
        output = ModelOutput(
            user_id=user_id,
            fatigue_prob=result.performance_state.fatigue_probability,
            stress_prob=result.risk_state.stress_probability,
            readiness_score=result.performance_state.readiness_score,
            confidence_score=result.meta.confidence_score,
            predicted_fatigue=result.performance_state.fatigue_probability,
            predicted_stress=result.risk_state.stress_probability,
            predicted_readiness=result.performance_state.readiness_score,
            model_version=result.meta.model_version,
            inference_version=PIPELINE_VERSION,
            inference_time_ms=result.meta.inference_time_ms,
        )
        db.add(output)
        db.commit()
        logger.info(
            "ModelOutput persisted | user_id=%d model_version=%s pipeline=%s",
            user_id, result.meta.model_version, PIPELINE_VERSION,
        )
    except Exception as e:
        db.rollback()
        logger.error("Failed to persist ModelOutput | user_id=%d error=%s", user_id, str(e))
        # Re-raise so caller is aware — do not swallow silently
        raise


# ── Internal Helpers ─────────────────────────────────────────────────────────

def _composite_deviation(behavioral_baseline: dict) -> float:
    """
    Compute mean absolute z-score across all behavioral metrics.
    - Ignores None values
    - Division-safe (returns 0.0 if no valid deviations)
    - Clamped to [0.0, 5.0] to prevent runaway z-score inflation
    """
    keys = ["step_deviation", "screen_deviation", "calendar_deviation", "sleep_deviation"]
    valid = []
    for k in keys:
        val = behavioral_baseline.get(k)
        if val is not None:
            safe_val = _safe_float(val, -100, 100, 0.0)
            valid.append(abs(safe_val))

    if not valid:
        return 0.0

    raw = sum(valid) / len(valid)
    # Clamp to reasonable upper bound
    return round(min(raw, 5.0), 3)


def _collect_top_features(
    fatigue_result: dict,
    stress_result: dict,
    physio_result: dict,
    behavioral_baseline: dict,
) -> list:
    """Collect the most influential features for explainability."""
    features = []

    screen_dev = _safe_float(behavioral_baseline.get("screen_deviation"), -100, 100, 0)
    step_dev = _safe_float(behavioral_baseline.get("step_deviation"), -100, 100, 0)
    sleep_dev = _safe_float(behavioral_baseline.get("sleep_deviation"), -100, 100, 0)

    if abs(screen_dev) > 1.0:
        features.append(f"screen_time_zscore: {round(screen_dev, 2)}")
    if abs(step_dev) > 1.0:
        features.append(f"step_count_zscore: {round(step_dev, 2)}")
    if abs(sleep_dev) > 1.0:
        features.append(f"sleep_zscore: {round(sleep_dev, 2)}")

    features.extend(physio_result.get("top_features", []))
    features.extend(fatigue_result.get("top_features", []))
    features.extend(stress_result.get("top_features", []))

    seen = set()
    unique = []
    for f in features:
        if f not in seen:
            seen.add(f)
            unique.append(f)
    return unique[:5]
