# Sanitized specification excerpt

## Objective

Allow an authenticated field worker to view only assigned work, submit three measurements, and let the server calculate the final severity, complete the assignment, and create a high-severity alert as one consistent operation.

## Scope decisions

- Identity comes from the authenticated session, never from client-supplied worker fields.
- The server owns calculated severity, timestamps, completion state, and alert creation.
- Existing tables and uniqueness rules are reused; task creation proposed no schema migration or new runtime dependency.
- Failed, unauthorized, out-of-range, or duplicate submissions must not leave partial results.

## Acceptance criteria summary

| ID | Category | Verifiable outcome |
| --- | --- | --- |
| AC-001 | Functional | A worker sees only their assigned and completed work, with estimated and final results clearly separated |
| AC-002 | Functional | Valid measurements produce server-calculated severity, atomic completion, and a conditional alert |
| AC-003 | Edge case | Boundary, invalid, duplicate, and concurrent submissions preserve one consistent result |
| AC-004 | Security | Authentication, ownership, and server-owned facts cannot be forged by the client |
| AC-005 | Integration | Requests, responses, session identity, calculation lookup, and persistence follow existing contracts |
| AC-UI-UX | Integration | Desktop/mobile layout, relevant interaction states, console state, and named screenshots are verified in a real browser |

All six criteria were mapped to one or more tasks. At task-creation time their `passes` state was false because implementation and acceptance had not yet run.
