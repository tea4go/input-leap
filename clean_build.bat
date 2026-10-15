@echo off
REM ===========================================================================
REM  clean_build.bat - wrapper for clean_build.ps1
REM
REM  Forwards ALL arguments to the PowerShell build script unchanged.
REM
REM  Usage:
REM      clean_build.bat [arguments...]
REM
REM  Examples:
REM      clean_build.bat
REM      set B_BUILD_TYPE=Debug && clean_build.bat
REM      clean_build.bat -AnyArg value
REM
REM  Notes:
REM      - clean_build.ps1 reads B_BUILD_TYPE from the environment.
REM      - Every argument given to this .bat is passed through via %*.
REM ===========================================================================

setlocal

REM Run from the directory that holds this .bat and clean_build.ps1, because the
REM PowerShell script uses relative paths (.\build, input-leap-install).
pushd "%~dp0"

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0clean_build.ps1" %*

set "RC=%ERRORLEVEL%"
popd

exit /b %RC%
