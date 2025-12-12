@echo off
echo Aplicando tema NEON (cyberpunk)...
cd /d "%~dp0"

REM Copiar tema neon como activo
copy /Y "src\styles\theme-neon.css" "src\styles\tema-active.css"
echo neon > "src\styles\theme-active.txt"

REM Subir cambios
git add src/styles/
git commit -m "style: Aplicar tema Neon"
git push origin main

echo.
echo ✓ Tema NEON aplicado!
echo   - Estilo cyberpunk
echo   - Efectos neon brillantes
echo   - Colores vibrantes
echo.
echo Se vera en chronelia.online en 2-3 minutos
pause













