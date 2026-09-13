# Cross-agent portability

The workflow is Codex-first, not Codex-only by design. Portability must be demonstrated through explicit adapters rather than claimed from Markdown similarity alone.

## Current portability

| Capability | `init-harness` | `new-task` | `subagent-orchestrator` |
| --- | --- | --- | --- |
| Markdown instructions and templates | Portable | Portable | Portable |
| `AGENTS.md` project context | Native | Consumed | Consumed |
| Codex session-start hooks | Native | May maintain | May inspect |
| Real-browser acceptance | Indirect | Chrome MCP default with invocation-level override | Uses the capability recorded in the task |
| Subagent dispatch and waiting | Not required | Not required | Codex-specific |
| Task and acceptance lifecycle | Portable | Native workflow contract | Native workflow contract |

## Adapter contract

An agent adapter must define:

1. where project-level and nested agent instructions live;
2. how lightweight session-start context is injected, or that no equivalent exists;
3. which real-browser capability provides navigation, viewport checks, interaction, console inspection, and screenshots;
4. how bounded subagents are created, messaged, waited on, and stopped;
5. how unavailable capabilities are reported without claiming their acceptance checks passed.

## Support labels

- **Supported:** the workflow has an adapter and a repeatable acceptance run on that agent.
- **Experimental:** an adapter exists but has incomplete acceptance evidence.
- **Portable concept:** the artifact format can be reused, but no working adapter is shipped.
- **Unsupported:** a required capability has no safe equivalent.

Only Codex should be labeled supported in the first release. Other agents remain portable concepts until their adapters and verification evidence exist.

## Codex collaboration dependency

`subagent-orchestrator` requires Codex collaboration capabilities equivalent to:

- `spawn_agent` to create bounded implementation or review agents
- `send_message` and `followup_task` to provide evidence or corrective direction
- `wait_agent` to await useful progress without busy polling
- `interrupt_agent` when an unsafe or conflicting assignment must stop
- `list_agents` to respect the active concurrency limit

These are runtime capabilities, not scripts supplied by this repository. If they are unavailable,
the orchestration Skill is unsupported; it must not pretend that multi-agent execution occurred.
