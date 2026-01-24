#!/bin/bash
# ============================================
# Antigravity Life OS - Parallel Agent Launcher
# ============================================
# Usage: ./launch-agents.sh [project-name] [--agents agent1,agent2,...]
# Example: ./launch-agents.sh my-app --agents coder-a,coder-b,reviewer

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Default values
PROJECT_NAME=""
AGENTS=""
WORKSPACE_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --agents)
            AGENTS="$2"
            shift 2
            ;;
        *)
            PROJECT_NAME="$1"
            shift
            ;;
    esac
done

if [ -z "$PROJECT_NAME" ]; then
    echo -e "${RED}Error: Project name is required${NC}"
    echo "Usage: ./launch-agents.sh <project-name> [--agents agent1,agent2,...]"
    echo ""
    echo "Examples:"
    echo "  ./launch-agents.sh my-app --agents pm,architect,coder-a,coder-b"
    echo "  ./launch-agents.sh my-app --agents parallel-coders"
    echo ""
    echo "Available agent presets:"
    echo "  pm              - Project Manager"
    echo "  ra              - Requirements Analyst"
    echo "  researcher      - Researcher"
    echo "  architect       - Architect-Plan"
    echo "  designer        - Designer"
    echo "  coder-a         - Senior-Coder Track A"
    echo "  coder-b         - Senior-Coder Track B"
    echo "  reviewer        - Review-Guardian"
    echo "  marketing       - Marketing"
    echo ""
    echo "  parallel-coders - Launch coder-a + coder-b + reviewer"
    echo "  full-team       - Launch all agents"
    exit 1
fi

PROJECT_PATH="${WORKSPACE_ROOT}/projects/${PROJECT_NAME}"

if [ ! -d "$PROJECT_PATH" ]; then
    echo -e "${RED}Error: Project not found at ${PROJECT_PATH}${NC}"
    exit 1
fi

echo -e "${BLUE}🚀 Launching agents for project: ${PROJECT_NAME}${NC}"
echo ""

# Agent prompts
get_agent_prompt() {
    local agent=$1
    case $agent in
        pm)
            echo "あなたは Project-Manager です。docs/PRP.md を読み、プロジェクト全体を管理してください。"
            ;;
        ra)
            echo "あなたは Requirements-Analyst です。docs/PRP.md を分析し、曖昧な点を明確化してください。"
            ;;
        researcher)
            echo "あなたは Researcher です。市場調査・競合分析を行い、research/ に保存してください。"
            ;;
        architect)
            echo "あなたは Architect-Plan です。spec/implementation_plan.md に実装プランを作成してください。"
            ;;
        designer)
            echo "あなたは Designer です。Nano Banana で resources/mockups/ にモックアップを生成してください。"
            ;;
        coder-a)
            echo "あなたは Senior-Coder (Track A: Frontend) です。resources/mockups/ を参照し実装してください。完了したら Track A: Complete と報告。"
            ;;
        coder-b)
            echo "あなたは Senior-Coder (Track B: Backend) です。実装してください。完了したら Track B: Complete と報告。"
            ;;
        reviewer)
            echo "あなたは Review-Guardian です。src/ をレビューし、問題があれば指摘してください。"
            ;;
        qa-tester)
            echo "あなたは QA-Tester です。ブラウザで動作確認し、E2Eテストを tests/e2e/ に作成してください。resources/mockups/ と比較検証もお願いします。"
            ;;
        marketing)
            echo "あなたは Marketing です。SEO最適化とコピーライティングを行ってください。"
            ;;
        *)
            echo "あなたは ${agent} です。"
            ;;
    esac
}

# Launch agent in new Terminal window (macOS)
launch_agent() {
    local agent=$1
    local prompt=$(get_agent_prompt "$agent")
    local title="Agent: ${agent}"
    
    echo -e "${GREEN}✓${NC} Launching ${YELLOW}${agent}${NC}..."
    
    osascript <<EOF
tell application "Terminal"
    activate
    do script "cd '${PROJECT_PATH}' && echo '=== ${title} ===' && claude '${prompt}'"
end tell
EOF
}

# Expand presets
expand_agents() {
    local agents=$1
    case $agents in
        parallel-coders)
            echo "coder-a,coder-b,reviewer,qa-tester"
            ;;
        full-team)
            echo "pm,ra,researcher,architect,designer,coder-a,coder-b,reviewer,qa-tester,marketing"
            ;;
        test-team)
            echo "coder-a,reviewer,qa-tester"
            ;;
        *)
            echo "$agents"
            ;;
    esac
}

# Default to PM if no agents specified
if [ -z "$AGENTS" ]; then
    AGENTS="pm"
fi

# Expand presets
AGENTS=$(expand_agents "$AGENTS")

# Launch each agent
IFS=',' read -ra AGENT_ARRAY <<< "$AGENTS"
for agent in "${AGENT_ARRAY[@]}"; do
    agent=$(echo "$agent" | xargs)  # trim whitespace
    launch_agent "$agent"
    sleep 1  # Small delay between launches
done

echo ""
echo -e "${GREEN}✅ Launched ${#AGENT_ARRAY[@]} agent(s)${NC}"
echo ""
echo "Tips:"
echo "  - Each agent runs in a separate Terminal window"
echo "  - Use Ctrl+C to stop an agent"
echo "  - All agents are working on: ${PROJECT_PATH}"
