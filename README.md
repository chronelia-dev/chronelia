# 🕐 Chronelia - Sistema de Gestión y Crecimiento Empresarial

![Chronelia Logo](public/logo.svg)

Chronelia es una aplicación web moderna para gestionar reservas de clientes mediante códigos QR. Permite controlar el tiempo de estancia de los clientes en tiempo real, con alertas automáticas y notificaciones.

## ✨ Características

- 🔐 **Sistema de autenticación** con roles (Admin y Trabajador)
- 📱 **Escáner QR** utilizando la cámara del dispositivo
- ⏱️ **Temporizadores en tiempo real** para cada reserva
- 🔔 **Notificaciones automáticas** cuando quedan 5 minutos
- ➕ **Extensión de tiempo** flexible (15 o 30 minutos)
- ✅ **Finalización manual** de reservas
- 📊 **Estadísticas del día** con métricas detalladas
- 📜 **Historial completo** de reservas finalizadas
- 👥 **Panel de administración** con estadísticas en tiempo real (Admin)
- 🛠️ **Gestión de trabajadores** - agregar, eliminar, activar/desactivar (Admin)
- 🎨 **Interfaz moderna** con animaciones suaves
- 📱 **Diseño responsive Mobile-First** (móvil, tablet y escritorio)
- 🌈 **Paleta de colores** degradado rosa-morado

## 🚀 Tecnologías

- **Frontend**: React 18 + Vite
- **Estilos**: TailwindCSS
- **Componentes**: shadcn/ui (custom)
- **Routing**: React Router v6
- **Estado**: Zustand
- **Animaciones**: Framer Motion
- **QR Scanner**: react-qr-reader
- **Notificaciones**: Sonner
- **Iconos**: Lucide React
- **Backend**: Supabase (configuración incluida, modo demo disponible)

## 📋 Requisitos Previos

- Node.js 18+ 
- npm o yarn
- Navegador con soporte para cámara (para escaneo QR)

## 🔧 Instalación

1. **Instalar dependencias:**

```bash
npm install
```

2. **Configurar variables de entorno (opcional):**

Si deseas usar Supabase para autenticación real, crea un archivo `.env`:

```bash
VITE_SUPABASE_URL=tu_url_de_supabase
VITE_SUPABASE_ANON_KEY=tu_clave_anonima
```

**Nota:** La aplicación incluye un sistema de autenticación demo que funciona sin configuración adicional.

3. **Iniciar servidor de desarrollo:**

```bash
npm run dev
```

4. **Abrir en el navegador:**

Visita `http://localhost:5173`

## 👤 Inicio de Sesión - Cuentas de Prueba

### 🔐 Administrador
- **Email**: `admin@chronelia.com`
- **Contraseña**: cualquiera
- **Acceso a**: Panel Admin, Gestión de Trabajadores, todas las funciones

### 👷 Trabajador
- **Email**: `trabajador@chronelia.com`
- **Contraseña**: cualquiera
- **Acceso a**: Dashboard, Escanear QR, Estadísticas, Historial

### Otros usuarios
Cualquier otro email se creará como trabajador automáticamente.

## 📖 Uso de la Aplicación

### 🎭 Roles y Permisos

La aplicación tiene dos tipos de usuario:

**Administrador:**
- Acceso completo a todas las funciones
- Panel de administración con estadísticas en tiempo real
- Gestión de trabajadores (agregar/eliminar/activar/desactivar)
- Vista de reservas por trabajador
- Métricas avanzadas

**Trabajador:**
- Gestión de reservas (escanear QR, extender tiempo, finalizar)
- Vista de estadísticas personales
- Acceso al historial
- Configuración de perfil

### 1. Dashboard Principal (Todos los roles)

- Ver **clientes activos** en tiempo real
- Monitorear **tiempo restante** de cada reserva
- **Extender tiempo** (+15 min o +30 min)
- **Finalizar reserva** manualmente
- Ver **estadísticas rápidas** (clientes activos, urgentes, tiempo total)

### 2. Escanear QR

Hay tres formas de agregar una reserva:

#### Opción A: Escanear con cámara
1. Ir a "Escanear QR"
2. Clic en "Activar Cámara"
3. Apuntar al código QR del cliente

#### Opción B: Entrada manual
1. Ir a "Escanear QR"
2. Ingresar JSON en el campo de entrada manual
3. Clic en "Activar Reserva"

Formato del JSON:
```json
{
  "clientName": "Juan Pérez",
  "clientEmail": "juan@email.com",
  "duration": 30,
  "code": "QR123456"
}
```

#### Opción C: Reserva de prueba
1. Ir a "Escanear QR"
2. Clic en "Crear Reserva de Prueba (45 min)"

### 3. Estadísticas

- **Reservas completadas** del día
- **Clientes activos** en tiempo real
- **Duración promedio** de reservas
- **Tiempo total** acumulado
- **Actividad en tiempo real** con detalles
- **Resumen diario** con métricas

### 4. Historial

- Consultar **todas las reservas finalizadas**
- Filtrar por: Hoy, Ayer, Última semana, Todas
- **Buscar** por nombre o email
- Ver **duración real** vs. tiempo reservado
- **Estadísticas de resumen** del período seleccionado

### 5. Panel de Administración (Solo Admin)

- **Estadísticas en tiempo real** con métricas avanzadas
- **Reservas por trabajador** - distribución actual
- **Estado de trabajadores** - quién está activo
- **Monitoreo completo** de todas las reservas
- **Rendimiento del día** con eficiencia y tendencias

### 6. Gestión de Trabajadores (Solo Admin)

- **Agregar nuevos trabajadores** con nombre y email
- **Eliminar trabajadores** del sistema
- **Activar/desactivar** trabajadores
- **Búsqueda** por nombre o email
- **Estadísticas** de personal (total, activos, inactivos)

### 7. Configuración (Todos los roles)

- Configurar **perfil de usuario**
- Activar/desactivar **notificaciones del navegador**
- Activar/desactivar **sonido de alertas**
- Configurar **tiempo de advertencia** (minutos antes de finalizar)
- Establecer **duración predeterminada** para reservas

## 🔔 Notificaciones

La aplicación envía notificaciones en dos momentos:

1. **5 minutos antes** de que finalice una reserva (configurable)
2. **Al finalizar** el tiempo de una reserva

Las notificaciones se muestran:
- ✅ En la interfaz (toast notifications)
- ✅ En el navegador (si se otorgan permisos)

## 📦 Reserva de Prueba Precargada

Al iniciar la aplicación, ya hay una reserva activa:

- **Cliente**: Ana Pérez
- **Email**: ana.perez@email.com
- **Duración**: 30 minutos
- **Tiempo restante**: 10 minutos
- **Estado**: Activa

Esto permite probar todas las funcionalidades inmediatamente.

## 🎨 Diseño y UX

- **Menú lateral contraíble** con animaciones suaves
- **Tarjetas (cards)** con efectos hover
- **Barras de progreso** con colores dinámicos:
  - 🟢 Verde: Más del 33% de tiempo restante
  - 🟠 Naranja: Entre 17% y 33%
  - 🔴 Rojo: Menos del 17% (urgente)
- **Badges** con estados visuales
- **Temporizador** con cuenta regresiva en tiempo real
- **Transiciones** fluidas con Framer Motion
- **Tipografía**: Inter (Google Fonts)

## 📱 Responsive

La aplicación se adapta perfectamente a:

- 📱 **Móvil**: Diseño compacto, menú colapsado
- 📱 **Tablet**: Vista intermedia, cards en 2 columnas
- 💻 **Desktop**: Vista completa, cards en 3 columnas

## 🏗️ Estructura del Proyecto

```
chronelia/
├── public/
│   └── logo.svg              # Logo de Chronelia
├── src/
│   ├── components/
│   │   ├── layout/
│   │   │   ├── Header.jsx    # Encabezado con logo
│   │   │   ├── Sidebar.jsx   # Menú lateral
│   │   │   └── Layout.jsx    # Layout principal
│   │   ├── ui/               # Componentes UI base
│   │   │   ├── Button.jsx
│   │   │   ├── Card.jsx
│   │   │   ├── Input.jsx
│   │   │   ├── Badge.jsx
│   │   │   └── Progress.jsx
│   │   └── ReservationCard.jsx # Card de reserva activa
│   ├── lib/
│   │   ├── utils.js          # Utilidades y helpers
│   │   └── supabase.js       # Config de Supabase/Auth
│   ├── pages/
│   │   ├── Login.jsx         # Pantalla de inicio de sesión
│   │   ├── Dashboard.jsx     # Dashboard principal
│   │   ├── QRScanner.jsx     # Escáner QR
│   │   ├── Statistics.jsx    # Estadísticas del día
│   │   ├── History.jsx       # Historial de reservas
│   │   ├── Settings.jsx      # Configuración
│   │   ├── AdminPanel.jsx    # Panel de administración (Admin)
│   │   └── Workers.jsx       # Gestión de trabajadores (Admin)
│   ├── store/
│   │   └── useStore.js       # Estado global con Zustand
│   ├── App.jsx               # Componente principal
│   ├── main.jsx              # Punto de entrada
│   └── index.css             # Estilos globales
├── index.html
├── package.json
├── vite.config.js
├── tailwind.config.js
└── README.md
```

## 📱 Compilar como APK para Android

Chronelia puede compilarse como una aplicación móvil nativa para Android.

### Inicio Rápido

**Para Windows:**
```bash
# Ejecutar script automático
compilar-apk.bat
```

**Manual:**
```bash
# 1. Compilar y sincronizar
npm run build:android

# 2. Abrir en Android Studio
npm run open:android

# 3. En Android Studio: Build → Build APK(s)
```

### Requisitos
- Java JDK 17+: https://adoptium.net/
- Android Studio: https://developer.android.com/studio

### Documentación Completa
- **Guía detallada**: [GUIA_COMPILAR_APK.md](GUIA_COMPILAR_APK.md)
- **Resumen rápido**: [RESUMEN_APK.md](RESUMEN_APK.md)

### Scripts APK
```bash
npm run build:android  # Compilar + sincronizar
npm run open:android   # Abrir Android Studio
npm run sync:android   # Solo sincronizar
```

**El APK estará en:** `android/app/build/outputs/apk/debug/app-debug.apk`

---

## 🔮 Funcionalidades Futuras

- [ ] Integración real con Supabase/Firebase
- [ ] Generador de códigos QR
- [ ] Exportar estadísticas a PDF/Excel
- [ ] Gráficos y visualizaciones avanzadas
- [ ] Sistema de reservas previas
- [ ] Notificaciones por email/SMS
- [ ] Modo oscuro
- [ ] Multi-idioma
- [x] ✅ Autenticación con roles (admin, trabajador)
- [x] ✅ Compilación como APK para Android

## 🐛 Scripts Disponibles

```bash
# Desarrollo
npm run dev

# Build para producción
npm run build

# Preview del build
npm run preview

# Linting
npm run lint

# Formateo de código
npm run format
```

## 📄 Licencia

Este proyecto es para uso educativo y demostrativo.

## 👨‍💻 Autor

Desarrollado para Osvaldo - Proyecto Chronelia

---

**¡Disfruta usando Chronelia! 🎉**

Para soporte o preguntas, consulta la documentación o contacta al equipo de desarrollo.

