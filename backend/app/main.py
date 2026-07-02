from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.db import SessionLocal
from app.routes import actions, data_contract, factory, health
from app.seed import is_empty, seed
from app.settings import settings


@asynccontextmanager
async def lifespan(app: FastAPI):
    db = SessionLocal()
    try:
        if is_empty(db):
            seed(db)
    finally:
        db.close()
    yield


app = FastAPI(
    title="Factory Cloud v0",
    description="NDT Factory Cloud backend — D7 Persistence / Postgres",
    version="0.7.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.origins_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health.router)
app.include_router(factory.router)
app.include_router(data_contract.router)
app.include_router(actions.router)
