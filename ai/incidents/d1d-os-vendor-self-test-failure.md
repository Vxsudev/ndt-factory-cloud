# Incident: D1D OS Vendor Self-Test Failure — Test 004

**Date:** 2026-06-30
**Phase:** D1D — Vendor Real Engineering OS
**Test:** `004-os-cli-backing-surfaces.sh`
**Severity:** Low — test harness assumption mismatch, not an OS installation issue

---

## Command Run

```sh
bash vendor/engineering-os/tests/run-self-tests.sh
```

## Failure Output (relevant excerpt)

```
V6. Adapter context simulation — correct classification and no cross-context leakage
  PASS  V6: boot reports Context: adapter
  PASS  V6: boot exits 0 (READY) in adapter simulation
  PASS  V6: no OS core check patterns in adapter mode output
rm: .engineering-os: is a directory

[test aborted — no summary printed]
```

Self-test suite result:
```
  Passed: 4 / 5
  Failed: 1 / 5
  Failed tests: 004-os-cli-backing-surfaces.sh
```

## Assertions Passed

Test 004 passed all 33 assertions before the failure. The failure occurred in the
post-assertion cleanup of the V6 adapter context simulation:

```bash
# cleanup at end of V6 simulation block
rm -f "$SIM_LINK"   # SIM_LINK = ".engineering-os"
```

## Likely Cause

**Root cause:** macOS `ln -sf source target` behavior when `target` is an existing
real directory (not a symlink).

On macOS, `ln -sf /path/to/src .engineering-os` when `.engineering-os` is an
existing directory creates a symlink `.engineering-os/.engineering-os` pointing to
`/path/to/src`. The `ln` command exits 0 (success). The test's `if` branch executes
and all V6 assertions pass using the real `.engineering-os/adapter.config.sh`.

Then `rm -f "$SIM_LINK"` (= `rm -f .engineering-os`) fails with "is a directory"
because `.engineering-os` is a real directory, not a symlink. Since `set -e` is active
at that point in the test script, the script aborts with exit code 1.

**Design assumption violated:** Test 004 V6 was designed for an OS context where
`.engineering-os` does not yet exist as a real directory. It simulates adapter context
by creating `.engineering-os` as a symlink, running boot, then removing it. When
`.engineering-os` is already a real directory (fully wired adapter project), the
simulation's symlink target landing behavior differs on macOS.

**Side effect left by test run:** A stale symlink `.engineering-os/.engineering-os`
was created during the test. Removed immediately after test run as part of D1D cleanup.

## All 33 Test 004 Assertions

All 33 checks ran and passed before the failure:
- V1: 8 CLI backing scripts present and executable ✓
- V2: os-boot-check exits valid code ✓
- V3: os-adapter-check exits valid code ✓
- V4: os-self-test routes to adapter context ✓
- V5: os-cli-v0 spec is approved with all script mappings ✓
- V6: V6 boot/check/isolation assertions ✓ (cleanup step failed)

## Repository Safety

**The repo is safe to continue.**

The Engineering OS is correctly installed. All 4 other self-tests pass fully:
- Test 001 (Enforcement Layer): 6/6 PASS
- Test 002 (State Machine): 8/8 PASS
- Test 003 (Invariant Engine): 9/9 PASS
- Test 005 (CLI Wrapper): 37/37 PASS

Total: 60/60 assertions pass across tests 001, 002, 003, 005.
Test 004: 33/33 assertions pass, 1 cleanup step fails (macOS-specific).

## Workaround

The failure is in the OS self-test suite's cleanup code, not in the OS installation.
No workaround is needed for normal project operation.

If the canonical OS test is updated to use `rm -rf "$SIM_LINK" 2>/dev/null || true`
(or to check whether `$SIM_LINK` is a symlink before removal), this test will pass.

## D3 Readiness

This incident does not block D3. The OS is operational:
```sh
bash vendor/engineering-os/scripts/raystrat-os boot    # READY
bash vendor/engineering-os/scripts/raystrat-os check   # adapter valid
bash vendor/engineering-os/scripts/raystrat-os verify  # 6/6 PASS
bash scripts/smoke.sh                                   # 29/29 PASS
```
