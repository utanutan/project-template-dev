# ============================================
# Antigravity Life OS - Parallel Agent Launcher (Windows)
# ============================================
# Usage: .\launch-agents.ps1 -ProjectName "my-app" -Agents "coder-a,coder-b,reviewer"
# Example: .\launch-agents.ps1 my-app -Agents parallel-coders

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$ProjectName,
    
    [Parameter(Mandatory=$false)]
    [string]$Agents = "pm"
)

$WorkspaceRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$ProjectPath = Join-Path $WorkspaceRoot "projects" $ProjectName

if (-not (Test-Path $ProjectPath)) {
    Write-Host "Error: Project not found at $ProjectPath" -ForegroundColor Red
    exit 1
}

Write-Host "🚀 Launching agents for project: $ProjectName" -ForegroundColor Blue
Write-Host ""

# Agent prompts
function Get-AgentPrompt {
    param([string]$Agent)
    
    switch ($Agent) {
        "pm"         { "あなたは Project-Manager です。docs/PRP.md を読み、プロジェクト全体を管理してください。" }
        "ra"         { "あなたは Requirements-Analyst です。docs/PRP.md を分析し、曖昧な点を明確化してください。" }
        "researcher" { "あなたは Researcher です。市場調査・競合分析を行い、research/ に保存してください。" }
        "architect"  { "あなたは Architect-Plan です。spec/implementation_plan.md に実装プランを作成してください。" }
        "designer"   { "あなたは Designer です。Nano Banana で resources/mockups/ にモックアップを生成してください。" }
        "coder-a"    { "あなたは Senior-Coder (Track A: Frontend) です。resources/mockups/ を参照し実装してください。完了したら Track A: Complete と報告。" }
        "coder-b"    { "あなたは Senior-Coder (Track B: Backend) です。実装してください。完了したら Track B: Complete と報告。" }
        "reviewer"   { "あなたは Review-Guardian です。src/ をレビューし、問題があれば指摘してください。" }
        "marketing"  { "あなたは Marketing です。SEO最適化とコピーライティングを行ってください。" }
        default      { "あなたは $Agent です。" }
    }
}

# Launch agent in new Windows Terminal / PowerShell window
function Launch-Agent {
    param([string]$Agent)
    
    $prompt = Get-AgentPrompt -Agent $Agent
    $title = "Agent: $Agent"
    
    Write-Host "✓ Launching " -NoNewline -ForegroundColor Green
    Write-Host $Agent -ForegroundColor Yellow
    
    # Try Windows Terminal first, fall back to PowerShell
    $command = "cd '$ProjectPath'; Write-Host '=== $title ===' -ForegroundColor Cyan; claude '$prompt'"
    
    try {
        # Windows Terminal
        Start-Process wt -ArgumentList "new-tab", "--title", $title, "powershell", "-NoExit", "-Command", $command
    }
    catch {
        # Fallback to regular PowerShell window
        Start-Process powershell -ArgumentList "-NoExit", "-Command", $command
    }
}

# Expand presets
function Expand-Agents {
    param([string]$Agents)
    
    switch ($Agents) {
        "parallel-coders" { "coder-a,coder-b,reviewer" }
        "full-team"       { "pm,ra,researcher,architect,designer,coder-a,coder-b,reviewer,marketing" }
        default           { $Agents }
    }
}

# Expand presets
$Agents = Expand-Agents -Agents $Agents

# Launch each agent
$AgentArray = $Agents -split ","
foreach ($agent in $AgentArray) {
    $agent = $agent.Trim()
    Launch-Agent -Agent $agent
    Start-Sleep -Seconds 1
}

Write-Host ""
Write-Host "✅ Launched $($AgentArray.Count) agent(s)" -ForegroundColor Green
Write-Host ""
Write-Host "Tips:"
Write-Host "  - Each agent runs in a separate window"
Write-Host "  - Use Ctrl+C to stop an agent"
Write-Host "  - All agents are working on: $ProjectPath"
