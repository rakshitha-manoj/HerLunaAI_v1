from fastapi import FastAPI
from app.db import engine, Base
from app.models import User, HealthProfile
from app.routers.profile_router import router as profile_router

app = FastAPI()

Base.metadata.create_all(bind=engine)

@app.get("/")
def root():
    return {"status": "HerLuna AI Backend Running"}
app.include_router(profile_router)
