# 📱 Chronelia v2.8 - Sistema de Temas

**Fecha:** 25 de Noviembre, 2025  
**Versión:** 2.8.0  
**Archivo APK:** `chronelia-v2.8-TEMAS.apk`

## 🎨 NUEVAS CARACTERÍSTICAS

### 1. Sistema de Temas Intercambiables

Ahora Chronelia incluye 5 temas diferentes que se pueden cambiar en segundos:

#### 🤍 Tema Modern (Original)
- Diseño limpio con gradientes pastel
- Fondo blanco puro
- Sombras suaves
- Colores: Rosa→Púrpura→Azul pastel

#### 💎 Tema Glassmorphism
- Efectos de vidrio con blur
- Fondo con gradiente dinámico
- Transparencias elegantes
- Estilo Apple/iOS moderno

#### 🌙 Tema Dark
- Modo oscuro completo
- Colores profundos
- Alto contraste
- Perfecto para uso nocturno

#### ⚡ Tema Neon
- Estilo cyberpunk
- Efectos neón brillantes
- Colores vibrantes
- Animaciones de pulso

#### 🧡 Tema Base44 (ACTIVO en esta versión)
- Inspirado en base44.com
- Naranja vibrante como color principal
- Gradientes pastel de fondo (Azul→Naranja→Amarillo)
- Diseño moderno y profesional
- Esquinas muy redondeadas
- Sombras suaves y difusas

### 2. Mejoras Visuales del Logo

- **Logo mantiene sus colores originales**
- **Texto "Chronelia" adaptativo:**
  - Blanco en temas oscuros (Dark, Neon, Glassmorphism)
  - Gris oscuro en temas claros (Modern, Base44)
- Sombra para mejor legibilidad
- Tipografía Sora bold

### 3. Componentes Actualizados

#### Cards
- Fondo blanco translúcido con blur ligero
- Sombras suaves y difusas
- Efecto flotante en hover
- Esquinas muy redondeadas (1.5rem)

#### Botones
- **Primarios:** Naranja vibrante (#FF6B35)
- **Secundarios:** Azul suave con gradiente
- **Outline:** Borde naranja, hover con fill
- Efectos de hover mejorados

#### Header y Sidebar
- Fondo claro con backdrop blur
- Bordes sutiles con tinte naranja
- Items activos con gradiente naranja
- Transiciones suaves

### 4. Estructura de Archivos de Temas

```
src/styles/
├── theme-modern.css          # Tema limpio original
├── theme-glassmorphism.css   # Efectos glass
├── theme-dark.css            # Modo oscuro
├── theme-neon.css            # Cyberpunk
├── theme-base44.css          # Naranja vibrante (NUEVO)
├── theme-active.css          # Tema actualmente activo
└── theme-active.txt          # Nombre del tema activo
```

## 🔧 ARQUITECTURA

### Plataforma Móvil (APK)
- **Usuario:** Trabajadores
- **Funcionalidades:**
  - Dashboard básico
  - Escáner QR
  - Gestión de reservas
  - Historial
  - Notificaciones
  - Configuración

### Plataforma Web (chronelia.online)
- **Usuario:** Administradores
- **Funcionalidades adicionales:**
  - Panel de administración
  - Gestión de trabajadores
  - Estadísticas avanzadas
  - Recomendaciones IA
  - Chat con IA

## 📊 CONFIGURACIÓN

### Variables CSS del Tema Base44

```css
--primary: #FF6B35       /* Naranja vibrante */
--secondary: #4A90E2     /* Azul suave */
--accent: #FF8C5A        /* Coral */
--radius: 1rem           /* Esquinas redondeadas */
```

### Gradiente de Fondo

```css
background: linear-gradient(135deg, 
  rgb(230, 245, 255) 0%,   /* Azul pastel */
  rgb(255, 240, 230) 50%,  /* Naranja pastel */
  rgb(255, 250, 240) 100%  /* Amarillo pastel */
);
```

## 🚀 INSTALACIÓN

1. **Descargar APK:**
   - Archivo: `chronelia-v2.8-TEMAS.apk`
   
2. **Habilitar instalación de fuentes desconocidas:**
   - Ajustes → Seguridad → Orígenes desconocidos
   
3. **Instalar:**
   - Abrir el APK
   - Seleccionar "Instalar"
   - Esperar a que termine la instalación

4. **Permisos necesarios:**
   - Cámara (para escanear QR)
   - Notificaciones
   - Almacenamiento

## 🎯 MIGRACIÓN GITHUB

Esta versión también incluye la migración a la organización corporativa:

- **Repositorio nuevo:** `github.com/chronelia-dev/chronelia`
- **Cuenta corporativa:** desarrollo@chronelia.com
- **Organización:** chronelia-dev

## 📝 NOTAS TÉCNICAS

### Build Info
- **Node.js:** v18+
- **Capacitor:** 6.x
- **Vite:** 5.x
- **React:** 18.x
- **Android:** Min SDK 22, Target SDK 34

### Optimizaciones
- CSS optimizado con Tailwind
- Lazy loading de componentes
- Imágenes optimizadas
- Build size reducido

## 🔄 SCRIPTS DISPONIBLES (Solo para Web)

Para cambiar de tema en la versión web:

```bash
aplicar-tema-modern.bat        # Tema original
aplicar-tema-glassmorphism.bat # Efectos glass
aplicar-tema-dark.bat          # Modo oscuro
aplicar-tema-neon.bat          # Cyberpunk
aplicar-tema-base44.bat        # Naranja vibrante
```

## 📞 SOPORTE

Para reportar problemas o sugerencias:
- Email: desarrollo@chronelia.com
- Repositorio: github.com/chronelia-dev/chronelia

---

**Desarrollado con ❤️ para mejorar la gestión de reservas**











