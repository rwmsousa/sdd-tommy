# Gate 8: Security Scan (always)

Detect injection flaws, unsafe sinks, and leaked secrets in the changed files — **independent of SonarQube** (Gate 5 may legitimately SKIP; this gate never skips). The rules being enforced are defined in the `tommy-security-practices` skill — read it for the "why" and the secure alternatives.

## Step 1 — Grep heuristics (mandatory)

Run these searches over the changed files. Every hit must be triaged — fixed, or explicitly justified as a false positive in the report.

- **SQL injection** — queries built by string concatenation/interpolation:
  - `grep -rn -E "(SELECT|INSERT INTO|UPDATE|DELETE FROM)[^\"']*(\\\$\\{|\\\" *\\+|' *\\+|% s|f\\\")" <files>`
  - Any query assembled with `+`, template literals, or f-strings around user-controllable input is a finding; the fix is parameterized queries / the project's ORM binding.
- **XSS sinks**:
  - `grep -rn -E "dangerouslySetInnerHTML|innerHTML *=|outerHTML *=|document\\.write|v-html|insertAdjacentHTML" <files>`
- **Code/command execution sinks**:
  - `grep -rn -E "\\beval\\(|new Function\\(|child_process|execSync|os\\.system|subprocess\\..*shell *= *True" <files>`
- **Hardcoded secrets**:
  - `grep -rn -E "(api[_-]?key|secret|password|token|credential)\\s*[:=]\\s*['\\\"][A-Za-z0-9_\\-]{8,}" <files>` (exclude `.env.example`, test fixtures with obviously fake values)
- **LLM/prompt injection surface** (when the project integrates an LLM): user-controlled or retrieved content concatenated directly into prompt strings without delimiting/labeling — search prompt-building code for direct interpolation of request data.

Adapt the patterns to the project's language(s); the categories are mandatory, the exact regexes are a starting point.

## Step 2 — Semgrep (when available)

If `semgrep` is installed, run `semgrep --config auto --error <changed paths>` and triage its findings like Step 1 hits. If it is not installed or has no network access for rules, record that the step was skipped — **the grep heuristics of Step 1 remain mandatory either way** — and suggest `pip install semgrep` in the report.

## Pass criteria

Zero unresolved findings: every hit is either fixed or documented as a justified false positive. Hardcoded real secrets are never justifiable — they must be removed and rotated.
