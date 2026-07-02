from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app import data_loader, state_store
from app.db import get_db
from app.db_models import Event, FactoryUnit, Part
from app.models import (
    DataContractStatusResponse,
    EventRecord,
    FactoryUnitRecord,
    ModelRecipeRecord,
    OrderRecord,
    PartRecord,
    ReferenceStandardRecord,
    StageRecord,
    UserRecord,
)

router = APIRouter()


@router.get("/factory/data-contract/status", response_model=DataContractStatusResponse)
async def data_contract_status(db: Session = Depends(get_db)) -> DataContractStatusResponse:
    unit_count = db.query(FactoryUnit).count()
    return DataContractStatusResponse(
        status="ok",
        phase="D4_MOCK_DATA_CONTRACT",
        read_only=True,
        domain_logic_enabled=False,
        data_files_loaded=data_loader.loaded_files(),
        unit_count=unit_count,
        stage_count=len(data_loader.get_stages()),
    )


@router.get("/factory/stages", response_model=list[StageRecord])
async def list_stages() -> list[StageRecord]:
    return [StageRecord(**s) for s in data_loader.get_stages()]


@router.get("/factory/orders", response_model=list[OrderRecord])
async def list_orders() -> list[OrderRecord]:
    return [OrderRecord(**o) for o in data_loader.get_orders()]


@router.get("/factory/units", response_model=list[FactoryUnitRecord])
async def list_units(db: Session = Depends(get_db)) -> list[FactoryUnitRecord]:
    rows = db.query(FactoryUnit).all()
    return [FactoryUnitRecord(**state_store._unit_to_dict(row)) for row in rows]


@router.get("/factory/units/{unit_id}", response_model=FactoryUnitRecord)
async def get_unit(unit_id: str, db: Session = Depends(get_db)) -> FactoryUnitRecord:
    row = db.query(FactoryUnit).filter(FactoryUnit.unit_id == unit_id).first()
    if row is None:
        raise HTTPException(status_code=404, detail=f"Unit '{unit_id}' not found")
    return FactoryUnitRecord(**state_store._unit_to_dict(row))


@router.get("/factory/parts", response_model=list[PartRecord])
async def list_parts(db: Session = Depends(get_db)) -> list[PartRecord]:
    rows = db.query(Part).all()
    return [PartRecord(**state_store._part_to_dict(row)) for row in rows]


@router.get("/factory/users", response_model=list[UserRecord])
async def list_users() -> list[UserRecord]:
    return [UserRecord(**u) for u in data_loader.get_users()]


@router.get("/factory/model-recipes", response_model=list[ModelRecipeRecord])
async def list_model_recipes() -> list[ModelRecipeRecord]:
    return [ModelRecipeRecord(**m) for m in data_loader.get_model_recipes()]


@router.get("/factory/reference-standards", response_model=list[ReferenceStandardRecord])
async def list_reference_standards() -> list[ReferenceStandardRecord]:
    return [ReferenceStandardRecord(**r) for r in data_loader.get_reference_standards()]


@router.get("/factory/events", response_model=list[EventRecord])
async def list_events(db: Session = Depends(get_db)) -> list[EventRecord]:
    rows = db.query(Event).order_by(Event.id).all()
    return [EventRecord(**state_store._event_to_dict(row)) for row in rows]
