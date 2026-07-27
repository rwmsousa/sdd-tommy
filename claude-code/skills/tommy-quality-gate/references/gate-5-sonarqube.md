# Gate 5: SonarQube Analysis (conditional)

**Applies when**: `sonar-project.properties` exists in the project root. Otherwise record SKIP.

## Steps

1. Run `.tommy/scripts/quality/sonar-run.sh --json`.
2. The script reports **SKIP** (a valid, non-blocking outcome) when any prerequisite is missing: no `sonar-project.properties`, no server configured (`sonar.host.url` or `SONAR_HOST_URL`), no `SONAR_TOKEN`, or no scanner installed. A properties file without a reachable server is a SKIP, never a FAIL.
3. When the analysis runs, review the **new** issues it reports on the changed files:
   - **Bugs**: fix immediately — these are correctness issues.
   - **Vulnerabilities**: fix immediately — these are security issues.
   - **Code Smells**: fix unless they conflict with an intentional design decision (document the rationale).
   - **Security Hotspots**: review and address, or mark as safe with justification.

## Pass criteria

Zero new bugs. Zero new vulnerabilities. Zero new code smells (or documented rationale for accepted smells). SKIP with reason counts as non-blocking.
