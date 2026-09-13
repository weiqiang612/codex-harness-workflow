# v0.1.0-beta release checklist

## Imported baseline

- [x] Import `init-harness` from the maintained `.agents/skills` source.
- [x] Import `new-task` from the maintained `.agents/skills` source.
- [x] Import `subagent-orchestrator` from the maintained `.agents/skills` source.
- [x] Verify Skill frontmatter and directory names.
- [x] Add a sanitized real-project case study and compact evidence bundle.

## Release blockers

- [x] Keep the existing `dev-standards` URL as a transparent default with per-invocation override and disable behavior.
- [x] Remove default forced port termination from generated bootstrap scripts.
- [x] Keep Chrome MCP as the default while allowing an invocation-level browser capability override and an explicit unavailable-tool outcome.
- [x] Document the exact Codex collaboration tools required by `subagent-orchestrator`.
- [x] Add the MIT License with the public copyright identity `weiqiang612`.
- [x] Add platform-appropriate installation and update instructions without machine-specific absolute paths.
- [x] Add a disposable, runnable example for independently reproducing initialization, task creation, orchestration, and acceptance.
- [x] Add a minimal release smoke-test checklist for fresh projects, existing governance, and UI capability selection.

## Verification gates

- [x] `scripts/verify.ps1` passes.
- [x] `scripts/verify.ps1 -Release` passes with no personal identifiers, machine paths, or unsafe default process handling.
- [x] All three skills pass the Codex Skill validator.
- [x] Every relative reference from a `SKILL.md` resolves to a repository file.
- [x] A clean Codex environment can install and discover all three skills.
- [x] A disposable sample project executes the documented workflow through acceptance and preserves
  incomplete state when a required browser capability is unavailable.

## Publication

- [x] Review the complete first-commit diff for private data and unsupported claims.
- [ ] Commit the release candidate locally.
- [ ] Push only after explicit user approval.
- [ ] Create GitHub Release `v0.1.0-beta` and label all three skills Beta.
