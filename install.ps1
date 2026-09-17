<#Requires -Version 5.1
<#
.SYNOPSIS
    安装 frontend-skill 到 TRAE / Claude Code / DeepSeek Harness。

.DESCRIPTION
    将 frontend/ 目录安装到各工具对应的 Skill 目录。

    TRAE:        $env:USERPROFILE\.trae\skills\frontend\ 或 项目/.trae/skills/frontend/
    Claude Code: $env:USERPROFILE\.claude\skills\frontend\ 或 项目/.claude/skills/frontend/
    DSH:         $env:USERPROFILE\.dsh\skills\frontend\ 或 项目/.dsh/skills/frontend/

    安装后自动替换路径占位符 "__SKILL_ROOT__" 为实际路径。

.PARAMETER Tool
    目标工具：trae | claude | dsh | all
    别名: -t

.PARAMETER Scope
    安装范围：user（用户级）| project（项目级）| both
    别名: -s
    默认值: user

.PARAMETER ProjectPath
    项目级安装时指定项目路径。
    别名: -p

.PARAMETER Uninstall
    卸载已安装的 Skill。
    别名: -u

.EXAMPLE
    .\install.ps1 -Tool trae -Scope user
    安装到 TRAE 用户级目录。

.EXAMPLE
    .\install.ps1 -Tool all -Scope project -ProjectPath "E:\AI\my-project"
    安装到 my-project 的项目级目录（TRAE + Claude Code + DSH）。

.EXAMPLE
    .\install.ps1 -Tool claude -Scope user -Uninstall
    从 Claude Code 用户级目录卸载。
#>

param(
    [Alias("t")]
    [ValidateSet("trae", "claude", "dsh", "all", IgnoreCase = $true)]
    [string]$Tool = "all",

    [Alias("s")]
    [ValidateSet("user", "project", "both", IgnoreCase = $true)]
    [string]$Scope = "user",

    [Alias("p")]
    [string]$ProjectPath = "",

    [Alias("u")]
    [switch]$Uninstall
)

$ErrorActionPreference = "Stop"
$SkillSource = Join-Path $PSScriptRoot "frontend"
$RepoRoot = $PSScriptRoot

function Write-Step([string]$Message) {
    $line = "  " + ("═" * 58)
    Write-Host ""
    Write-Host $line -ForegroundColor Cyan
    Write-Host "  $Message" -ForegroundColor Cyan
    Write-Host $line -ForegroundColor Cyan
}

function Write-Success([string]$Message) {
    Write-Host "  [OK] $Message" -ForegroundColor Green
}

function Write-Warn([string]$Message) {
    Write-Host "  [WARN] $Message" -ForegroundColor Yellow
}

function Write-Err([string]$Message) {
    Write-Host "  [ERR] $Message" -ForegroundColor Red
}

function Get-TraeSkillRoot {
    param([string]$Scope, [string]$ProjectPath)

    if ($Scope -eq "user") {
        return Join-Path $env:USERPROFILE ".trae\skills\frontend"
    } elseif ($Scope -eq "project") {
        if ([string]::IsNullOrWhiteSpace($ProjectPath)) {
            throw "-ProjectPath is required when -Scope is 'project'"
        }
        return Join-Path $ProjectPath ".trae\skills\frontend"
    } else {
        throw "Unknown scope: $Scope"
    }
}

function Get-ClaudeSkillRoot {
    param([string]$Scope, [string]$ProjectPath)

    if ($Scope -eq "user") {
        return Join-Path $env:USERPROFILE ".claude\skills\frontend"
    } elseif ($Scope -eq "project") {
        if ([string]::IsNullOrWhiteSpace($ProjectPath)) {
            throw "-ProjectPath is required when -Scope is 'project'"
        }
        return Join-Path $ProjectPath ".claude\skills\frontend"
    } else {
        throw "Unknown scope: $Scope"
    }
}

function Get-DshSkillRoot {
    param([string]$Scope, [string]$ProjectPath)

    $DshHome = if ($null -ne $env:DSH_HOME) { $env:DSH_HOME } else { Join-Path $env:USERPROFILE ".dsh" }

    if ($Scope -eq "user") {
        return Join-Path $DshHome "skills\frontend"
    } elseif ($Scope -eq "project") {
        if ([string]::IsNullOrWhiteSpace($ProjectPath)) {
            throw "-ProjectPath is required when -Scope is 'project'"
        }
        return Join-Path $ProjectPath ".dsh\skills\frontend"
    } else {
        throw "Unknown scope: $Scope"
    }
}

function Install-Skill {
    param(
        [string]$ToolName,
        [string]$TargetRoot,
        [string]$RepoRoot,
        [string]$SkillSource
    )

    $resolvedTarget = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($TargetRoot)

    if (Test-Path $resolvedTarget) {
        if ($Uninstall) {
            Write-Step "[$ToolName] 卸载 Skill"
            Remove-Item -Path $resolvedTarget -Recurse -Force
            Write-Success "已从 $resolvedTarget 移除 frontend Skill"
            return
        } else {
            Write-Step "[$ToolName] Skill 已存在，跳过（使用 -Uninstall 先移除）"
            Write-Host "  路径: $resolvedTarget" -ForegroundColor DarkGray
            return
        }
    }

    if ($Uninstall) {
        Write-Step "[$ToolName] 未安装，无需卸载"
        return
    }

    Write-Step "[$ToolName] 安装 Skill"
    Write-Host "  源: $SkillSource" -ForegroundColor DarkGray
    Write-Host "  目标: $resolvedTarget" -ForegroundColor DarkGray

    $parent = Split-Path $resolvedTarget -Parent
    if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
        Write-Host "  已创建目录: $parent" -ForegroundColor DarkGray
    }

    Copy-Item -Path $SkillSource -Destination $resolvedTarget -Recurse -Force
    Write-Success "已复制到 $resolvedTarget"

    $placeholder = "__SKILL_ROOT__"
    $filesToPatch = @(
        (Join-Path $resolvedTarget "SKILL.md"),
        (Join-Path $resolvedTarget "agent.md"),
        (Join-Path $resolvedTarget "commands\distill.md")
    )

    $patched = 0
    foreach ($file in $filesToPatch) {
        if (-not (Test-Path $file)) { continue }
        $content = Get-Content $file -Raw -Encoding UTF8
        if ($content -match [regex]::Escape($placeholder)) {
            $content = $content -replace [regex]::Escape($placeholder), $resolvedTarget
            Set-Content -Path $file -Value $content -Encoding UTF8 -NoNewline
            $patched++
        }
    }

    if ($patched -gt 0) {
        Write-Success "已替换 $patched 个文件中的路径占位符"
    } else {
        Write-Warn "未找到需要替换的路径占位符（可能已替换或无需替换）"
    }
}

$toolsToProcess = if ($Tool -eq "all") { @("trae", "claude", "dsh") } else { @($Tool.ToLower()) }
$scopesToProcess = if ($Scope -eq "both") { @("user", "project") } else { @($Scope.ToLower()) }

if ($scopesToProcess -contains "project" -and [string]::IsNullOrWhiteSpace($ProjectPath)) {
    $ProjectPath = $PWD.Path
    Write-Warn "未指定 -ProjectPath，使用当前目录: $ProjectPath"
}

Write-Host ""
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "  frontend-skill 安装脚本" -ForegroundColor Magenta
Write-Host "  工具: $($toolsToProcess -join ', ')" -ForegroundColor Magenta
Write-Host "  范围: $($scopesToProcess -join ', ')" -ForegroundColor Magenta
Write-Host "  操作: $(if ($Uninstall) { '卸载' } else { '安装' })" -ForegroundColor Magenta
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Magenta

if (-not (Test-Path $SkillSource)) {
    Write-Err "未找到 Skill 源目录: $SkillSource"
    Write-Err "请确认 install.ps1 位于仓库根目录"
    exit 1
}

foreach ($t in $toolsToProcess) {
    foreach ($s in $scopesToProcess) {
        Write-Host ""
        Write-Host "▶ [$t] [$s]" -ForegroundColor Yellow

        try {
            switch ($t) {
                "trae"   { $root = Get-TraeSkillRoot -Scope $s -ProjectPath $ProjectPath }
                "claude" { $root = Get-ClaudeSkillRoot -Scope $s -ProjectPath $ProjectPath }
                "dsh"    { $root = Get-DshSkillRoot -Scope $s -ProjectPath $ProjectPath }
            }
            Install-Skill -ToolName $t.ToUpper() -TargetRoot $root -RepoRoot $RepoRoot -SkillSource $SkillSource
        } catch {
            Write-Err $_.Exception.Message
        }
    }
}

Write-Host ""
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "  完成" -ForegroundColor Magenta
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host ""
