import json
import os
from pathlib import Path
from typing import Any

# DATA_DIR is set via environment variable in Docker (DATA_DIR=/app/data).
# For local runs outside Docker, defaults to the data/ directory at repo root.
_DEFAULT_DATA_DIR = Path(__file__).resolve().parents[2] / "data"
DATA_DIR = Path(os.environ.get("DATA_DIR", str(_DEFAULT_DATA_DIR)))


def _load(filename: str) -> Any:
    path = DATA_DIR / filename
    with open(path, encoding="utf-8") as f:
        return json.load(f)


_cache: dict[str, Any] = {}


def _cached(filename: str) -> Any:
    if filename not in _cache:
        _cache[filename] = _load(filename)
    return _cache[filename]


def get_stages() -> list[dict]:
    return _cached("stages.json")["stages"]


def get_orders() -> list[dict]:
    return _cached("orders.json")["orders"]


def get_factory_units() -> list[dict]:
    return _cached("factory_units.json")["factory_units"]


def get_parts() -> list[dict]:
    return _cached("parts.json")["parts"]


def get_users() -> list[dict]:
    return _cached("users.json")["users"]


def get_model_recipes() -> list[dict]:
    return _cached("model_recipes.json")["model_recipes"]


def get_reference_standards() -> list[dict]:
    return _cached("reference_standards.json")["reference_standards"]


def get_events() -> list[dict]:
    return _cached("events.json")["events"]


def loaded_files() -> list[str]:
    files = [
        "stages.json",
        "orders.json",
        "factory_units.json",
        "parts.json",
        "users.json",
        "model_recipes.json",
        "reference_standards.json",
        "events.json",
    ]
    return [f for f in files if (DATA_DIR / f).exists()]
