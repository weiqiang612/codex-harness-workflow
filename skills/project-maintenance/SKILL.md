---
name: project-maintenance
description: Maintain and simplify an existing project when the user asks to reduce redundant code, unsuitable tests, unused generated outputs, or confusing task documentation. Deliver a scoped improvement with measured results and preserved behavior.
---

<!-- Copyright (c) 2026 weiqiang612. Licensed under the MIT License. Official source: https://github.com/weiqiang612/codex-harness-workflow -->

# project-maintenance

Reduce the cost of running and maintaining the project. A useful result may remove work,
simplify code, or establish that a proposed cleanup should be deferred.

## Choose a worthwhile change

Read the project's instructions, current status and applicable constraints; reuse context
already read when unchanged. Inspect the live diff and preserve unrelated work.
Start from an observed problem or existing measurement and inspect the relevant files.
Do not default to a repository-wide audit, new task package or new audit tool for a small fix.
State the intended result, verification cost and stopping point briefly.

Confirm current uses and coverage before deleting anything. Names, age, task numbers and
zero static references are clues, not proof: manual tools and dynamic entrypoints matter.
Prefer removing repeated work over introducing another abstraction or configuration layer.

## Maintain task documentation when needed

Use this path when task state conflicts, current conclusions are hard to locate, or repeated
reports obscure useful material. File count alone does not justify moving or deleting files.

- Identify the maintained specification, execution state, accepted delivery and independent
  follow-ups. Keep useful materials such as submission forms discoverable; a task's stage
  completion does not close every later patch or outstanding acceptance check.
- Give readers a clear entry to those conclusions. Reuse existing navigation where sufficient;
  add a short index only when it resolves ambiguity. Do not impose a fixed root file count.
- Group historical drafts and iterations using project conventions. Before moving documents,
  inspect incoming/outgoing links and manual or scripted path uses. Update affected references
  and preserve command working-directory assumptions, original evidence and distinct versions.
- Align current summaries and any existing task index with verified scope and evidence. Label
  dated snapshots rather than rewriting historical counts, checkboxes or AC results to agree.
- Verify retained content and affected links; report entry/navigation improvements separately
  from total file or storage changes. Leave archive layout and retention rules project-specific.

## Preserve what matters

- Tests: retain business behavior, important failure cases and security/data protections.
  Reduce repeated setup or consolidate equivalent coverage when justified; do not mock away
  the boundary being tested. Replace fixed waits with observable completion when appropriate.
- Outputs: delete only verified project-owned, rebuildable or obsolete items within the
  existing authorization. Check absolute paths, ownership, tracked status and reparse points.
  Ignored files are not automatically disposable. Preserve user data, originals, databases,
  backups, secrets and failure/acceptance evidence according to project rules.
- Scope: finish the agreed local work before proposing external actions. Follow existing
  permissions and cost limits; maintenance does not itself authorize CI, publishing or merging.

## Verify value and report it

Measure before and after under comparable conditions when claiming a performance or space
benefit. Separate startup/cache effects from the changed operation and disclose small samples.
Line count and passing-test count alone do not establish improvement.
Run affected checks; reuse unchanged evidence. Use full regression or remote execution only
when the impact and project rules justify the cost. Repeated failures of the same cause call
for reassessing the approach, not another remote debugging cycle.

Give a compact result: original problem, actual change, measured benefit and conditions,
preserved coverage, verification limits, and local/remote delivery status. Recommend keeping,
reverting or deferring the change. Say plainly when the benefit is small or unmeasured.
Update the existing status/report only as needed; do not create a reporting framework.
