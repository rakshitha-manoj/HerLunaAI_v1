"""
HerLuna Pydantic Schemas
Request/response models and the nested multi-agent InferenceResponse.

Architectural Principles:
  - No user_id in any create body (extracted from JWT)
  - cycle_length is DERIVED, not user-supplied
  - Validation enforces system safety, NOT biological normality
  - Confidence derivation is explicitly documented
  - Model versioning included for reproducibility
  - Phase probabilities normalized to sum to 1.0
"""
from pydantic import BaseModel, Field, field_validator
from typing import Optional, List
from datetime import date, datetime
from enum import Enum


# ── Enums ─────────────────────────────────────────────────────────────────────

class AgeRange(str, Enum):
    CHILD = "6-12"
    TEEN = "13-18"
    YOUNG_ADULT = "19-25"
    ADULT = "26-35"
    MID_ADULT = "36-45"
    SENIOR = "46+"


class ActivityLevel(str, Enum):
    SEDENTARY = "sedentary"
    MODERATE = "moderate"
    HIGH_PERFORMANCE = "high_performance"


class FlowIntensity(str, Enum):
    LIGHT = "light"
    MODERATE = "moderate"
    HEAVY = "heavy"


class TravelType(str, Enum):
    WORK = "work"
    LEISURE = "leisure"
    COMPETITION = "competition"


# ── Auth ──────────────────────────────────────────────────────────────────────

class UserCreate(BaseModel):
    email: str
    password: str
    full_name: str
    age_range: AgeRange = AgeRange.YOUNG_ADULT
    activity_level: ActivityLevel = ActivityLevel.MODERATE
    storage_mode: str = "cloud"
    is_young_girl_mode: bool = False
    average_cycle_length: Optional[int] = Field(
        default=None,
        description=(
            "Optional user-reported average cycle length. "
            "Used as a Bayesian prior ONLY when fewer than 2 historical logs exist. "
            "Automatically overridden once personal baseline is computed from ≥2 logged period_start entries. "
            "Never replaces derived cycle intervals in inference."
        ),
    )
    cycle_variability_known: bool = False


class UserLogin(BaseModel):
    email: str
    password: str


class UserResponse(BaseModel):
    id: int
    email: str
    full_name: str
    age_range: str
    activity_level: str
    storage_mode: str
    is_young_girl_mode: bool
    average_cycle_length: Optional[int] = None
    cycle_variability_known: bool
    created_at: datetime

    class Config:
        from_attributes = True


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    expires_in: int  # seconds
    user: UserResponse


# ── Cycle Logs ────────────────────────────────────────────────────────────────

class CycleLogCreate(BaseModel):
    """
    Create a new cycle log entry.
    cycle_length is intentionally absent — it is computed from consecutive
    period_start differences in the service layer to ensure variability-aware
    modeling integrity.
    """
    period_start: date
    bleeding_days: Optional[int] = Field(
        default=None, ge=0, le=30,
        description="Number of bleeding days. System safety bound 0-30; anomaly detection handles outliers.",
    )
    flow_intensity: Optional[FlowIntensity] = None
    symptoms: Optional[List[str]] = None
    notes: Optional[str] = None


class CycleLogResponse(BaseModel):
    id: int
    user_id: int
    period_start: date
    cycle_length: Optional[int] = Field(
        default=None,
        description="Derived from difference between consecutive period_start entries. Never user-supplied.",
    )
    bleeding_days: Optional[int]
    flow_intensity: Optional[str]
    symptoms: Optional[List[str]]
    notes: Optional[str]
    created_at: datetime

    class Config:
        from_attributes = True


# ── Behavioral Data ──────────────────────────────────────────────────────────

class BehavioralDataCreate(BaseModel):
    step_count: int = Field(default=0, ge=0)
    screen_time: float = Field(default=0.0, ge=0)
    calendar_load: int = Field(default=0, ge=0)
    sleep_hours: Optional[float] = Field(
        default=None, ge=0, le=24,
        description="Hours of sleep. System safety bound 0-24.",
    )
    mood_score: Optional[int] = Field(
        default=None, ge=1, le=5,
        description="Self-reported mood on 1-5 scale.",
    )
    date: date


class BehavioralDataResponse(BaseModel):
    id: int
    user_id: int
    step_count: int
    screen_time: float
    calendar_load: int
    sleep_hours: Optional[float]
    mood_score: Optional[int]
    date: date

    class Config:
        from_attributes = True


# ── Travel Data ──────────────────────────────────────────────────────────────

class TravelDataCreate(BaseModel):
    start_date: date
    end_date: date
    travel_type: TravelType = TravelType.LEISURE


class TravelDataResponse(BaseModel):
    id: int
    user_id: int
    start_date: date
    end_date: date
    travel_type: str

    class Config:
        from_attributes = True


# ── Inference (Nested Multi-Agent Response) ──────────────────────────────────

class PhaseProbability(BaseModel):
    """
    Phase probability distribution — variability-aware.
    Probabilities are normalized and MUST sum to 1.0.
    Distribution width expands with higher cycle variability_index:
      - Low variability  → sharper distribution (one phase dominant)
      - High variability → flatter distribution (more uncertainty)
    Never assumes 28-day cycles.
    """
    menstrual: float = Field(default=0.25, ge=0, le=1)
    follicular: float = Field(default=0.25, ge=0, le=1)
    ovulatory: float = Field(default=0.25, ge=0, le=1)
    luteal: float = Field(default=0.25, ge=0, le=1)


class PhysiologicalState(BaseModel):
    """Output from Physiological + Fertility agents."""
    phase_probability: PhaseProbability = PhaseProbability()
    fertility_probability: float = Field(default=0.0, ge=0, le=1)


class PerformanceState(BaseModel):
    """Output from Fatigue agent."""
    fatigue_probability: float = Field(default=0.0, ge=0, le=1)
    readiness_score: float = Field(
        default=0.0, ge=0, le=100,
        description="0-100 readiness score derived from fatigue and behavioral baselines.",
    )


class RiskState(BaseModel):
    """Output from Stress, Travel, and Anomaly agents."""
    stress_probability: float = Field(default=0.0, ge=0, le=1)
    travel_risk: float = Field(default=0.0, ge=0, le=1)
    anomaly_flag: bool = Field(
        default=False,
        description=(
            "Triggered when: (1) cycle interval deviates significantly from personal baseline "
            "(not fixed population thresholds), OR (2) behavioral deviation_score exceeds "
            "personal threshold. Reflects individual variability, not normative assumptions."
        ),
    )


class GuidanceSuggestion(BaseModel):
    category: str
    suggestion: str
    reason: str


class BaselineMetrics(BaseModel):
    """
    Derived statistical indicators from personal data.
    Exposed for scientific transparency — no sensitive raw data.
    """
    mean_cycle_length: Optional[float] = Field(
        default=None,
        description="Mean interval between consecutive period_start entries.",
    )
    cycle_variability_index: Optional[float] = Field(
        default=None,
        description="Coefficient of variation (std/mean) of cycle intervals. Higher = more irregular.",
    )
    behavioral_deviation_score: Optional[float] = Field(
        default=None,
        description="Composite z-score deviation from personal rolling behavioral averages.",
    )


class InferenceMeta(BaseModel):
    """
    Explainability, guidance, disclaimers, and baseline transparency.
    """
    confidence_score: float = Field(
        default=0.0, ge=0, le=1,
        description=(
            "Confidence in inference quality. "
            "0.0 = insufficient data (no logs available). "
            "0.1 = minimum confidence when any data exists. "
            "Derived from: (1) data volume — more cycle and behavioral entries increase confidence; "
            "(2) baseline consistency — lower cycle variability improves score; "
            "(3) behavioral stability — consistent patterns boost confidence. "
            "Range 0.0 (no data) or 0.1-1.0 (data available)."
        ),
    )
    baseline_metrics: BaselineMetrics = BaselineMetrics()
    model_version: str = Field(
        default="v1.0.0",
        description="Semantic version of the ML models used for this inference.",
    )
    inference_time_ms: int = Field(
        default=0,
        description="Wall-clock time for the full multi-agent pipeline in milliseconds.",
    )
    top_features: List[str] = []
    trend_flags: List[str] = Field(
        default=[],
        description="Longitudinal trend flags from TrendAgent (cycle drift, behavioral shift).",
    )
    guidance: List[GuidanceSuggestion] = []
    disclaimers: List[str] = []


class InferenceResponse(BaseModel):
    """
    Nested multi-agent inference response.
    Each section maps to a group of agents:
      - physiological_state → PhysiologicalAgent + FertilityAgent
      - performance_state  → FatigueAgent
      - risk_state         → StressAgent + TravelAgent + AnomalyAgent
      - meta               → Baseline + GuidanceAgent + TrendAgent + explainability
    """
    physiological_state: PhysiologicalState = PhysiologicalState()
    performance_state: PerformanceState = PerformanceState()
    risk_state: RiskState = RiskState()
    meta: InferenceMeta = InferenceMeta()


class InferenceRequestCloud(BaseModel):
    """Cloud mode: user_id comes from JWT, data from DB."""
    is_young_girl_mode: bool = False


class InferenceRequestLocal(BaseModel):
    """Local mode: snapshot data in body, nothing stored."""
    is_young_girl_mode: bool = False
    cycle_logs: Optional[List[CycleLogCreate]] = None
    behavioral_data: Optional[List[BehavioralDataCreate]] = None
    travel_data: Optional[List[TravelDataCreate]] = None


# ── Healthcare ───────────────────────────────────────────────────────────────

class HealthcareLocation(BaseModel):
    name: str
    address: str
    lat: float
    lng: float
    phone: Optional[str] = None


class HealthcareResponse(BaseModel):
    locations: List[HealthcareLocation] = []


# ── System Status Models (typed responses for GET / and GET /health) ─────────

class MLModelStatus(BaseModel):
    phase_model: str = "not_found"
    stress_model: str = "not_found"
    fatigue_model: str = "not_found"


class HealthResponse(BaseModel):
    """Structured health check response — typed, not string."""
    status: str = "healthy"
    database: str = "unknown"
    ml_models: MLModelStatus = MLModelStatus()
    environment: str = "development"
    version: str = "2.0.0"


class RootResponse(BaseModel):
    """Structured root endpoint response — typed, not string."""
    name: str = "HerLuna API"
    version: str = "2.0.0"
    description: str = "Multi-Agent AI Women's Lifestyle Intelligence Platform"
    environment: str = "development"
    status: str = "running"
    multi_agent_architecture: bool = True
    api_versioning: str = Field(
        default="v1 (current path: /). Future versions will use /api/v2/ prefix.",
        description="Versioning strategy documentation.",
    )


# ── Feedback & Calibration ───────────────────────────────────────────────────

class FeedbackCreate(BaseModel):
    """User feedback for adaptive model calibration."""
    predicted_fatigue: float = Field(ge=0, le=1)
    actual_fatigue: float = Field(ge=0, le=1)
    predicted_stress: float = Field(ge=0, le=1)
    actual_stress: float = Field(ge=0, le=1)
    guidance_helpful: bool = True


class PersonalModelResponse(BaseModel):
    """Current adaptive weights for transparency."""
    anomaly_sensitivity: float
    fatigue_weight: float
    stress_weight: float
    phase_uncertainty_factor: float
    learning_rate: float
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class FeedbackResponse(BaseModel):
    """Response after calibration update."""
    message: str = "Calibration updated"
    updated_weights: PersonalModelResponse


# ── Analytics ────────────────────────────────────────────────────────────────

class AnalyticsResponse(BaseModel):
    """Performance tracking dashboard data."""
    total_inferences: int = 0
    average_confidence: float = 0.0
    total_anomalies: int = 0
    average_readiness: float = 0.0
    personal_model: Optional[PersonalModelResponse] = None
