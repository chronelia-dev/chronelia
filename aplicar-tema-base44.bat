@echo off
echo Aplicando tema BASE44 (inspirado en base44.com)...
cd /d "%~dp0"

REM Copiar tema base44 como activo
copy /Y "src\styles\theme-base44.css" "src\styles\theme-active.css"
echo base44 > "src\styles\theme-active.txt"

REM Subir cambios
git add src/styles/
git commit -m "style: Aplicar tema Base44 (naranja vibrante, gradientes pastel)"
git push origin main

echo.
echo ✓ Tema BASE44 aplicado!
echo   - Naranja vibrante como color principal
echo   - Gradientes pastel de fondo
echo   - Diseño moderno y limpio
echo   - Inspirado en base44.com
echo.
echo Se vera en chronelia.online en 2-3 minutos
pause











