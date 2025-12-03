@echo off
cd /d "%~dp0"
echo Mostrando historial de commits...
git log --oneline -30
pause





