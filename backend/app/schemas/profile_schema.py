from pydantic import BaseModel
from typing import List
from uuid import UUID

class ProfileCreate(BaseModel):
    condition: str
    active_goals: List[str]

class ProfileResponse(BaseModel):
    user_id: UUID
    condition: str
    active_goals: List[str]
