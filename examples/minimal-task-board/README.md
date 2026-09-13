# Minimal task-board workflow fixture

This is a disposable, dependency-free Node.js project for release smoke testing. It is deliberately
small: the starter only lists tasks, so the workflow can plan and implement one visible feature.

## Baseline

```powershell
npm test
node server.js
```

Open `http://localhost:3000` and confirm the two starter tasks are visible.

## Reproduce the three-skill workflow

Copy this directory outside the repository so generated Harness files and implementation changes
remain disposable. Run Codex from that copied project root.

1. Invoke `init-harness` and disable external dev-standards.
2. Review the generated project context.
3. Invoke `new-task` with this requirement:

   ```text
   Add a button beside each task that marks it complete. Completed tasks must remain visible with
   a distinct style, and refreshing the page may reset the sample data.
   ```

4. Review and approve the proposed implementation approach.
5. Invoke `subagent-orchestrator` for the generated task.
6. Confirm automated tests pass and any unavailable browser acceptance remains incomplete.

This fixture proves only workflow behavior. It is not a benchmark or an example of production
architecture.
