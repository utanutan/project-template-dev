# ============================================
# Antigravity Life OS - Subagent Prompt Generator (Windows)
# ============================================
# Usage: .\subagent-prompt-generator.ps1 <agent-name>
#        .\subagent-prompt-generator.ps1 list

param(
    [Parameter(Mandatory=$false, Position=0)]
    [string]$AgentName
)

# Find repo root
function Find-RepoRoot {
    $dir = Get-Location
    while ($dir.Path -ne [System.IO.Path]::GetPathRoot($dir.Path)) {
        $configPath = Join-Path $dir.Path "library\config\agents.json"
        if (Test-Path $configPath) {
            return $dir.Path
        }
        $dir = Split-Path $dir.Path -Parent | Get-Item
    }
    return (Get-Location).Path
}

$RepoRoot = Find-RepoRoot
$AgentsJson = Join-Path $RepoRoot "library\config\agents.json"

# List all agents
function Get-AgentList {
    if (-not (Test-Path $AgentsJson)) {
        Write-Host "Error: agents.json not found" -ForegroundColor Red
        return
    }
    $config = Get-Content $AgentsJson -Raw | ConvertFrom-Json
    $config.agents.PSObject.Properties.Name
}

# Generate prompt for agent
function Get-SubagentPrompt {
    param([string]$Key)
    
    if (-not (Test-Path $AgentsJson)) {
        Write-Host "Error: agents.json not found at $AgentsJson" -ForegroundColor Red
        return
    }
    
    $config = Get-Content $AgentsJson -Raw | ConvertFrom-Json
    $agent = $config.agents.$Key
    
    if (-not $agent) {
        Write-Host "Error: Agent '$Key' not found" -ForegroundColor Red
        Write-Host "Available agents:"
        Get-AgentList
        return
    }
    
    $name = $agent.name
    $model = $agent.model
    $role = $agent.role
    $mission = $agent.mission
    $responsibilities = ($agent.responsibilities | ForEach-Object { "- $_" }) -join "`n"
    $constraints = ($agent.constraints | ForEach-Object { "- $_" }) -join "`n"
    $workflow = ($agent.workflow) -join "`n"
    $forbidden = ($agent.forbiddenTools) -join ", "
    $receivesFrom = $agent.receivesInstructionsFrom
    $delegatesTo = ($agent.delegatesTo) -join ", "
    $notes = ($agent.notes | ForEach-Object { "- $_" }) -join "`n"
    $reviewChecklist = ($agent.reviewChecklist | ForEach-Object { "- $_" }) -join "`n"
    
    # Build inputs
    $inputs = ""
    if ($agent.inputs) {
        $inputsList = @()
        foreach ($prop in $agent.inputs.PSObject.Properties) {
            $inputsList += "- $($prop.Name): $($prop.Value)"
        }
        $inputs = $inputsList -join "`n"
    }
    
    $primaryOutput = $agent.outputFormat.primaryOutput
    $reportTo = $agent.outputFormat.reportTo
    
    # Build prompt
    $prompt = @"
# Agent Configuration: $name

**Role**: $role
**Recommended Model**: $model

## Mission
$mission

## Responsibilities
$responsibilities

## Constraints (MUST FOLLOW)
$constraints
"@

    if ($forbidden) {
        $prompt += @"

## Forbidden Tools
$forbidden
"@
    }
    
    if ($notes) {
        $prompt += @"

## Important Notes
$notes
"@
    }
    
    if ($receivesFrom) {
        $prompt += @"

## Command Chain
You receive instructions from: **$receivesFrom**
You do NOT receive direct instructions from Project-Manager.
"@
    }
    
    if ($delegatesTo) {
        $prompt += @"

## Delegation
Delegate implementation work to: **$delegatesTo**
"@
    }
    
    if ($inputs) {
        $prompt += @"

## Required Inputs (Reference These Files)
$inputs
"@
    }
    
    if ($workflow) {
        $prompt += @"

## Workflow
$workflow
"@
    }
    
    if ($reviewChecklist) {
        $prompt += @"

## Review Checklist
$reviewChecklist
"@
    }
    
    $prompt += @"

## Output
- Primary Output: $primaryOutput
- Report To: $reportTo

---
Start by reading docs/PRP.md and proceed with your assigned tasks.
"@

    return $prompt
}

# Main
if (-not $AgentName) {
    Write-Host "Usage: .\subagent-prompt-generator.ps1 <agent-name> | list" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Available agents:"
    Get-AgentList
    exit 1
}

if ($AgentName -eq "list") {
    Get-AgentList
} else {
    Get-SubagentPrompt -Key $AgentName
}
