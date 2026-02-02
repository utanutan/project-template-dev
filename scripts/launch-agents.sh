#!/bin/bash
# ============================================
# Antigravity Life OS - Parallel Agent Launcher
# ============================================
# Usage: ./launch-agents.sh [project-name] [--agents agent1,agent2,...] [--dangerously-skip-permissions]
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
SKIP_PERMISSIONS=""
WORKSPACE_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --agents)
            AGENTS="$2"
            shift 2
            ;;
        --dangerously-skip-permissions)
            SKIP_PERMISSIONS="--dangerously-skip-permissions"
            shift
            ;;
        *)
            PROJECT_NAME="$1"
            shift
            ;;
    esac
done

if [ -z "$PROJECT_NAME" ]; then
    echo -e "${RED}Error: Project name is required${NC}"
    echo "Usage: ./launch-agents.sh <project-name> [--agents agent1,agent2,...] [--dangerously-skip-permissions]"
    echo ""
    echo "Examples:"
    echo "  ./launch-agents.sh my-app --agents pm,architect,coder-a,coder-b"
    echo "  ./launch-agents.sh my-app --agents parallel-coders"
    echo "  ./launch-agents.sh my-app --dangerously-skip-permissions"
    echo ""
    echo "Options:"
    echo "  --agents <list>                 Comma-separated list of agents to launch"
    echo "  --dangerously-skip-permissions  Skip Yes/No confirmation prompts in Claude"
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
    echo "  qa-tester       - QA-Tester"
    echo "  marketing       - Marketing"
    echo "  monetization    - Monetization-Strategist"
    echo "  legal           - Legal-Advisor"
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
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
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
        monetization) agent_key="monetization" ;;
        legal) agent_key="legal-advisor" ;;
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
    local model=$(jq -r ".agents[\"${agent_key}\"].model // \"\"" "$AGENTS_JSON")
    local role=$(jq -r ".agents[\"${agent_key}\"].role // \"Agent\"" "$AGENTS_JSON")
    local mission=$(jq -r ".agents[\"${agent_key}\"].mission // \"\"" "$AGENTS_JSON")
    local responsibilities=$(jq -r ".agents[\"${agent_key}\"].responsibilities // [] | join(\"\n- \")" "$AGENTS_JSON")
    local constraints=$(jq -r ".agents[\"${agent_key}\"].constraints // [] | join(\"\n- \")" "$AGENTS_JSON")
    local workflow=$(jq -r ".agents[\"${agent_key}\"].workflow // [] | join(\"\n\")" "$AGENTS_JSON")
    local forbidden=$(jq -r ".agents[\"${agent_key}\"].forbiddenTools // [] | join(\", \")" "$AGENTS_JSON")
    local receives_from=$(jq -r ".agents[\"${agent_key}\"].receivesInstructionsFrom // \"\"" "$AGENTS_JSON")
    local delegates_to=$(jq -r ".agents[\"${agent_key}\"].delegatesTo // [] | join(\", \")" "$AGENTS_JSON")
    local notes=$(jq -r ".agents[\"${agent_key}\"].notes // [] | join(\"\n- \")" "$AGENTS_JSON")
    local review_checklist=$(jq -r ".agents[\"${agent_key}\"].reviewChecklist // [] | join(\"\n- \")" "$AGENTS_JSON")
    local inputs=$(jq -r ".agents[\"${agent_key}\"].inputs // {} | to_entries | map(\"\(.key): \(.value)\") | join(\"\n\")" "$AGENTS_JSON")
    local primary_output=$(jq -r ".agents[\"${agent_key}\"].outputFormat.primaryOutput // \"\"" "$AGENTS_JSON")
    local report_to=$(jq -r ".agents[\"${agent_key}\"].outputFormat.reportTo // \"\"" "$AGENTS_JSON")
    
    # Build comprehensive prompt
    local prompt="あなたは **${name}** (Role: ${role}) です。"
    
    if [ -n "$model" ]; then
        prompt="${prompt}
推奨モデル: ${model}"
    fi
    
    prompt="${prompt}

## Mission
${mission}"
    
    if [ -n "$responsibilities" ]; then
        prompt="${prompt}

## 責務 (Responsibilities)
- ${responsibilities}"
    fi
    
    if [ -n "$constraints" ]; then
        prompt="${prompt}

## 制約事項（厳守）
- ${constraints}"
    fi
    
    if [ -n "$forbidden" ]; then
        prompt="${prompt}

## 使用禁止ツール
${forbidden}"
    fi
    
    if [ -n "$notes" ]; then
        prompt="${prompt}

## 重要な注意事項
- ${notes}"
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
    
    if [ -n "$inputs" ]; then
        prompt="${prompt}

## 参照すべきファイル (Inputs)
${inputs}"
    fi
    
    if [ -n "$workflow" ]; then
        prompt="${prompt}

## ワークフロー
${workflow}"
    fi
    
    if [ -n "$review_checklist" ]; then
        prompt="${prompt}

## レビューチェックリスト
- ${review_checklist}"
    fi
    
    if [ -n "$primary_output" ]; then
        prompt="${prompt}

## 出力先
- Primary Output: ${primary_output}"
        if [ -n "$report_to" ]; then
            prompt="${prompt}
- Report To: ${report_to}"
        fi
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

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Darwin) echo "macos" ;;
        Linux)  echo "linux" ;;
        CYGWIN*|MINGW*|MSYS*) echo "windows" ;;
        *)      echo "unknown" ;;
    esac
}

# Launch agent in new Terminal window (cross-platform)
launch_agent() {
    local agent=$1
    local prompt=$(get_agent_prompt "$agent")
    local title="Agent: ${agent}"
    local claude_cmd="claude"
    local os_type=$(detect_os)

    # Add --dangerously-skip-permissions if specified
    if [ -n "$SKIP_PERMISSIONS" ]; then
        claude_cmd="claude --dangerously-skip-permissions"
    fi

    echo -e "${GREEN}✓${NC} Launching ${YELLOW}${agent}${NC}..."

    if [ -n "$SKIP_PERMISSIONS" ]; then
        echo -e "  ${YELLOW}⚠ Running with --dangerously-skip-permissions${NC}"
    fi

    # Write prompt to temp file to avoid shell escaping issues
    local prompt_file=$(mktemp)
    echo "$prompt" > "$prompt_file"

    if [[ "$(uname)" == "Darwin" ]]; then
        # macOS: use osascript to open new Terminal window
        osascript <<EOF
tell application "Terminal"
    activate
    do script "cd '${PROJECT_PATH}' && echo '=== ${title} ===' && ${claude_cmd} \"\$(cat '${prompt_file}')\" ; rm -f '${prompt_file}'"
end tell
EOF
    elif command -v tmux &> /dev/null && [ -n "$TMUX" ]; then
        # Linux with tmux: create new window
        tmux new-window -n "${agent}" "cd '${PROJECT_PATH}' && echo '=== ${title} ===' && ${claude_cmd} \"\$(cat '${prompt_file}')\" ; rm -f '${prompt_file}'; exec bash"
    elif command -v screen &> /dev/null; then
        # Linux with screen: create new window
        screen -dmS "agent-${agent}" bash -c "cd '${PROJECT_PATH}' && echo '=== ${title} ===' && ${claude_cmd} \"\$(cat '${prompt_file}')\" ; rm -f '${prompt_file}'"
        echo -e "  ${BLUE}→ screen session: agent-${agent} (attach with: screen -r agent-${agent})${NC}"
    else
        # Fallback: run in background with nohup, output to log
        local log_file="${PROJECT_PATH}/agent-${agent}.log"
        nohup bash -c "cd '${PROJECT_PATH}' && ${claude_cmd} \"\$(cat '${prompt_file}')\" ; rm -f '${prompt_file}'" > "$log_file" 2>&1 &
        echo -e "  ${BLUE}→ Running in background (PID: $!, log: ${log_file})${NC}"
    fi
}

# Expand presets
expand_agents() {
    local agents=$1
    case $agents in
        parallel-coders)
            echo "coder-a,coder-b,reviewer,qa-tester"
            ;;
        full-team)
            echo "pm,ra,researcher,architect,designer,coder-a,coder-b,reviewer,qa-tester,marketing,monetization,legal"
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
