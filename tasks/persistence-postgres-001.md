# Task: Add Postgres service, SQLAlchemy models, and Alembic migration

## Parent Spec
specs/persistence-postgres.md

## Phase
phase-persistence

## Status
complete

## Layer
database

## Description
Add Postgres to docker-compose.yml, create SQLAlchemy ORM models (db_models.py),
create Alembic configuration (alembic.ini, alembic/env.py, alembic/versions/001_initial),
and add required Python dependencies (sqlalchemy, alembic, psycopg[binary]) to requirements.txt.
This is the schema foundation that backend and seed tasks depend on.

## Acceptance Criteria
- [ ] docker-compose.yml has postgres:16 service (db: factory_cloud, user: factory_cloud, pw: factory_cloud_dev)
- [ ] backend service has DATABASE_URL env var and depends_on postgres
- [ ] postgres_data named volume declared
- [ ] backend/requirements.txt includes sqlalchemy, alembic, psycopg[binary]
- [ ] backend/app/db.py creates engine, SessionLocal, get_db dependency
- [ ] backend/app/db_models.py defines all 8 SQLAlchemy ORM models
- [ ] backend/alembic.ini exists with correct script_location
- [ ] backend/alembic/env.py imports db_models metadata for autogenerate
- [ ] backend/alembic/versions/001_initial_factory_cloud_schema.py creates all 8 tables
- [ ] .env.example updated with DATABASE_URL entry

## Files Likely Affected
- docker-compose.yml
- .env.example
- backend/requirements.txt
- backend/app/db.py (CREATE)
- backend/app/db_models.py (CREATE)
- backend/alembic.ini (CREATE)
- backend/alembic/env.py (CREATE)
- backend/alembic/versions/001_initial_factory_cloud_schema.py (CREATE)

## Blocked By
- none
