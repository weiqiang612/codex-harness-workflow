# Templates Reference

All file templates for the `init-harness` skill.

---

## Root AGENTS.md template

```markdown
# AGENTS.md

## Project
- **Name**: {{PROJECT_NAME}}
- **Stack**: {{TECH_STACK_SUMMARY}}
- **Rule**: This file is an index only. All details live in `docs/`.

## Session start
The `.codex/hooks.json` SessionStart hook runs automatically on every session.
It injects git context and a compact `CURRENT_PLAN.md` snapshot independently of local service status.
When a configured service port is not listening, it reports that state and continues without starting or waiting for anything.

Run the platform init script only when the dev server is not running:
- Windows: `pwsh -ExecutionPolicy Bypass -File .\init.ps1`
- Windows fallback: `powershell -ExecutionPolicy Bypass -File .\init.ps1`
- macOS/Linux/WSL/Git Bash: `bash init.sh`

## Commands
- **Build**: `{{BUILD_COMMAND}}`
- **Test**: `{{TEST_COMMAND}}`
- **Lint**: `{{LINT_COMMAND}}`

{{LINT_WARNING}}

## Boundaries
| Before you... | Read this first |
|---|---|
| Understand business context | `docs/1-requirements/project_overview.md` |
| Understand detailed requirements | `docs/1-requirements/requirements_analysis.md` |
| Touch architecture / DB / API | `docs/2-designs/` |
| Write or modify code | `docs/3-constraints/never-do.md` |
| Take risky action | `docs/3-constraints/ask-first.md` |
| Start a session | `docs/3-constraints/always-do.md` |
| Work on a feature | `docs/4-tasks/features/<TASK-NNN>/spec.md` |
| Resume a session | `docs/4-tasks/CURRENT_PLAN.md` |

## Workflow
1. If the dev server is not running, review the SessionStart diagnostic. Run the platform init script above only when a human explicitly chooses to start the environment.
2. Read `docs/4-tasks/CURRENT_PLAN.md`.
3. Read the active feature `spec.md`.
4. Read `docs/2-designs/` if the task touches API or DB behavior.
5. Check `docs/3-constraints/never-do.md` before non-trivial changes.
6. Run affected checks; reuse passing results when relevant inputs/conditions are unchanged. Full release gates follow project policy.
7. Update `docs/4-tasks/features/<active-task>/tasks.md` as work progresses.
8. Update `docs/4-tasks/CURRENT_PLAN.md` when the feature is complete.

{{SUBMODULE_INDEX}}
```

---


**PowerShell startup command contract**
- `{{STARTUP_COMMAND_PS1}}` must be valid in both Windows PowerShell 5.1 and PowerShell 7+.
- Do not use Bash-only separators such as `&&` in `{{STARTUP_COMMAND_PS1}}`.
- Do not append stdout/stderr redirection to `{{STARTUP_COMMAND_PS1}}`; this template redirects stdout and stderr via `Start-Process`.
- For subdirectory startup, use `Set-Location -LiteralPath 'subdir'; <command>`.

**Shell startup command contract**
- `{{STARTUP_COMMAND}}` is only for `init.sh` and may use POSIX shell syntax such as `cd subdir && <command>`.
- Do not add untested heredoc-based environment extraction to this template. If environment extraction is required later, pass arguments before the heredoc, e.g. `python3 - "$WORKSPACE_XML" << 'EOF'` and close with `EOF` on its own line.
**Health check contract**
- Treat the dev server as ready when the configured port is reachable, not only when the configured URL returns HTTP 200.
- Many apps protect `/` with authentication and may return 401/403 while the server is correctly running.
---

## init.sh template

```bash
#!/bin/bash
# =============================================================================
# init.sh — AI Agent environment bootstrap
# macOS/Linux/WSL/Git Bash path. Windows PowerShell should use .\init.ps1.
# =============================================================================
APP_PORT={{APP_PORT}}
HEALTH_CHECK_URL="{{HEALTH_CHECK_URL}}"
STARTUP_COMMAND="{{STARTUP_COMMAND}}"
LOG_DIR="logs"
LOG_FILE="$LOG_DIR/dev_server.log"
HEALTH_TIMEOUT=60

set -euo pipefail
echo "[init] Bootstrapping {{PROJECT_NAME}}..."

MISSING=()
{{TOOL_CHECKS}}
if [ ${#MISSING[@]} -gt 0 ]; then
  echo "[ERROR] Missing tools: ${MISSING[*]}"
  exit 1
fi

PORT_PID=""
if command -v lsof >/dev/null 2>&1; then
  PORT_PID=$(lsof -t -i:"$APP_PORT" 2>/dev/null || true)
fi
PORT_IN_USE=false
if [ -n "$PORT_PID" ]; then
  PORT_IN_USE=true
elif (exec 3<>"/dev/tcp/localhost/$APP_PORT") 2>/dev/null; then
  exec 3>&-
  exec 3<&-
  PORT_IN_USE=true
fi
if [ "$PORT_IN_USE" = true ]; then
  OWNER=""
  [ -n "$PORT_PID" ] && OWNER=" (PID $PORT_PID)"
  echo "[ERROR] Port $APP_PORT is already in use$OWNER."
  echo "[ERROR] Stop that process yourself or configure a different port, then run this script again."
  exit 1
fi

mkdir -p "$LOG_DIR"
nohup sh -c "$STARTUP_COMMAND" > "$LOG_FILE" 2>&1 &
echo "[init] Server starting (PID $!, logs -> $LOG_FILE)"

COUNT=0
until [ $COUNT -ge $HEALTH_TIMEOUT ]; do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$HEALTH_CHECK_URL" 2>/dev/null || echo "000")
  [ "$STATUS" != "000" ] && { echo "[init] Server reachable at $HEALTH_CHECK_URL (HTTP $STATUS)"; break; }
  sleep 1
  COUNT=$((COUNT+1))
done

if [ $COUNT -ge $HEALTH_TIMEOUT ]; then
  echo "[ERROR] Server not healthy after ${HEALTH_TIMEOUT}s - check $LOG_FILE"
  exit 1
fi

echo ""
echo "[init] -- Git status --------------------------------"
git status -s
echo ""
echo "[init] -- Recent commits ----------------------------"
git log -n 3 --oneline
echo ""
echo "[init] Environment ready."
```

---

## init.ps1 template

```powershell
# =============================================================================
# init.ps1 - AI Agent environment bootstrap
# Windows path. Run on demand when the dev server needs starting.
# =============================================================================
$APP_PORT = {{APP_PORT}}
$HEALTH_CHECK_URL = "{{HEALTH_CHECK_URL}}"
$STARTUP_COMMAND = "{{STARTUP_COMMAND_PS1}}"
$LOG_DIR = "logs"
$STDOUT_LOG = Join-Path $LOG_DIR "dev_server.out.log"
$STDERR_LOG = Join-Path $LOG_DIR "dev_server.err.log"
$HEALTH_TIMEOUT = 60

$ErrorActionPreference = "Stop"
Write-Host "[init] Bootstrapping {{PROJECT_NAME}}..."

$Missing = @()
{{TOOL_CHECKS_PS1}}
if ($Missing.Count -gt 0) {
  Write-Host "[ERROR] Missing tools: $($Missing -join ', ')"
  exit 1
}

$PortPids = @()
try {
  $PortPids = Get-NetTCPConnection -LocalPort $APP_PORT -State Listen -ErrorAction Stop |
    Select-Object -ExpandProperty OwningProcess -Unique
} catch {}

$PortInUse = $PortPids.Count -gt 0
if (-not $PortInUse) {
  $Probe = $null
  try {
    $Probe = [System.Net.Sockets.TcpClient]::new()
    $Connect = $Probe.BeginConnect("127.0.0.1", $APP_PORT, $null, $null)
    if ($Connect.AsyncWaitHandle.WaitOne(500, $false)) {
      $Probe.EndConnect($Connect)
      $PortInUse = $true
    }
  } catch {
  } finally {
    if ($Probe) { $Probe.Close() }
  }
}

if ($PortInUse) {
  $Owner = if ($PortPids.Count -gt 0) { " (PID $($PortPids -join ', '))" } else { "" }
  Write-Host "[ERROR] Port $APP_PORT is already in use$Owner."
  Write-Host "[ERROR] Stop that process yourself or configure a different port, then run this script again."
  exit 1
}

if (-not (Test-Path $LOG_DIR)) {
  New-Item -ItemType Directory -Path $LOG_DIR | Out-Null
}

$ShellCommand = Get-Command pwsh -ErrorAction SilentlyContinue
if (-not $ShellCommand) { $ShellCommand = Get-Command powershell -ErrorAction Stop }

$StartParams = @{
  FilePath = $ShellCommand.Source
  ArgumentList = @("-NoProfile", "-NoExit", "-ExecutionPolicy", "Bypass", "-Command", $STARTUP_COMMAND)
  WorkingDirectory = (Get-Location).Path
  PassThru = $true
}
$Process = Start-Process @StartParams

Write-Host "[init] Server starting in a new window..."

$Count = 0
while ($Count -lt $HEALTH_TIMEOUT) {
  try {
    $TcpClient = [System.Net.Sockets.TcpClient]::new()
    $Connect = $TcpClient.BeginConnect("localhost", $APP_PORT, $null, $null)
    if ($Connect.AsyncWaitHandle.WaitOne(1000, $false)) {
      $TcpClient.EndConnect($Connect)
      $TcpClient.Close()
      Write-Host "[init] Server reachable on port $APP_PORT"
      break
    }
    $TcpClient.Close()
  } catch {}
  Start-Sleep -Seconds 1
  $Count += 1
}

if ($Count -ge $HEALTH_TIMEOUT) {
  Write-Host "[ERROR] Server not healthy after ${HEALTH_TIMEOUT}s."
  Write-Host "[ERROR] Please check the popped backend window for startup errors."
  exit 1
}

Write-Host ""
Write-Host "[init] -- Git status --------------------------------"
git status -s
Write-Host ""
Write-Host "[init] -- Recent commits ----------------------------"
git log -n 3 --oneline
Write-Host ""
Write-Host "[init] Environment ready."
```

---

## .codex/hooks.json template

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "node .codex/session-start.js",
            "async": false,
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

---

## .codex/session-start.js template

```javascript
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const APP_PORT = {{APP_PORT}};

try {
  let isRunning = false;
  let pid = '';
  if (process.platform === 'win32') {
    try {
      const output = execSync(`netstat -ano | findstr :${APP_PORT}`, { stdio: ['pipe', 'pipe', 'ignore'] }).toString();
      for (const line of output.split('\n')) {
        if (line.includes('LISTENING')) {
          const parts = line.trim().split(/\s+/);
          pid = parts[parts.length - 1];
          isRunning = true;
          break;
        }
      }
    } catch {}
  } else {
    try {
      pid = execSync(`lsof -t -i:${APP_PORT}`, { stdio: ['pipe', 'pipe', 'ignore'] }).toString().trim();
      if (pid) isRunning = true;
    } catch {}
  }

  if (isRunning) {
    console.log(`✓ Dev server running on port ${APP_PORT} (PID ${pid})`);
  } else {
    console.log(`⚠️  Service not started: no listener on port ${APP_PORT}.`);
    console.log(`   Start manually when needed:`);
    console.log(`   Windows: pwsh -ExecutionPolicy Bypass -File .\\init.ps1`);
    console.log(`   macOS/Linux/WSL/Git Bash: bash init.sh`);
  }
} catch {}

try {
  const branch = execSync('git branch --show-current', { stdio: ['pipe', 'pipe', 'ignore'] }).toString().trim();
  console.log('\n── Branch & status ────────────────────────────────');
  console.log(`Branch: ${branch || 'unknown'}`);
  const status = execSync('git status --short', { stdio: ['pipe', 'pipe', 'ignore'] }).toString().trim();
  if (status) console.log(status.split('\n').slice(0, 10).join('\n'));
} catch {}

try {
  console.log('\n── Recent commits ──────────────────────────────────');
  console.log(execSync('git log -n 3 --oneline', { stdio: ['pipe', 'pipe', 'ignore'] }).toString().trim());
} catch {}

try {
  console.log('\n── Active task ─────────────────────────────────────');
  const planPath = path.join(process.cwd(), 'docs', '4-tasks', 'CURRENT_PLAN.md');
  if (fs.existsSync(planPath)) {
    const lines = fs.readFileSync(planPath, 'utf8').split('\n');
    let found = false;
    let printed = 0;
    for (const line of lines) {
      if (line.startsWith('## Active feature')) found = true;
      if (found) {
        console.log(line);
        printed += 1;
        if (printed > 10) break;
      }
    }
  } else {
    console.log('No CURRENT_PLAN.md found — run /new-task to create your first task.');
  }
} catch {}

console.log('');
```

---

## docs/1-requirements/project_overview.md template

```markdown
# 项目说明 (Project Overview)

## 1. 项目背景 (Background)
<!-- 描述为什么建设该项目，解决什么核心痛点 -->

## 2. 总体建设目标 (Goals)
- 目标 1
- 目标 2

## 3. 核心业务大盘 (Core Business Context)
<!-- 描述系统的业务流向、关键参与方与核心价值链 -->
```

---

## docs/1-requirements/requirements_analysis.md template

```markdown
# 需求分析 (Requirements Analysis)

## 1. 业务场景描述 (Scenarios)
<!-- 详细的用户故事和使用场景 -->

## 2. 用户角色与用例 (User Roles & Use Cases)
| 角色名称 | 职责描述 | 核心用例 |
|---|---|---|
| 管理员 | 系统管理 | 用户审核、系统配置 |
| 普通用户 | 日常使用 | 数据录入、报表查看 |

## 3. 系统核心业务流 (Core Business Flow)
<!-- 描述系统的跨模块业务协作逻辑 -->
```

---

## docs/2-designs/architecture.md template

```markdown
# 系统架构设计 (System Architecture)

## 1. 分层规则 (Layered Architecture Rules)
- **Controller / 接口层**：只负责路由转发、入参校验，禁止包含业务逻辑。
- **Service 业务逻辑层**：具体业务实现，封装事务。
- **Manager 通用管理层**（可选）：下沉通用逻辑、第三方调用或多表事务包装。
- **Repository / Mapper 数据持久层**：纯粹数据库操作，禁止包含业务逻辑。

## 2. 架构图 (Architecture Diagrams)
<!-- 使用 Mermaid 描述部署与逻辑分层关系 -->
```

---

## docs/2-designs/db_schema.md template

```markdown
# 数据库设计 (Database Schema)

## 1. 建表基线与设计原则 (Conventions)
- **命名规范**：下划线命名，如 `user_id`。
- **通用字段**：优先统一主键、创建时间、更新时间、逻辑删除字段。
- **物理外键**：默认不使用物理外键约束，由应用层维护关系。

## 2. ER 实体关系图 (Entity Relationship Diagram)
<!-- 使用 Mermaid ER 语法 -->

## 3. 已扫描的数据表结构 (Scanned Database Tables)
{{SCANNED_DB_TABLES}}
```

---

## docs/2-designs/api_contract.md template

```markdown
# 接口设计与契约 (API Contract)

## 1. 全局设计原则 (API Design Guidelines)
- **协议与前缀**：记录已扫描项目的实际协议与路由前缀，不自动新增 `/api/v1`。
- **响应体格式**：沿用当前契约；初始化文档不改变已有响应结构。
- **错误行为**：记录实际错误语义；尚未确定的契约明确标为待设计，不凭模板推断。

## 2. 已扫描的接口清单 (Scanned API Endpoints)
{{SCANNED_APIS}}
```

---

## docs/2-designs/ui_prototype.md template

```markdown
# 原型与 UI 设计 (UI/UX Mockups)

## 1. 交互原型与视觉稿链接
- Figma: `Figma_URL`
- Axure / 原型链接: `Axure_URL`

## 2. 核心交互流程截图
<!-- 嵌入核心截图或外链 -->
```

---

## docs/3-constraints/never-do.md template

```markdown
# Never Do

🚫 These are absolute prohibitions. No exceptions.

## Security & secrets
- 🚫 Commit secrets, credentials, API keys, or tokens to the repository
- 🚫 Log sensitive user data in plain text
- 🚫 Skip server-side validation on public APIs

## File boundaries
- 🚫 Edit generated directories such as `node_modules/`, `vendor/`, `dist/`, `target/`
- 🚫 Change CI, deployment or production behavior beyond the existing authorization
- 🚫 Expand the delivery goal without agreement; necessary related file edits belong to the authorized task

## Database & API design contracts
- 🚫 Change API request or response structures without updating `docs/2-designs/api_contract.md`
- 🚫 Change database schema or entity constraints without updating `docs/2-designs/db_schema.md`
- 🚫 Change schema-affecting code without a corresponding migration when the project uses migrations

## Tests
- 🚫 Delete or weaken tests to hide defects; obsolete or equivalent tests may be consolidated with a reason
- 🚫 Replace assertions with logs
- 🚫 Copy task-numbered tools/tests or add expensive routine checks without a concrete benefit
```

---

## docs/3-constraints/ask-first.md template

```markdown
# Ask First

⚠️ Confirm these boundaries only when existing authorization does not cover them.
Necessary local edits, affected checks and local commits within the agreed task may proceed.

## Dependencies
- ⚠️ Add a new dependency or plugin
- ⚠️ Upgrade a major dependency version

## Architecture & structure
- ⚠️ Introduce a new architectural layer or abstraction
- ⚠️ Rename or move public interfaces/modules in a way that affects external compatibility
- ⚠️ Add a new service or submodule

## Database & API contracts
- ⚠️ Add or modify API endpoints in a breaking way
- ⚠️ Create, modify, or delete migration files
- ⚠️ Change entity field types, names, or constraints
- ⚠️ Add or remove indexes

## CI / deployment
- ⚠️ Change CI scope, deployment behavior or environment configuration outside the agreed task
- ⚠️ Add spending or exceed agreed remote-run limits
- ⚠️ Change production or staging environment configuration
- A specifically approved execution chain covers its agreed steps; do not ask at every step.
  Material scope/candidate changes require reconsideration; merge/CI approval is not production approval.
```

---

## docs/3-constraints/always-do.md template

```markdown
# Always Do

✅ These behaviors are mandatory in every session.

## Session start
- ✅ Let the `.codex` SessionStart hook inject git state and current-plan context
- ✅ If the service is not running, report that state and leave environment startup to an explicit human decision
- ✅ Read `docs/4-tasks/CURRENT_PLAN.md` and the active feature `spec.md`
- ✅ Read `docs/2-designs/` before changing API or DB behavior
- ✅ Check `docs/3-constraints/never-do.md` before non-trivial changes

## Before committing
- ✅ Run affected tests/lint; documentation-only edits need documentation checks, not application regression
- ✅ Reuse passing results only when relevant source, dependencies and conditions are unchanged; release candidates still follow project gates
- ✅ Confirm no secrets are staged
- ✅ Update `docs/4-tasks/features/<active-task>/tasks.md`
- ✅ Keep only current state in `docs/4-tasks/CURRENT_PLAN.md`; detailed history belongs in the existing task report
- ✅ Keep `docs/2-designs/` in sync with implementation when contracts change

## General
- ✅ Use explicit types where the stack expects them
- ✅ Define constants for repeated values
- ✅ Verify changed behavior and add/update regression tests when they protect a meaningful risk
- ✅ Assess execution/maintenance cost before adding tools or gates; after two failures of the same cause, reassess before another remote run
- ✅ Sync long-lived Harness documents (`docs/1-requirements/`, `docs/2-designs/`, `docs/3-constraints/`, `AGENTS.md`) whenever you change what they describe — do not defer documentation updates to later.
```

---

## docs/3-constraints/adr/TEMPLATE.md template

```markdown
# ADR-000: [Decision title]

**Date**: YYYY-MM-DD
**Status**: Proposed | Accepted | Deprecated | Superseded by ADR-XXX

## Context
What situation or problem forced this decision?

## Decision
What did we decide to do?

## Constraints for agents
- 🚫 MUST NOT: ...
- ⚠️ ASK FIRST before: ...
- ✅ ALWAYS: ...

## Rationale
Why this option over the alternatives?

## Consequences
What becomes easier or harder as a result?
```

---

## docs/4-tasks/CURRENT_PLAN.md template

```markdown
# Current Plan

> Session entry point. Read this first every session.

## Active feature
_None yet — run `/new-task` to create your first task._

## Stages
<!-- Features are added here automatically by /new-task -->

## Completed
<!-- Move finished features here with completion date -->

## Notes for next session
<!-- Context the next agent session will need -->
```

---

## docs/4-tasks/features/README.md template

```markdown
# Features

Each feature directory is created by `/new-task`.

## Structure

```text
TASK-{NNN}-{slug}/
├── spec.md
└── tasks.md
```

## Active task

See `../CURRENT_PLAN.md`.
```

---

## Submodule AGENTS.md template

```markdown
# AGENTS.md — {{MODULE_NAME}}

> Supplements the root `AGENTS.md`. All root rules apply unless explicitly overridden.

## Module context
- **Purpose**: {{MODULE_PURPOSE}}
- **Port**: {{MODULE_PORT}}
- **Entry point**: `{{MODULE_ENTRY_CLASS}}`

## Commands
- **Run**: `{{MODULE_RUN_COMMAND}}`
- **Test**: `{{MODULE_TEST_COMMAND}}`

## Documentation
- Requirements: root `docs/1-requirements/`
- Designs: root `docs/2-designs/`
- Constraints: root `docs/3-constraints/`
- Tasks: root `docs/4-tasks/`
```
