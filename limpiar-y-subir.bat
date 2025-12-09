@echo off
echo Limpiando version de prueba y subiendo version final...
cd /d "%~dp0"
git add .
git commit -m "clean: Version final limpia de produccion"
git push origin main
echo.
echo Listo! En 2-3 minutos los cambios estaran en chronelia.online
pause











