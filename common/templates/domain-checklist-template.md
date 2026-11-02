# Tommy Domain Checklist — [DOMAIN]: [FEATURE NAME]

**Purpose**: "Unit tests for the requirements" in the [DOMAIN] domain — each item tests whether the **spec is well written** (complete, clear, consistent, measurable) for this domain. It does **not** test whether code works.
**Created**: [DATE]
**Feature**: [spec.md](../spec.md)

> Ownership: generated and marked by the independent PM reviewer during the Specify phase. `[x]` means the reviewer verified the spec satisfies the item — never that something was implemented. The Prompt phase precondition gate requires every item here to be checked.

<!--
  How to write items (delete this comment in the generated file):
  - Phrase every item as a question about the SPEC TEXT, citing the spec section or ID it tests:
      ✅ "Is 'fast loading' quantified with a concrete target? [SC-002]"
      ✅ "Are error states defined for every user action that can fail? [US2, Edge Cases]"
      ✅ "Is the session-expiry behavior specified for an in-progress form? [FR-004]"
      ❌ "Verify the button works" / "Test that the API returns 200" (those test code, not requirements)
  - Group items by quality dimension: Completeness, Clarity, Consistency, Measurability, Coverage (edge/negative cases).
  - Number items globally: CHK001, CHK002, ...
  - 5-15 items per domain is usually enough; prefer high-signal items over exhaustive lists.
-->

## Completeness

- [ ] CHK001 [Question about a requirement that must exist for this domain] [Spec ref]

## Clarity

- [ ] CHK002 [Question about vague wording that must be made precise] [Spec ref]

## Consistency

- [ ] CHK003 [Question about requirements that must agree with each other] [Spec ref]

## Measurability

- [ ] CHK004 [Question about a criterion that must be objectively verifiable] [Spec ref]

## Coverage

- [ ] CHK005 [Question about an edge/negative/exception case that must be specified] [Spec ref]

## Notes

- [Reviewer notes]
