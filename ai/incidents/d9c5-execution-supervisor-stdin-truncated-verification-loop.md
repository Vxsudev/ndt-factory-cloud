# Incident — D9C-5: execution-supervisor.sh's verification gate silently only runs 7 of 13 scripts

## Summary

While verifying D9C-5, task 002's worker found `scripts/verification/013-d9c-4-attention-first-actor-views.sh`
now fails (17/18, later 18/18 after the fix below) because it hardcoded an assumption
— `variantB` always stays on `VariantPlaceholderPane` — that D9C-5's own approved spec
legitimately invalidates. That finding is correct and is handled below. But
investigating *why the automated pipeline's own final Verification Gate never caught
this* surfaced a second, more serious, previously-undiscovered defect in
`vendor/engineering-os/scripts/execution-supervisor.sh` itself.

## Root Cause

`execution-supervisor.sh`'s verification loop (both the per-task gate and the final
Verification Gate) selects scripts via `list_full_corpus()` (a plain `ls
scripts/verification/*.sh | sort`, confirmed by direct execution to correctly return
all 13 current scripts) and iterates them with:

```bash
while IFS= read -r vscript; do
  ...
  bash "$vscript" > /dev/null 2>&1
  ...
done <<< "$VSCRIPTS"
```

`$VSCRIPTS` (all 13 script paths) is fed to the loop via a here-string, which becomes
the **stdin of the entire while-loop**, including every command run inside the loop
body — `bash "$vscript"` is invoked with no stdin redirection of its own, so it
inherits that same stdin stream.

`scripts/verification/007-persistence-postgres.sh` runs three `docker compose exec -T
postgres psql ...` commands. `-T` disables pseudo-TTY allocation but does **not**
detach stdin — the exec'd `psql` process still inherits the parent shell's stdin,
which at that point is the *remaining, unconsumed lines* of the outer while loop's
here-string (i.e., the paths of scripts 008 through 013). This drains those lines from
the stream. The result, confirmed by inspecting the actual execution-supervisor.sh
transcripts for this run (and, in retrospect, every prior D9C-1 through D9C-5 run):
**the loop announces "DELTA MODE: fallback (13 script(s))" but only ever prints
"Running: ..." for scripts 001 through 007**, then exits cleanly (no error — `while
read` just sees EOF) and reports `Verification: pass` without having executed
`008`–`013` at all, this run or apparently any prior run in this session.

## Consequence

**Every `RELEASE_APPROVED` state reached by the automated pipeline in this entire
session (D9C-1 through D9C-5) was only ever automatically gated on scripts `001`–`007`
by `execution-supervisor.sh` itself** — never on `008`–`013`, regardless of what the
printed script count claimed. This did not produce an undetected regression in this
session only because I independently re-ran the full `001`–`0NN` corpus manually after
every single node, every time, as part of not trusting the pipeline's self-report
alone (an already-established practice, not a new one adopted because of this
incident) — that manual habit is what actually caught D9C-5's legitimate-but-breaking
change to script `013`, not the pipeline's own gate.

## Resolution

1. Fixed the actual, real problem the discovery led to: `scripts/verification/
   013-d9c-4-attention-first-actor-views.sh`'s `V10` check hardcoded `variantB` staying
   on `VariantPlaceholderPane`. Retired that half of the assertion (D9C-5 legitimately
   changes it), kept the still-valid half (`variantC`/Command-Center must remain a
   placeholder). Re-ran: 18/18 PASS.
2. Did **not** attempt to patch `vendor/engineering-os/scripts/execution-supervisor.sh`
   itself — it is vendored, centralized doctrine/runtime, not a repository-local file
   this session's scope covers modifying, and doing so was not requested or
   authorized. Documenting the defect here is the correct action; a vendor-layer fix is
   an operator decision, not mine to make unilaterally.
3. Continuing to manually re-run the full `001`–`0NN` verification corpus after every
   node remains the load-bearing safeguard against this gap — already established
   practice, now with a confirmed root cause for *why* it matters, not just a vague
   "don't trust the pipeline" heuristic.

## Process Implication

No change needed to this session's own conduct — the existing practice (manual,
independent full-corpus re-run after every automated pipeline execution, regardless of
its own "Verification: pass" self-report) already fully mitigates this gap and should
continue exactly as-is for every future D9C node. If the vendor
`execution-supervisor.sh` is ever revisited by the operator, the fix is straightforward:
redirect each inner `bash "$vscript"` call's stdin from `/dev/null` explicitly (e.g.
`bash "$vscript" < /dev/null > /dev/null 2>&1`) so no verification script can ever
consume the outer loop's remaining work queue.

## Relationship to Prior Incidents

Distinct from, but in the same family as,
`ai/incidents/d9c1-worker-question-not-enforced.md` (exit-code-only success gating) and
`ai/incidents/d9c3-verification-script-deliverable-skipped-by-worker.md` (missing
deliverable slipping through to `RELEASE_APPROVED`) — all three are instances of the
same underlying theme: the automated pipeline's own self-reported "pass"/"done"/
"Verified: true" signals are not sufficient evidence on their own and must be
independently, manually re-confirmed by the orchestrator before trusting a
`RELEASE_APPROVED` state. This incident supplies the most concrete, root-caused
evidence yet for why that standing practice is necessary.
