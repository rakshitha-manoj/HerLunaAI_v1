from sqlalchemy.orm import Session
from app.models import User, HealthProfile


def create_profile(db: Session, data):

    # 🔎 Check if user already exists
    user = db.query(User).filter(User.email == data.email).first()

    if not user:
        user = User(
            email=data.email,
            name=data.name
        )
        db.add(user)
        db.commit()
        db.refresh(user)

    profile = HealthProfile(
        user_id=user.id,
        name=data.name,
        age_range=data.age_range,
        condition=data.condition,
        active_goals=data.goals,
        height_cm=data.height,
        weight_kg=data.weight,
    )

    db.add(profile)
    db.commit()
    db.refresh(profile)

    return profile
    return profile

def get_profile(db: Session, user_id):
    return db.query(HealthProfile).filter(
        HealthProfile.user_id == user_id
    ).first()
