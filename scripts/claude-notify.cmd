@echo off
rem =============================================================================
rem claude-notify.cmd - Windows wrapper for claude-notify.sh
rem =============================================================================
rem Claude Code Hooks on Windows: WSL's bash may intercept, so this wrapper
rem explicitly uses Git Bash to run the actual notification script.
rem =============================================================================

setlocal enabledelayedexpansion

set "GIT_BASH="

rem Strategy 1: Derive from 'where git' (native backslash paths)
for /f "tokens=*" %%i in ('where git 2^>nul') do (
    if not defined GIT_BASH (
        set "GIT_DIR=%%~dpi"
        rem where git returns e.g. C:\Program Files\Git\cmd\git.exe
        rem We need C:\Program Files\Git\usr\bin\bash.exe
        rem Go up from cmd\ to Git\, then into usr\bin\
        for %%d in ("!GIT_DIR!\..") do set "GIT_ROOT=%%~fd"
        if exist "!GIT_ROOT!\usr\bin\bash.exe" (
            set "GIT_BASH=!GIT_ROOT!\usr\bin\bash.exe"
        )
    )
)

rem Strategy 2: Common install path
if not defined GIT_BASH (
    if exist "C:\Program Files\Git\usr\bin\bash.exe" (
        set "GIT_BASH=C:\Program Files\Git\usr\bin\bash.exe"
    )
)

if defined GIT_BASH (
    "!GIT_BASH!" "%~dp0claude-notify.sh"
    exit /b %ERRORLEVEL%
)

echo Warning: Git Bash not found, cannot send notification >&2
exit /b 0
