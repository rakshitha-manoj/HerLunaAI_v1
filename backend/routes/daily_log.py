"""
HerLuna Daily Log Routes
JWT-protected. Accepts daily tracking data from the frontend calendar screen.
Stores energy/stress as text levels matching frontend UI (e.g., "Very Low", "Calm").
"""
from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session
from typing import List

from database import get_db
from models import DailyLog, User
from schemas import DailyLogCreate, DailyLogResponse
from routes.auth import get_current_user

router = APIRouter()


@router.post(
    "/log",
    response_model=DailyLogResponse,
    status_code=status.HTTP_201_CREATED,
    responses={
        201: {"description": "Daily log created"},
        401: {"description": "Invalid or expired token"},
    },
)
def create_daily_log(
    data: DailyLogCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Save a daily log entry from the calendar screen."""
    # Check if entry already exists for this date — update if so
    existing = (
        db.query(DailyLog)
        .filter(DailyLog.user_id == current_user.id, DailyLog.date == data.date)
        .first()
    )
    if existing:
        existing.on_period = data.on_period
        existing.flow_level = data.flow_level
        existing.energy_level = data.energy_level
        existing.stress_level = data.stress_level
        existing.notes = data.notes
        db.commit()
        db.refresh(existing)
        return existing

    log = DailyLog(
        user_id=current_user.id,
        date=data.date,
        on_period=data.on_period,
        flow_level=data.flow_level,
        energy_level=data.energy_level,
        stress_level=data.stress_level,
        notes=data.notes,
    )
    db.add(log)
    db.commit()
    db.refresh(log)
    return log


@router.get(
    "/logs",
    response_model=List[DailyLogResponse],
    responses={
        401: {"description": "Invalid or expired token"},
    },
)
def get_daily_logs(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
    limit: int = Query(90, ge=1, le=365, description="Max results"),
    offset: int = Query(0, ge=0, description="Skip N results"),
):
    """Retrieve daily logs with pagination."""
    return (
        db.query(DailyLog)
        .filter(DailyLog.user_id == current_user.id)
        .order_by(DailyLog.date.desc())
        .offset(offset)
        .limit(limit)
        .all()
    )
