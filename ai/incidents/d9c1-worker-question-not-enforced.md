# Incident: Worker's Blocking Question Was Not Enforced by the Supervisor

**Date:** 2026-07-11
**Phase:** D9C-1 — Variant Review Shell
**Task:** `tasks/d9c-1-variant-review-shell-002.md` (verification layer)
**Severity:** Low for this capability (verification passed on its merits regardless) —
Medium as a standing governance gap in the self-running pipeline.

---

## What happened

During the D9C-1 execution run, the headless worker for the verification-layer task
correctly followed the project's own hard rule (both the global and project `CLAUDE.md`:
"if OS files are missing, STOP and report — do not proceed") and identified a genuine
gap: its own system prompt instructs it to "Follow: `ai/execution-orchestrator.md`", but
that file does not exist at that path in the live `ai/` directory — it exists only at
`vendor/engineering-os/core-docs/execution-orchestrator.md` (the real vendored copy) and,
separately, as a quarantined stub under `_archive/invented-os-bootstrap-d1c/ai/` (per
`docs/d1c-invented-os-cleanup.md`). It also flagged that `PROJECT_BOOTSTRAP.md` at the
repo root is stale ("D3 not started, no application code exists yet" — the repo is
actually well past D9C with a live stack).

The worker's final message asked a clarifying question ("how would you like me to
proceed?") instead of declaring the task done, and then exited normally (exit code 0),
since its instruction was simply "when implementation is complete, exit" — nothing in its
prompt distinguishes "I finished" from "I'm stopping to ask a question" at the process
level.

`scripts/execution-supervisor.sh`'s `execute_task()` only checks the subprocess's **exit
code**, not the semantic content of its final message. Because the worker exited 0, the
supervisor treated the task as executed and proceeded straight into that task's
verification gate — with no mechanism to actually pause and surface the worker's question
to a human. The verification gate happened to pass anyway (the task's substance — running
the existing 001–011 corpus and confirming file diffs — had already been completed by the
worker before it hit the objection), so the pipeline completed and reached
`RELEASE_APPROVED` on the real merits of the work. But this was incidental, not because
the mechanism enforced a pause.

## Why this matters

This is the exact risk already flagged in `ai/recon/d9c1-variant-review-shell.md` §1
before this capability began: "spawning an additional, fully permission-bypassed Claude
instance per task, autonomously... with no human checkpoint in between." That risk
surfaced in practice on this very run — a worker tried to stop and ask, and the
automation did not actually stop.

## Root cause

Two independent, small gaps:

1. `vendor/engineering-os/scripts/execution-supervisor.sh`'s worker prompt (inside
   `execute_task()`) hardcodes `ai/execution-orchestrator.md` as a path for the worker to
   follow, but the adapter's actual layout keeps that doc under
   `vendor/engineering-os/core-docs/` rather than mirroring it into `ai/`. This is a
   vendor-script issue — out of scope to patch here (`vendor/**` is a forbidden mutation
   surface for D9C per `ai/recon/d9c0-variant-review-shell-preflight-scope-lock.md` §6).
2. The same script's `execute_task()` has no way to distinguish "worker completed the
   task" from "worker is blocked and asking a question" — both look identical (clean
   exit) to the supervisor's `$claude_exit` check. This is also a vendor-script
   characteristic, not something a per-capability spec or task file can fix.

## Impact on D9C-1

None — verified independently. The actual `d9c-1-variant-review-shell` deliverable was
confirmed correct via direct manual inspection (component source review) and live
browser verification (Playwright: `/` unchanged, `/#/variants` shell renders and switches
correctly), independent of what task 002's worker did or didn't confirm on its own. See
`ai/engineering-journal.md`'s D9C-1 addendum for the full verification record.

## Recommendation (not actioned here — out of D9C-1's declared scope)

- Either mirror the real core-docs the worker prompt references into `ai/` (a documented,
  intentional adapter decision), or change the worker prompt's paths in
  `vendor/engineering-os/scripts/execution-supervisor.sh` to point at
  `vendor/engineering-os/core-docs/*` directly. Either requires an explicit directive
  since it touches `vendor/**`.
- Consider having the supervisor grep the worker's final output for a question mark or an
  explicit "BLOCKED:"/"QUESTION:" marker and halt the pipeline (exit non-zero, leave task
  `in-progress` rather than advancing) instead of only trusting the process exit code.
  This is a meaningful hardening of the "self-running system" the recon flagged as
  consequential — worth its own explicitly-directed node, not a silent fix bundled into
  an unrelated capability.
