#!/usr/bin/env bash
set -e
# See ai/incidents/d8c-state-registry-proxy-bug.md — this proxy calls
# scripts/state-manager.sh internally; sourcing here too for defense in depth.
[ -f .engineering-os/adapter.config.sh ] && source .engineering-os/adapter.config.sh
exec bash vendor/engineering-os/scripts/execution-supervisor.sh "$@"
