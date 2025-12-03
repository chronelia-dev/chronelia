# Sistema de Temas de Chronelia

## 🎨 ¿Qué es?

Un sistema para cambiar rápidamente entre diferentes estilos gráficos de la aplicación. Solo ejecuta un script `.bat` y en 2-3 minutos verás el nuevo tema en `chronelia.online`.

## 📦 Temas Disponibles

### 1. **Modern** (Actual)
- Diseño limpio con gradientes pastel
- Fondo blanco puro
- Sombras suaves
- **Script:** `aplicar-tema-modern.bat`

### 2. **Glassmorphism**
- Efectos de vidrio con blur
- Fondo con gradiente
- Transparencias elegantes
- **Script:** `aplicar-tema-glassmorphism.bat`

### 3. **Dark**
- Modo oscuro completo
- Colores profundos
- Alto contraste
- **Script:** `aplicar-tema-dark.bat`

### 4. **Neon**
- Estilo cyberpunk
- Efectos neón brillantes
- Colores vibrantes
- **Script:** `aplicar-tema-neon.bat`

### 5. **Base44** (Nuevo)
- Inspirado en base44.com
- Naranja vibrante como color principal
- Gradientes pastel de fondo (azul→naranja→amarillo)
- Diseño moderno y limpio
- **Script:** `aplicar-tema-base44.bat`

## 🚀 Cómo Usar

1. **Elige un tema** de los disponibles arriba
2. **Ejecuta el script** correspondiente (doble clic)
3. **Espera 2-3 minutos** para ver los cambios en producción
4. **Repite** cuantas veces quieras para probar diferentes estilos

## 📁 Estructura de Archivos

```
src/styles/
├── theme-modern.css          # Tema limpio actual
├── theme-glassmorphism.css   # Tema con efectos glass
├── theme-dark.css            # Tema oscuro
├── theme-neon.css            # Tema cyberpunk
├── theme-active.css          # Tema actualmente en uso (auto-generado)
└── theme-active.txt          # Nombre del tema activo (auto-generado)
```

## 🎯 Ventajas

- ✅ Cambio instantáneo entre temas
- ✅ Sin perder trabajo previo
- ✅ Todos los temas guardados
- ✅ Fácil de probar y comparar
- ✅ Deploy automático a producción

## 🔧 Cómo Funciona

1. Cada tema está en un archivo CSS separado
2. Los scripts copian el tema elegido como `theme-active.css`
3. Los componentes usan clases especiales (ej: `theme-card`, `theme-header`)
4. El script hace commit y push automáticamente
5. Vercel detecta el cambio y despliega

## ⚡ Mantener Efectos Hover

Todos los temas mantienen:
- Efectos hover suaves
- Escalado en botones y cards
- Transiciones animadas
- La estructura general de la UI

Solo cambian colores, fondos y efectos visuales.

## 📝 Crear Nuevos Temas

1. Copia cualquier archivo `theme-*.css`
2. Renómbralo (ej: `theme-minimalista.css`)
3. Modifica las variables y clases CSS
4. Crea un script `.bat` similar a los existentes
5. ¡Listo! Ya puedes aplicarlo



