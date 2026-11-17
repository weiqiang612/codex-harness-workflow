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

### Git delivery and local closeout
{For Git-backed work only: record the project's primary checkout/branch and remote, current
implementation branch/worktree or not started, and push/merge authorization. Link any existing
handoff and use the conditional closeout below for post-merge work.}

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

## Git closeout for task branches

Use one checklist item with separately reportable outcomes. After the authorized merge and
applicable checks, act only on the recorded task checkout and within project authorization.

- **Primary sync.** Refresh the remote primary ref. In the designated primary checkout,
  fast-forward the primary branch only when clean and without unique commits. Verify both refs
  agree. Leave a dirty or divergent primary untouched and continue eligible handoff and cleanup.
- **Evidence handoff.** Inspect tracked, untracked and ignored task files. Preserve required
  candidates, binaries, screenshots and failure/acceptance logs outside the removable
  checkout. Verify copied evidence, digests for key artifacts and recovery links. A patch
  does not replace a binary or authorize deletion of unique work.
- **Task worktree removal.** Confirm actual merge, final delivered and local task heads, and
  no unique commits or working changes, outstanding evidence or remaining use. For a
  squash/rebase, verify the exact reviewed head and delivered scope. Remove only the
  eligible task worktree normally, then evaluate normal local branch deletion separately.
  If Git refuses deletion, retain and report the branch. Never auto-stash, reset or force-delete.

Record merge and former-head SHAs, each outcome, and durable evidence paths in the existing
handoff. Task creation does not perform cleanup. Push, merge and production actions retain
their own authorization.

## CURRENT_PLAN.md

Keep the literal `## Active feature` heading for SessionStart. Replace its content with
links to the current `spec.md` and `tasks.md` and the immediate next step if useful. When
idle, use an explicit no-task line. Add the heading if a legacy plan lacks it.
Link an existing index for prior tasks and verify affected links. Leave unrelated legacy
sections intact during routine task creation.

## Existing verification report

Replace the current verdict in place. Include the scope actually verified, key measurements,
limitations and recovery pointers. Keep material failures, accepted proofs and distinct
versions in the report or link to durable evidence. Verify recovery paths after moving it.
