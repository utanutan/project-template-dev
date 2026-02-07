#!/bin/bash
# ============================================
# Antigravity Life OS - Project Initializer
# ============================================
# Usage: ./init-project.sh <project-name> [--type dev|creative|life] [--template <name>] [--list-templates]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Default values
PROJECT_TYPE="dev"
TEMPLATE_NAME=""
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORKSPACE_ROOT="${REPO_ROOT}/projects"
TEMPLATES_JSON="${REPO_ROOT}/library/config/templates.json"

# Function: List available templates
list_templates() {
    echo -e "${BLUE}📦 Available Templates:${NC}"
    echo ""
    if [ -f "$TEMPLATES_JSON" ]; then
        # Parse templates.json using jq if available, otherwise use grep
        if command -v jq &> /dev/null; then
            jq -r '.templates | to_entries[] | "  \(.key): \(.value.description)"' "$TEMPLATES_JSON"
        else
            grep -E '"name"|"description"' "$TEMPLATES_JSON" | sed 's/.*: *"\([^"]*\)".*/  \1/'
        fi
    else
        echo "  (No templates configured)"
    fi
    echo ""
    exit 0
}

# Function: Copy template files with overlay approach
copy_template() {
    local template_name="$1"
    local target_path="$2"
    
    # Get template path from templates.json
    local template_path=""
    if command -v jq &> /dev/null; then
        template_path=$(jq -r ".templates[\"$template_name\"].path // empty" "$TEMPLATES_JSON")
    else
        # Fallback: assume projects/<template_name>
        template_path="projects/${template_name}"
    fi
    
    if [ -z "$template_path" ]; then
        echo -e "${RED}Error: Template '$template_name' not found in templates.json${NC}"
        exit 1
    fi
    
    local full_template_path="${REPO_ROOT}/${template_path}"
    
    if [ ! -d "$full_template_path" ]; then
        echo -e "${RED}Error: Template directory not found: ${full_template_path}${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}📋 Applying template: ${template_name}${NC}"
    
    # Copy src/ directly (overlay)
    if [ -d "${full_template_path}/src" ]; then
        rm -rf "${target_path}/src/.gitkeep" 2>/dev/null || true
        cp -r "${full_template_path}/src/." "${target_path}/src/"
        echo -e "${GREEN}✓${NC} Copied src/ (implementation base)"
    fi
    
    # Copy spec/ to spec/BASE_REFERENCE/
    if [ -d "${full_template_path}/spec" ] && [ "$(ls -A ${full_template_path}/spec 2>/dev/null)" ]; then
        mkdir -p "${target_path}/spec/BASE_REFERENCE"
        # Copy only files, not .gitkeep
        find "${full_template_path}/spec" -maxdepth 1 -type f ! -name ".gitkeep" -exec cp {} "${target_path}/spec/BASE_REFERENCE/" \;
        echo -e "${GREEN}✓${NC} Copied spec/ → spec/BASE_REFERENCE/"
    fi
    
    # Copy research/ to research/BASE_REFERENCE/
    if [ -d "${full_template_path}/research" ] && [ "$(ls -A ${full_template_path}/research 2>/dev/null)" ]; then
        mkdir -p "${target_path}/research/BASE_REFERENCE"
        find "${full_template_path}/research" -maxdepth 1 -type f ! -name ".gitkeep" -exec cp {} "${target_path}/research/BASE_REFERENCE/" \;
        echo -e "${GREEN}✓${NC} Copied research/ → research/BASE_REFERENCE/"
    fi
    
    # Copy learning/ directly
    if [ -d "${full_template_path}/learning" ] && [ "$(ls -A ${full_template_path}/learning 2>/dev/null)" ]; then
        mkdir -p "${target_path}/learning"
        cp -r "${full_template_path}/learning/." "${target_path}/learning/"
        echo -e "${GREEN}✓${NC} Copied learning/ (technical guides)"
    fi
    
    # Generate TEMPLATE_README.md
    cat > "${target_path}/TEMPLATE_README.md" << TEMPLATE_EOF
# Template Base: ${template_name}

このプロジェクトは \`${template_name}\` テンプレートをベースに作成されました。

## テンプレートから引き継いだファイル

| パス | 説明 | 使い方 |
|------|------|--------|
| \`src/\` | 実装ベース | そのまま使用・拡張可能 |
| \`spec/BASE_REFERENCE/\` | 設計・実装プラン資料 | 参照用（新規は spec/ 直下に作成） |
| \`research/BASE_REFERENCE/\` | 技術調査資料 | 参照用 |
| \`learning/\` | 技術解説ドキュメント | 学習・参照用 |

## エージェント向けガイド

1. **PRP作成**: \`docs/PRP.md\` に新プロジェクトの要件を記載
2. **設計参照**: \`spec/BASE_REFERENCE/\` の既存設計を参考に
3. **新規設計**: 新しい実装プランは \`spec/implementation_plan.md\` に作成
4. **実装**: \`src/\` を拡張・改修

## テンプレート情報

- **Template**: ${template_name}
- **Applied**: $(date +%Y-%m-%d)
- **Config**: library/config/templates.json
TEMPLATE_EOF

    echo -e "${GREEN}✓${NC} Generated TEMPLATE_README.md"
}

# Parse arguments
if [ -z "$1" ]; then
    echo -e "${RED}Error: Project name is required${NC}"
    echo "Usage: ./init-project.sh <project-name> [--type dev|creative|life] [--template <name>]"
    echo "       ./init-project.sh --list-templates"
    exit 1
fi

# Check for --list-templates as first arg
if [ "$1" = "--list-templates" ]; then
    list_templates
fi

PROJECT_NAME="$1"
shift

while [[ $# -gt 0 ]]; do
    case $1 in
        --type)
            PROJECT_TYPE="$2"
            shift 2
            ;;
        --template)
            TEMPLATE_NAME="$2"
            shift 2
            ;;
        --list-templates)
            list_templates
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

PROJECT_PATH="${WORKSPACE_ROOT}/${PROJECT_NAME}"

echo -e "${BLUE}🚀 Initializing project: ${PROJECT_NAME}${NC}"
echo "   Type: ${PROJECT_TYPE}"
if [ -n "$TEMPLATE_NAME" ]; then
    echo -e "   Template: ${YELLOW}${TEMPLATE_NAME}${NC}"
fi
echo "   Path: ${PROJECT_PATH}"
echo ""

# Create project structure
mkdir -p "${PROJECT_PATH}/src"
mkdir -p "${PROJECT_PATH}/tests"
mkdir -p "${PROJECT_PATH}/docs"
mkdir -p "${PROJECT_PATH}/spec"
mkdir -p "${PROJECT_PATH}/research"
mkdir -p "${PROJECT_PATH}/resources/mockups"
mkdir -p "${PROJECT_PATH}/tracks"

# Copy appropriate template
case $PROJECT_TYPE in
    dev)
        cp "${REPO_ROOT}/library/dev-templates/PRP_TEMPLATE.md" "${PROJECT_PATH}/docs/PRP.md"
        echo -e "${GREEN}✓${NC} Copied PRP template"
        ;;
    creative)
        cp "${REPO_ROOT}/library/creative-templates/CONTENT_TEMPLATE.md" "${PROJECT_PATH}/docs/CONTENT.md"
        echo -e "${GREEN}✓${NC} Copied Content template"
        ;;
    life)
        cp "${REPO_ROOT}/library/life-templates/WEEKLY_PLANNER.md" "${PROJECT_PATH}/docs/PLANNER.md"
        echo -e "${GREEN}✓${NC} Copied Planner template"
        ;;
esac

# Copy CLAUDE.md for Claude Code
if [ -f "${REPO_ROOT}/library/claude-templates/CLAUDE.md" ]; then
    cp "${REPO_ROOT}/library/claude-templates/CLAUDE.md" "${PROJECT_PATH}/CLAUDE.md"
    echo -e "${GREEN}✓${NC} Copied CLAUDE.md"
fi

# Copy .claude directory if exists
if [ -d "${REPO_ROOT}/library/claude-templates/.claude" ]; then
    cp -r "${REPO_ROOT}/library/claude-templates/.claude" "${PROJECT_PATH}/.claude"
    echo -e "${GREEN}✓${NC} Copied .claude directory"
fi

# Ensure .claude/rules/ exists with template rules
if [ -d "${REPO_ROOT}/library/claude-templates/.claude/rules" ]; then
    mkdir -p "${PROJECT_PATH}/.claude/rules"
    cp -r "${REPO_ROOT}/library/claude-templates/.claude/rules/." "${PROJECT_PATH}/.claude/rules/"
    echo -e "${GREEN}✓${NC} Copied .claude/rules/ (knowledge base)"
fi

# Apply template overlay if specified
if [ -n "$TEMPLATE_NAME" ]; then
    echo ""
    copy_template "$TEMPLATE_NAME" "$PROJECT_PATH"
fi

# Create .project-meta.json for dashboard integration
cat > "${PROJECT_PATH}/.project-meta.json" << EOF
{
  "name": "${PROJECT_NAME}",
  "type": "${PROJECT_TYPE}",
  "pm2_name": "${PROJECT_NAME}",
  "db_path": null,
  "victoria_logs_query": "project:${PROJECT_NAME}",
  "status_file": "spec/implementation_plan.md",
  "created_at": "$(date +%Y-%m-%d)",
  "tags": [],
  "description": ""
}
EOF

echo -e "${GREEN}✓${NC} Created .project-meta.json"

# Create project README
cat > "${PROJECT_PATH}/README.md" << EOF
# ${PROJECT_NAME}

**Type:** ${PROJECT_TYPE}
**Created:** $(date +%Y-%m-%d)
**Status:** Initial
$([ -n "$TEMPLATE_NAME" ] && echo "**Template:** ${TEMPLATE_NAME}")

---

## Overview
[プロジェクトの概要をここに記載]

## Structure
\`\`\`
${PROJECT_NAME}/
├── src/        # ソースコード
├── tests/      # テスト
├── docs/       # PRP等ドキュメント
├── spec/       # 実装プラン
└── tracks/     # 並列実行トラック
\`\`\`

## Quick Start
1. \`docs/PRP.md\` に要件を記載
2. Architect-Plan に設計依頼
3. 並列実装開始

---
*Generated by Antigravity Life OS*
EOF

echo -e "${GREEN}✓${NC} Created README.md"

# Create .gitkeep files (only if directories are empty)
[ ! "$(ls -A ${PROJECT_PATH}/src 2>/dev/null)" ] && touch "${PROJECT_PATH}/src/.gitkeep"
[ ! "$(ls -A ${PROJECT_PATH}/tests 2>/dev/null)" ] && touch "${PROJECT_PATH}/tests/.gitkeep"
[ ! "$(ls -A ${PROJECT_PATH}/spec 2>/dev/null)" ] && touch "${PROJECT_PATH}/spec/.gitkeep"
[ ! "$(ls -A ${PROJECT_PATH}/tracks 2>/dev/null)" ] && touch "${PROJECT_PATH}/tracks/.gitkeep"

# Initialize git repository
echo ""
echo -e "${BLUE}📦 Initializing Git repository...${NC}"
cd "${PROJECT_PATH}"
git init
git config user.name "carpediem"
git config user.email "nakanisi.yuuta@gmail.com"
echo "agent-*.log" >> .gitignore
git add -A
git commit -m "chore: Initialize project structure"
cd "${REPO_ROOT}"
echo -e "${GREEN}✓${NC} Git repository initialized"

echo ""
echo -e "${GREEN}✅ Project initialized successfully!${NC}"
echo ""
echo "Next steps:"
echo "  1. cd ${PROJECT_PATH}"
echo "  2. Edit docs/PRP.md with your requirements"
if [ -n "$TEMPLATE_NAME" ]; then
    echo -e "  3. Review TEMPLATE_README.md for template details"
    echo "  4. Launch PM agent: ./scripts/launch-agents.sh ${PROJECT_NAME} --dangerously-skip-permissions"
else
    echo "  3. Launch PM agent: ./scripts/launch-agents.sh ${PROJECT_NAME} --dangerously-skip-permissions"
fi
