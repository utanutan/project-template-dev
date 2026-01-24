#!/bin/bash
# ============================================
# Antigravity Life OS - Subagent Prompt Generator
# ============================================
# Usage: source this file, then call get_subagent_prompt <agent-name>
# This is used by PM to spawn subagents with proper context from agents.json

# Find the repository root
find_repo_root() {
    local dir="$PWD"
    while [ "$dir" != "/" ]; do
        if [ -f "$dir/library/config/agents.json" ]; then
            echo "$dir"
            return
        fi
        dir="$(dirname "$dir")"
    done
    # Fallback
    echo "$PWD"
}

REPO_ROOT="$(find_repo_root)"
AGENTS_JSON="${REPO_ROOT}/library/config/agents.json"

# Generate a complete subagent prompt from agents.json
get_subagent_prompt() {
    local agent_key="$1"
    
    if [ ! -f "$AGENTS_JSON" ]; then
        echo "Error: agents.json not found at $AGENTS_JSON" >&2
        return 1
    fi
    
    if ! command -v jq &> /dev/null; then
        echo "Error: jq is required but not installed" >&2
        return 1
    fi
    
    # Extract all fields
    local name=$(jq -r ".agents[\"${agent_key}\"].name // \"${agent_key}\"" "$AGENTS_JSON")
    local model=$(jq -r ".agents[\"${agent_key}\"].model // \"\"" "$AGENTS_JSON")
    local role=$(jq -r ".agents[\"${agent_key}\"].role // \"Agent\"" "$AGENTS_JSON")
    local mission=$(jq -r ".agents[\"${agent_key}\"].mission // \"\"" "$AGENTS_JSON")
    local responsibilities=$(jq -r ".agents[\"${agent_key}\"].responsibilities // [] | map(\"- \" + .) | join(\"\n\")" "$AGENTS_JSON")
    local constraints=$(jq -r ".agents[\"${agent_key}\"].constraints // [] | map(\"- \" + .) | join(\"\n\")" "$AGENTS_JSON")
    local workflow=$(jq -r ".agents[\"${agent_key}\"].workflow // [] | join(\"\n\")" "$AGENTS_JSON")
    local forbidden=$(jq -r ".agents[\"${agent_key}\"].forbiddenTools // [] | join(\", \")" "$AGENTS_JSON")
    local receives_from=$(jq -r ".agents[\"${agent_key}\"].receivesInstructionsFrom // \"\"" "$AGENTS_JSON")
    local delegates_to=$(jq -r ".agents[\"${agent_key}\"].delegatesTo // [] | join(\", \")" "$AGENTS_JSON")
    local notes=$(jq -r ".agents[\"${agent_key}\"].notes // [] | map(\"- \" + .) | join(\"\n\")" "$AGENTS_JSON")
    local review_checklist=$(jq -r ".agents[\"${agent_key}\"].reviewChecklist // [] | map(\"- \" + .) | join(\"\n\")" "$AGENTS_JSON")
    local inputs=$(jq -r ".agents[\"${agent_key}\"].inputs // {} | to_entries | map(\"- \" + .key + \": \" + .value) | join(\"\n\")" "$AGENTS_JSON")
    local primary_output=$(jq -r ".agents[\"${agent_key}\"].outputFormat.primaryOutput // \"\"" "$AGENTS_JSON")
    local report_to=$(jq -r ".agents[\"${agent_key}\"].outputFormat.reportTo // \"\"" "$AGENTS_JSON")
    
    # Build the prompt
    cat << EOF
# Agent Configuration: ${name}

**Role**: ${role}
**Recommended Model**: ${model}

## Mission
${mission}

## Responsibilities
${responsibilities}

## Constraints (MUST FOLLOW)
${constraints}
EOF

    if [ -n "$forbidden" ]; then
        cat << EOF

## Forbidden Tools
${forbidden}
EOF
    fi

    if [ -n "$notes" ]; then
        cat << EOF

## Important Notes
${notes}
EOF
    fi

    if [ -n "$receives_from" ]; then
        cat << EOF

## Command Chain
You receive instructions from: **${receives_from}**
You do NOT receive direct instructions from Project-Manager.
EOF
    fi

    if [ -n "$delegates_to" ]; then
        cat << EOF

## Delegation
Delegate implementation work to: **${delegates_to}**
EOF
    fi

    if [ -n "$inputs" ]; then
        cat << EOF

## Required Inputs (Reference These Files)
${inputs}
EOF
    fi

    if [ -n "$workflow" ]; then
        cat << EOF

## Workflow
${workflow}
EOF
    fi

    if [ -n "$review_checklist" ]; then
        cat << EOF

## Review Checklist
${review_checklist}
EOF
    fi

    cat << EOF

## Output
- Primary Output: ${primary_output}
- Report To: ${report_to}

---
Start by reading docs/PRP.md and proceed with your assigned tasks.
EOF
}

# List all available agents
list_agents() {
    jq -r '.agents | keys[]' "$AGENTS_JSON"
}

# Export for use in scripts
export -f get_subagent_prompt
export -f list_agents
export AGENTS_JSON

# Allow direct execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [ "$1" == "list" ]; then
        list_agents
    elif [ -n "$1" ]; then
        get_subagent_prompt "$1"
    else
        echo "Usage: $0 <agent-name> | list"
        echo "Available agents:"
        list_agents
        exit 1
    fi
fi
