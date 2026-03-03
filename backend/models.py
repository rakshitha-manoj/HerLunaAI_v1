"""
HerLuna SQLAlchemy ORM Models
Database table definitions for PostgreSQL (Neon).
cycle_length is derived in service layer, stored for retrieval only.
ModelOutput includes versioning metadata and predicted values for analytics.
PersonalModel stores adaptive calibration parameters per user.
"""
from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, Date, ForeignKey, JSON
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=False)
    full_name = Column(String, nullable=False, default="")
    age_range = Column(String, default="19-25")
    activity_level = Column(String, default="moderate")
    storage_mode = Column(String, default="cloud")
    is_young_girl_mode = Column(Boolean, default=False)
    average_cycle_length = Column(Integer, nullable=True)
    cycle_variability_known = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    cycle_logs = relationship("CycleLog", back_populates="user")
    behavioral_data = relationship("BehavioralData", back_populates="user")
    travel_data = relationship("TravelData", back_populates="user")
    model_outputs = relationship("ModelOutput", back_populates="user")
    personal_model = relationship("PersonalModel", back_populates="user", uselist=False)


class CycleLog(Base):
    __tablename__ = "cycle_logs"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    period_start = Column(Date, nullable=False)
    # cycle_length is DERIVED in service layer from consecutive period_start diffs
    cycle_length = Column(Integer, nullable=True)
    bleeding_days = Column(Integer, nullable=True)
    flow_intensity = Column(String, nullable=True)
    symptoms = Column(JSON, nullable=True)
    notes = Column(String, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", back_populates="cycle_logs")


class BehavioralData(Base):
    __tablename__ = "behavioral_data"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    step_count = Column(Integer, default=0)
    screen_time = Column(Float, default=0.0)
    calendar_load = Column(Integer, default=0)
    sleep_hours = Column(Float, nullable=True)
    mood_score = Column(Integer, nullable=True)
    date = Column(Date, nullable=False)

    user = relationship("User", back_populates="behavioral_data")


class TravelData(Base):
    __tablename__ = "travel_data"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    start_date = Column(Date, nullable=False)
    end_date = Column(Date, nullable=False)
    travel_type = Column(String, default="leisure")

    user = relationship("User", back_populates="travel_data")


class ModelOutput(Base):
    """
    Stores every inference result for analytics and performance tracking.
    Includes predicted values to enable model evaluation.
    """
    __tablename__ = "model_outputs"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    fatigue_prob = Column(Float, default=0.0)
    stress_prob = Column(Float, default=0.0)
    readiness_score = Column(Float, default=0.0)
    confidence_score = Column(Float, default=0.0)
    # Predicted values for analytics (#4)
    predicted_fatigue = Column(Float, default=0.0)
    predicted_stress = Column(Float, default=0.0)
    predicted_readiness = Column(Float, default=0.0)
    # Versioning metadata
    model_version = Column(String, default="v1.0.0")
    inference_version = Column(String, default="v2.0.0")
    inference_time_ms = Column(Integer, default=0)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", back_populates="model_outputs")


class PersonalModel(Base):
    """
    User-specific adaptive parameters that adjust inference behavior.
    Updated through feedback calibration loop.
    All weights clamped to [0.5, 1.5] — never null.
    """
    __tablename__ = "personal_models"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True, index=True, nullable=False)
    anomaly_sensitivity = Column(Float, nullable=False, default=1.0)
    fatigue_weight = Column(Float, nullable=False, default=1.0)
    stress_weight = Column(Float, nullable=False, default=1.0)
    phase_uncertainty_factor = Column(Float, nullable=False, default=1.0)
    learning_rate = Column(Float, nullable=False, default=0.02)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    user = relationship("User", back_populates="personal_model")
