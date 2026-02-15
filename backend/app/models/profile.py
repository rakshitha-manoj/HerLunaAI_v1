import uuid
import enum
from sqlalchemy import Column, DateTime, ForeignKey, Enum
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.sql import func
from app.db import Base

class ConditionEnum(str, enum.Enum):
    regular = "regular"
    pcos = "pcos"
    endometriosis = "endometriosis"
    pmdd = "pmdd"
    perimenopause = "perimenopause"

class HealthProfile(Base):
    __tablename__ = "health_profiles"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"))
    condition = Column(Enum(ConditionEnum), nullable=False)
    active_goals = Column(JSONB, nullable=True)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
