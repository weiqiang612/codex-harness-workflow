---
name: new-task
description: Creates a new feature task from a natural language requirement description by drafting a spec, resolving ambiguities, confirming the implementation approach, and generating task files under the Harness task tree. Use when starting a feature, defining scoped implementation work, or turning a requirement into an executable task package.
---

<!-- Copyright (c) 2026 weiqiang612. Licensed under the MIT License. Official source: https://github.com/weiqiang612/codex-harness-workflow -->

# new-task

This skill turns a natural language requirement into a structured, executable task package.
It is the Harness entry point for new feature work: it creates the task package, updates
`CURRENT_PLAN.md`, identifies affected long-lived Harness documents, and adds the required
maintenance work to `tasks.md`.

It does not replace `init-harness`. Do not rebuild the Harness scaffold, regenerate hooks, or
refresh project baselines during task creation unless the feature itself explicitly requires
those runtime files to be maintained.


## Compatibility contract

All agents using this skill must follow this minimum contract, even when local phase wording differs:
- Do not rebuild the Harness scaffold during task creation. Create or update only the feature `spec.md`, feature `tasks.md`, and `docs/4-tasks/CURRENT_PLAN.md`, unless the user explicitly asks for runtime or scaffold file changes.
- Always read root `AGENTS.md` before generating `tasks.md`; use it to extract project commands, plan structure, boundary rules, and submodule entrypoints, not as a maintenance target by default.
- Always read `docs/4-tasks/CURRENT_PLAN.md`, `docs/1-requirements/project_overview.md`, `docs/3-constraints/never-do.md`, `docs/3-constraints/ask-first.md`, and `docs/3-constraints/always-do.md` before drafting the final task package.
- Read `docs/1-requirements/requirements_analysis.md` when business scenarios, roles, rules, workflows, or scope boundaries might change.
- Read the relevant `docs/2-designs/` documents when API, database, architecture, UI, or project-specific design behavior might change.
- Derive test and lint gates from root `AGENTS.md` or explicit project configuration. Omit unavailable gates; do not invent lint commands when lint is not configured.
- Never write unresolved template placeholders such as `{{TEST_COMMAND}}`, `{{LINT_COMMAND}}`, or `{AC ids}` into generated task files.
- Use a documentation impact matrix and include maintenance tasks only for long-lived Harness documents whose described facts change.
- Treat `project_overview.md` and `requirements_analysis.md` as general Harness requirements documents. Maintain `project_overview.md` for project goals, background, core modules, or business boundary changes; maintain `requirements_analysis.md` for roles, use cases, workflows, rules, or scope changes.
- Do not add a mandatory `config` impact dimension unless the project has a centralized configuration document. New environment variables or config keys must still be recorded in `spec.md` notes and implementation or verification tasks.
- Do not read every ADR by default. List ADRs, read `TEMPLATE.md`, and read only ADRs clearly related to the task decision.
- For UI acceptance, use the browser capability explicitly requested by the user. Otherwise
  default to Chrome MCP. This is an invocation-level choice; do not create a browser adapter
  framework or project configuration file. Record the resolved capability in the generated AC
  and task. If it is unavailable during implementation, leave UI acceptance incomplete.
## Prerequisites

The following should exist:
- `docs/4-tasks/`
- `docs/4-tasks/CURRENT_PLAN.md`

If they do not exist, create the minimal task directory structure using the templates from
`init-harness`, then warn that full Harness setup is recommended.

## What this skill produces

```text
docs/4-tasks/features/
└── TASK-{NNN}-{slug}/
    ├── spec.md
    └── tasks.md
```

`docs/4-tasks/CURRENT_PLAN.md` is updated to point to the new feature.

## Decision ownership

- Make routine implementation choices directly when they do not materially affect feature scope, business behavior, the data model, API contract, security boundary, post-login destination, or acceptance criteria.
- When two or more reasonable approaches would materially affect any of those areas, pause before writing task files. Present concrete options, their consequences, and a recommendation; wait for the user's choice before finalizing the task package.
- Do not hide a material choice inside a default assumption. Record the user's selected option in `spec.md` and `tasks.md` when it affects implementation or verification.

## Execution phases

Work through these phases in order. Do not skip phases.

### Phase 1 — Parse the requirement and assign task ID

- List directories under `docs/4-tasks/features/`.
- Find the highest `TASK-NNN` number and increment it.
- Extract:
  - core intent
  - explicit constraints
  - explicit out-of-scope items
- Generate a short kebab-case slug, max 4 words.
- Define the target path in memory only. Do not write files yet.

### Phase 2 — Read Harness context and classify documentation impact

Before drafting the spec, read:
- `docs/4-tasks/CURRENT_PLAN.md`
- `docs/3-constraints/never-do.md`
- `docs/3-constraints/ask-first.md`
- `docs/3-constraints/always-do.md`
- `docs/2-designs/architecture.md`
- `docs/2-designs/api_contract.md`
- `docs/2-designs/db_schema.md`

Conditionally read only when the requirement might touch that area:
- `docs/1-requirements/requirements_analysis.md`
- `docs/2-designs/ui_prototype.md`
- `docs/3-constraints/adr/`
- submodule `AGENTS.md` when a specific runnable module is affected
- `.codex/session-start.js`
- `init.sh`
- `init.ps1`

For UI-impacting work, resolve the browser acceptance capability before drafting `AC-UI-UX`:
- an explicit user choice overrides the default
- otherwise use Chrome MCP
- substitute the resolved capability name into `spec.md` and `tasks.md`; never leave a generic
  browser placeholder in generated files

Create a documentation impact matrix with these boolean keys:
- `requirements`: affects `docs/1-requirements/project_overview.md` or `docs/1-requirements/requirements_analysis.md`
- `architecture`: affects `docs/2-designs/architecture.md`
- `api`: affects `docs/2-designs/api_contract.md`
- `db`: affects `docs/2-designs/db_schema.md`
- `ui`: affects `docs/2-designs/ui_prototype.md`
- `constraints`: affects `docs/3-constraints/ask-first.md`, `always-do.md`, or `never-do.md`
- `adr`: requires a new ADR under `docs/3-constraints/adr/`
- `agent-runtime`: affects root/submodule `AGENTS.md`, `.codex/session-start.js`, `init.sh`, or `init.ps1`

Use the matrix to shape ACs, approval prompts, and task order. If any matrix entry cannot be
classified safely, add a clarification marker instead of guessing.

**Impact classification rules**
- `requirements` is true when the feature adds or changes business scenarios, user roles,
  business rules, core workflows, or scope boundaries.
- `architecture` is true when the feature adds or changes services, modules, layers,
  cross-module calls, async flows, permission chains, caches, queues, or external systems.
- `api` is true when the feature adds or changes endpoints, request/response shapes, error
  codes, authorization behavior, or compatibility behavior.
- `db` is true when the feature adds or changes tables, fields, indexes, constraints, entity
  mappings, or migrations.
- `ui` is true when the feature adds or changes pages, forms, dialogs, visible states,
  navigation, or user interaction paths.
- `constraints` is true when the feature creates a long-lived prohibition, mandatory behavior,
  approval rule, safety boundary, or security boundary.
- `adr` is true when the feature contains an important technical tradeoff, new dependency,
  irreversible migration, architecture strategy, or long-lived constraint rationale.
- `agent-runtime` is true when the feature changes ports, startup commands, health checks,
  test/lint commands, runnable submodules, or session-start context.

Do not mark every document as impacted by default. Simple internal logic changes should usually
leave most matrix entries false.

### Phase 3 — Generate draft spec.md

Generate `spec.md` using `references/templates.md`.

**Acceptance criteria rules**
- Write 3–6 AC items.
- Cover happy path, failure path, edge case, and security where relevant.
- Use JSON items with:
  - `id`
  - `category`
  - `description`
  - `steps`
  - `passes: false`
- `category` must be one of:
  - `functional`
  - `security`
  - `edge-case`
  - `performance`
  - `integration`
- If the documentation impact matrix marks `ui` as `true`, always add a dedicated integration
  AC with the fixed id `AC-UI-UX`.
- `AC-UI-UX` must require the resolved browser capability to perform:
  - responsive layout verification at `1440x900`
  - responsive layout verification at `375x812`
  - hover-state interaction checks for relevant interactive elements
  - browser console audit with zero JavaScript errors
  - screenshot archival using explicit, deterministic file names
- Do not rename `AC-UI-UX`, collapse it into another AC, or omit it when UI/UX behavior changes
  are in scope.

**Contract awareness**
- If API changes are required, add an integration AC that requires the implementation
  to match `docs/2-designs/api_contract.md`.
- If DB/schema changes are required, add an integration AC that requires the implementation
  and migration to match `docs/2-designs/db_schema.md`.
- If both change, cover both contract types explicitly.

**Ambiguity rules**
- Use `[NEEDS CLARIFICATION: ...]` only for ambiguities that materially change the AC shape.
- Maximum 3 markers.
- Do not invent defaults when the ambiguity changes the implementation shape.

Keep the draft `spec.md` in memory only.

### Phase 4 — Clarification round

If there are no clarification markers, skip ahead.

If markers exist:
- Present all questions at once.
- Provide 3–4 realistic options plus a custom option.
- Wait for the user's reply.

After answers:
1. Replace all clarification markers
2. Update affected AC steps
3. Keep finalized `spec.md` in memory only
4. Confirm that the spec is finalized and you are generating the implementation approach

### Phase 5 — Implementation approach checkpoint

Before generating `tasks.md`, present a concise implementation approach covering:
- layers involved
- key reuse or technical decisions
- implementation order rationale
- documentation maintenance required by the impact matrix

If API changes are involved, include a request/response payload sketch.
If DB/schema changes are involved, include a DDL or migration sketch.
If UI changes are involved, include the interaction/state-flow sketch and the `AC-UI-UX`
verification plan, including the resolved browser capability, target routes, interactive elements
to hover, and screenshot names.
If architecture or ADR changes are involved, include the proposed decision summary.

Ask the user to confirm the approach before generating the task list.

### Phase 6 — Create feature directory and write files

In one step:
1. Create `docs/4-tasks/features/TASK-{NNN}-{slug}/`
2. Write finalized `spec.md`
3. Generate `tasks.md` using `references/templates.md`

**Task rules**
- Each task must be atomic.
- Harness documentation maintenance comes first when applicable.
- Contract updates come before implementation when applicable.
- Task order is:
  - Harness long-lived document maintenance if needed
  - design contracts and ADRs if needed
  - models/types/data objects
  - business logic
  - API/UI layer
  - tests
  - verification / housekeeping gates
- Every non-gate task must reference AC IDs or use `covers: doc-maintenance`.
- API, DB, architecture, and UI documentation tasks that affect acceptance behavior should
  reference the relevant AC IDs in addition to any documentation maintenance label.
- If `ui` is `true`, include at least one implementation or verification task that explicitly
  covers `AC-UI-UX`.
- Final tasks must include:
  - run tests
  - verify ACs in `spec.md`
  - update `CURRENT_PLAN.md`

### Phase 7 — Update CURRENT_PLAN.md

Update `docs/4-tasks/CURRENT_PLAN.md`:
- set active feature
- add the new task entry under stages
- preserve existing completed items

### Phase 8 — Consistency check

After writing:
- every AC must be covered by at least one task
- if the documentation impact matrix marks `ui` as `true`, `spec.md` must contain `AC-UI-UX`
- every true documentation impact matrix entry must map to at least one maintenance task, unless
  `spec.md` explicitly explains why no maintenance is required
- every non-gate task must reference at least one AC or use `covers: doc-maintenance`
- generated files must not contain unresolved template placeholders such as `{{...}}`, `{AC ids}`, or unavailable lint/test commands
- UI task files must contain the resolved browser capability rather than `{resolved BROWSER_CAPABILITY}`

Fix any gaps before finishing.

### Phase 9 — Summary

Print:

```text
## Task created: TASK-{NNN} — {title}

**Files written:**
- docs/4-tasks/features/TASK-{NNN}-{slug}/spec.md
- docs/4-tasks/features/TASK-{NNN}-{slug}/tasks.md
- docs/4-tasks/CURRENT_PLAN.md

**Acceptance criteria:** {N}
**Tasks:** {N}
[if UI is impacted: **Browser acceptance:** {resolved capability}]

**Ready to implement.**
```

## Important constraints

- `spec.md` is the source of truth.
- Do not generate tasks until all clarification markers are resolved.
- Do not generate tasks until the user confirms the implementation approach.
- One feature per invocation.

## Reference files

- `references/templates.md`
