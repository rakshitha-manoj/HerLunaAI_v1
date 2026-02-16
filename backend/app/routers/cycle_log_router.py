from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.db import get_db
from app.schemas.cycle_log_schema import CycleLogCreate, CycleLogResponse
from app.services.cycle_log_service import create_or_update_log
from datetime import date
from typing import List
from uuid import UUID
from app.services.cycle_log_service import get_logs_by_user

router = APIRouter(prefix="/logs", tags=["Cycle Logs"])

@router.post("/", response_model=CycleLogResponse)
def create_cycle_log(payload: CycleLogCreate, db: Session = Depends(get_db)):
    return create_or_update_log(db, payload)


@router.get("/{user_id}", response_model=List[CycleLogResponse])
def fetch_logs(
    user_id: UUID,
    start_date: date | None = None,
    end_date: date | None = None,
    db: Session = Depends(get_db),
):
    return get_logs_by_user(db, user_id, start_date, end_date)