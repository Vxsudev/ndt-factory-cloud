#!/usr/bin/env bash
set -euo pipefail

DB_HOST="${DB_HOST:-postgres}"
DB_PORT="${DB_PORT:-5432}"

echo "[entrypoint] Waiting for Postgres at $DB_HOST:$DB_PORT ..."
until pg_isready -h "$DB_HOST" -p "$DB_PORT" -q; do
  sleep 1
done
echo "[entrypoint] Postgres ready."

echo "[entrypoint] Running alembic upgrade head ..."
alembic upgrade head

echo "[entrypoint] Starting uvicorn ..."
exec uvicorn app.main:app --host 0.0.0.0 --port 8000
