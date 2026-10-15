@echo off
taskkill /F /IM input-leaps.exe >nul 2>&1
"%~dp0input-leaps.exe" -f --name WorkPC --debug NOTE --disable-crypto --ipc --enable-drag-drop -c "C:\GreenSoft\SysTools\input-leap\mywork.sgc"
pause
