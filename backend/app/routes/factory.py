from fastapi import APIRouter
from app.models import ScaffoldStatusResponse

router = APIRouter()


@router.get("/factory/scaffold-status", response_model=ScaffoldStatusResponse)
async def scaffold_status() -> ScaffoldStatusResponse:
    return ScaffoldStatusResponse(
        status="scaffold_only",
        domain_logic_enabled=False,
        stage_model_locked=True,
        current_phase="D3_STACK_SCAFFOLD",
    )
