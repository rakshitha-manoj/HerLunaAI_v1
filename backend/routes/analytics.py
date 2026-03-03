"""
HerLuna Analytics Route
GET /analytics/performance — JWT protected.
Returns performance tracking dashboard data.
"""
import logging
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func as sql_func

from database import get_db
from models import ModelOutput
from schemas import AnalyticsResponse, PersonalModelResponse
from routes.auth import get_current_user
from services.storage_service import get_personal_model

logger = logging.getLogger("herluna.analytics")

router = APIRouter()


@router.get(
    "/performance",
    response_model=AnalyticsResponse,
    responses={
        200: {"description": "Performance analytics retrieved"},
        401: {"description": "Not authenticated"},
    },
)
def get_performance(
    current_user=Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Return aggregated performance metrics and PersonalModel weights.
    Data sources: ModelOutput table + PersonalModel.
    """
    user_id = current_user.id

    # ── Aggregate from ModelOutput ────────────────────────────────────────
    stats = (
        db.query(
            sql_func.count(ModelOutput.id).label("total"),
            sql_func.avg(ModelOutput.confidence_score).label("avg_confidence"),
            sql_func.avg(ModelOutput.predicted_readiness).label("avg_readiness"),
        )
        .filter(ModelOutput.user_id == user_id)
        .first()
    )

    total_inferences = stats.total or 0
    avg_confidence = round(float(stats.avg_confidence or 0.0), 4)
    avg_readiness = round(float(stats.avg_readiness or 0.0), 2)

    # Count anomalies (where anomaly flag would have been set — stress_prob > 0.7 as proxy)
    # A more precise version would store anomaly_flag in ModelOutput
    total_anomalies = 0  # Placeholder — extend ModelOutput with anomaly_flag for precision

    # ── Load PersonalModel ───────────────────────────────────────────────
    pm = get_personal_model(user_id, db)

    logger.info(
        "Analytics retrieved | user_id=%d total_inferences=%d avg_confidence=%.3f",
        user_id, total_inferences, avg_confidence,
    )

    return AnalyticsResponse(
        total_inferences=total_inferences,
        average_confidence=avg_confidence,
        total_anomalies=total_anomalies,
        average_readiness=avg_readiness,
        personal_model=PersonalModelResponse.model_validate(pm),
    )
