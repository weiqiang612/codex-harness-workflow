[CmdletBinding()]
param(
    [switch]$Release
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$skillsRoot = Join-Path $repoRoot 'skills'
$expectedSkills = @('init-harness', 'new-task', 'subagent-orchestrator')
$requiredPublicFiles = @(
    'README.md',
    'README.zh-CN.md',
    'CHANGELOG.md',
    'docs/architecture.md',
    'docs/installation.md',
    'docs/portability.md',
    'docs/case-study-environmental-monitoring.md',
    'docs/release-checklist.md',
    'docs/release-smoke-test.md',
    'docs/releases/v0.1.0-beta.md',
    'examples/environmental-monitoring/README.md',
    'examples/environmental-monitoring/harness-tree.md',
    'examples/environmental-monitoring/task-package/spec-excerpt.md',
    'examples/environmental-monitoring/task-package/tasks-excerpt.md',
    'examples/environmental-monitoring/verification-summary.md',
    'examples/minimal-task-board/README.md',
    'examples/minimal-task-board/package.json',
    'examples/minimal-task-board/server.js',
    'examples/minimal-task-board/public/index.html',
    'examples/minimal-task-board/test/server.test.js'
)
$errors = [System.Collections.Generic.List[string]]::new()
$warnings = [System.Collections.Generic.List[string]]::new()

function Add-ErrorMessage {
    param([string]$Message)
    $errors.Add($Message)
    Write-Output "ERROR: $Message"
}

function Add-WarningMessage {
    param([string]$Message)
    $warnings.Add($Message)
    Write-Output "WARN: $Message"
}

if (-not (Test-Path -LiteralPath $skillsRoot -PathType Container)) {
    Add-ErrorMessage "Missing skills directory: $skillsRoot"
}

foreach ($skillName in $expectedSkills) {
    $skillRoot = Join-Path $skillsRoot $skillName
    $skillFile = Join-Path $skillRoot 'SKILL.md'

    if (-not (Test-Path -LiteralPath $skillFile -PathType Leaf)) {
        Add-ErrorMessage "Missing $skillName/SKILL.md"
        continue
    }

    $content = Get-Content -LiteralPath $skillFile -Raw -Encoding utf8
    $frontmatterMatch = [regex]::Match($content, '\A---\s*\r?\n(?<frontmatter>.*?)\r?\n---\s*\r?\n', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    if (-not $frontmatterMatch.Success) {
        Add-ErrorMessage "$skillName has invalid or missing YAML frontmatter boundaries."
        continue
    }

    $frontmatter = $frontmatterMatch.Groups['frontmatter'].Value
    $nameMatch = [regex]::Match($frontmatter, '(?m)^name:\s*["'']?(?<name>[^"''\r\n]+)["'']?\s*$')
    $descriptionMatch = [regex]::Match($frontmatter, '(?m)^description:\s*(?<description>.+?)\s*$')

    if (-not $nameMatch.Success) {
        Add-ErrorMessage "$skillName frontmatter has no name."
    }
    elseif ($nameMatch.Groups['name'].Value.Trim() -cne $skillName) {
        Add-ErrorMessage "$skillName frontmatter name does not match its directory."
    }

    if (-not $descriptionMatch.Success -or [string]::IsNullOrWhiteSpace($descriptionMatch.Groups['description'].Value)) {
        Add-ErrorMessage "$skillName frontmatter has no description."
    }

    if ($content.Contains('\n-')) {
        Add-ErrorMessage "$skillName contains a literal \\n- sequence."
    }

    Write-Output "CHECKED: $skillName"
}

$unexpectedSkills = @(
    Get-ChildItem -LiteralPath $skillsRoot -Directory -ErrorAction SilentlyContinue |
        Where-Object { $expectedSkills -notcontains $_.Name }
)
foreach ($directory in $unexpectedSkills) {
    Add-WarningMessage "Unlisted skill directory: $($directory.Name)"
}

$expectedSkillReferences = @(
    'skills/init-harness/references/templates.md',
    'skills/new-task/references/templates.md'
)
foreach ($relativePath in $expectedSkillReferences) {
    if (-not (Test-Path -LiteralPath (Join-Path $repoRoot $relativePath) -PathType Leaf)) {
        Add-ErrorMessage "Missing Skill reference: $relativePath"
    }
}

foreach ($relativePath in $requiredPublicFiles) {
    $fullPath = Join-Path $repoRoot $relativePath
    if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
        Add-ErrorMessage "Missing public documentation or evidence file: $relativePath"
    }
}

$publicMarkdownFiles = @(
    Get-Item -LiteralPath (Join-Path $repoRoot 'README.md'), (Join-Path $repoRoot 'README.zh-CN.md') -ErrorAction SilentlyContinue
    Get-ChildItem -LiteralPath (Join-Path $repoRoot 'docs') -Recurse -File -Filter '*.md' -ErrorAction SilentlyContinue
    Get-ChildItem -LiteralPath (Join-Path $repoRoot 'examples') -Recurse -File -Filter '*.md' -ErrorAction SilentlyContinue
)

$privacyPatterns = @(
    @{ Pattern = 'DongRuanEnvironment'; Message = 'original project name' },
    @{ Pattern = '(?i)(?:[A-Z]:\\(?:Users|project)\\|[A-Z]:/(?:Users|project)/)'; Message = 'local machine path' },
    @{ Pattern = '(?i)com\.dongruan|东软'; Message = 'original organization identifier' },
    @{ Pattern = '(?i)\bNEP[SMGV]\b'; Message = 'original internal role code' },
    @{ Pattern = '(?i)gh[opsu]_[A-Za-z0-9]{20,}'; Message = 'GitHub token-like value' }
)

foreach ($file in $publicMarkdownFiles) {
    $content = Get-Content -LiteralPath $file.FullName -Raw -Encoding utf8
    $relativePath = [System.IO.Path]::GetRelativePath($repoRoot, $file.FullName)

    foreach ($rule in $privacyPatterns) {
        if ($content -match $rule.Pattern) {
            Add-ErrorMessage "$relativePath contains $($rule.Message)."
        }
    }

    foreach ($linkMatch in [regex]::Matches($content, '!?' + '\[[^\]]*\]\((?<target>[^)]+)\)')) {
        $target = $linkMatch.Groups['target'].Value.Trim()
        if ($target.StartsWith('<') -and $target.EndsWith('>')) {
            $target = $target.Substring(1, $target.Length - 2)
        }
        if ($target -match '^(?i:https?://|mailto:|#)') {
            continue
        }

        $pathPart = ($target -split '#', 2)[0]
        if ([string]::IsNullOrWhiteSpace($pathPart)) {
            continue
        }

        $resolvedTarget = Join-Path $file.DirectoryName ([System.Uri]::UnescapeDataString($pathPart))
        if (-not (Test-Path -LiteralPath $resolvedTarget)) {
            Add-ErrorMessage "$relativePath contains a broken relative link: $target"
        }
    }
}

if ($Release) {
    $releasePatterns = @(
        @{ Pattern = '(?i)(?:[A-Z]:\\Users\\|/Users/|/home/)'; Message = 'machine-specific user path' },
        @{ Pattern = '(?i)kill\s+-9'; Message = 'forced POSIX process termination' },
        @{ Pattern = '(?i)Stop-Process[^\r\n]*-Force'; Message = 'forced PowerShell process termination' },
        @{ Pattern = 'EquipTrack Backend Server'; Message = 'project-specific template residue' }
    )

    foreach ($file in Get-ChildItem -LiteralPath $skillsRoot -Recurse -File) {
        $content = Get-Content -LiteralPath $file.FullName -Raw -Encoding utf8
        $relativePath = [System.IO.Path]::GetRelativePath($repoRoot, $file.FullName)
        foreach ($rule in $releasePatterns) {
            if ($content -match $rule.Pattern) {
                Add-ErrorMessage "$relativePath contains $($rule.Message)."
            }
        }
    }

    $initSkillContent = Get-Content -LiteralPath (Join-Path $skillsRoot 'init-harness/SKILL.md') -Raw -Encoding utf8
    if ($initSkillContent -notmatch 'explicitly disables external standards' -or
        $initSkillContent -notmatch 'user provides a base URL') {
        Add-ErrorMessage 'init-harness does not document override and disable behavior for external standards.'
    }

    $initTemplatesContent = Get-Content -LiteralPath (Join-Path $skillsRoot 'init-harness/references/templates.md') -Raw -Encoding utf8
    if ($initTemplatesContent -notmatch '\$PortInUse' -or
        $initTemplatesContent -notmatch '\[System\.Net\.Sockets\.TcpClient\]') {
        Add-ErrorMessage 'init-harness PowerShell bootstrap lacks the occupied-port TCP probe fallback.'
    }
    if ($initTemplatesContent -notmatch 'PORT_IN_USE=false' -or
        $initTemplatesContent -notmatch '/dev/tcp/localhost/\$APP_PORT') {
        Add-ErrorMessage 'init-harness POSIX bootstrap lacks the occupied-port TCP probe fallback.'
    }

    $newTaskContent = Get-Content -LiteralPath (Join-Path $skillsRoot 'new-task/SKILL.md') -Raw -Encoding utf8
    if ($newTaskContent -notmatch 'default to Chrome MCP' -or
        $newTaskContent -notmatch 'explicit user choice overrides the default') {
        Add-ErrorMessage 'new-task does not preserve a configurable browser acceptance default.'
    }

    $orchestratorContent = Get-Content -LiteralPath (Join-Path $skillsRoot 'subagent-orchestrator/SKILL.md') -Raw -Encoding utf8
    if ($orchestratorContent -notmatch 'browser capability recorded in') {
        Add-ErrorMessage 'subagent-orchestrator does not consume the browser capability recorded by new-task.'
    }

    if (-not (Test-Path -LiteralPath (Join-Path $repoRoot 'LICENSE') -PathType Leaf)) {
        Add-ErrorMessage 'Missing open-source LICENSE selected by the repository owner.'
    }
}

Write-Output "SUMMARY: errors=$($errors.Count), warnings=$($warnings.Count), releaseMode=$Release"
if ($errors.Count -gt 0) {
    exit 1
}

exit 0
