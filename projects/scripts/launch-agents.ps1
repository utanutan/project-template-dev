<#
.SYNOPSIS
Antigravity Life OS - Parallel Agent Launcher (Windows)

.DESCRIPTION
Launches agent(s) for a specified project in separate PowerShell windows.
Reads agent configurations from library/config/agents.json.

.EXAMPLE
.\launch-agents.ps1 -ProjectName "my-app" -Agents "coder-a,coder-b,reviewer"
.\launch-agents.ps1 "my-app" -Agents "parallel-coders"
.\launch-agents.ps1 "my-app" -DangerouslySkipPermissions
#>

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$ProjectName,

    [Parameter(Mandatory=$false)]
    [string]$Agents = "pm",

    [Parameter(Mandatory=$false)]
    [Switch]$DangerouslySkipPermissions
)

$ErrorActionPreference = "Stop"

# Colors for output
function Write-Color {
    param($Text, $Color)
    Write-Host $Text -ForegroundColor $Color
}

# Paths
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Resolve-Path "$ScriptDir\..\.."
$WorkspaceRoot = "$RepoRoot\projects"
$ProjectPath = Join-Path $WorkspaceRoot $ProjectName
$AgentsJsonPath = "$RepoRoot\library\config\agents.json"

# Validate Project
if (-not (Test-Path $ProjectPath)) {
    Write-Color "Error: Project not found at $ProjectPath" "Red"
    exit 1
}

Write-Color "🚀 Launching agents for project: $ProjectName" "Cyan"
Write-Host ""

# Load Agents Config
if (-not (Test-Path $AgentsJsonPath)) {
    Write-Color "Error: agents.json not found at $AgentsJsonPath" "Red"
    exit 1
}

try {
    $JsonContent = Get-Content -Path $AgentsJsonPath -Raw -Encoding UTF8
    $AgentsConfig = $JsonContent | ConvertFrom-Json
} catch {
    Write-Color "Error: Failed to parse agents.json" "Red"
    Write-Error $_
    exit 1
}

# Helper to join array
function Join-Array {
    param($Arr)
    if ($Arr) {
        return $Arr -join "`n- "
    } else {
        return ""
    }
}

# Helper to get agent prompt
function Get-AgentPrompt {
    param([string]$AgentName)

    $AgentKey = switch -Regex ($AgentName) {
        "^pm$" { "project-manager" }
        "^ra$" { "requirements-analyst" }
        "^researcher$" { "researcher" }
        "^architect$" { "architect-plan" }
        "^designer$" { "designer" }
        "^coder-[ab]$" { "senior-coder" }
        "^reviewer$" { "review-guardian" }
        "^qa-tester$" { "qa-tester" }
        "^marketing$" { "marketing" }
        "^spec-writer$" { "spec-writer" }
        "^content-writer$" { "content-writer" }
        "^monetization$" { "monetization" }
        "^legal$" { "legal-advisor" }
        Default { $AgentName }
    }

    $AgentInstance = $AgentsConfig.agents.$AgentKey

    if (-not $AgentInstance) {
        return "あなたは $AgentName です。"
    }

    # Extract fields
    if ($AgentInstance.name) {
        $Name = $AgentInstance.name
    } else {
        $Name = $AgentName
    }

    if ($AgentInstance.role) {
        $Role = $AgentInstance.role
    } else {
        $Role = "Agent"
    }

    if ($AgentInstance.model) {
        $Model = $AgentInstance.model
    } else {
        $Model = ""
    }

    if ($AgentInstance.mission) {
        $Mission = $AgentInstance.mission
    } else {
        $Mission = ""
    }
    
    $Responsibilities = Join-Array -Arr $AgentInstance.responsibilities
    $Constraints = Join-Array -Arr $AgentInstance.constraints
    $Notes = Join-Array -Arr $AgentInstance.notes
    $ReviewChecklist = Join-Array -Arr $AgentInstance.reviewChecklist
    
    if ($AgentInstance.workflow) {
        $Workflow = $AgentInstance.workflow -join "`n"
    } else {
        $Workflow = ""
    }

    if ($AgentInstance.forbiddenTools) {
        $Forbidden = $AgentInstance.forbiddenTools -join ", "
    } else {
        $Forbidden = ""
    }

    if ($AgentInstance.receivesInstructionsFrom) {
        $ReceivesFrom = $AgentInstance.receivesInstructionsFrom
    } else {
        $ReceivesFrom = ""
    }

    if ($AgentInstance.delegatesTo) {
        $DelegatesTo = $AgentInstance.delegatesTo -join ", "
    } else {
        $DelegatesTo = ""
    }
    
    $InputsStr = ""
    if ($AgentInstance.inputs) {
        $InputLines = @()
        foreach ($Key in ($AgentInstance.inputs | Get-Member -MemberType NoteProperty).Name) {
            $InputLines += "$($Key): $($AgentInstance.inputs.$Key)"
        }
        $InputsStr = $InputLines -join "`n"
    }

    if ($AgentInstance.outputFormat) {
        if ($AgentInstance.outputFormat.primaryOutput) {
            $PrimaryOutput = $AgentInstance.outputFormat.primaryOutput
        } else {
            $PrimaryOutput = ""
        }
        
        if ($AgentInstance.outputFormat.reportTo) {
            $ReportTo = $AgentInstance.outputFormat.reportTo
        } else {
            $ReportTo = ""
        }
    } else {
        $PrimaryOutput = ""
        $ReportTo = ""
    }

    # Build Prompt
    $Prompt = "あなたは **$Name** (Role: $Role) です。"
    if ($Model) { $Prompt += "`n推奨モデル: $Model" }
    $Prompt += "`n`n## Mission`n$Mission"
    if ($Responsibilities) { $Prompt += "`n`n## 責務 (Responsibilities)`n- $Responsibilities" }
    if ($Constraints) { $Prompt += "`n`n## 制約事項（厳守）`n- $Constraints" }
    if ($Forbidden) { $Prompt += "`n`n## 使用禁止ツール`n$Forbidden" }
    if ($Notes) { $Prompt += "`n`n## 重要な注意事項`n- $Notes" }
    if ($ReceivesFrom) { $Prompt += "`n`n## 指示系統`nあなたは **$ReceivesFrom** から指示を受けます。Project-Managerから直接指示を受けません。" }
    if ($DelegatesTo) { $Prompt += "`n`n## 委譲先`n実装作業は **$DelegatesTo** に委譲してください。" }
    if ($InputsStr) { $Prompt += "`n`n## 参照すべきファイル (Inputs)`n$InputsStr" }
    if ($Workflow) { $Prompt += "`n`n## ワークフロー`n$Workflow" }
    if ($ReviewChecklist) { $Prompt += "`n`n## レビューチェックリスト`n- $ReviewChecklist" }
    
    if ($PrimaryOutput) {
        $Prompt += "`n`n## 出力先`n- Primary Output: $PrimaryOutput"
        if ($ReportTo) { $Prompt += "`n- Report To: $ReportTo" }
    }

    # Track Assignment
    if ($AgentName -eq "coder-a") {
        $Prompt += "`n`n## Track Assignment`nあなたは **Track A (Frontend)** 担当です。完了したら「Track A: Complete」と報告。"
    } elseif ($AgentName -eq "coder-b") {
        $Prompt += "`n`n## Track Assignment`nあなたは **Track B (Backend)** 担当です。完了したら「Track B: Complete」と報告。"
    }

    $Prompt += "`n`n---`ndocs/PRP.md を参照して作業を開始してください。"

    return $Prompt
}

# Expand Presets
$ExpandedAgents = switch ($Agents) {
    "parallel-coders" { "coder-a,coder-b,reviewer,qa-tester" }
    "full-team" { "pm,ra,researcher,architect,designer,coder-a,coder-b,reviewer,qa-tester,marketing,monetization,legal" }
    "test-team" { "coder-a,reviewer,qa-tester" }
    Default { $Agents }
}

$AgentList = $ExpandedAgents -split ","

# Launch Agents
foreach ($AgentName in $AgentList) {
    $AgentName = $AgentName.Trim()
    if (-not $AgentName) { continue }

    Write-Host "Check agent: $AgentName" -ForegroundColor DarkGray
    $Prompt = Get-AgentPrompt -AgentName $AgentName
    $Title = "Agent: $AgentName"
    
    $ClaudeCmd = "claude"
    if ($DangerouslySkipPermissions) {
        $ClaudeCmd += " --dangerously-skip-permissions"
        Write-Color "  ⚠ Running with --dangerously-skip-permissions" "Yellow"
    }

    Write-Color "✓ Launching $AgentName..." "Green"

    # Escape for PowerShell Command
    $EscapedPrompt = $Prompt -replace "'", "''" -replace '"', '\"'

    # Construct command
    # Using -Command "..." to handle the whole block
    $Command = "cd '$ProjectPath'; Write-Host '=== $Title ===' -ForegroundColor Cyan; $ClaudeCmd '$EscapedPrompt'"
    
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "$Command" -WindowStyle Normal
    Start-Sleep -Seconds 1
}

Write-Host ""
Write-Color "✅ Launched $($AgentList.Count) agent(s)" "Green"
Write-Host "Tips:"
Write-Host "  - Each agent runs in a separate PowerShell window"
Write-Host "  - Use Ctrl+C to stop an agent"
Write-Host "  - All agents are working on: $ProjectPath"
