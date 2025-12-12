@echo off
echo Aplicando tema GLASSMORPHISM (efectos de vidrio)...
cd /d "%~dp0"

REM Copiar tema glassmorphism como activo
copy /Y "src\styles\theme-glassmorphism.css" "src\styles\theme-active.css"
echo glassmorphism > "src\styles\theme-active.txt"

REM Subir cambios
git add src/styles/
git commit -m "style: Aplicar tema Glassmorphism"
git push origin main

echo.
echo ✓ Tema GLASSMORPHISM aplicado!
echo   - Efectos de vidrio con blur
echo   - Fondo con gradiente
echo   - Transparencias
echo.
echo Se vera en chronelia.online en 2-3 minutos
pause













