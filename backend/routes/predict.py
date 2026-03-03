"""
HerLuna Prediction Routes
Split into cloud (JWT-protected, DB fetch) and local (snapshot only).
Consistent 401/403 response documentation.
"""
import logging
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from database import get_db
from models import User
from schemas import InferenceRequestCloud, InferenceRequestLocal, InferenceResponse
from services.inference_service import run_inference_cloud, run_inference_local
from routes.auth import get_current_user

router = APIRouter()
logger = logging.getLogger("herluna.predict")


@router.post(
    "/cloud",
    response_model=InferenceResponse,
    responses={
        200: {"description": "Inference completed"},
        401: {"description": "Invalid or expired token"},
        403: {"description": "Authenticated but not authorized"},
        500: {"description": "Inference pipeline error"},
    },
)
def predict_cloud(
    request: InferenceRequestCloud,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Cloud Mode: multi-agent inference using data from DB.
    User ID from JWT — fetches cycle, behavioral, travel data automatically.
    Results persisted to ModelOutputs with version metadata.
    """
    try:
        return run_inference_cloud(current_user.id, request.is_young_girl_mode, db)
    except ValueError as e:
        logger.error("Inference ValueError: %s", str(e))
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error("Inference error: %s", str(e))
        raise HTTPException(status_code=500, detail=f"Inference error: {str(e)}")


@router.post(
    "/local",
    response_model=InferenceResponse,
    responses={
        200: {"description": "Inference completed (nothing persisted)"},
        429: {"description": "Rate limit exceeded"},
        500: {"description": "Inference pipeline error"},
    },
)
def predict_local(request: InferenceRequestLocal):
    """
    Local Mode: multi-agent inference using snapshot data.
    Does NOT persist anything. No authentication required.
    Server-side persist_output=False prevents accidental DB writes.
    """
    try:
        return run_inference_local(request)
    except ValueError as e:
        logger.error("Local inference ValueError: %s", str(e))
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error("Local inference error: %s", str(e))
        raise HTTPException(status_code=500, detail=f"Inference error: {str(e)}")
