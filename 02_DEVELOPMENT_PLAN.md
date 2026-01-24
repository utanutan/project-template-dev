# Antigravity Life OS - Development Plan

**Project Name:** Personal Agent Guild "Antigravity Life OS"
**Date:** 2026-01-24
**Version:** 2.0 (English Edition)
**Author:** Antigravity (Assistant)

---

## 1. Development Policy

### 1.1 Technology Stack & Guild Members

This project utilizes a hybrid approach with a smart Orchestrator and specialized Executors.

*   **Core Platform**: Google Antigravity (Orchestration & Planning)
*   **Execution Engine**: OpenCode (Parallel Execution & Sub-agents)
*   **Agent Models**:
    *   **Orchestrator**: Gemini 1.5 Pro (Strategy, Inbox Triage)
    *   **Implementation**: DeepSeek-V3 (Coding Loop)
    *   **Review/Safety**: Claude 3.5 Sonnet (Logic Check), ELYZA (JP Compliance)
    *   **Creative**: GPT-4o, Sakana AI (Trends)

### 1.2 Architecture Design
Refer to `03_SYSTEM_ARCHITECTURE.md` for the detailed directory structure.
Key concept: **Separation of Planning (`spec/`) and Execution (`projects/`)**.

## 2. Implementation Steps

### Phase 1: Foundation Setup
*   [x] **Directory Structure**: Establish `config`, `library`, `spec` directories.
*   [ ] **Configuration**: Create `config/agents.json` defining the "Guild Members".
*   [ ] **Environment**: Set up multiple API keys (Gemini, Anthropic, OpenRouter) in `.env`.

### Phase 2: Agent Harness & Loop Implementation
*   [ ] **Ralph Wiggum Loop Integration**: Implement the script/hook to allow agents to run in a loop until "DONE".
*   [ ] **PRP Template**: Create a Product Requirement Prompt template in `library/docs/PRP_TEMPLATE.md` to standardize input for the loop.
*   [ ] **Multimodal Inbox**: Implement the auto-transcription pipeline for `inbox/voice/`.

### Phase 3: Workflow Automation
*   [ ] **Parallel Track Script**: Create a workflow to spawn multiple OpenCode instances (sub-agents) for different tracks.
*   [ ] **Review Pipeline**: Automated hand-off from Executor to Reviewer agent.

## 3. Verification Plan

### 3.1 Scenario: "The Loop" Test
1.  **Input**: Create a PRP in `spec/` for a simple "Todo App Feature".
2.  **Execute**: Trigger the "Ralph Wiggum Loop" with a generic coding model.
3.  **Verify**: Does the agent iterate (fix errors, refactor) automatically until it outputs the Safety Phrase?

### 3.2 Scenario: Parallel Tracks
1.  **Input**: Request to build "Frontend UI" and "Backend API" simultaneously.
2.  **Verify**: Are two distinct sub-agents running without context collision?

## 4. Deployment Strategy
*   **Local-First**: deeper integration with local tools (Obsidian, local git).
*   **Git Strategy**: `library/` templates are versioned; `projects/` are treated as ephemeral workspaces until finalized.

---
*Approver:*
*Date:*
