# Incident — D9C-3: Verification-script deliverable was skipped by the worker, and the pipeline still reached RELEASE_APPROVED

## Summary

Task `d9c-3-current-baseline-shared-view-model-migration-001.md` (layer: frontend)
asked its headless worker to do two things: (A) migrate `FactoryFlowBoard.tsx` to
consume `useFactoryViewModel()`, and (B) create a new verification script,
`scripts/verification/012-d9c-3-current-shared-view-model.sh`. The spec's own
acceptance criteria listed the script's existence as a required condition for
`RELEASE_APPROVED`.

The worker completed Part A, but refused Part B, citing its own operating constraint:
"my session mandate explicitly says I may modify **application source code only**...
`scripts/` is off-limits." It reported this refusal in its final message, in enough
detail to be actionable, and correctly did not touch `tasks/`, `ai/`, or `scripts/`.

Task 002's worker (layer: verification) independently re-derived the same fact —
`scripts/verification/012-d9c-3-current-shared-view-model.sh` does not exist — and
explicitly wrote: "I'm leaving task 002 unfinished rather than marking it complete
with a known-failing check."

Despite this, `execute_task()` in `vendor/engineering-os/scripts/execution-supervisor.sh`
only checks subprocess exit code, not message content (the same gap already documented
in `ai/incidents/d9c1-worker-question-not-enforced.md`). Both workers exited 0. Both
tasks were marked `done`. The pipeline proceeded through the Invariant Gate and
Verification Gate (which only run the existing `001`–`011` corpus — the new `012`
script was never in that corpus because it didn't exist) and advanced
`d9c-3-current-baseline-shared-view-model-migration` all the way to
`RELEASE_APPROVED`, despite an explicitly-flagged, unmet acceptance criterion.

## Root Cause

Confirmed by reading `vendor/engineering-os/scripts/execution-supervisor.sh` directly
(lines ~174-212): every headless worker's dispatch prompt hardcodes
"Claude is a pure execution worker. It may only write to application source.
Control-plane files (tasks/, ai/, scripts/) are off-limits." This is a **universal**
constraint applied to every task regardless of its declared `## Layer`, not a
layer-specific policy. My own task-file design for D9C-3 asked a "frontend"-layer
worker to author a new file under `scripts/verification/` — something no worker,
under any layer, is ever permitted to do. The worker was correct to refuse; the task
file I wrote was structurally impossible to satisfy as written.

Compounding this: `execute_task()`'s exit-code-only success gate means a worker
explicitly reporting a failed/incomplete acceptance criterion in its final message
still counts as a successful task completion, so the missing deliverable was never
surfaced as a pipeline-level blocker — only visible to a human actually reading the
transcript.

## Resolution

Verified independently (not fabricated): `frontend/src/components/FactoryFlowBoard.tsx`
was migrated correctly and completely (Part A) — confirmed by direct read, matching
every acceptance criterion in `specs/d9c-3-current-baseline-shared-view-model-migration.md`.

Because Part B (the verification script) is a `scripts/`-tree artifact and therefore
categorically outside any headless worker's permitted write scope, I (the orchestrator,
not a pipeline worker) authored `scripts/verification/012-d9c-3-current-shared-view-model.sh`
directly, matching exactly the checks specified in task 001's Part B and confirmed
missing by task 002. Ran it: 8/8 PASS. Re-ran the full `001`–`012` corpus plus
`scripts/invariant-check.sh` fresh after adding it: all pass (see journal entry for
exact counts). Also performed independent live Playwright verification of the full
Current interaction surface (load, select, action+refresh, reset, theme toggle,
compact panes) and the `/#/variants` shell, beyond what any automated script checks.

State was already `RELEASE_APPROVED` by the time this gap was discovered (a fait
accompli in `ai/state_registry.json`); resetting and re-running the task graph would
have hit the identical wall (no task-graph-driven worker can ever create a `scripts/`
file), so it was not reset. The missing deliverable was created directly instead, and
this incident records the gap transparently rather than silently patching over it.

## Process Change For Future Capabilities

**Any spec/task that requires creating a new file under `scripts/` (most commonly a
new node-specific verification script) must NOT delegate that file's creation to a
task-graph worker, regardless of declared `## Layer`.** The orchestrator must author
it directly, the same way specs, recon artifacts, and task files themselves are
orchestrator-owned, not worker-owned. Future task files should scope worker-facing
"Files Likely Affected" to application source only, and route new `scripts/verification/*`
files through direct orchestrator action from the start — not discover this the hard
way per-capability.

## Relationship to Prior Incident

This is a second, more severe occurrence of the same underlying gap documented in
`ai/incidents/d9c1-worker-question-not-enforced.md` (exit-code-only success gating).
That incident involved a worker asking a clarifying question that happened not to
matter. This one involves a worker explicitly reporting a **failed acceptance
criterion** — a missing required file — and the pipeline still reaching
`RELEASE_APPROVED` regardless. The risk flagged as hypothetical in the first incident
is now confirmed to have real consequences: an operator who trusts the pipeline's own
`Verified: true` self-report without independently reading the transcript and checking
the file, as done here, would not have noticed `scripts/verification/012-*.sh` was
missing until some later capability needed it.
