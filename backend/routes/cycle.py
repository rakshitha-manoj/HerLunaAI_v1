"""
HerLuna Cycle Log Routes
JWT-protected. cycle_length is DERIVED from consecutive period_start diffs.
Supports pagination with limit/offset.
"""
from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session
from typing import List

from database import get_db
from models import CycleLog, User
from schemas import CycleLogCreate, CycleLogResponse
from routes.auth import get_current_user

router = APIRouter()


@router.post(
    "/log",
    response_model=CycleLogResponse,
    status_code=status.HTTP_201_CREATED,
    responses={
        201: {"description": "Cycle log created"},
        401: {"description": "Invalid or expired token"},
        403: {"description": "Not authorized"},
        422: {"description": "Validation error"},
    },
)
def create_cycle_log(
    data: CycleLogCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """
    Add a new cycle log entry. User ID from JWT.
    cycle_length is computed from the previous entry's period_start —
    never accepted as user input.
    """
    # Derive cycle_length from previous log
    derived_cycle_length = None
    prev_log = (
        db.query(CycleLog)
        .filter(CycleLog.user_id == current_user.id)
        .order_by(CycleLog.period_start.desc())
        .first()
    )
    if prev_log and prev_log.period_start:
        delta = (data.period_start - prev_log.period_start).days
        if delta > 0:
            derived_cycle_length = delta

    log = CycleLog(
        user_id=current_user.id,
        period_start=data.period_start,
        cycle_length=derived_cycle_length,
        bleeding_days=data.bleeding_days,
        flow_intensity=data.flow_intensity.value if data.flow_intensity else None,
        symptoms=data.symptoms,
        notes=data.notes,
    )
    db.add(log)
    db.commit()
    db.refresh(log)
    return log


@router.get(
    "/logs",
    response_model=List[CycleLogResponse],
    responses={
        401: {"description": "Invalid or expired token"},
        403: {"description": "Not authorized"},
    },
)
def get_cycle_logs(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
    limit: int = Query(50, ge=1, le=200, description="Max results"),
    offset: int = Query(0, ge=0, description="Skip N results"),
):
    """Retrieve cycle logs with pagination."""
    return (
        db.query(CycleLog)
        .filter(CycleLog.user_id == current_user.id)
        .order_by(CycleLog.period_start.desc())
        .offset(offset)
        .limit(limit)
        .all()
    )
