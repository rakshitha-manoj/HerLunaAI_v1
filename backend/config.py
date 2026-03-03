"""
HerLuna Backend Configuration
Loads environment variables and provides application settings.
"""
import os
from dotenv import load_dotenv

load_dotenv()


class Settings:
    """Application settings loaded from environment variables."""

    # Database
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL",
        "postgresql://user:password@localhost:5432/herluna"
    )

    # Security
    SECRET_KEY: str = os.getenv("SECRET_KEY", "herluna-dev-secret-key-change-in-production")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24  # 24 hours

    # CORS
    CORS_ORIGINS: list = ["*"]

    # Environment
    ENVIRONMENT: str = os.getenv("ENVIRONMENT", "development")

    # ML Model paths
    ML_MODEL_DIR: str = os.path.join(os.path.dirname(__file__), "ml")
    PHASE_MODEL_PATH: str = os.path.join(ML_MODEL_DIR, "phase_classifier.pkl")
    STRESS_MODEL_PATH: str = os.path.join(ML_MODEL_DIR, "stress_classifier.pkl")
    FATIGUE_MODEL_PATH: str = os.path.join(ML_MODEL_DIR, "fatigue_model.pkl")

    # Model versioning
    MODEL_VERSION: str = os.getenv("MODEL_VERSION", "v1.0.0")


settings = Settings()
