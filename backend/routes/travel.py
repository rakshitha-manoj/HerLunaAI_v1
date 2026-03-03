"""
HerLuna Travel Data Routes
JWT-protected with pagination support.
"""
from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session
from typing import List

from database import get_db
from models import TravelData, User
from schemas import TravelDataCreate, TravelDataResponse
from routes.auth import get_current_user

router = APIRouter()


@router.post(
    "/log",
    response_model=TravelDataResponse,
    status_code=status.HTTP_201_CREATED,
    responses={
        201: {"description": "Travel log created"},
        401: {"description": "Invalid or expired token"},
        403: {"description": "Not authorized"},
        422: {"description": "Validation error"},
    },
)
def create_travel_log(
    data: TravelDataCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Add a new travel data entry. User ID from JWT."""
    entry = TravelData(
        user_id=current_user.id,
        start_date=data.start_date,
        end_date=data.end_date,
        travel_type=data.travel_type.value,
    )
    db.add(entry)
    db.commit()
    db.refresh(entry)
    return entry


@router.get(
    "/logs",
    response_model=List[TravelDataResponse],
    responses={
        401: {"description": "Invalid or expired token"},
        403: {"description": "Not authorized"},
    },
)
def get_travel_logs(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
    limit: int = Query(50, ge=1, le=200, description="Max results"),
    offset: int = Query(0, ge=0, description="Skip N results"),
):
    """Retrieve travel data with pagination."""
    return (
        db.query(TravelData)
        .filter(TravelData.user_id == current_user.id)
        .order_by(TravelData.start_date.desc())
        .offset(offset)
        .limit(limit)
        .all()
    )
