# Task templates

Adapt these examples to the requirement. Remove unused sections and sample ACs/tasks; do not
copy a fixed count or manufacture layers, documents, approvals or tests to fill the template.
Use the project's language and existing conventions.

## spec.md

````markdown
# TASK-{NNN}: {Title}

**Status**: Draft
**Created**: {YYYY-MM-DD}
**Feature dir**: `docs/4-tasks/features/TASK-{NNN}-{slug}/`

## Objective
{User-visible outcome and reason}

## Scope
- In scope: {affected behavior}
- Out of scope: {explicit exclusions}

## Acceptance criteria
```json
[
  {
    "id": "AC-001",
    "category": "functional",
    "description": "{Required observable outcome}",
    "steps": ["{Action/precondition}", "{Expected result and evidence}"],
    "passes": false
  }
]
```

## Notes
- {Only material decisions, reuse, changed config keys and outstanding approvals}
- {Relevant validation commands, evidence to reuse, major cost and stopping conditions}

### Documentation impact
{For a small task, name affected documents or state none. Use a matrix only when useful or
required by the project: requirements, architecture, api, db, ui, constraints, adr,
agent-runtime. Mark changed facts and combine related maintenance; do not invent documents.}
````

Add failure, integrity, edge-case, security or performance ACs only when relevant. Use concrete
project actions and evidence rather than repeating checks under several AC IDs.

For UI changes use `AC-UI-UX`, category `integration`. It can be the only AC for a small fix.
Replace these example steps with the supported platform's actual checks:

```json
{
  "id": "AC-UI-UX",
  "category": "integration",
  "description": "{Affected UI behavior verified with the resolved capability}",
  "steps": [
    "{Open the affected route/screen with the actual browser, widget, integration or device capability}",
    "{Exercise the changed interaction/state and relevant layout, text-scale or scrolling boundary}",
    "{Verify the expected result, relevant errors and any required visual evidence}"
  ],
  "passes": false
}
```

Web may use Chrome MCP unless the user chooses otherwise. Native targets use project-native
validation; do not insert a browser, desktop viewport or hover check by default.
Missing capabilities leave their checks unverified, not passed.

## tasks.md

```markdown
# TASK-{NNN}: Tasks

**Spec**: `spec.md`
**Status**: Not started

## Work
- [ ] T1 — {Implement the bounded change, including affected existing documentation} · covers: AC-001
- [ ] T2 — {Run relevant checks and verify the required outcome} · covers: AC-001
- [ ] T3 — {Record actual acceptance/current status; leave incomplete work open}
```

This is an example, not a mandatory three-step workflow. Generate only meaningful items.
For larger tasks add actual dependencies and work packages. Contract changes precede their
consumers; unrelated documentation is not an implementation prerequisite. Documentation-only
work may use `covers: doc-maintenance`; behavior-facing contracts also reference their ACs.

Record real test/lint commands and necessary remote/release gates with authorization boundaries.
Do not emit unavailable commands or unresolved placeholders. Reuse a passing result only when
its relevant inputs/conditions are unchanged. Verification must cover changed behavior and
project-required release candidates.

Update `passes` only for verified ACs, check only finished tasks, and mark complete only when
current required scope has passed. Record explicit user scope changes instead of pretending
removed or deferred checks were performed.

## CURRENT_PLAN.md

Make the minimum update to the active feature and current stage/status. Preserve unrelated
completed entries. Keep history in the existing task report; do not append repeated dated
snapshots or create a new reporting system.
