@echo off
echo Aplicando tema DARK (modo oscuro elegante)...
cd /d "%~dp0"

REM Copiar tema dark como activo
copy /Y "src\styles\theme-dark.css" "src\styles\theme-active.css"
echo dark > "src\styles\theme-active.txt"

REM Subir cambios
git add src/styles/
git commit -m "style: Aplicar tema Dark"
git push origin main

echo.
echo ✓ Tema DARK aplicado!
echo   - Modo oscuro completo
echo   - Colores profundos
echo   - Alto contraste
echo.
echo Se vera en chronelia.online en 2-3 minutos
pause









