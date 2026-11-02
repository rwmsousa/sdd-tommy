# Gate 6: Checklist Verification (always last)

Perform the final review against the project's quality checklist, after every other gate has passed.

## Steps

1. Read the checklist created by the codegen workflow (`.tommy/specs/[SPEC_FOLDER]/checklists/[CHECKLIST_FILE].md`, or `.tommy/bugs/[BUG_ID]/checklists/[CHECKLIST_FILE].md` for a bugfix — plan-only items are marked N/A there).
2. Evaluate every item in the checklist against the generated code.
3. Confirm the outcomes of the other gates are reflected: any SKIP recorded with reason, any accepted trade-off documented.
4. Mark each item as passed or failed — failed items must be fixed and their gates re-run.

## Pass criteria

All checklist items pass.
