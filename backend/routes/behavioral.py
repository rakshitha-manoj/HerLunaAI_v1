"""
HerLuna Behavioral Data Routes
JWT-protected with pagination support.
"""
from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session
from typing import List

from database import get_db
from models import BehavioralData, User
from schemas import BehavioralDataCreate, BehavioralDataResponse
from routes.auth import get_current_user

router = APIRouter()


@router.post(
    "/log",
    response_model=BehavioralDataResponse,
    status_code=status.HTTP_201_CREATED,
    responses={
        201: {"description": "Behavioral log created"},
        401: {"description": "Invalid or expired token"},
        403: {"description": "Not authorized"},
        422: {"description": "Validation error"},
    },
)
def create_behavioral_log(
    data: BehavioralDataCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Add a new behavioral data entry. User ID from JWT."""
    entry = BehavioralData(
        user_id=current_user.id,
        step_count=data.step_count,
        screen_time=data.screen_time,
        calendar_load=data.calendar_load,
        sleep_hours=data.sleep_hours,
        mood_score=data.mood_score,
        date=data.date,
    )
    db.add(entry)
    db.commit()
    db.refresh(entry)
    return entry


@router.get(
    "/logs",
    response_model=List[BehavioralDataResponse],
    responses={
        401: {"description": "Invalid or expired token"},
        403: {"description": "Not authorized"},
    },
)
def get_behavioral_logs(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
    limit: int = Query(50, ge=1, le=200, description="Max results"),
    offset: int = Query(0, ge=0, description="Skip N results"),
):
    """Retrieve behavioral data with pagination."""
    return (
        db.query(BehavioralData)
        .filter(BehavioralData.user_id == current_user.id)
        .order_by(BehavioralData.date.desc())
        .offset(offset)
        .limit(limit)
        .all()
    )
