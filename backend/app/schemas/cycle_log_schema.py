from pydantic import BaseModel
from typing import Optional, List
from uuid import UUID
from datetime import date

class CycleLogCreate(BaseModel):
    user_id: UUID
    log_date: date

    is_period_active: Optional[bool] = False
    flow_encoded: Optional[str] = None
    selected_symptoms: Optional[List[str]] = []
    extra_symptoms: Optional[str] = None
    note: Optional[str] = None

class CycleLogResponse(BaseModel):
    id: UUID
    user_id: UUID
    log_date: date
    is_period_active: bool
    flow_encoded: str | None
    selected_symptoms: List[str]
    extra_symptoms: str
    note: str

    class Config:
        from_attributes = True

