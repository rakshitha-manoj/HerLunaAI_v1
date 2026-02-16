from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db import get_db
from app.models.user import User

router = APIRouter(prefix="/auth", tags=["Auth"])

@router.post("/email")
def login_with_email(payload: dict, db: Session = Depends(get_db)):
    email = payload.get("email")

    if not email:
        raise HTTPException(status_code=400, detail="Email required")

    user = db.query(User).filter(User.email == email).first()

    if user:
        return {"user_id": str(user.id), "is_new": False}

    return {"user_id": None, "is_new": True}
