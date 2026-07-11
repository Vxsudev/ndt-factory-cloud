# D9C-1 — Variant Review Shell: Recon (STOP — Conflicts Found)

**Feature slug (as given):** `d9c-1-variant-review-shell`
**Mode:** RECON ONLY, per the directive's own "RECON OBJECTIVE" section, which requires validating branch/runtime/migrations/prior work/conflicting artifacts and says explicitly: **"Conflict: STOP."** Real, concrete conflicts were found (below). Per the directive's own stated rule, execution stops here and reports back rather than proceeding into the implementation pipeline. No frontend, backend, spec, task, or state-registry file was modified to produce this report.

---

## 0. What was actually checked

| Directive requirement | Command run | Result |
|---|---|---|
| Repository mode | `ls vendor/engineering-os/`, `ls .engineering-os/` | Both present — OS-ENABLED, confirmed real (same as D9C-0) |
| Git integrity | `git status --short`, `git diff --name-only`, `git diff --cached` | Clean tree except the 5 expected D9A/D9B/D9C-0 recon artifacts + transcript; no product file modified |
| Adapter integrity | `bash vendor/engineering-os/scripts/os-adapter-check.sh` | 12/12 PASS, "Status: adapter valid" (re-run, same result as D9C-0) |
| Invariant layer | `bash scripts/invariant-check.sh` | 6/6 PASS |
| State machine — required state `TASK_GRAPH_LOCKED` for this feature | `cat ai/state_registry.json`, grep for `d9c` | **No entry exists for `d9c-1-variant-review-shell` (or any `d9c*` key) — state is absent/unknown, not `TASK_GRAPH_LOCKED`.** |
| Verification scripts the directive says must pass | `ls scripts/verification/`, existence check for each named file | **`001-typecheck.sh`, `002-lint.sh`, `003-build.sh`, `004-invariants.sh`, `012-d9c1-variant-review-shell.sh` — all 5 MISSING.** The real `scripts/verification/001-011` are entirely different scripts (docker-compose-config, backend-health, frontend-reachable, data-contract-api, etc. — see D9A §15) already in active use. |
| Spec pipeline scripts | Read `vendor/engineering-os/scripts/compile-spec.sh`, `generate-tasks.sh`, `execution-supervisor.sh` in full | See §1 below — these are real, working scripts, not stubs, but they require inputs that don't exist yet. |
| Prior/conflicting artifacts | Read `ai/recon/d9b-three-functional-actor-first-ui-variants.md` | See §2 — the directive's 4-tab selector doesn't match D9B's settled 3-variant design. |

---

## 1. What the pipeline scripts actually do (read in full, not assumed)

This matters because the directive instructs running these as literal steps, and their real behavior is more consequential than the directive's prose implies:

- **`compile-spec.sh <spec-file>`**: requires a real file at `<spec-file>` with a `## Status` field equal to `approved` and a `## Phase` field matching a file in `specs/phases/` (currently: `phase-1.md`, `phase-backend.md`, `phase-demo-readiness.md`, `phase-persistence.md`, `phase-ui.md`). **No spec file exists yet for this feature** (`find specs -iname "*d9c*"` → empty). Running this now would fail immediately with `ERROR: Spec file not found`. It also calls `scripts/state-manager.sh require <feature> RECON_READY` before advancing to `SPEC_LOCKED` — i.e. it additionally expects the feature to already be at `RECON_READY` in the state registry, which it also is not (no entry exists at all).
- **`generate-tasks.sh`**: refuses to run unless invoked *by* `compile-spec.sh` (it checks for a one-time token file, `/tmp/.os-compile-token`, written by `compile-spec.sh` and deleted on use). Cannot be run standalone or ahead of a real, approved spec.
- **`execution-supervisor.sh <feature>`**: requires task files already generated at `tasks/<feature>-*.md`; requires state `TASK_GRAPH_LOCKED`; runs a pre-execution invariant gate; then, for **each task**, it invokes a **separate, non-interactive Claude Code subprocess** via `claude --dangerously-skip-permissions -p "..."` to perform the actual implementation, restricted by prompt (not by OS-level sandboxing beyond a post-hoc control-plane hash check) from touching `tasks/`, `scripts/`, or `ai/`. It then re-runs verification (falling back to the **full existing `scripts/verification/*.sh` corpus**, since no spec-declared `## Verification Scripts` list exists yet), and on success appends a journal entry and advances state all the way to `RELEASE_APPROVED` automatically, with no human checkpoint in between.

**This is real, working automation, not a fictional stub** — but it is a meaningfully bigger and more consequential action than "Claude Code writes some frontend files": it means spawning an additional, fully permission-bypassed Claude instance per task, autonomously, ending in an automatic state-registry write and journal append, with no pause for review between spec → tasks → execution → release. That is worth the operator's explicit, informed go-ahead as its own decision — distinct from having already authorized "execute the D9C-1 directive" — since the directive's prose doesn't describe *that specific mechanism* (headless sub-agent, `--dangerously-skip-permissions`, auto-advance to `RELEASE_APPROVED`) even though the script it names does exactly that.

---

## 2. Conflicting artifact found: selector naming/structure vs. D9B

The directive's **Implementation Objective** specifies a 4-item flat selector: **Current / Assembler View / Floor Manager / Operations Center**.

D9B (`ai/recon/d9b-three-functional-actor-first-ui-variants.md`, the settled, operator-reviewed design) specifies a different structure: **three functionally distinct variants** — **Attention-First**, **Current-Unit Workflow-First**, and **Dashboard/Command-Center** — **each of which contains both an Assembler view and a Floor Manager view** (i.e. 3 variants × 2 actor sub-views, not 4 flat top-level tabs mixing variant-level and actor-level concepts).

Concretely, this directive's selector conflates two different axes that D9B kept separate:
- "Assembler View" and "Floor Manager" (per this directive) are **actor-level** concepts — but in D9B, every one of the 3 variants has both.
- "Operations Center" (per this directive) resembles D9B's **Variant C — Dashboard/Command-Center** in name only, but as a single flat 4th tab it's unclear whether it's meant to replace the whole 3-variant idea or sit alongside it, and it doesn't carry Variant A or Variant B's names/content at all.

This is a real, structural discrepancy, not a naming nitpick: building exactly what this directive's Implementation Objective literally describes would produce a UI that does not let the client compare 3 functional approaches side-by-side (D9B's actual purpose, confirmed by the transcript: *"let's stick to three options... show it to Vijay and pick"*) — it would instead produce one baseline plus three oddly-scoped, only-partially-labeled panes.

---

## 3. Conclusion — Conflict: STOP (per the directive's own rule)

Per the directive's own "RECON OBJECTIVE" section ("Conflict: STOP") and its own "STATE MACHINE GATE" section ("Invalid state: STOP" for anything other than `TASK_GRAPH_LOCKED`, including "unknown"), this recon stops here rather than proceeding into spec-compile / task-generation / execution-supervisor. Concretely, three independent things would each already block a literal run of the stated pipeline:

1. **State gate fails as written** — no state entry exists for this feature (must be `TASK_GRAPH_LOCKED`; is actually absent/unknown).
2. **Spec precondition fails as written** — no `specs/*.md` file exists for this feature yet, so `compile-spec.sh` would exit 1 immediately; there's also no matching `specs/phases/` tag decided yet.
3. **Selector content conflicts with the operator's own settled D9B design** (§2) — building literally what this directive describes would not match what D9B and the transcript actually called for.

None of these are objections to the operator's authority to proceed — they are concrete, verified facts about the current repository state and the real behavior of the scripts this directive names, surfaced so the next step can be chosen deliberately rather than by an automation pipeline hitting a precondition failure or silently building the wrong selector shape.

---

## 4. Options for how to proceed (no option has been chosen or acted on)

- **(a) Full ceremony, as literally written**: I write a real `specs/d9c-1-variant-review-shell.md` (with a `## Phase` tag — either reusing `phase-ui` or adding a new phase file), set it to `## Status: approved`, then actually run `compile-spec.sh` → `generate-tasks.sh` → `execution-supervisor.sh`, which will spawn a headless `claude --dangerously-skip-permissions` subprocess per generated task and auto-advance state to `RELEASE_APPROVED` on success with no pause in between. Requires deciding the selector content question (§2) first, since the spec is what the generated tasks (and thus the sub-agent's instructions) will be built from.
- **(b) Direct implementation**: I build the shell myself, in this session, honoring every stated architecture invariant (current console behaviorally identical, presentation-only switching, no backend/schema/API/data/verification-script changes, no auth) — without invoking the spec/task/execution-supervisor ceremony or spawning a sub-agent. This still fully respects D9C-0's forbidden/allowed surface list and D9B's design; it just skips the self-running pipeline mechanism in favor of direct, reviewable edits in this conversation.
- **(c) Resolve the naming conflict first**, either way: confirm whether "Operations Center" replaces Variant C or is a mistake for it, and confirm whether "Assembler View"/"Floor Manager" as flat top-level tabs (this directive) or as sub-views under each of 3 variants (D9B) is what's actually wanted, before either (a) or (b) proceeds.

---

**Files read for this recon:** `vendor/engineering-os/scripts/{compile-spec.sh, generate-tasks.sh, execution-supervisor.sh}` (in full), `ai/state_registry.json`, `ai/coding-patterns.md` (headings), `scripts/verification/` directory listing, `specs/` and `specs/phases/` directory listings, `ai/recon/d9b-three-functional-actor-first-ui-variants.md`, plus the D9C-0 preflight artifact for continuity.

**D9C-1 STATUS — BLOCKED (recon complete, conflicts found, stopped per directive's own rule) | IMPLEMENTATION — NONE | NEXT — OPERATOR DECISION ON §4**
