@echo off
REM ============================================
REM Antigravity Life OS - Parallel Agent Launcher (Windows Batch)
REM ============================================
REM Usage: launch-agents.bat my-app coder-a,coder-b,reviewer
REM Usage: launch-agents.bat my-app parallel-coders

setlocal enabledelayedexpansion

set PROJECT_NAME=%1
set AGENTS=%2

if "%PROJECT_NAME%"=="" (
    echo Error: Project name is required
    echo Usage: launch-agents.bat ^<project-name^> [agents]
    echo.
    echo Examples:
    echo   launch-agents.bat my-app parallel-coders
    echo   launch-agents.bat my-app coder-a,coder-b,reviewer
    echo.
    echo Presets:
    echo   parallel-coders - coder-a, coder-b, reviewer
    echo   full-team       - all agents
    exit /b 1
)

if "%AGENTS%"=="" set AGENTS=pm

REM Expand presets
if "%AGENTS%"=="parallel-coders" set AGENTS=coder-a,coder-b,reviewer
if "%AGENTS%"=="full-team" set AGENTS=pm,ra,researcher,architect,designer,coder-a,coder-b,reviewer,marketing

set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%\..\%PROJECT_NAME%"

echo Launching agents for project: %PROJECT_NAME%
echo.

REM Parse comma-separated agents
for %%a in (%AGENTS%) do (
    echo Launching: %%a
    call :launch_agent %%a
    timeout /t 1 /nobreak >nul
)

echo.
echo Done! Agents launched in separate windows.
goto :eof

:launch_agent
set AGENT=%1
set PROMPT=

if "%AGENT%"=="pm" set PROMPT=あなたは Project-Manager です。docs/PRP.md を読み、プロジェクト全体を管理してください。
if "%AGENT%"=="ra" set PROMPT=あなたは Requirements-Analyst です。docs/PRP.md を分析し、曖昧な点を明確化してください。
if "%AGENT%"=="researcher" set PROMPT=あなたは Researcher です。市場調査・競合分析を行い、research/ に保存してください。
if "%AGENT%"=="architect" set PROMPT=あなたは Architect-Plan です。spec/implementation_plan.md に実装プランを作成してください。
if "%AGENT%"=="designer" set PROMPT=あなたは Designer です。resources/mockups/ にモックアップを生成してください。
if "%AGENT%"=="coder-a" set PROMPT=あなたは Senior-Coder (Track A) です。実装してください。完了したら Track A: Complete と報告。
if "%AGENT%"=="coder-b" set PROMPT=あなたは Senior-Coder (Track B) です。実装してください。完了したら Track B: Complete と報告。
if "%AGENT%"=="reviewer" set PROMPT=あなたは Review-Guardian です。src/ をレビューしてください。
if "%AGENT%"=="marketing" set PROMPT=あなたは Marketing です。SEO最適化を行ってください。

if "%PROMPT%"=="" set PROMPT=あなたは %AGENT% です。

start "Agent: %AGENT%" cmd /k "claude "%PROMPT%""
goto :eof
