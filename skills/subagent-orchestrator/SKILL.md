---
name: subagent-orchestrator
description: Execute a Harness feature task through scoped Codex subagents, contract-first sequencing, independent review, bounded repair loops, browser acceptance when required, and task-state closeout. Use when the user asks to orchestrate, coordinate, implement, or finish a TASK-NNN package with subagents or parallel agent work.
---

<!-- Copyright (c) 2026 weiqiang612. Licensed under the MIT License. Official source: https://github.com/weiqiang612/codex-harness-workflow -->

# Subagent Orchestrator

Execute one existing Harness task package to completion. Treat `spec.md` as the acceptance source of truth, `tasks.md` as the execution ledger, and long-lived Harness documents as shared contracts.

## Operating contract

- Use Codex collaboration tools for subagents. Do not assume Antigravity commands such as `define_subagent` or `invoke_subagent` exist.
- Obey the active system concurrency limit. Count the primary agent as one active slot.
- Keep the primary agent responsible for orchestration, conflict checks, integration, verification, and user communication.
- Give each subagent a concrete, bounded, independently executable scope. Do not delegate the entire task.
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
3. Run targeted tests first, then the task's required broader gates in the primary agent context.
4. Start an independent review subagent when a free slot exists and the change is non-trivial. Give it the spec, constraints, and raw diff or changed files; do not provide suspected findings or the intended answer.
5. Classify findings by severity and evidence. Fix verified critical or high-severity issues before acceptance.

### Bounded repair loop

- Route a finding to the original owner only when its file boundary remains clear; otherwise fix it in the primary agent.
- Re-run the relevant review and validation after each repair.
- Allow at most two delegated repair rounds for the same class of blocking defect.
- After two unsuccessful rounds, stop delegating, summarize the evidence, and either solve it locally or ask the user only if a material decision is required.

## Phase 5 — Acceptance

Execute every applicable AC from `spec.md` using the most direct evidence available.

For UI work or `AC-UI-UX`:

1. Start services with project-defined commands and poll project-defined health signals with a bounded timeout.
2. Use the browser capability recorded in `spec.md` or `tasks.md`. For older task packages that
   do not name one, prefer Chrome MCP when available, otherwise use another available real-browser
   capability. Do not build or install a new adapter unless the user asks.
3. Verify desktop `1440x900` and mobile `375x812` layouts.
4. Exercise relevant hover, focus, loading, empty, success, error, and permission states.
5. Audit the browser console and require zero uncaught JavaScript errors.
6. Capture deterministic screenshots in a user-visible project or requested artifact location. Do not assume Antigravity session paths or `file:///` walkthrough links.

If browser tooling is unavailable, do not claim UI acceptance passed. Report the exact unverified AC and continue with all other safe verification.

For non-UI work, use tests, API calls, database checks, logs, or other project-defined evidence. Never set `passes: true` without current evidence.

## Phase 6 — Close out task state

Only after implementation and required acceptance gates pass:

1. Set each verified AC's `passes` field to `true`; leave unverified or failing ACs false.
2. Check only completed items in `tasks.md`. Do not bulk-check incomplete work.
3. Set task status to completed only when all required tasks and ACs are complete.
4. Update `docs/4-tasks/CURRENT_PLAN.md` minimally, preserving unrelated and completed entries.
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
