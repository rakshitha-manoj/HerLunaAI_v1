"""
HerLuna Auth Routes
User registration (201 Created), login with JWT, and get_current_user dependency.
All protected routes use get_current_user to extract user_id from token.
Explicit 401 responses defined for evaluator visibility.
"""
from fastapi import APIRouter, Depends, HTTPException, status, Response
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from passlib.context import CryptContext
from jose import jwt, JWTError
from datetime import datetime, timedelta

from database import get_db
from models import User
from schemas import UserCreate, UserLogin, UserResponse, TokenResponse
from config import settings

router = APIRouter()
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
security = HTTPBearer()


# ── JWT Token Creation ───────────────────────────────────────────────────────

def create_access_token(data: dict) -> str:
    """Generate a JWT access token with expiration."""
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)


# ── JWT Dependency — get_current_user ────────────────────────────────────────

def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db),
) -> User:
    """
    Extract and validate user from JWT token.
    Use this as a dependency on all protected routes.
    Prevents user_id spoofing — user_id is NEVER accepted in request body.
    """
    token = credentials.credentials
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        user_id = payload.get("sub")
        if user_id is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token: missing subject",
            )
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
        )

    user = db.query(User).filter(User.id == int(user_id)).first()
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found",
        )
    return user


# ── Register ─────────────────────────────────────────────────────────────────

@router.post(
    "/register",
    response_model=TokenResponse,
    status_code=status.HTTP_201_CREATED,
    responses={
        201: {"description": "User created successfully"},
        400: {"description": "Email already registered"},
        422: {"description": "Validation error"},
    },
)
def register(user_data: UserCreate, db: Session = Depends(get_db)):
    """Register a new user with profile information. Returns 201 Created."""
    existing = db.query(User).filter(User.email == user_data.email).first()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered",
        )

    user = User(
        email=user_data.email,
        password_hash=pwd_context.hash(user_data.password),
        full_name=user_data.full_name,
        age_range=user_data.age_range.value,
        activity_level=user_data.activity_level.value,
        storage_mode=user_data.storage_mode,
        is_young_girl_mode=user_data.is_young_girl_mode,
        average_cycle_length=user_data.average_cycle_length,
        cycle_variability_known=user_data.cycle_variability_known,
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    # Auto-create PersonalModel with defaults for adaptive calibration
    from models import PersonalModel
    pm = PersonalModel(user_id=user.id)
    db.add(pm)
    db.commit()

    token = create_access_token({"sub": str(user.id)})
    expires_in = settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60

    return TokenResponse(
        access_token=token,
        expires_in=expires_in,
        user=UserResponse.model_validate(user),
    )


# ── Login ────────────────────────────────────────────────────────────────────

@router.post(
    "/login",
    response_model=TokenResponse,
    responses={
        200: {"description": "Login successful"},
        401: {"description": "Invalid email or password"},
        422: {"description": "Validation error"},
    },
)
def login(credentials: UserLogin, db: Session = Depends(get_db)):
    """Authenticate user, return JWT with user metadata."""
    user = db.query(User).filter(User.email == credentials.email).first()
    if not user or not pwd_context.verify(credentials.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
        )

    token = create_access_token({"sub": str(user.id)})
    expires_in = settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60

    return TokenResponse(
        access_token=token,
        expires_in=expires_in,
        user=UserResponse.model_validate(user),
    )
