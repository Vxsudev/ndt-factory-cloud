# D8C Incident — State Registry Proxy Bug (Discovered During Release Gate)

**Date:** 2026-07-02
**Discovered during:** touch-first-responsive-factory-ui-d8c release gate execution
**Severity:** Medium — silent, non-corrupting, but defeats state-machine auditability
**Status:** Fixed for `scripts/state-manager.sh` and the three proxies that call it

---

## What Happened

While advancing `touch-first-responsive-factory-ui-d8c` to `RELEASE_APPROVED`, the
real project registry at `ai/state_registry.json` did not show the new entry after
`bash scripts/state-manager.sh advance ... RELEASE_APPROVED` reported success and
`bash scripts/state-manager.sh get ...` correctly echoed back `RELEASE_APPROVED`.

## Root Cause

`scripts/state-manager.sh` (and `scripts/compile-spec.sh`, `scripts/generate-tasks.sh`,
`scripts/execution-supervisor.sh`, which call it internally) are one-line proxies:

```sh
exec bash vendor/engineering-os/scripts/state-manager.sh "$@"
```

None of them sourced `.engineering-os/adapter.config.sh` first. The vendored
`state-manager.sh` resolves the registry path as:

```sh
if [ -n "$EOS_STATE_REGISTRY" ]; then
  REGISTRY="$EOS_STATE_REGISTRY"        # project-correct path
else
  REGISTRY="$(cd "$(dirname "$0")/.." && pwd)/ai/state_registry.json"   # fallback
fi
```

Because `EOS_STATE_REGISTRY` was never exported, every invocation hit the fallback,
which resolves **relative to the vendored script's own location** (`$0`), not the
project root or CWD. `$0` inside the proxy's `exec` is
`vendor/engineering-os/scripts/state-manager.sh`, so `dirname/..` resolves to
`vendor/engineering-os/`, and the fallback silently wrote to
`vendor/engineering-os/ai/state_registry.json` — a copy of the vendored OS's own
template registry, not the project's.

`scripts/invariant-check.sh` (→ `vendor/engineering-os/scripts/invariant-engine.sh`)
is **not** affected: that script resolves its own config independently via
`./.engineering-os/adapter.config.sh` relative to the current working directory
(its own documented resolution order), not `$0`-relative. This is why
`INV-004: State registry is valid JSON` has always passed — it was validating the
correct, real file, which was always syntactically valid — it just never checked
whether prior features' entries were actually present.

## Blast Radius

Every state transition ever driven through `scripts/state-manager.sh` (directly or
via `compile-spec.sh` / `generate-tasks.sh` / `execution-supervisor.sh`) for the life
of this project has been writing to `vendor/engineering-os/ai/state_registry.json`
instead of `ai/state_registry.json`. That vendor-tree shadow file shows the accurate
history:

```
docker-stack-scaffold          TASK_GRAPH_LOCKED
mock-data-contract              RELEASE_APPROVED
backend-state-behavior          RELEASE_APPROVED
factory-flow-board-ui           RELEASE_APPROVED
persistence-postgres            RELEASE_APPROVED
factory-review-hardening        EXECUTION_ACTIVE
light-mode-readability-d8a      TASK_GRAPH_LOCKED
material-theme-readability-d8b  EXECUTION_ACTIVE
```

The real `ai/state_registry.json` instead shows only 4 entries, all
`RELEASE_APPROVED`, evidently hand-written as part of each phase's own
"update ai/state_registry.json" documentation task step (e.g.
`material-theme-readability-d8b-004.md`'s description explicitly says "Update
ai/state_registry.json: add material-theme-readability-d8b RELEASE_APPROVED" —
a manual doc-edit instruction, not a script invocation) rather than being written by
the state machine itself. This is why the discrepancy went unnoticed: the manual
doc-update steps happened to keep the real file plausible-looking, while the actual
automated state machine was quietly tracking a different, more complete truth in the
vendor tree.

No data was corrupted or lost — the vendor-tree shadow file is a complete and
accurate record of every real transition. This is a bookkeeping-location bug, not a
data-integrity bug.

## Fix Applied (This Session, D8C)

Added one line to each of the four local proxies, sourcing the adapter config before
exec'ing into the vendored script, so `EOS_STATE_REGISTRY` is correctly exported and
the vendored script's primary (correct) resolution path is used instead of ever
reaching the `$0`-relative fallback:

```sh
[ -f .engineering-os/adapter.config.sh ] && source .engineering-os/adapter.config.sh
exec bash vendor/engineering-os/scripts/<name>.sh "$@"
```

Files changed: `scripts/state-manager.sh`, `scripts/compile-spec.sh`,
`scripts/generate-tasks.sh`, `scripts/execution-supervisor.sh`. No change was made to
`vendor/engineering-os/` (forbidden mutation surface) — the fix is entirely in the
local adapter/proxy layer, which is exactly where this project's OS-ENABLED mode
places responsibility for correct environment wiring.

Verified after fix: `source .engineering-os/adapter.config.sh; bash
scripts/state-manager.sh get touch-first-responsive-factory-ui-d8c` correctly reads
`ai/state_registry.json` (confirmed by the previously-registered feature keys not
being present there, as expected, versus the vendor shadow file where they are).

## Not Done (Recommended Follow-Up, Out of D8C Scope)

The real `ai/state_registry.json` was **not** backfilled with the accurate historical
entries from the vendor-tree shadow file (`docker-stack-scaffold`,
`mock-data-contract`, `backend-state-behavior`, `factory-flow-board-ui`,
`persistence-postgres`, `factory-review-hardening`, `light-mode-readability-d8a`,
`material-theme-readability-d8b`). Migrating/reconciling that history is a
judgment call outside D8C's declared scope (touch-first responsive UI) and is
recommended as an explicit follow-up directive so a human can decide whether to
backfill, and with what `updated_at` semantics (the vendor-tree timestamps are the
real historical ones and should likely be preserved if backfilled).

## D8C's Own State

With the proxy fixed, `touch-first-responsive-factory-ui-d8c` was advanced through
the full legitimate sequence (`RECON_READY → SPEC_LOCKED → TASK_GRAPH_LOCKED →
EXECUTION_ACTIVE → VERIFICATION_REQUIRED → RELEASE_APPROVED`) against the now-correct
`ai/state_registry.json`, replaying the transitions for real rather than
hand-editing the JSON — every one of those transitions corresponds to work that was
actually completed and verified in this session.
