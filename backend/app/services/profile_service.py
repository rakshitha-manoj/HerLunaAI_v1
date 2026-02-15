from sqlalchemy.orm import Session
from app.models import User, HealthProfile

def create_profile(db: Session, condition: str, goals: list):
    user = User()
    db.add(user)
    db.commit()
    db.refresh(user)

    profile = HealthProfile(
        user_id=user.id,
        condition=condition,
        active_goals=goals
    )

    db.add(profile)
    db.commit()
    db.refresh(profile)

    return profile

def get_profile(db: Session, user_id):
    return db.query(HealthProfile).filter(
        HealthProfile.user_id == user_id
    ).first()
