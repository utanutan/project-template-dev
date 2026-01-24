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

PROJECT_PATH="${WORKSPACE_ROOT}/${PROJECT_NAME}"

if [ ! -d "$PROJECT_PATH" ]; then
    echo -e "${RED}Error: Project not found at ${PROJECT_PATH}${NC}"
    exit 1
fi

echo -e "${BLUE}🚀 Launching agents for project: ${PROJECT_NAME}${NC}"
echo ""

# Path to agents.json
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
AGENTS_JSON="${REPO_ROOT}/library/config/agents.json"

# Agent prompts - now reads from agents.json
get_agent_prompt() {
    local agent=$1
    local agent_key=""
    
    # Map CLI agent name to agents.json key
    case $agent in
        pm) agent_key="project-manager" ;;
        ra) agent_key="requirements-analyst" ;;
        researcher) agent_key="researcher" ;;
        architect) agent_key="architect-plan" ;;
        designer) agent_key="designer" ;;
        coder-a|coder-b) agent_key="senior-coder" ;;
        reviewer) agent_key="review-guardian" ;;
        qa-tester) agent_key="qa-tester" ;;
        marketing) agent_key="marketing" ;;
        spec-writer) agent_key="spec-writer" ;;
        content-writer) agent_key="content-writer" ;;
        *) agent_key="$agent" ;;
    esac
    
    # Check if jq is available
    if ! command -v jq &> /dev/null; then
        echo "あなたは ${agent} です。"
        return
    fi
    
    # Check if agents.json exists
    if [ ! -f "$AGENTS_JSON" ]; then
        echo "あなたは ${agent} です。"
        return
    fi
    
    # Read agent config from JSON
    local name=$(jq -r ".agents[\"${agent_key}\"].name // \"${agent}\"" "$AGENTS_JSON")
    local role=$(jq -r ".agents[\"${agent_key}\"].role // \"Agent\"" "$AGENTS_JSON")
    local mission=$(jq -r ".agents[\"${agent_key}\"].mission // \"\"" "$AGENTS_JSON")
    local constraints=$(jq -r ".agents[\"${agent_key}\"].constraints // [] | join(\"\n- \")" "$AGENTS_JSON")
    local workflow=$(jq -r ".agents[\"${agent_key}\"].workflow // [] | join(\"\n\")" "$AGENTS_JSON")
    local forbidden=$(jq -r ".agents[\"${agent_key}\"].forbiddenTools // [] | join(\", \")" "$AGENTS_JSON")
    local receives_from=$(jq -r ".agents[\"${agent_key}\"].receivesInstructionsFrom // \"\"" "$AGENTS_JSON")
    local delegates_to=$(jq -r ".agents[\"${agent_key}\"].delegatesTo // [] | join(\", \")" "$AGENTS_JSON")
    
    # Build comprehensive prompt
    local prompt="あなたは **${name}** (Role: ${role}) です。

## Mission
${mission}

## 制約事項（厳守）"
    
    if [ -n "$constraints" ]; then
        prompt="${prompt}
- ${constraints}"
    fi
    
    if [ -n "$forbidden" ]; then
        prompt="${prompt}

## 使用禁止ツール
${forbidden}"
    fi
    
    if [ -n "$receives_from" ]; then
        prompt="${prompt}

## 指示系統
あなたは **${receives_from}** から指示を受けます。Project-Managerから直接指示を受けません。"
    fi
    
    if [ -n "$delegates_to" ]; then
        prompt="${prompt}

## 委譲先
実装作業は **${delegates_to}** に委譲してください。"
    fi
    
    if [ -n "$workflow" ]; then
        prompt="${prompt}

## ワークフロー
${workflow}"
    fi
    
    # Add track-specific info for coders
    if [ "$agent" = "coder-a" ]; then
        prompt="${prompt}

## Track Assignment
あなたは **Track A (Frontend)** 担当です。完了したら「Track A: Complete」と報告。"
    elif [ "$agent" = "coder-b" ]; then
        prompt="${prompt}

## Track Assignment
あなたは **Track B (Backend)** 担当です。完了したら「Track B: Complete」と報告。"
    fi
    
    prompt="${prompt}

---
docs/PRP.md を参照して作業を開始してください。"
    
    echo "$prompt"
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
