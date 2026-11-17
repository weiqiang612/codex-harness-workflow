---
name: new-task
description: Create a scoped Harness task package when the user asks to define or plan a new task. Use existing tasks for routine fixes; scale acceptance and verification to actual impact.
---

<!-- Copyright (c) 2026 weiqiang612. Licensed under the MIT License. Official source: https://github.com/weiqiang612/codex-harness-workflow -->

# new-task

Turn an agreed requirement into `spec.md`, `tasks.md`, and a concise entry in
`docs/4-tasks/CURRENT_PLAN.md`. Preserve project conventions and authorization boundaries.

## Choose the necessary scope

- A routine fix in an existing task does not need a new package. If neither the user nor the
  project requires a package, handle a small, clear fix directly with affected checks.
- If the user explicitly asks to create a task, create the smallest useful package. Do not
  invent work to fill a template or a minimum number of ACs/tasks.
- Use fuller planning for actual dependencies, cross-module contracts or material choices.
  Reuse existing conventions, helpers and standard libraries. Add a parser, low-level wrapper
  or concurrency framework only for a specific acceptance gap the simpler approach cannot cover.
- Do not rebuild the Harness, regenerate hooks or update unrelated baselines. Task creation
  changes feature spec/tasks, CURRENT_PLAN and an existing task index as needed; preserve unrelated files.

## Read relevant context

Read root `AGENTS.md`, CURRENT_PLAN, applicable constraints and any existing related task.
Reuse already-read context when unchanged. Derive real test/lint and acceptance commands
from the project; do not invent unavailable commands, runtimes or tools.

Read other documents only when their facts matter:

- `project_overview.md` / `requirements_analysis.md`: goals, roles, business rules or scope.
- `architecture.md`: services, layers, cross-module behavior or trust boundaries.
- `api_contract.md` / `db_schema.md`: API/data behavior and compatibility.
- `ui_prototype.md` and submodule instructions: affected screens and platform support.
- Related ADRs: important decisions; do not read all ADRs or force a new ADR for a routine fix.
- Runtime files such as init scripts/hooks: only when their behavior actually changes.

If no Harness task directory exists, create only the minimal task structure needed using
`init-harness` templates. Do not turn task creation into full initialization.

## Resolve intent and choices

1. Identify the objective, non-goals, affected behavior and existing implementation to reuse.
2. For a new package, check both task directories and any existing index before choosing an
   unused next ID and a short slug. Existing duplicate IDs are not permission to renumber old
   tasks; identify related work by its full name/path and avoid adding another collision.
3. Make routine implementation choices directly within scope.
4. Ask only when a material choice changes scope, business behavior, contracts, security,
   cost or acceptance, or project rules require authorization not already present. Present
   concrete alternatives together with a recommendation; resolve them before finalizing
   affected parts. Do not ask again for an approach already approved.
5. Explain the approach briefly. A separate confirmation checkpoint is needed only for those
   material decisions or when the user explicitly requests one.

## Draft acceptance and documentation impact

Use [references/templates.md](references/templates.md) as an adaptable structure. Write only
independently verifiable outcomes needed by the requirement; there is no fixed AC count.
Cover failure, integrity, security and edge cases where the change affects them.

Each AC has `id`, `category`, `description`, concrete `steps` and `passes: false`.
Categories are `functional`, `security`, `edge-case`, `performance` or `integration`.
Generated files and a successful build alone do not establish acceptance.

For a small task, a short note naming affected documents (or none) is enough unless the
project requires a matrix. For broader work use the project's matrix; supported keys are:

| Key | Facts that require maintenance when changed |
|---|---|
| requirements | Goals, roles, use cases, business rules or scope |
| architecture | Services, layers, cross-module flows or trust boundaries |
| api | Endpoints, request/response shapes, authorization or compatibility |
| db | Tables, fields, indexes, constraints or migrations |
| ui | Pages, visible states, navigation or interactions |
| constraints | Long-lived safety, approval or mandatory behavior rules |
| adr | An important tradeoff or durable architectural decision |
| agent-runtime | Actual startup/health/test commands or agent entrypoints |

Mark only changed facts. A local cache or internal helper does not automatically require an
architecture/ADR task. Combine related maintenance into implementation tasks where useful;
settle contracts before dependent code. Do not add a `config` document/dimension unless the
project has one; record changed environment/config keys in notes.

### UI acceptance follows the platform

For UI changes include `AC-UI-UX`; it may be the only AC for a small UI fix. Record actual
capabilities and affected screens rather than copying a universal matrix.

- For web UI, an explicit user choice overrides the default; otherwise default to Chrome MCP
  when available. Another available real browser is acceptable; do not build/install an adapter.
- For native/Flutter UI, use applicable project widget, integration or device validation.
  Use a browser only for an actual web target. Device/data-sensitive actions retain their
  own authorization requirements.
- Select affected states/viewports from supported devices, breakpoints, text scaling and
  changed behavior. Do not require desktop sizes or hover for a native phone flow.
- Check relevant interactions and uncaught errors. Capture screenshots when needed for visual
  acceptance or requested; do not repeat whole business flows merely to produce screenshots.
- Missing tools leave the specific checks unverified. Functional substitutes do not prove
  visual or real-device acceptance; do not invent an adapter or pass.

## Plan Git delivery and local closeout

For Git-backed work, read the project's branch/worktree policy and inspect local/remote refs,
dirty files and existing worktrees. Record the actual primary checkout and implementation
branch/worktree (or that implementation has not started) in the existing task/handoff. Reuse
an existing task checkout; when implementation is authorized, derive a new isolated checkout
from the refreshed trusted primary branch if that is the project's workflow. Creating a task
package alone does not create implementation branches, push, merge, run CI or delete anything.

Include conditional closeout in the checklist for task branches. Use the
[Git closeout guidance](references/templates.md#git-closeout-for-task-branches) to specify
independent sync, evidence handoff and worktree removal checks. Keep authorization, refs and
evidence paths in the task package or existing handoff. Omit Git closeout for non-Git tasks.

## Write the package

After material choices are resolved, write the feature directory and both files together.
Generate tasks from actual work, not a fixed layer-by-layer checklist:

- Include implementation and valuable verification for each AC.
- Settle API/data/shared contracts before dependent implementation where applicable.
- Reference relevant AC IDs; documentation-only work may use `covers: doc-maintenance`.
- Include affected test/lint commands and justified broader/release gates. Reuse passing
  evidence when relevant inputs and conditions are unchanged.
- Distinguish local checks, remote CI, release validation and production actions. Note major
  validation costs and stopping conditions; task creation does not authorize remote runs,
  dependencies, spending, merge or publication.
- End with verification and truthful task-state maintenance. Incomplete checks stay incomplete.

Update the current pointer under `## Active feature` in CURRENT_PLAN. Link to the task package
and existing index instead of mirroring their status or moving unrelated history. Keep
the current verdict in the existing task report and retain evidence needed for acceptance
or recovery. Verify that the pointer still resolves after changes.

## Check and report

Verify before finishing:

- Every AC has necessary work and evidence, including platform-appropriate UI checks.
- Every true documentation impact has maintenance or an explicit reason none is needed.
- Commands/capabilities are real; generated files have no unresolved template placeholders.
- The task ID is unused and any existing index links the new package with its actual state.
- Current user decisions are consistent in spec/tasks; update later scope changes rather
  than retaining obsolete gates or marking them passed.
- Git-backed task delivery records the intended checkout, authorization and conditional local
  sync/cleanup, without claiming that task creation performed those actions.

Briefly report the task path, key decisions and remaining unverified or approval-sensitive
work. Task creation itself does not constitute implementation or acceptance.
