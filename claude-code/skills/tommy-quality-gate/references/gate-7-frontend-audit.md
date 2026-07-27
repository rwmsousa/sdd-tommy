# Gate 7: Frontend Audit — Accessibility & Performance (conditional)

**Applies when**: `.tommy/codebase/stack.md` indicates a frontend UI (React, Vue, Angular, Svelte, Next.js, Nuxt, plain HTML/CSS, or similar) **and** the change touches UI code. Otherwise record SKIP.

This gate verifies the *result* of the accessibility and performance guidance that `tommy-ux-practices` applies at design time.

## Prerequisites

- A way to run the app locally: check the "Run & Serve" section of `.tommy/codebase/structure.md` (dev server command, port, ready signal). If it is missing, fill it via `tommy-project-research` before running this gate.
- Start the dev server with the documented command and wait until it responds before auditing. Stop it when the audit ends.

## Accessibility (axe)

1. Preferred: if the Playwright MCP is configured for the project (see `.tommy/mcp.json`), navigate to the changed pages/flows and run an axe scan on each.
2. Fallback: `npx @axe-core/cli <url-of-changed-page>` for each affected route.
3. Triage violations: **critical/serious** must be fixed; **moderate/minor** fixed or justified in the report.
4. Remember automated scans cover only ~30-40% of WCAG — for keyboard navigation, focus order, and screen-reader semantics, verify against the Accessibility Baseline in `tommy-ux-practices`.

## Performance — lab Core Web Vitals (Lighthouse)

1. If the project has Lighthouse CI configured (`lighthouserc.*`), run `npx lhci autorun`.
2. Otherwise run `npx lighthouse <url> --output=json --quiet --chrome-flags="--headless"` for each changed route.
3. Default lab thresholds (adjust only if the project documents its own):
   - **LCP** <= 2.5s · **CLS** <= 0.1 · **TBT** <= 200ms (lab proxy for INP).
4. If Lighthouse/Chrome is unavailable in the environment, record SKIP for the performance half with the exact command the user can run.

**PageSpeed Insights API** requires a public URL — it is a **post-deploy** verification, never a local gate. Mention it in the report as a follow-up when relevant.

## Pass criteria

Zero unresolved critical/serious accessibility violations. Lab CWV within thresholds (or documented, accepted rationale). SKIP with reason (not a frontend change, tooling unavailable) is non-blocking but must be recorded.
