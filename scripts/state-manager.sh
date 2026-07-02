#!/usr/bin/env bash
set -e
# Source the adapter config so EOS_STATE_REGISTRY resolves to the real
# project registry (ai/state_registry.json). Without this, the vendored
# script's fallback resolves $0-relative to vendor/engineering-os/ai/,
# silently writing state to the wrong file. See ai/incidents/
# d8c-state-registry-proxy-bug.md.
[ -f .engineering-os/adapter.config.sh ] && source .engineering-os/adapter.config.sh
exec bash vendor/engineering-os/scripts/state-manager.sh "$@"
