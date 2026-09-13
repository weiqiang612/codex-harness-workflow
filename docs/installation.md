# Installation

The repository is the distribution source for the three skills. Install only these directories:

- `init-harness`
- `new-task`
- `subagent-orchestrator`

## Codex on Windows

Clone or download this repository, then copy the three directories under `skills/` into
`%USERPROFILE%\.codex\skills\`.

```powershell
$skillSource = 'path\to\codex-harness-workflow\skills'
$codexSkillRoot = Join-Path $env:USERPROFILE '.codex\skills'
New-Item -ItemType Directory -Path $codexSkillRoot -Force | Out-Null
'init-harness','new-task','subagent-orchestrator' | ForEach-Object {
    Copy-Item -LiteralPath (Join-Path $skillSource $_) -Destination $codexSkillRoot -Recurse -Force
}
```

Restart Codex after installation. If a target directory already exists, back it up or review the
diff before copying; the command above updates matching files but does not remove extra files.

## Codex on macOS or Linux

Copy the same three directories into `${CODEX_HOME:-$HOME/.codex}/skills/`, then restart Codex.

## Verify discovery

Ask Codex which of the following skills are available:

```text
init-harness, new-task, subagent-orchestrator
```

## Minimal use

Run the workflow from the real project root:

```text
Initialize this project with init-harness.
```

The default external standards source may be replaced or disabled per invocation:

```text
Initialize this project with init-harness and disable external dev-standards.
```

```text
Initialize this project with init-harness and use https://example.com/standards as the dev-standards base URL.
```

After reviewing the generated project context:

```text
Use new-task to plan: add a refund workflow with customer submission and administrator approval.
```

Chrome MCP is the default for UI acceptance. A different available capability can be selected:

```text
Use new-task to plan this UI change and use Playwright for browser acceptance.
```

After approving the task package:

```text
Use subagent-orchestrator to implement TASK-001.
```

## Update

Pull or download the newer repository version, review the release notes and Skill diff, then copy
the same three directories again. Do not treat the mirror under an installed Codex directory as an
editing source.

## Current support boundary

Codex is the only supported runtime for the first release. Browser acceptance requires the
capability recorded in the task package, and multi-agent execution requires Codex collaboration
tools. Missing capabilities must be reported as incomplete rather than silently skipped.
