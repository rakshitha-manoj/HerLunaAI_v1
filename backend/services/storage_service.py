"""
HerLuna Storage Service
Handles Cloud vs Local data retrieval logic.
Cloud mode: fetches from PostgreSQL using user_id (from JWT).
Local mode: accepts snapshot data, does NOT persist.
Includes get_personal_model for adaptive calibration.
"""
from sqlalchemy.orm import Session
from models import CycleLog, BehavioralData, TravelData, User, PersonalModel


def get_cloud_data(user_id: int, db: Session) -> dict:
    """
    Fetch all user data from PostgreSQL for cloud mode inference.
    User ID comes from JWT — never from request body.
    """
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise ValueError(f"User {user_id} not found")

    cycle_logs = (
        db.query(CycleLog)
        .filter(CycleLog.user_id == user_id)
        .order_by(CycleLog.period_start.desc())
        .all()
    )

    behavioral_data = (
        db.query(BehavioralData)
        .filter(BehavioralData.user_id == user_id)
        .order_by(BehavioralData.date.desc())
        .all()
    )

    travel_data = (
        db.query(TravelData)
        .filter(TravelData.user_id == user_id)
        .order_by(TravelData.start_date.desc())
        .all()
    )

    return {
        "user_id": user_id,
        "is_young_girl_mode": user.is_young_girl_mode,
        "activity_level": user.activity_level,
        "average_cycle_length": user.average_cycle_length,
        "cycle_logs": [
            {
                "period_start": str(cl.period_start),
                "cycle_length": cl.cycle_length,
                "bleeding_days": cl.bleeding_days,
                "flow_intensity": cl.flow_intensity,
                "symptoms": cl.symptoms or [],
            }
            for cl in cycle_logs
        ],
        "behavioral_data": [
            {
                "step_count": bd.step_count,
                "screen_time": bd.screen_time,
                "calendar_load": bd.calendar_load,
                "sleep_hours": bd.sleep_hours,
                "mood_score": bd.mood_score,
                "date": str(bd.date),
            }
            for bd in behavioral_data
        ],
        "travel_data": [
            {
                "start_date": str(td.start_date),
                "end_date": str(td.end_date),
                "travel_type": td.travel_type,
            }
            for td in travel_data
        ],
    }


def get_local_data(request) -> dict:
    """
    Extract snapshot data from request body for local mode.
    This does NOT persist anything on the backend.
    """
    return {
        "user_id": None,
        "is_young_girl_mode": request.is_young_girl_mode,
        "activity_level": "moderate",
        "average_cycle_length": None,
        "cycle_logs": [
            {
                "period_start": str(cl.period_start),
                "cycle_length": cl.cycle_length,
                "bleeding_days": cl.bleeding_days,
                "flow_intensity": cl.flow_intensity.value if cl.flow_intensity else None,
                "symptoms": cl.symptoms or [],
            }
            for cl in (request.cycle_logs or [])
        ],
        "behavioral_data": [
            {
                "step_count": bd.step_count,
                "screen_time": bd.screen_time,
                "calendar_load": bd.calendar_load,
                "sleep_hours": bd.sleep_hours,
                "mood_score": bd.mood_score,
                "date": str(bd.date),
            }
            for bd in (request.behavioral_data or [])
        ],
        "travel_data": [
            {
                "start_date": str(td.start_date),
                "end_date": str(td.end_date),
                "travel_type": td.travel_type.value if td.travel_type else "leisure",
            }
            for td in (request.travel_data or [])
        ],
    }


def get_personal_model(user_id: int, db: Session) -> PersonalModel:
    """
    Get the user's PersonalModel for adaptive inference.
    Auto-creates with defaults if missing.
    """
    pm = db.query(PersonalModel).filter(PersonalModel.user_id == user_id).first()
    if pm is None:
        pm = PersonalModel(user_id=user_id)
        db.add(pm)
        db.commit()
        db.refresh(pm)
    return pm
