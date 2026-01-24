@echo off
REM ============================================
REM Antigravity Life OS - Project Initializer (Windows Batch)
REM ============================================
REM Usage: init-project.bat my-app [dev|creative|life]

setlocal enabledelayedexpansion

set PROJECT_NAME=%1
set PROJECT_TYPE=%2

if "%PROJECT_NAME%"=="" (
    echo Error: Project name is required
    echo Usage: init-project.bat ^<project-name^> [dev^|creative^|life]
    exit /b 1
)

if "%PROJECT_TYPE%"=="" set PROJECT_TYPE=dev

set SCRIPT_DIR=%~dp0
set WORKSPACE_ROOT=%SCRIPT_DIR%..
set PROJECT_PATH=%WORKSPACE_ROOT%\%PROJECT_NAME%

echo Initializing project: %PROJECT_NAME%
echo    Type: %PROJECT_TYPE%
echo    Path: %PROJECT_PATH%
echo.

REM Create directories
mkdir "%PROJECT_PATH%\src" 2>nul
mkdir "%PROJECT_PATH%\tests" 2>nul
mkdir "%PROJECT_PATH%\docs" 2>nul
mkdir "%PROJECT_PATH%\spec" 2>nul
mkdir "%PROJECT_PATH%\research" 2>nul
mkdir "%PROJECT_PATH%\resources\mockups" 2>nul
mkdir "%PROJECT_PATH%\tracks" 2>nul
echo Created directory structure

REM Copy templates based on type
set LIBRARY_PATH=%WORKSPACE_ROOT%\..\library

if "%PROJECT_TYPE%"=="dev" (
    copy "%LIBRARY_PATH%\dev-templates\PRP_TEMPLATE.md" "%PROJECT_PATH%\docs\PRP.md" >nul
    echo Copied PRP template
)
if "%PROJECT_TYPE%"=="creative" (
    copy "%LIBRARY_PATH%\creative-templates\CONTENT_TEMPLATE.md" "%PROJECT_PATH%\docs\CONTENT.md" >nul
    echo Copied Content template
)
if "%PROJECT_TYPE%"=="life" (
    copy "%LIBRARY_PATH%\life-templates\WEEKLY_PLANNER.md" "%PROJECT_PATH%\docs\PLANNER.md" >nul
    echo Copied Planner template
)

REM Copy CLAUDE.md
if exist "%LIBRARY_PATH%\claude-templates\CLAUDE.md" (
    copy "%LIBRARY_PATH%\claude-templates\CLAUDE.md" "%PROJECT_PATH%\CLAUDE.md" >nul
    echo Copied CLAUDE.md
)

REM Create .gitkeep files
type nul > "%PROJECT_PATH%\src\.gitkeep"
type nul > "%PROJECT_PATH%\tests\.gitkeep"
type nul > "%PROJECT_PATH%\spec\.gitkeep"
type nul > "%PROJECT_PATH%\research\.gitkeep"
type nul > "%PROJECT_PATH%\tracks\.gitkeep"

echo.
echo Project initialized successfully!
echo.
echo Next steps:
echo   1. cd %PROJECT_PATH%
echo   2. Edit docs\PRP.md with your requirements
echo   3. Start development with Agent Guild
