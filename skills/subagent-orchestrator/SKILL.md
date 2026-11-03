---
name: subagent-orchestrator
description: Execute a Harness feature task through scoped Codex subagents, contract-first sequencing, independent review, bounded repair loops, browser acceptance when required, and task-state closeout. Use when the user asks to orchestrate, coordinate, implement, or finish a TASK-NNN package with subagents or parallel agent work.
---

<!-- Copyright (c) 2026 weiqiang612. Licensed under the MIT License. Official source: https://github.com/weiqiang612/codex-harness-workflow -->

# Subagent Orchestrator

Execute one existing Harness task package. Follow current user decisions and project constraints;
use `spec.md` for agreed acceptance, `tasks.md` for execution state, and maintained documents for shared contracts.

## Operating contract

- Use Codex collaboration tools for subagents. Do not assume Antigravity commands such as `define_subagent` or `invoke_subagent` exist.
- Obey the active system concurrency limit. Count the primary agent as one active slot.
- Keep the primary agent responsible for orchestration, conflict checks, integration, verification, and user communication.
- Give each subagent a concrete, bounded, independently executable scope. Do not delegate the entire task.
- Delegate only when independent work or review justifies its coordination cost; a free slot alone is not a reason. Small repairs may stay with the primary agent.
- Share the filesystem intentionally: agents see each other's edits. Assign non-overlapping file ownership and never ask two agents to edit the same file concurrently.
- Preserve user changes and unrelated dirty-worktree changes. Never use destructive reset or checkout operations.
- Ask for user input only when a contract choice, approval-sensitive action, or unresolved conflict would materially change the result. Self-recover routine failures first.
- Do not mark a task complete from agent claims or checked boxes alone. Verify artifacts and gates directly.

## Phase 1 — Resolve and read the task

1. Resolve the requested `TASK-NNN` under `docs/4-tasks/features/`. If more than one directory matches, stop and ask which package is intended.
2. Read root `AGENTS.md`, `docs/4-tasks/CURRENT_PLAN.md`, the task's `spec.md` and `tasks.md`, and all project-level instructions that apply to targeted files.
3. Read `docs/3-constraints/never-do.md`, `ask-first.md`, and `always-do.md` when present.
4. Use the spec's documentation impact matrix to read only relevant files under `docs/1-requirements/` and `docs/2-designs/`. Read related ADRs when a design decision is implicated.
5. Inspect the live worktree and relevant code before assigning work. Record pre-existing changes so they are not attributed to subagents.
6. Derive actual test, lint, startup, and acceptance commands from `AGENTS.md` and project configuration. Do not assume fixed module names, ports, routes, credentials, or frameworks.

## Phase 2 — Build the execution graph

Map unchecked tasks and ACs into work packages. Prefer boundaries such as backend, frontend, tests, documentation contracts, or independent modules only when their files do not overlap.

For each proposed package, record:

- exact objective and covered AC IDs
- allowed files or directories
- forbidden or shared files
- dependencies and required contract version
- validation command the subagent should run
- expected handoff: changed files, tests, risks, and remaining work

Run packages in parallel only when they are dependency-independent and have disjoint write sets. Otherwise sequence them.

### Contract-first gate

If API, database, architecture, or another shared contract must change:

1. Draft or implement the contract update before dependent code.
2. If `ask-first.md`, the spec, or the user requires approval, present the proposed contract change and wait.
3. After approval when required, update the contract source of truth.
4. Start dependent subagents only after they can read the settled contract from disk.

Do not use the primary agent as a lossy relay for request or response shapes that belong in a project contract.

## Phase 3 — Dispatch scoped subagents

Spawn only the agents justified by the execution graph. Include the task directory and relevant raw artifacts, but do not leak the intended solution or another agent's conclusions.

Use a prompt with this shape:

```text
Implement <bounded package> for <TASK path>.
Read <instructions and contract files> first.
You own only <allowed paths>; do not edit <shared/forbidden paths>.
Cover <AC IDs> and run <validation>.
Do not commit, reset, or overwrite unrelated changes.
Return changed files, validation results, risks, and remaining work.
```

While agents run, the primary agent may perform useful non-overlapping work such as contract inspection, integration planning, or acceptance preparation. Track agent status and inspect their actual diffs when they finish.

If a subagent blocks on a routine issue, send a focused follow-up with new evidence. Reassign or take over locally when that is safer than repeated delegation.

## Phase 4 — Integrate and verify

After development agents finish:

1. Inspect `git status`, the complete diff, and each changed file. Separate task changes from pre-existing changes.
2. Check contract alignment, AC coverage, file-boundary compliance, error handling, security, regressions, and constraint violations.
3. Run affected checks first; use broader gates when changed behavior, project policy or a release candidate requires them. Reuse passing evidence only when relevant inputs and conditions are unchanged.
4. Use an independent review subagent when risk/complexity justifies it and delegation is authorized. Give it the spec, constraints and raw diff; do not seed the expected findings. A small fix can use primary-agent review.
5. Classify findings by severity and evidence. Fix verified critical or high-severity issues before acceptance.

### Bounded repair loop

- Route a finding to the original owner only when its file boundary remains clear; otherwise fix it in the primary agent.
- After a repair, repeat only review/checks whose evidence it invalidated.
- After two unsuccessful rounds for the same underlying cause, stop the repeated strategy and diagnose locally before further delegation or remote runs. Different files/errors can share one cause.
- Respect existing authorization/run limits; ask only for a material decision not already covered.

## Phase 5 — Acceptance

Execute applicable ACs using direct evidence. If the user changes scope, update spec/tasks and
record removed/deferred requirements explicitly; do not silently retain obsolete gates or mark them passed.

For UI work or `AC-UI-UX`:

1. Use only the services needed by the affected flow, with project-defined startup/health commands and existing authorization. A stopped local service is not evidence that a deployed app is broken.
2. For web targets use the browser capability recorded in `spec.md` or `tasks.md`; otherwise prefer an available real browser such as Chrome MCP. Native/Flutter targets use the project's appropriate widget, integration or device checks. Do not build/install adapters to replace unavailable tools.
3. Choose layout checks from supported devices and changed behavior, not a fixed desktop/mobile matrix. For a full-screen default view, check primary controls fit without unintended clipping/scrolling; preserve intentional mobile and long-content scrolling.
4. Exercise affected interactions/states; select hover, focus, loading, error, permissions, resize and content-growth checks where relevant.
5. Check relevant console/platform errors and distinguish new defects from existing issues; enforce any explicit zero-error AC.
6. Capture named screenshots when required by visual acceptance or the user. Reuse setup/evidence rather than repeating full business flows for each screenshot.

Functional tests or a build alone do not establish visual/device acceptance. Report verified results,
visual differences and unverified behavior separately; implementation fidelity is not user design approval.

If a required UI capability is unavailable, leave that check unverified, report it and continue other safe work.

For non-UI work, use tests, API calls, database checks, logs, or other project-defined evidence. Never set `passes: true` without current evidence.

## Phase 6 — Close out task state

Only after implementation and required acceptance gates pass:

1. Set each verified AC's `passes` field to `true`; leave unverified or failing ACs false.
2. Check only completed items in `tasks.md`. Do not bulk-check incomplete work.
3. Set task status to completed only when all required tasks and ACs are complete.
4. Update CURRENT_PLAN's current status minimally, preserving unrelated/completed work; keep process history in the existing task report.
5. Update long-lived Harness documents only when the implementation changed the facts they describe.
6. Create a walkthrough or screenshot report only when the task, project conventions, or user requests it.

## Final report

Lead with the outcome and include:

- completion or remaining blocker
- implemented scopes and key files
- tests and acceptance evidence
- review findings fixed or still open
- task-document and `CURRENT_PLAN.md` state
- paths to user-visible screenshots or walkthrough artifacts when produced

Never describe the task as complete if required validation remains unavailable or failing.
