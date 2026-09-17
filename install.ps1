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
    $resolvedSource = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($SkillSource)
    $resolvedTarget = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($TargetRoot)

    # Path equality check (case-insensitive on Windows)
    $samePath = [string]::Equals(
        (Resolve-Path $resolvedSource -ErrorAction SilentlyContinue).Path,
        (Resolve-Path $resolvedTarget -ErrorAction SilentlyContinue).Path,
        [StringComparison]::OrdinalIgnoreCase
    )

    if ($Uninstall) {
        Write-Step "[$ToolName] Uninstalling Skill"
        if (Test-Path $resolvedTarget) {
            $attr = (Get-Item $resolvedTarget).Attributes
            if ($attr -band [IO.FileAttributes]::ReparsePoint) {
                # Junction: just remove the link, don't touch the source
                cmd /c rmdir $resolvedTarget | Out-Null
                Write-Success "Removed junction: $resolvedTarget"
            } else {
                Remove-Item -Path $resolvedTarget -Recurse -Force
                Write-Success "Removed frontend Skill from $resolvedTarget"
            }
        } else {
            Write-Warn "Not installed at $resolvedTarget"
        }
        return
    }

    # If target is the same physical directory as source, we are essentially
    # "installing into self" — make sure there's a junction from target to source
    # so IDEs can pick it up, but DON'T touch the actual files.
    if ($samePath) {
        Write-Step "[$ToolName] Skill lives at this exact path already, no action needed"
        Write-Host "  Source: $resolvedSource" -ForegroundColor DarkGray
        Write-Host "  Target: $resolvedTarget" -ForegroundColor DarkGray
        Write-Success "Nothing to copy (single source of truth)"
        return
    }

    # Detect: target may already be a junction into our source (this happens
    # when install is run twice and the prior install already chose junction).
    if (Test-Path $resolvedTarget) {
        $item = Get-Item $resolvedTarget
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            $linkTarget = $item.Target
            if ($linkTarget -and (Resolve-Path $linkTarget -ErrorAction SilentlyContinue).Path -eq `
                (Resolve-Path $resolvedSource -ErrorAction SilentlyContinue).Path) {
                Write-Step "[$ToolName] Junction already linked to source — OK"
                Write-Host "  $resolvedTarget -> $linkTarget" -ForegroundColor DarkGray
                Write-Success "Nothing to do"
                return
            } else {
                Write-Warn "Target is a junction but points elsewhere: $linkTarget"
                Write-Warn "Re-creating junction to source $resolvedSource"
                cmd /c rmdir $resolvedTarget | Out-Null
            }
        } else {
            Write-Step "[$ToolName] Skill already exists as a real directory, skipping (use -Uninstall first)"
            Write-Host "  Path: $resolvedTarget" -ForegroundColor DarkGray
            return
        }
    }

    Write-Step "[$ToolName] Installing Skill"
    Write-Host "  From: $resolvedSource" -ForegroundColor DarkGray
    Write-Host "  To:   $resolvedTarget" -ForegroundColor DarkGray

    $parent = Split-Path $resolvedTarget -Parent
    if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
        Write-Host "  Created: $parent" -ForegroundColor DarkGray
    }

    # Use Windows directory junction so target and source share the same physical
    # files. Edits in either path show up immediately on the other side; no
    # sync step is ever required. Junction needs no admin and works on NTFS.
    cmd /c mklink /J "$resolvedTarget" "$resolvedSource" | Out-Null
    Write-Success "Junction created: $resolvedTarget -> $resolvedSource"
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
