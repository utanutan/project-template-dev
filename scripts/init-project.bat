@echo off
REM ============================================
REM Antigravity Life OS - Project Initializer (Windows Batch)
REM ============================================
REM Usage: init-project.bat my-app [dev|creative|life] [template-name]
REM        init-project.bat --list-templates

setlocal enabledelayedexpansion

REM Check for --list-templates
if "%1"=="--list-templates" (
    echo Available Templates:
    echo   user-mgmt - Node.js + Express user authentication template
    echo.
    echo Use: init-project.bat my-app dev user-mgmt
    exit /b 0
)

set PROJECT_NAME=%1
set PROJECT_TYPE=%2
set TEMPLATE_NAME=%3

if "%PROJECT_NAME%"=="" (
    echo Error: Project name is required
    echo Usage: init-project.bat ^<project-name^> [dev^|creative^|life] [template-name]
    echo        init-project.bat --list-templates
    exit /b 1
)

if "%PROJECT_TYPE%"=="" set PROJECT_TYPE=dev

set SCRIPT_DIR=%~dp0
set REPO_ROOT=%SCRIPT_DIR%..\..
set WORKSPACE_ROOT=%REPO_ROOT%\projects
set PROJECT_PATH=%WORKSPACE_ROOT%\%PROJECT_NAME%

echo Initializing project: %PROJECT_NAME%
echo    Type: %PROJECT_TYPE%
if not "%TEMPLATE_NAME%"=="" echo    Template: %TEMPLATE_NAME%
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
set LIBRARY_PATH=%REPO_ROOT%\library

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

REM Apply template if specified
if not "%TEMPLATE_NAME%"=="" (
    echo.
    echo Applying template: %TEMPLATE_NAME%
    set TEMPLATE_PATH=%LIBRARY_PATH%\project-templates\%TEMPLATE_NAME%
    
    if exist "!TEMPLATE_PATH!\src" (
        xcopy "!TEMPLATE_PATH!\src" "%PROJECT_PATH%\src" /E /I /Y >nul
        echo Copied src/
    )
    
    if exist "!TEMPLATE_PATH!\spec" (
        mkdir "%PROJECT_PATH%\spec\BASE_REFERENCE" 2>nul
        xcopy "!TEMPLATE_PATH!\spec\*.*" "%PROJECT_PATH%\spec\BASE_REFERENCE" /Y >nul 2>nul
        echo Copied spec/ to BASE_REFERENCE/
    )
    
    if exist "!TEMPLATE_PATH!\research" (
        mkdir "%PROJECT_PATH%\research\BASE_REFERENCE" 2>nul
        xcopy "!TEMPLATE_PATH!\research\*.*" "%PROJECT_PATH%\research\BASE_REFERENCE" /Y >nul 2>nul
        echo Copied research/ to BASE_REFERENCE/
    )
    
    if exist "!TEMPLATE_PATH!\learning" (
        xcopy "!TEMPLATE_PATH!\learning" "%PROJECT_PATH%\learning" /E /I /Y >nul
        echo Copied learning/
    )
    
    echo Generated TEMPLATE_README.md
)

REM Create .gitkeep files
type nul > "%PROJECT_PATH%\src\.gitkeep" 2>nul
type nul > "%PROJECT_PATH%\tests\.gitkeep" 2>nul
type nul > "%PROJECT_PATH%\spec\.gitkeep" 2>nul
type nul > "%PROJECT_PATH%\research\.gitkeep" 2>nul
type nul > "%PROJECT_PATH%\tracks\.gitkeep" 2>nul

echo.
echo Project initialized successfully!
echo.
echo Next steps:
echo   1. cd %PROJECT_PATH%
echo   2. Edit docs\PRP.md with your requirements
if not "%TEMPLATE_NAME%"=="" (
    echo   3. Review TEMPLATE_README.md
    echo   4. Start development with Agent Guild
) else (
    echo   3. Start development with Agent Guild
)
