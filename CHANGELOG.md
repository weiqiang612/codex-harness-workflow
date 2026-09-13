# Changelog

## v0.1.0-beta — Unreleased

- Added the three-skill Harness workflow: project initialization, feature task design, and scoped
  multi-agent implementation with evidence-backed acceptance.
- Added configurable external development standards with the existing standards source as the
  default and per-invocation override or disable behavior.
- Made occupied-port handling non-destructive in generated bootstrap scripts.
- Added a short TCP probe fallback when PowerShell cannot resolve the process owning an occupied
  port, so bootstrap still exits instead of starting a competing service.
- Made Chrome MCP the default but replaceable UI acceptance capability.
- Added protection for existing `AGENTS.md` and constraint files during initialization.
- Added a sanitized real-project case study, verification script, installation guide, and release
  smoke-test checklist.
- Added the MIT License, per-Skill copyright notices, and an official-source statement.
- Completed an isolated release smoke test covering clean Skill discovery, Harness generation,
  task planning, scoped multi-agent implementation, automated behavior tests, and truthful
  incomplete UI acceptance when Chrome MCP is unavailable.

See [release notes](docs/releases/v0.1.0-beta.md) for scope and known limitations.
