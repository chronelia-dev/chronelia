# Script para configurar GitHub Pages
Write-Host "📦 Agregando archivos..." -ForegroundColor Cyan
git add .github/workflows/deploy.yml
git add vite.config.js
git add public/CNAME
git add src/pages/Login.jsx

Write-Host "✅ Commiteando cambios..." -ForegroundColor Green
git commit -m "feat: Configurar GitHub Pages para deploy automático"

Write-Host "🚀 Subiendo a GitHub..." -ForegroundColor Yellow
git push origin main

Write-Host "`n✨ ¡Listo! Ahora sigue estos pasos:" -ForegroundColor Green
Write-Host "1. Ve a: https://github.com/pedromillorconsult-dev/chronelia/settings/pages" -ForegroundColor White
Write-Host "2. En 'Source', selecciona: GitHub Actions" -ForegroundColor White
Write-Host "3. Espera 2-3 minutos" -ForegroundColor White
Write-Host "4. Tu sitio estará en: https://chronelia.online" -ForegroundColor Cyan











