# Minimal release smoke test

Run this checklist before tagging a release. It intentionally covers only the behavior most likely
to damage a project or undermine the workflow contract.

## Automated repository checks

- [x] Run `pwsh -File .\scripts\verify.ps1`.
- [x] Run `pwsh -File .\scripts\verify.ps1 -Release`.
- [x] Run the Codex Skill validator against all three Skill directories.

## Behavior checks in disposable projects

### 1. Fresh project

- [x] Run `init-harness` on a disposable project with a real build manifest.
- [x] Confirm required files are created and no placeholder remains.
- [x] Occupy its configured port and confirm the generated init script exits without terminating
  the existing process.

### 2. Existing governance

- [ ] Add an existing `AGENTS.md` and one existing constraint file.
- [ ] Run `init-harness` and confirm it shows proposed governance changes before replacement.
- [ ] Decline the replacement and confirm the original files remain unchanged.

### 3. UI task capability

- [x] Run `new-task` once without a browser override and confirm Chrome MCP is recorded.
- [ ] Run it again with another named browser capability and confirm that capability is recorded.
- [x] Simulate an unavailable browser during orchestration and confirm `AC-UI-UX` remains false.

## Release record

Record the date, Codex version, operating system, test project commit, and result beside the release
candidate. Do not mark a behavior check complete from instruction review alone.

### v0.1.0-beta candidate

- Date: 2026-09-13
- Codex CLI: 0.146.0
- Operating system: Windows
- Test project: disposable copy of `examples/minimal-task-board` (no standalone commit)
- Clean discovery: `init-harness`, `new-task`, and `subagent-orchestrator` all reported `AVAILABLE`
- Generated Harness: 17 required files; JSON, JavaScript, PowerShell, placeholder, link, and
  non-destructive port checks passed
- Feature package: 4 ACs and 9 tasks; Chrome MCP recorded as the default browser capability
- Repository fixture baseline: `npm test` passed 1/1
- Disposable implementation run: scoped documentation and frontend/test work packages; a temporary
  zero-dependency `node:vm` DOM behavior test expanded that disposable copy to 2/2 passing tests
- Acceptance in the disposable copy: AC-001 through AC-003 passed from the temporary executable
  behavior test; Chrome MCP initialization was unavailable, so `AC-UI-UX` and its task remained
  false/incomplete as required
- Result: workflow behavior passed; the unavailable browser outcome was recorded rather than
  reported as successful UI acceptance
