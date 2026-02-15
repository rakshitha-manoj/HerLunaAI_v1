from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.db import get_db
from app.schemas.profile_schema import ProfileCreate, ProfileResponse
from app.services.profile_service import create_profile, get_profile

router = APIRouter(prefix="/profile", tags=["Profile"])

@router.post("/", response_model=ProfileResponse)
def create_profile_route(payload: ProfileCreate, db: Session = Depends(get_db)):
    profile = create_profile(db, payload.condition, payload.active_goals)

    return {
        "user_id": profile.user_id,
        "condition": profile.condition,
        "active_goals": profile.active_goals
    }

@router.get("/{user_id}", response_model=ProfileResponse)
def get_profile_route(user_id: str, db: Session = Depends(get_db)):
    profile = get_profile(db, user_id)

    if not profile:
        return {
            "user_id": user_id,
            "condition": None,
            "active_goals": []
        }

    return {
        "user_id": profile.user_id,
        "condition": profile.condition,
        "active_goals": profile.active_goals
    }
