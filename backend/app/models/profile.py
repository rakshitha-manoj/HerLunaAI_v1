import uuid
import enum
from sqlalchemy import Column, DateTime, ForeignKey, Enum, String, Float
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.sql import func
from app.db import Base

class ConditionEnum(str, enum.Enum):
    regular = "regular"
    pcos = "pcos"
    endometriosis = "endometriosis"
    pmdd = "pmdd"
    perimenopause = "perimenopause"

class AgeRangeEnum(str, enum.Enum):
    under_18 = "<18"
    age_18_25 = "18-25"
    age_26_35 = "26-35"
    age_36_45 = "36-45"
    age_45_plus = "45+"

class HealthProfile(Base):
    __tablename__ = "health_profiles"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"))

    name = Column(String, nullable=False)
    age_range = Column(Enum(AgeRangeEnum), nullable=False)

    condition = Column(Enum(ConditionEnum), nullable=False)
    active_goals = Column(JSONB, nullable=True)

    height_cm = Column(Float, nullable=True)
    weight_kg = Column(Float, nullable=True)

    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
