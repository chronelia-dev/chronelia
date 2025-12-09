@echo off
echo Subiendo cambios a GitHub...
cd /d "%~dp0"
git add .
git commit -m "feat: Configurar GitHub Pages para deploy automatico"
git push origin main
echo.
echo Listo! Ahora ve a:
echo https://github.com/pedromillorconsult-dev/chronelia/settings/pages
pause











