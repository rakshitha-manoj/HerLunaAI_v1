from pydantic import BaseModel
from typing import List, Optional
from uuid import UUID

class ProfileCreate(BaseModel):
    email: str
    name: str
    age_range: str
    condition: str
    goals: List[str]
    height: Optional[float] = None
    weight: Optional[float] = None

class ProfileResponse(BaseModel):
    user_id: UUID
    name: str
    age_range: str
    condition: str
    active_goals: List[str]
    height_cm: Optional[float]
    weight_kg: Optional[float]
