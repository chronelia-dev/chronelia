@echo off
echo Aplicando tema MODERN (limpio con gradientes pastel)...
cd /d "%~dp0"

REM Copiar tema modern como activo
copy /Y "src\styles\theme-modern.css" "src\styles\theme-active.css"
echo modern > "src\styles\theme-active.txt"

REM Subir cambios
git add src/styles/
git commit -m "style: Aplicar tema Modern"
git push origin main

echo.
echo ✓ Tema MODERN aplicado!
echo   - Fondo blanco limpio
echo   - Gradientes pastel
echo   - Sombras suaves
echo.
echo Se vera en chronelia.online en 2-3 minutos
pause









