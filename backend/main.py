"""
HerLuna – Multi-Agent AI Women's Lifestyle Intelligence Platform
FastAPI Application Entry Point v2.0.0

Production-grade features:
  - Typed response models (no string schemas)
  - Structured logging (INFO/WARNING/ERROR, no sensitive data)
  - Rate limiting on /predict/local, /healthcare/nearby, /auth/login
  - Health checks with DB + ML model validation
"""
import logging
from fastapi import FastAPI, Request, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from database import engine, Base, get_db
from config import settings
from schemas import RootResponse, HealthResponse, MLModelStatus
import os
import time
from collections import defaultdict

# ── Structured Logging ───────────────────────────────────────────────────────
# No sensitive personal data in logs. INFO for flow, WARNING for anomalies,
# ERROR for failures.

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(name)s | %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger("herluna")

# Import routers
from routes.auth import router as auth_router
from routes.cycle import router as cycle_router
from routes.behavioral import router as behavioral_router
from routes.travel import router as travel_router
from routes.predict import router as predict_router
from routes.healthcare import router as healthcare_router
from routes.feedback import router as feedback_router
from routes.analytics import router as analytics_router
from routes.daily_log import router as daily_log_router

app = FastAPI(
    title="HerLuna API",
    description="Multi-Agent AI Women's Lifestyle Intelligence Platform",
    version="2.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ── Rate Limiting (in-memory sliding window) ─────────────────────────────────
# Production would use Redis. This demonstrates the concept.

_rate_limit_store: dict = defaultdict(list)

# Different limits for different endpoints
RATE_LIMITS = {
    "/predict/local": {"max": 30, "window": 60},
    "/healthcare/nearby": {"max": 30, "window": 60},
    "/auth/login": {"max": 10, "window": 60},  # Brute-force mitigation
}


@app.middleware("http")
async def rate_limit_middleware(request: Request, call_next):
    """Rate limit sensitive endpoints."""
    path = request.url.path

    for limited_path, limits in RATE_LIMITS.items():
        if path.startswith(limited_path):
            client_ip = request.client.host if request.client else "unknown"
            key = f"{client_ip}:{limited_path}"
            now = time.time()

            _rate_limit_store[key] = [
                t for t in _rate_limit_store[key]
                if now - t < limits["window"]
            ]

            if len(_rate_limit_store[key]) >= limits["max"]:
                logger.warning(f"Rate limit hit: {limited_path} from {client_ip}")
                return JSONResponse(
                    status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                    content={
                        "detail": f"Rate limit exceeded. Max {limits['max']} requests per {limits['window']}s."
                    },
                )

            _rate_limit_store[key].append(now)
            break

    response = await call_next(request)
    return response


# Include routers
app.include_router(auth_router, prefix="/auth", tags=["Authentication"])
app.include_router(cycle_router, prefix="/cycle", tags=["Cycle Logs"])
app.include_router(behavioral_router, prefix="/behavioral", tags=["Behavioral Data"])
app.include_router(travel_router, prefix="/travel", tags=["Travel Data"])
app.include_router(predict_router, prefix="/predict", tags=["Prediction / Inference"])
app.include_router(healthcare_router, prefix="/healthcare", tags=["Healthcare Locator"])
app.include_router(feedback_router, tags=["Feedback & Calibration"])
app.include_router(analytics_router, prefix="/analytics", tags=["Analytics"])
app.include_router(daily_log_router, prefix="/daily", tags=["Daily Logs"])


@app.on_event("startup")
def on_startup():
    """Create all database tables on startup."""
    # Explicit import to ensure all models are registered with Base.metadata
    import models  # noqa: F401
    Base.metadata.create_all(bind=engine)
    logger.info("HerLuna API v2.0.0 started | environment=%s", settings.ENVIRONMENT)


@app.get("/", response_model=RootResponse, tags=["System"])
def root():
    """API metadata, version, environment, and architectural identity."""
    return RootResponse(
        environment=settings.ENVIRONMENT,
    )


@app.get("/health", response_model=HealthResponse, tags=["System"])
def health_check():
    """
    System health check.
    Validates DB connectivity and ML model availability.
    Returns typed structured status for monitoring.
    """
    ml_status = MLModelStatus()
    db_status = "unknown"
    overall = "healthy"

    # Check DB connectivity
    try:
        db = next(get_db())
        db.execute(__import__("sqlalchemy").text("SELECT 1"))
        db_status = "connected"
    except Exception as e:
        db_status = f"error: {str(e)}"
        overall = "degraded"
        logger.error("Health check: DB connection failed: %s", str(e))

    # Check ML model files
    if os.path.exists(settings.PHASE_MODEL_PATH):
        ml_status.phase_model = "loaded"
    if os.path.exists(settings.STRESS_MODEL_PATH):
        ml_status.stress_model = "loaded"
    if os.path.exists(settings.FATIGUE_MODEL_PATH):
        ml_status.fatigue_model = "loaded"

    all_loaded = all(
        v == "loaded" for v in [ml_status.phase_model, ml_status.stress_model, ml_status.fatigue_model]
    )
    if not all_loaded:
        overall = "degraded"

    return HealthResponse(
        status=overall,
        database=db_status,
        ml_models=ml_status,
        environment=settings.ENVIRONMENT,
    )
