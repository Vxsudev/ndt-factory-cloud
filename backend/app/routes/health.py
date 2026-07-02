from fastapi import APIRouter
from app.models import HealthResponse

router = APIRouter()


@router.get("/health", response_model=HealthResponse)
async def health() -> HealthResponse:
    return HealthResponse(
        status="ok",
        service="ndt-factory-cloud-backend",
        phase="D3_STACK_SCAFFOLD",
    )
