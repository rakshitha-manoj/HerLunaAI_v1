"""
HerLuna Feedback & Calibration Route
POST /feedback — JWT protected.
Implements the adaptive learning loop for PersonalModel.
"""
import logging
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from database import get_db
from models import PersonalModel
from schemas import FeedbackCreate, FeedbackResponse, PersonalModelResponse
from routes.auth import get_current_user
from services.storage_service import get_personal_model

logger = logging.getLogger("herluna.feedback")

router = APIRouter()


@router.post(
    "/feedback",
    response_model=FeedbackResponse,
    responses={
        200: {"description": "Calibration updated successfully"},
        401: {"description": "Not authenticated"},
        422: {"description": "Validation error"},
    },
)
def submit_feedback(
    feedback: FeedbackCreate,
    current_user=Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Submit feedback to calibrate PersonalModel weights.

    Calibration loop:
      - fatigue_weight += learning_rate * (actual_fatigue - predicted_fatigue)
      - stress_weight  += learning_rate * (actual_stress - predicted_stress)
      - If guidance unhelpful → increase anomaly_sensitivity slightly
      - All weights clamped to [0.5, 1.5]
    """
    pm = get_personal_model(current_user.id, db)

    # ── Fatigue calibration ──────────────────────────────────────────────
    fatigue_error = feedback.actual_fatigue - feedback.predicted_fatigue
    pm.fatigue_weight += pm.learning_rate * fatigue_error

    # ── Stress calibration ───────────────────────────────────────────────
    stress_error = feedback.actual_stress - feedback.predicted_stress
    pm.stress_weight += pm.learning_rate * stress_error

    # ── Guidance feedback → anomaly sensitivity ──────────────────────────
    if not feedback.guidance_helpful:
        pm.anomaly_sensitivity += pm.learning_rate

    # ── Clamp all weights to [0.5, 1.5] ──────────────────────────────────
    pm.fatigue_weight = max(0.5, min(1.5, pm.fatigue_weight))
    pm.stress_weight = max(0.5, min(1.5, pm.stress_weight))
    pm.anomaly_sensitivity = max(0.5, min(1.5, pm.anomaly_sensitivity))
    pm.phase_uncertainty_factor = max(0.5, min(1.5, pm.phase_uncertainty_factor))

    db.commit()
    db.refresh(pm)

    logger.info(
        "Calibration updated | user_id=%d fatigue_w=%.3f stress_w=%.3f anomaly_s=%.3f",
        current_user.id, pm.fatigue_weight, pm.stress_weight, pm.anomaly_sensitivity,
    )

    return FeedbackResponse(
        message="Calibration updated",
        updated_weights=PersonalModelResponse.model_validate(pm),
    )
