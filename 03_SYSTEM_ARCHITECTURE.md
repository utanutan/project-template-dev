# Antigravity Life OS - System Architecture

This document defines the system architecture, directory structure, and agent guild roles for the "Antigravity Life OS".

## 1. Core Architecture Pattern: Orchestrator & Executor

The system follows a two-tiered architecture to maximize efficiency and context management.

*   **Orchestrator (Antigravity)**: 
    *   **Role**: High-level planning, defining requirements (PRP), and project management.
    *   **Model**: Gemini 1.5 Pro / Claude 3.7 Sonnet.
*   **Executor (OpenCode / Sub-agents)**:
    *   **Role**: executing specific implementation tasks, running tests, and detailed coding.
    *   **Key Feature**: **Parallel Execution** in isolated contexts (Background Tracks).

## 2. Directory Structure

```
/workspace_root/
├── config/                  # System definitions
│   ├── agents.json          # Agent definitions (Roles, Models, Personalities)
│   └── common_settings.env  # Shared environment variables
├── library/                 # Knowledge Base & Templates
│   ├── dev-templates/       # Development templates
│   ├── creative-templates/  # Content creation templates
│   ├── life-templates/      # Life planning templates
│   └── docs/                # System documentation & prompt examples
├── spec/                    # Active Project Specifications (PRPs, Implementation Plans)
├── research/                # Research materials & insights
│   ├── 01_CLAUDE_CODE...    # Transcripts/Notes
│   └── RESEARCH_INSIGHTS.md # Synthesized findings
├── inbox/                   # Multimodal Input
│   ├── voice/               # Audio files -> Auto-transcription
│   └── text/                # Text notes
└── projects/                # Active Project Workspaces
    ├── [project_name]/      # Individual Project
    │   ├── src/             # Source code
    │   └── tracks/          # Parallel execution tracks
    └── ...
```

## 3. Agent Guild (Roles)

| Role | Responsibility | Type | Typical Model |
| :--- | :--- | :--- | :--- |
| **Guild Master** | Orchestration, Strategy, PRP Creation | **Orchestrator** | Gemini 1.5 Pro |
| **Solution Architect**| Technical Design, System Specs | Orchestrator/Sub | Claude 3.5 Sonnet |
| **Lead Developer** | Implementation, Debugging, Refactoring | **Executor** | DeepSeek-V3 |
| **Minute Taker** | Transcription, Summary of Voice Notes | Executor | Gemini 1.5 Flash |
| **Code Reviewer** | Quality Assurance, Security Checks | Executor | Claude 3 Haiku |

## 4. Workflow Strategy: Parallel Tracks

1.  **Plan**: Orchestrator creates a detailed user requirement document (PRP) in `spec/`.
2.  **Split**: The work is divided into independent "Tracks" (e.g., Frontend, Backend, Database).
3.  **Execute**: Sub-agents (Executors) run in parallel on each track within `projects/[name]/tracks/`.
4.  **Loop**: Executors run in a "Ralph Wiggum Loop" (Iterative Refinement) until the completion criteria (Safety Phrase) is met.
5.  **Merge**: Results are merged and reviewed by the Architect/Reviewer.
