# Case study: environmental-monitoring full-stack application

## What this case demonstrates

This case is a sanitized record of the workflow being used on an existing Java/Spring Boot, Vue/TypeScript, and MySQL application. It demonstrates durable project context, feature-task generation, contract-first implementation, and evidence-aware closeout.

It is not a performance benchmark. Historical time, token, defect-rate, and labor baselines were not consistently measured, so no productivity percentage is claimed.

## Starting situation

The application already contained backend and frontend code, database entities, partial API behavior, several user roles, and a sequence of dependent business modules. Important context was distributed across code, database assumptions, UI prototypes, and conversation history.

The workflow needed to prevent five recurring risks:

1. scanning or modifying the wrong project directory;
2. implementing a feature before its business and security boundaries were agreed;
3. allowing frontend, backend, and long-lived design documents to diverge;
4. parallelizing work before shared contracts were stable;
5. treating partial validation as complete acceptance.

## Stage 1: establish the project Harness

`init-harness` inspected the runnable project structure and created an agent-facing baseline covering:

- root and module-level project instructions;
- project overview and requirements analysis;
- architecture, database, API, and UI design documents;
- permanent `never`, `ask first`, and `always` constraints;
- an ADR area, active-plan file, feature-task tree, and lightweight session-start context.

The important outcome was not the number of files. Later feature work had explicit places to read the current architecture, update shared contracts, find project commands, and record task state.

## Stage 2: turn a feature request into a task contract

A field-measurement feature required authenticated workers to see only their assignments, submit three measurements, let the server calculate a final severity level, complete the assignment atomically, and conditionally create an alert.

At task-creation time, `new-task` kept the work planning-only. It produced:

- 6 acceptance criteria covering functional behavior, edge cases, security, integration, and UI acceptance;
- 16 ordered tasks covering long-lived documentation, backend objects and logic, API boundaries, tests, frontend work, browser acceptance, and final state updates;
- an impact decision for requirements, architecture, API, database, UI, constraints, ADRs, and agent runtime;
- explicit decisions that the client could not submit identity, final severity, completion state, timestamps, or alert facts.

Creating the task package did not modify business code or the database. Implementation could begin later from an approved and inspectable contract.

## Stage 3: implement and preserve incomplete evidence

An adjacent management workflow in the same application exercised the delivery side of the process. Its task package required contract updates before backend and frontend implementation, followed by automated and browser gates.

Recorded execution evidence included:

- 23 backend tests passing;
- frontend type/build checks passing;
- frontend lint passing;
- implementation and quality tasks marked complete only where evidence existed;
- desktop/mobile interaction and console acceptance left incomplete when browser initialization failed.

The last point is intentional. The workflow preserved a visible validation gap rather than translating an unavailable browser into a successful UI claim.

## Observed effects

| Before the workflow risk | Observable workflow effect |
| --- | --- |
| Project knowledge scattered across code and conversation | Requirements, designs, constraints, commands, and active work had stable locations |
| Feature scope mixed with implementation decisions | Scope, exclusions, approval-sensitive choices, and acceptance criteria were recorded before coding |
| Frontend/backend assumptions could drift | Shared API and architecture tasks preceded dependent implementation |
| Parallel work could overlap | Task dependencies and ownership boundaries made sequencing explicit |
| Completion could hide missing checks | The browser gate remained incomplete while automated results stayed separately visible |

These effects establish traceability, reviewability, and truthful task state. They do not by themselves establish faster delivery or fewer defects; those claims require a future controlled evaluation.

## Evidence included in this repository

The [sanitized evidence bundle](../examples/environmental-monitoring/) contains:

- the generated Harness shape;
- a reduced six-criterion specification excerpt;
- the sixteen-step task sequence;
- a verification summary separating passed, incomplete, and not-measured evidence.

The original application source, database content, screenshots, machine paths, organization names, accounts, and internal identifiers are intentionally excluded.
