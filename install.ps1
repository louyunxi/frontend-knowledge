#Requires -Version 5.1
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
    Write-Host ""
    Write-Host "  =========================================================" -ForegroundColor Cyan
    Write-Host "  $Message" -ForegroundColor Cyan
    Write-Host "  =========================================================" -ForegroundColor Cyan
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
            throw "-ProjectPath is required when -Scope is project"
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
            throw "-ProjectPath is required when -Scope is project"
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
            throw "-ProjectPath is required when -Scope is project"
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
            Write-Step "[$ToolName] Uninstalling Skill"
            Remove-Item -Path $resolvedTarget -Recurse -Force
            Write-Success "Removed frontend Skill from $resolvedTarget"
            return
        } else {
            Write-Step "[$ToolName] Skill already exists, skipping (use -Uninstall first)"
            Write-Host "  Path: $resolvedTarget" -ForegroundColor DarkGray
            return
        }
    }
    if ($Uninstall) {
        Write-Step "[$ToolName] Not installed, nothing to uninstall"
        return
    }
    Write-Step "[$ToolName] Installing Skill"
    Write-Host "  From: $SkillSource" -ForegroundColor DarkGray
    Write-Host "  To:   $resolvedTarget" -ForegroundColor DarkGray
    $parent = Split-Path $resolvedTarget -Parent
    if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
        Write-Host "  Created: $parent" -ForegroundColor DarkGray
    }
    Copy-Item -Path $SkillSource -Destination $resolvedTarget -Recurse -Force
    Write-Success "Copied to $resolvedTarget"
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
        Write-Success "Replaced path placeholder in $patched file(s)"
    } else {
        Write-Warn "No placeholder found to replace (may already be replaced)"
    }
}

$toolsToProcess = if ($Tool -eq "all") { @("trae", "claude", "dsh") } else { @($Tool.ToLower()) }
$scopesToProcess = if ($Scope -eq "both") { @("user", "project") } else { @($Scope.ToLower()) }

if ($scopesToProcess -contains "project" -and [string]::IsNullOrWhiteSpace($ProjectPath)) {
    $ProjectPath = $PWD.Path
    Write-Warn "No -ProjectPath specified, using current directory: $ProjectPath"
}

Write-Host ""
Write-Host "==============================================================" -ForegroundColor Magenta
Write-Host "  frontend-skill Installer" -ForegroundColor Magenta
Write-Host "  Tools: $($toolsToProcess -join ', ')" -ForegroundColor Magenta
Write-Host "  Scope: $($scopesToProcess -join ', ')" -ForegroundColor Magenta
Write-Host "  Action: $(if ($Uninstall) { 'Uninstall' } else { 'Install' })" -ForegroundColor Magenta
Write-Host "==============================================================" -ForegroundColor Magenta

if (-not (Test-Path $SkillSource)) {
    Write-Err "Skill source not found: $SkillSource"
    Write-Err "Make sure install.ps1 is in the repo root"
    exit 1
}

foreach ($t in $toolsToProcess) {
    foreach ($s in $scopesToProcess) {
        Write-Host ""
        Write-Host ">> [$t] [$s]" -ForegroundColor Yellow
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
Write-Host "==============================================================" -ForegroundColor Magenta
Write-Host "  Done" -ForegroundColor Magenta
Write-Host "==============================================================" -ForegroundColor Magenta
Write-Host ""
