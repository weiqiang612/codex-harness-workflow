---
name: project-maintenance
description: Maintain and simplify an existing project when the user asks to reduce redundant code, unsuitable tests, or unused generated outputs. Deliver a scoped improvement with measured results and preserved behavior.
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
