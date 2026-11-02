# Tommy Bug Report: [BUG TITLE]

**Bug ID**: `[###-short-name]`
**Branch**: `fix/[###-short-name]`
**Created**: [DATE]
**Status**: Assessing | Fix approved | Fixing | Verified | Partial | Failed
**Severity**: Critical | High | Medium | Low
**Related spec**: [`.tommy/specs/[###-feature]/spec.md` or "none"]
**Input**: User description: "[ORIGINAL_BUG_DESCRIPTION]"

## 1. Assessment *(mandatory — filled before any code change)*

### Symptom

- **Expected behavior**: [What should happen — cite the spec criterion (FR-/SC-/AC) when one exists]
- **Actual behavior**: [What happens instead — error messages, wrong output, screenshots/log excerpts]
- **Scope of impact**: [Who/what is affected, frequency, data at risk]

### Reproduction

1. [Step 1]
2. [Step 2]
3. [Observed result]

**Reproduced locally**: Yes / No — [command or test that reproduces it]

### Root Cause

- **Location**: `[path/to/file.ext]` — `[function/method]`
- **Cause**: [The actual defect, backed by evidence (code path, data, log) — not a hypothesis presented as fact]
- **Why it was not caught**: [Missing test, untested edge case, spec gap, regression from change X]

### Classification

- [ ] **Bug** — the system contradicts an existing requirement or obvious expected behavior → continue with this flow.
- [ ] **Spec gap** — the behavior was never specified; the "fix" is new scope → stop and use the Specify phase instead.

### Fix Approach *(confirmed with the user before Fixing)*

- **Change**: [Minimal change that removes the root cause]
- **Files**: `[path/to/file.ext]`, `[path/to/test.ext]`
- **Regression test**: [Test that fails today and passes after the fix — name and location]
- **Out of scope**: [Related issues noticed but deliberately not touched]

## 2. Fix *(filled by codegen)*

- **Files changed**: [list]
- **Regression test added**: [path — confirmed failing before the fix, passing after]
- **Quality gate**: [link to `quality-report.md` in this folder]

## 3. Verification *(mandatory)*

| Check | Result | Evidence |
| --- | --- | --- |
| Original reproduction steps no longer reproduce the symptom | PASS/FAIL | [command/output] |
| Regression test fails without the fix and passes with it | PASS/FAIL | [test name] |
| Related test suite passes | PASS/FAIL | [suite/command] |
| No unrequested changes outside the fix approach | PASS/FAIL | [diff summary] |

**Verdict**: `verified` (all checks pass) | `partial` (symptom gone but a check failed or a related case remains) | `failed` (symptom still reproduces)

## Notes

- [Anything the user should know — follow-ups, related bugs, spec updates suggested]
