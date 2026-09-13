# Templates Reference

All file templates for the `new-task` skill.

---

## spec.md template

```markdown
# TASK-{NNN}: {Title}

**Status**: Draft
**Created**: {YYYY-MM-DD}
**Feature dir**: `docs/4-tasks/features/TASK-{NNN}-{slug}/`

## Objective
{One sentence: what this feature achieves and why it matters.}

## Scope

### In scope
- {explicit behavior included}
- {explicit behavior included}

### Out of scope
- {explicit exclusion}

## Acceptance criteria

```json
[
  {
    "id": "AC-001",
    "category": "functional",
    "description": "{Core user-facing behavior}",
    "steps": [
      "{Concrete action step 1}",
      "{Concrete action step 2}",
      "{Verify: expected outcome}"
    ],
    "passes": false
  },
  {
    "id": "AC-002",
    "category": "functional",
    "description": "{Main failure path}",
    "steps": [
      "{Setup: precondition}",
      "{Action}",
      "{Verify: expected error response}"
    ],
    "passes": false
  },
  {
    "id": "AC-003",
    "category": "security",
    "description": "{Security or integrity concern}",
    "steps": [
      "{Action that should be rejected or constrained}",
      "{Verify: system behaves safely}"
    ],
    "passes": false
  }
]
```

When the documentation impact matrix marks `ui` as `true`, add an extra integration AC with the
fixed id `AC-UI-UX`. Use concrete project-specific routes and element names, but keep the same
acceptance shape:

```json
{
  "id": "AC-UI-UX",
  "category": "integration",
  "description": "{resolved BROWSER_CAPABILITY} validates the UI/UX flow across desktop and mobile breakpoints with clean interactions and console state.",
  "steps": [
    "Open the affected route with {resolved BROWSER_CAPABILITY} at 1440x900 and verify layout, spacing, visibility, and overflow are correct.",
    "Switch to 375x812 and verify the responsive layout, navigation, and primary actions remain usable without clipping or overlap.",
    "Hover each relevant interactive element and verify the expected visual feedback or expanded state appears.",
    "Audit the browser console during the flow and verify there are zero JavaScript errors.",
    "Archive named screenshots for the desktop and mobile checks using deterministic names agreed in the implementation approach."
  ],
  "passes": false
}
```

## Notes
### Documentation impact
| Area | Impacted | Maintenance target |
|---|---:|---|
| requirements | {true/false} | `docs/1-requirements/project_overview.md`, `docs/1-requirements/requirements_analysis.md` |
| architecture | {true/false} | `docs/2-designs/architecture.md` |
| api | {true/false} | `docs/2-designs/api_contract.md` |
| db | {true/false} | `docs/2-designs/db_schema.md` |
| ui | {true/false} | `docs/2-designs/ui_prototype.md` |
| constraints | {true/false} | `docs/3-constraints/` |
| adr | {true/false} | `docs/3-constraints/adr/` |
| agent-runtime | {true/false} | `AGENTS.md`, `.codex/session-start.js`, `init.sh`, `init.ps1` |

### Approval-sensitive changes
- {breaking API / DB migration / dependency / architecture / runtime change, or "None"}
- New environment variables or config keys are listed here when no centralized configuration document exists.

### Explicit non-maintenance
- {Harness document that might look relevant but does not need maintenance, with reason}
```

---

## tasks.md template

```markdown
# TASK-{NNN}: Tasks

**Spec**: `spec.md`
**Status**: In Progress

## Key decisions
- {Technical decision 1}
- {Technical decision 2}
- {Technical decision 3}

## Progress

<!-- Harness documentation first when applicable, then contracts, implementation, and gates -->

- [ ] T1 — {If requirements impact: update `docs/1-requirements/project_overview.md` and/or `docs/1-requirements/requirements_analysis.md`} · covers: doc-maintenance
- [ ] T2 — {If architecture impact: update `docs/2-designs/architecture.md`} · covers: doc-maintenance, {AC ids if behavior-facing}
- [ ] T3 — {If API changes: update `docs/2-designs/api_contract.md`} · covers: {AC ids}
- [ ] T4 — {If DB/schema changes: update `docs/2-designs/db_schema.md` and migration draft} · covers: {AC ids}
- [ ] T5 — {If UI impact: update `docs/2-designs/ui_prototype.md`} · covers: doc-maintenance, {AC ids if behavior-facing}
- [ ] T6 — {If constraints impact: update `docs/3-constraints/` rules} · covers: doc-maintenance
- [ ] T7 — {If ADR impact: add ADR under `docs/3-constraints/adr/`} · covers: doc-maintenance
- [ ] T8 — {If agent-runtime impact: update root/submodule `AGENTS.md`, `.codex/session-start.js`, `init.sh`, or `init.ps1`} · covers: doc-maintenance
- [ ] T9 — {Data objects / types / schemas} · covers: {AC ids}
- [ ] T10 — {Core business logic} · covers: {AC ids}
- [ ] T11 — {Secondary logic / manager / repository / hook / composable concern} · covers: {AC ids}
- [ ] T12 — {API layer / UI layer / route integration} · covers: {AC ids}
- [ ] T13 — {Tests} · covers: {AC ids}
- [ ] T14 — {If `ui` is true: run {resolved BROWSER_CAPABILITY} acceptance for `AC-UI-UX`, including desktop `1440x900`, mobile `375x812`, hover checks, console audit, and named screenshot archival} · covers: AC-UI-UX
- [ ] T15 — Run `{resolved TEST_COMMAND}` — all tests must pass
- [ ] T16 — Verify ACs: update `passes` to `true` in spec.md for each passing criterion
- [ ] T17 — Run `{resolved LINT_COMMAND}` — no violations, or omit this gate when lint is not configured
- [ ] T18 — Update `docs/4-tasks/CURRENT_PLAN.md` — mark this task complete

## Dependencies
- Implementation tasks require any applicable documentation and contract tasks.
- API/UI integration requires core business logic and any relevant contract tasks.
- Test, AC verification, lint, and `CURRENT_PLAN.md` gates require implementation tasks to be complete.

## Blockers
<!-- Fill in if something is preventing progress -->
```

**Task generation rules**
- Omit documentation tasks for matrix entries that are false.
- If a matrix entry is true, include a matching maintenance task unless `spec.md` explicitly explains why no maintenance is required.
- Keep documentation and contract tasks before implementation tasks.
- If `ui` is true, generate `AC-UI-UX` in `spec.md` and include the dedicated resolved-browser
  verification task. Chrome MCP is the default unless the user selected another capability.
- Every non-gate task must reference AC IDs or use `covers: doc-maintenance`.
- API, DB, architecture, and UI documentation tasks that affect acceptance behavior should reference relevant AC IDs.
- Gate tasks are resolved-browser UI acceptance when required, test, AC verification, lint when configured, and `CURRENT_PLAN.md` update.
- Resolve test/lint commands from root `AGENTS.md`; omit unavailable gates instead of emitting placeholders.
- Before finishing, verify generated `spec.md` and `tasks.md` contain no unresolved placeholders such as `{{...}}`, `{AC ids}`, `{resolved TEST_COMMAND}`, `{resolved LINT_COMMAND}`, or `{resolved BROWSER_CAPABILITY}`.
- `CURRENT_PLAN.md` is updated by `new-task` during task creation and later updated again by the final housekeeping gate when the feature is complete.

---

## CURRENT_PLAN.md update rules

When updating `CURRENT_PLAN.md`, make the minimum necessary changes:

1. Set `## Active feature` to:
   ```markdown
   `docs/4-tasks/features/TASK-{NNN}-{slug}/`
   - spec.md ✅ Ready
   - tasks.md → Not started
   ```

2. Add the feature under `## Stages` in this format:
   ```markdown
   ### TASK-{NNN}: {Title}
   - [ ] Implementation ({N} tasks)
   ```

3. Do not modify existing completed items.
4. Do not reformat unrelated sections.
