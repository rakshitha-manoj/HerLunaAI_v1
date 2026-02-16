from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db import get_db
from app.schemas.profile_schema import ProfileCreate, ProfileResponse
from app.services.profile_service import create_profile, get_profile
from app.models import HealthProfile
from uuid import UUID

router = APIRouter(prefix="/profile", tags=["Profile"])


@router.post("/", response_model=ProfileResponse)
def create_profile_route(payload: ProfileCreate, db: Session = Depends(get_db)):
    profile = create_profile(db, payload)

    return {
        "user_id": profile.user_id,
        "name": profile.name,
        "age_range": profile.age_range,
        "condition": profile.condition,
        "active_goals": profile.active_goals,
        "height_cm": profile.height_cm,
        "weight_kg": profile.weight_kg
    }


@router.get("/{user_id}", response_model=ProfileResponse)
def get_profile_route(user_id: UUID, db: Session = Depends(get_db)):

    profile = db.query(HealthProfile).filter(
        HealthProfile.user_id == user_id
    ).first()

    if not profile:
        raise HTTPException(
            status_code=404,
            detail="Profile not found"
        )

    return {
        "user_id": profile.user_id,
        "name": profile.name,
        "age_range": profile.age_range,
        "condition": profile.condition,
        "active_goals": profile.active_goals,
        "height_cm": profile.height_cm,
        "weight_kg": profile.weight_kg,
    }
