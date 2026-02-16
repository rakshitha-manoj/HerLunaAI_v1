import uuid
from sqlalchemy import Column, Date, String, Boolean, ForeignKey, DateTime, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID, ARRAY
from sqlalchemy.sql import func
from app.db import Base


class CycleLog(Base):
    __tablename__ = "cycle_logs"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)

    log_date = Column(Date, nullable=False)

    is_period_active = Column(Boolean, default=False)  # FIXED

    flow_encoded = Column(String, nullable=True)

    selected_symptoms = Column(ARRAY(String), nullable=True)

    extra_symptoms = Column(String, nullable=True)

    note = Column(String, nullable=True)

    created_at = Column(DateTime(timezone=True), server_default=func.now())

    __table_args__ = (
        UniqueConstraint("user_id", "log_date", name="unique_user_day"),
    )
