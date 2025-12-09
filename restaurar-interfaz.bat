@echo off
echo Restaurando interfaz original sin glassmorphism...
cd /d "%~dp0"
git add src/index.css src/pages/Login.jsx
git commit -m "revert: Restaurar interfaz original sin glassmorphism ni fondo"
git push origin main
echo.
echo Listo! En 2-3 minutos se vera la interfaz original en chronelia.online
pause











