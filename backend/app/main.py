from fastapi import FastAPI
from app.db import engine, Base
from app.models import User, HealthProfile
from app.routers.profile_router import router as profile_router
from app.routers.cycle_log_router import router as cycle_log_router
from app.routers import auth_router

app = FastAPI()

Base.metadata.create_all(bind=engine)

@app.get("/")
def root():
    return {"status": "HerLuna AI Backend Running"}
app.include_router(profile_router)
app.include_router(cycle_log_router)
app.include_router(auth_router.router)
