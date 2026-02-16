from sqlalchemy.orm import Session
from app.models import CycleLog
from datetime import date
from uuid import UUID
from typing import List


def create_or_update_log(db: Session, data):

    existing = (
        db.query(CycleLog)
        .filter(
            CycleLog.user_id == data.user_id,
            CycleLog.log_date == data.log_date
        )
        .first()
    )

    if existing:
        existing.is_period_active = data.is_period_active or False
        existing.flow_encoded = data.flow_encoded
        existing.selected_symptoms = data.selected_symptoms or []
        existing.extra_symptoms = data.extra_symptoms
        existing.note = data.note

        db.commit()
        db.refresh(existing)
        return existing

    log = CycleLog(
        user_id=data.user_id,
        log_date=data.log_date,
        is_period_active=data.is_period_active or False,
        flow_encoded=data.flow_encoded,
        selected_symptoms=data.selected_symptoms or [],
        extra_symptoms=data.extra_symptoms,
        note=data.note,
    )

    db.add(log)
    db.commit()
    db.refresh(log)

    return log


def get_logs_by_user(
    db: Session,
    user_id: UUID,
    start_date: date | None = None,
    end_date: date | None = None,
) -> List[CycleLog]:

    query = db.query(CycleLog).filter(CycleLog.user_id == user_id)

    if start_date:
        query = query.filter(CycleLog.log_date >= start_date)

    if end_date:
        query = query.filter(CycleLog.log_date <= end_date)

    return query.order_by(CycleLog.log_date).all()
