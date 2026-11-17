# Codex Harness Workflow

> 一套用 Markdown、项目文档和任务契约组织人机协作的 Agent Coding SOP。

Codex Harness Workflow 包含 `init-harness`、`new-task` 和 `subagent-orchestrator` 三个核心 Skill，以及按需清理和优化的 `project-maintenance`。它的首个完整参考实现面向 Codex；但它的核心不是某个工具的专属 API，而是一套可以迁移到其他 Coding Agent 的协作流程：

```text
建立项目 Harness → 把需求变成契约 → 按依赖实施、验证并留痕
 init-harness          new-task          subagent-orchestrator
```

作者关心的不是“AI 能不能写代码”，而是另一个问题：

> 当一个长项目跨越多个会话、多个功能和多个 Agent 时，怎样避免上下文漂移，让需求、设计、规则、任务进度和验证结论在前后协作中保持一致？

[English](README.md)

**当前版本：v0.1.0-beta。** Codex 是当前完整验证的参考实现；作者也在个人实践中将这套 Skill 适配到 Claude Code、Antigravity 等 Coding Agent。

## 灵感来源

这套工作流来自真实开发实践，也受到以下代表性文章和工程方法的启发：

- [Thoughtworks：Spec-driven development](https://www.thoughtworks.com/en-gb/insights/blog/agile-engineering-practices/spec-driven-development-unpacking-2025-new-engineering-practices)
- [GitHub Spec Kit](https://github.github.com/spec-kit/index.html)
- [Anthropic：Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Anthropic：Harness design for long-running application development](https://www.anthropic.com/engineering/harness-design-long-running-apps)
- [Agents.md Guide for Java and Spring Boot Developers](https://josealopez.dev/en/blog/agents-md-java-spring-boot)

它们分别启发了本项目的几个方向：Vibe Coding 的流畅探索、Spec-driven Development 的“规格—计划—任务—实现”、Harness Engineering 的外部结构化状态与验证围栏，以及 `AGENTS.md` 等项目内指令文件的渐进式上下文组织。传统软件工程中的文档先行、契约先行、前后端分离、Code Review、测试与验收，则构成了这套 SOP 的流程骨架。

本项目不是对任何一套方案的复制，而是将这些思路结合真实项目维护经验形成的实现。

## 它为长项目带来什么

这套 SOP 的核心目标，是降低长项目在跨会话、跨功能、跨 Agent 开发中发生的**上下文漂移**：避免同一项目的需求、设计、代码风格、接口契约、任务状态和验证结论在不同阶段逐渐说法不一。

它通过把关键协作状态外置、分层并留痕，提升 AI 辅助编码过程的稳定性、可靠性和可复核性。它不承诺自动写出无误代码，也不取代开发者对业务、风险和最终交付的判断；它让这些判断有更稳定的依据，并让协作过程可以回看。

| 长项目中容易发生的漂移或失真 | 工作流的稳定性机制 | 可检查、可审计的痕迹 |
| --- | --- | --- |
| 新会话或新 Agent 不知道之前为什么这样设计 | 将高频事实、长期设计与当前任务分层保存，并按需读取 | `AGENTS.md`、设计文档、`CURRENT_PLAN.md` |
| 团队代码风格、分层边界和已知坑逐渐被忽略 | 将规则分为 `always-do`、`ask-first`、`never-do`，并可同步外部规范 | 约束文档、规则来源和项目本地补充 |
| 一个新功能改变了 API、数据库或 UI，但长期文档没有同步 | 在规划任务时识别文档影响，把文档更新排在实现之前或一起完成 | 文档影响记录、`spec.md`、`tasks.md` |
| 前端、后端和测试从同一句自然语言得出不同理解 | 将范围、非目标、验收标准和共享契约先确认，再进入实现 | API/数据库/UI 的契约任务与验收标准 |
| 多 Agent 并行修改时互相覆盖，或在未稳定的前提上各自实现 | 先识别依赖并稳定共享契约，只让写入范围不重叠的任务并行 | 任务依赖、所有权边界、实际差异与审查记录 |
| Agent 把“代码已生成”说成“需求已完成” | 将测试、构建、Lint、浏览器验收和未完成项分别记录 | 通过、失败和未验证的验证证据 |
| 日后只能从 Git diff 猜测一个改动的原因与完成过程 | 将需求、决策、任务状态和验证结果关联到代码变更 | Git 提交之外的协作审计链 |

## 1. 上下文不是越多越好，而是要按需读取

`AGENTS.md` 很适合保存项目级、高频、每次会话都值得读取的信息，例如项目定位、可运行模块、常用命令、重要规则和文档导航。

但它不适合成为无限增长的知识库。若把零碎需求、历史决策、数据库细节、当前任务和全部团队规范都堆进一个文件，Agent 会持续加载大量与当前工作无关的信息，反而降低上下文的有效信息密度。

因此，这套 Harness 将 `AGENTS.md` 定义为：

> 高频规则 + 会话入口 + 上下文导航

详细的需求、架构、数据库、API、UI、约束和任务状态放在相应文档中，Agent 根据当前任务逐步读取。这不是让 `AGENTS.md` 变成空索引，而是让每一类信息放在最适合维护和加载的位置。

## 2. 让 Agent 遵守团队规范，而不是只会生成通用代码

AI 能生成可运行代码，不代表它天然知道当前团队的命名方式、分层边界、测试习惯、历史踩坑和敏感操作限制。

`init-harness` 的约束层用于把这些经验显式化。它可以从 GitHub 等外部规则源导入基础代码规范和常见问题，再与项目本地规则结合，并组织为三个层级：

- `always-do`：每次编码都应遵守的规则；
- `ask-first`：可能改变业务、数据、安全或运行环境时必须先询问的规则；
- `never-do`：明确禁止的操作。

默认可以使用作者维护的 `dev-standards` 作为基础来源；用户可以提供自己的地址，也可以明确关闭外部规则导入。目标不是堆积通用提示词，而是让 Agent 在编码前读到与当前团队有关的约束和已知风险。

## 3. 用任务契约同步信息，而不是靠转述同步信息

多 Agent 协作的难点不是“多开几个 Agent”，而是它们依据什么做出一致决定。

这套工作流把规格、验收标准、任务清单、长期设计文档和任务进度作为共享外部状态。前端、后端和测试不必各自翻译一句自然语言需求，而应从同一份已确认契约领取工作。

这不能保证零冲突，但能把冲突从“做完后才发现理解不同”，前移为“开始前先确认契约和依赖”。

任务生命周期借鉴了 A2A 的任务化通信与状态思想，但本项目不实现或宣称兼容标准 A2A 协议。

## 4. 留痕：作为 Git 提交记录的补充

Git 擅长记录“哪些文件在何时发生变化”，但不一定完整说明：这个改动对应哪个需求、为什么这样设计、验收过什么、还有哪些验证没有完成。

Harness 文档、功能规格、任务状态和验证结果补充了这一层语义。它们不取代 Git，而是让开发者或新的 Agent 能把一次代码变更重新放回需求、设计和验收上下文中理解，便于审查、交接、回溯和继续迭代。

## 三个 Skill 如何协作

```mermaid
flowchart LR
    A[开发者提出目标] --> B[init-harness]
    B --> C[分层项目上下文与约束]
    C --> D[new-task]
    D --> E[规格 验收标准 任务清单]
    E --> F[subagent-orchestrator]
    F --> G[契约优先的实现 审查 验证]
    G --> H[任务状态与证据]
    H --> I[开发者确认结果]
```

| Skill | 核心职责 | 关键产物 |
| --- | --- | --- |
| `init-harness` | 建立项目基线、约束与分层上下文 | `AGENTS.md`、设计文档、约束层、初始化环境、任务目录 |
| `new-task` | 将需求变成经人确认的功能契约 | `spec.md`、验收标准、`tasks.md`、文档影响记录 |
| `subagent-orchestrator` | 按依赖组织实现、审查、验证与任务关闭 | 实际代码差异、验证证据、任务完成状态 |
| `project-maintenance` | 在约定范围内简化现有代码、测试或产物 | 可审阅改动、实际收益及验证边界 |

## `init-harness` 会生成什么

`init-harness` 会先扫描真实项目，再在项目根目录建立下列 Harness。已有 `AGENTS.md` 或约束文件不会被静默覆盖：需要替换时会先展示差异并征得确认；替换 `AGENTS.md` 前会创建不覆盖旧文件的备份。

```text
<project-root>/
├── AGENTS.md
├── init.sh
├── init.ps1
├── .codex/
│   ├── hooks.json
│   └── session-start.js
└── docs/
    ├── 1-requirements/
    │   ├── project_overview.md
    │   └── requirements_analysis.md
    ├── 2-designs/
    │   ├── architecture.md
    │   ├── db_schema.md
    │   ├── api_contract.md
    │   └── ui_prototype.md
    ├── 3-constraints/
    │   ├── always-do.md
    │   ├── ask-first.md
    │   ├── never-do.md
    │   └── adr/
    │       └── TEMPLATE.md
    └── 4-tasks/
        ├── CURRENT_PLAN.md
        └── features/
            └── README.md
```

| 区域 | 用途 | 变化频率 |
| --- | --- | --- |
| `AGENTS.md` | 高频规则、项目命令、文档导航与当前工作入口；保持简短，不承载全部细节 | 低 |
| `docs/1-requirements/` | 项目目标、业务范围和需求分析，回答“为什么做、要做什么” | 中 |
| `docs/2-designs/` | 架构、数据库、API、UI 契约，回答“准备怎样做” | 中 |
| `docs/3-constraints/` | 团队经验和操作边界：必须做、先询问、禁止做 | 低到中 |
| `docs/3-constraints/adr/` | 关键架构决定及其原因，避免后续只看结果、不知道取舍 | 中 |
| `docs/4-tasks/CURRENT_PLAN.md` | 当前正在推进什么、下一步是什么，供新会话快速恢复状态 | 高 |
| `docs/4-tasks/features/` | 每个功能的 `spec.md`、`tasks.md` 与验收、进度记录 | 高 |
| `init.sh` / `init.ps1` | 由人显式触发的环境启动入口；不会自动终止占用端口的进程 | 按环境变化 |
| `.codex/` | Codex 参考实现的轻量会话启动提示；其他 Agent 可按自己的 Hook 或启动机制适配 | 运行时相关 |

可运行的后端服务或前端应用还会获得各自的 `AGENTS.md`，让局部模块的命令和边界不必全部堆在根目录。整体上，这个目录把协作信息分为三层：**长期项目事实**（需求与设计）、**长期行为边界**（约束）和**高频动态状态**（任务）；Agent 根据工作阶段读取相应层次。

## 三个 Skill 如何在真实开发中演化

在真实项目中，三个 Skill 不是一次性设计完成的，而是随着上下文维护、任务规划和多 Agent 协作的实际问题逐步演化出来的。

### 第一步：先让 Agent 认识真实项目 —— `init-harness`

项目里已经有代码、配置、数据库、接口、页面和历史规则。只靠一次对话描述，Agent 容易遗漏事实；每换一个会话，开发者又要重新介绍项目入口、命令和限制。

`init-harness` 的第一目标是扫描真实工程，而不是根据一句描述猜测项目。它为项目建立一个可持续使用的 Harness：

- 根目录和必要子模块的 Agent 指令；
- 需求、架构、数据库、API、UI/UX 等长期文档；
- 当前计划和功能任务目录；
- `always-do`、`ask-first`、`never-do` 三类约束；
- SessionStart 上下文和跨平台初始化脚本。

### 第二步：先规划任务，再让文档跟着功能演化 —— `new-task`

`new-task` 最初来自作者对 Plan 模式和 Spec-driven Development 的实践：在开始实现前，先把自然语言需求整理为范围、规格、验收标准和任务清单，而不是直接进入编码。

随后在真实开发中，作者发现每创建一个新任务，项目的需求、架构、数据库、API、UI 或约束文档都可能需要同步更新。若任务规划和文档维护彼此脱节，长期仍要靠开发者记忆并手工补齐，维护成本很高。

因此，`new-task` 被进一步设计为“任务契约 + 文档先行”的流程：

1. 阅读项目 Harness 和当前任务状态；
2. 判断本次需求会影响哪些长期文档；
3. 起草范围、非目标、边界条件和验收标准；
4. 把会改变业务、权限、数据、API、体验或验收结果的选择交给人确认；
5. 在确认实施方案后，生成 `spec.md` 和 `tasks.md`；
6. 将实现、文档更新和验证任务一起纳入任务清单。

这样，文档不再只是项目开始时写一次的说明；每个新任务在进入实现前，先明确需要更新哪些长期契约，并把这些更新和代码、验证任务一起纳入实施过程。

### 第三步：先稳定契约，再协同开发 —— `subagent-orchestrator`

后来，作者开始频繁进行多 Agent 协同开发，又遇到两个问题：信息怎样同步，以及并发修改怎样避免互相打架。

工作流的答案不是让所有 Agent 同时开工，而是先建立共享外部状态：规格、验收标准、任务清单、长期设计文档和结构化任务进度。任务是否完成用明确状态记录，例如 `passes: true/false`，而不是只靠一句“已经完成”。

对于前后端、数据库和接口共同涉及的功能，先识别依赖关系，稳定 API、数据模型、权限和行为契约；再让写入范围不重叠、依赖已经满足的任务并行推进。这借鉴了实际前后端分离开发的流程：**先约定契约，再分别实现，最后联调和验收。**

`subagent-orchestrator` 因此负责：按依赖组织 Agent、限制写入边界、检查实际差异、独立审查、有限修复，以及依据证据关闭任务。

### 交付后的项目维护

`project-maintenance` 适合有明确范围的维护工作，例如收敛过时的任务文档、简化重复代码或测试，以及回收可重建产物。可以在项目根目录直接使用，先核对现有用途，再用项目已有检查和证据验证结果。

这次更新来自项目收尾时的三个问题。

- 部分 SessionStart Hook 在本地服务未启动时提前退出，会漏掉当前任务。新模板将端口探测与任务预览分开，限制 `CURRENT_PLAN.md` 的输出。
- 进度在计划、清单和报告里反复更新，容易出现不一致。计划作为任务包入口，报告原位更新现态，保留验收证据和恢复链接。
- 合入后，主目录有本地改动会阻断快进。证据移交与工作树移除分别核验，满足条件的任务工作树可继续回收。项目可选择归档位置，启用前验证构建、扫描和打包的排除边界。

新增解析器、封装或并发框架前，先确认它要填补的验收缺口。CI 等待中断后继续跟踪同一 run 和 attempt，让验证结果对应到实际运行。

## 迁移到 Claude Code、Antigravity 或其他 Coding Agent

这套 Skill 的核心是 SOP，不是 Codex 专属的命令。Markdown 文档结构、任务契约、验收标准、任务状态、契约先行和依赖排序本身都可以复用。

迁移时，不需要开发者先研究各个平台的全部机制。可以直接让目标 Coding Agent 执行类似这样的请求：

```text
请阅读这三个 Skill：init-harness、new-task、subagent-orchestrator。
扫描你当前运行环境中项目指令、会话初始化、子 Agent、浏览器验证和任务状态管理的原生能力，
保持三个 Skill 的流程与产物契约不变，并为当前环境生成最小适配方案。
对于没有等价能力的步骤，明确标记为不可用或未完成，不要伪造执行结果。
```

目标 Agent 应自行完成的适配包括：

| 这套 SOP 的概念 | 目标 Agent 需要映射的能力 |
| --- | --- |
| `AGENTS.md` 与嵌套指令 | 该 Agent 的项目指令文件、规则发现方式或兼容读取策略 |
| SessionStart 与初始化脚本 | 会话 Hook、启动 Prompt、项目启动命令，或明确没有等价能力 |
| 子 Agent 编排 | 创建、通信、等待、停止和并发控制能力 |
| 浏览器验收 | 可用的真实浏览器、截图、交互和控制台检查能力 |
| 任务状态 | 继续使用仓库中的 Markdown/JSON 契约，或提供等价且可审计的状态记录 |

作者已在个人实践中让 Claude Code、Antigravity 等 Agent 安装并适配这些 Skill。当前仓库仍只把 Codex 标为“完整验证的参考实现”：其他运行时可以迁移这套 SOP，但是否达到完整支持，应以该运行时实际的适配文件和验收证据为准。详见[跨 Agent 适配说明](docs/portability.md)。

## 与传统软件开发流程的关系

这套工作流没有试图替代传统软件工程。它将原本就重要的工程活动，转换成 Agent 能读取、遵守和持续维护的协作契约。

| 传统研发活动 | 人负责什么 | Skill 如何参与 |
| --- | --- | --- |
| 项目调研与需求分析 | 说明业务目标，纠正事实 | `init-harness` 从代码和配置建立基线 |
| 架构、数据库、API、UI 设计 | 决定关键方案和取舍 | Harness 为长期设计提供固定位置和入口 |
| 需求评审 | 确认范围、权限、非目标和体验 | `new-task` 暴露歧义并形成规格 |
| 任务拆分与排期 | 决定优先级和交付范围 | `new-task` 生成对应验收标准的任务 |
| 前后端开发 | 处理重大例外和新增决策 | `subagent-orchestrator` 先契约后实施 |
| Code Review、联调与验收 | 判断风险是否可接受 | 差异检查、验证证据和真实未完成状态 |
| 交接与继续迭代 | 保持业务方向正确 | 文档、当前计划和任务状态承接下一次会话 |

敏捷开发、Code Review、测试、CI/CD 和团队管理仍然有效；这套 SOP 只是在 AI 参与开发时，为它们补上稳定的上下文、边界和交接方式。

## 真实使用案例

仓库包含一个真实 Java/Spring Boot、Vue/TypeScript、MySQL 全栈项目的完全脱敏快照：

- `init-harness` 建立了需求、架构、数据库、API、UI、约束和任务文档树；
- `new-task` 为一个现场检测功能生成了 6 条验收标准和 16 项任务；
- 任务创建阶段没有修改业务代码或数据库；
- 一个相邻的已实施模块记录了 23 项后端测试通过、前端构建与 Lint 通过；
- 浏览器初始化失败，因此桌面端、移动端和控制台检查如实保留为未完成。

这个案例证明的是上下文可追踪、任务可复核、行动边界明确，以及工作流不会把未验证内容宣称为完成。它不是性能 Benchmark：没有可靠的前后耗时、Token、缺陷率或人工成本基线，本项目不宣称效率提升百分比。

阅读[完整案例说明](docs/case-study-environmental-monitoring.md)、检查[脱敏证据包](examples/environmental-monitoring/)，或运行[最小任务看板示例](examples/minimal-task-board/)。

## 安装与快速开始

### Codex 参考实现

将 `skills/` 下的三个目录复制到 Codex Skill 目录，重启 Codex，然后在真实项目根目录依次使用：

需要维护流程时，另复制 `skills/` 下的 `project-maintenance`。可以在项目根目录说：`使用 project-maintenance 收敛任务报告，并验证保留的证据链接。`

```text
使用 init-harness 初始化这个项目。
```

审阅并确认生成的项目上下文后：

```text
使用 new-task 规划：增加一个由用户申请、管理员审核的退款功能。
```

确认规格和实施方案后：

```text
使用 subagent-orchestrator 实施 TASK-001。
```

Windows、macOS/Linux 安装命令、外部规范配置和浏览器能力选择，请查看[安装说明](docs/installation.md)。

### 其他 Coding Agent

将三个 Skill 放到目标 Agent 能访问的位置，先让它阅读三个 `SKILL.md`，再按上文的迁移提示完成最小适配。优先保留文档结构、任务契约和完成状态；会话 Hook、子 Agent 调度和浏览器工具则根据目标运行时能力替换。

## 什么时候适合使用

适合：

- 会跨多个会话完成、需要长期维护的代码库；
- 同时影响前端、后端、API 或数据库的中型和复杂功能；
- 需要多个 Agent 协作，并且在意写入边界和集成顺序；
- 需要用测试和真实验收证据说明完成状态的工作。

可能太重：

- 修改一个错别字；
- 不影响行为或契约的微小局部重构；
- 用完即丢、无需交接的实验；
- 还在探索想法、尚未需要形成长期项目状态的早期阶段。

v0.1.0 有意保持边界：不试图仅凭 Skill 覆盖 CI/CD、部署回滚、权限沙箱、成本分析或长期漂移监控。

## 仓库内容

| 路径 | 内容 |
| --- | --- |
| [`skills/init-harness`](skills/init-harness/) | 项目 Harness 初始化 Skill |
| [`skills/new-task`](skills/new-task/) | 功能规格与任务生成 Skill |
| [`skills/subagent-orchestrator`](skills/subagent-orchestrator/) | 多 Agent 实施、审查与验收 Skill |
| [`skills/project-maintenance`](skills/project-maintenance/) | 小范围清理优化与实际结果说明 |
| [`docs`](docs/) | 架构、安装、可移植性、案例和发布文档 |
| [`examples/environmental-monitoring`](examples/environmental-monitoring/) | 真实项目脱敏证据包 |
| [`examples/minimal-task-board`](examples/minimal-task-board/) | 可独立运行的最小工作流示例 |
| [`scripts/verify.ps1`](scripts/verify.ps1) | 仅供维护者在修改仓库或发布前执行的结构、链接、隐私和发布校验 |

如果你只是安装和使用 Skill，不需要运行这个脚本。维护者或贡献者在修改本仓库后可以运行：

```powershell
pwsh -File .\scripts\verify.ps1
pwsh -File .\scripts\verify.ps1 -Release
```

另请参阅[变更记录](CHANGELOG.md)、[v0.1.0-beta 发布说明](docs/releases/v0.1.0-beta.md)和[发布回归步骤](docs/release-smoke-test.md)。

## 项目与许可

Codex Harness Workflow 由 [weiqiang612](https://github.com/weiqiang612) 原始设计并维护，官方仓库为 [github.com/weiqiang612/codex-harness-workflow](https://github.com/weiqiang612/codex-harness-workflow)。

代码、Skill、模板和文档采用 [MIT License](LICENSE)。版权和许可证声明必须保留；修改版本不自动代表本项目官方版本，也不代表获得原作者背书。
