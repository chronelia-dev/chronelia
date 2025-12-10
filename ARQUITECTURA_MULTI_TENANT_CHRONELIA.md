# 🏗️ ARQUITECTURA MULTI-TENANT DE CHRONELIA

## 📋 **ÍNDICE**
1. [Qué es Multi-Tenant](#qué-es-multi-tenant)
2. [Cómo Funciona](#cómo-funciona)
3. [Estructura de Base de Datos](#estructura-de-base-de-datos)
4. [Flujo de Datos](#flujo-de-datos)
5. [Realtime](#realtime)
6. [Setup](#setup)
7. [Testing](#testing)

---

## 🎯 **QUÉ ES MULTI-TENANT**

**Multi-tenant** significa que **múltiples negocios** pueden usar la misma app, pero **cada uno ve solo sus datos**.

### Ejemplo:
```
Negocio A: "Locos X Cerveza"
  - Admin: admin@locosxcerveza.com
  - Trabajadores: trabajador1@locosxcerveza.com
  - Reservas: Solo las de "Locos X Cerveza"

Negocio B: "Bar El Refugio"
  - Admin: admin@elrefugio.com
  - Trabajadores: trabajador1@elrefugio.com
  - Reservas: Solo las de "Bar El Refugio"
```

**Cada negocio tiene:**
- ✅ Su propio schema en la base de datos
- ✅ Sus propios usuarios
- ✅ Sus propias reservas
- ✅ Sus propias estadísticas

**Los datos NO se mezclan nunca.**

---

## 🔄 **CÓMO FUNCIONA**

### 1. **Registro/Login**
```
Usuario ingresa:
  Email: trabajador@locosxcerveza.com
  Password: Chronelia@2025

↓

Sistema busca en public.users:
  - Encuentra el usuario
  - Lee su schema_name: "locosxcerveza"
  - Lee su business_id
  - Guarda en localStorage

↓

Usuario queda "conectado" al schema locosxcerveza
```

### 2. **Al escanear QR**
```
Trabajador escanea QR
  ↓
App llama: save_reservation(
    schema_name: "locosxcerveza",  ← Del usuario
    customer_name: "Juan Pérez",
    duration: 240,
    worker_name: "Carlos López"
  )
  ↓
Supabase guarda en: locosxcerveza.reservations
  ↓
REALTIME detecta el cambio
  ↓
Todas las sesiones del negocio se actualizan automáticamente
```

### 3. **Dashboard Admin en Tiempo Real**
```
Admin de "Locos X Cerveza" inicia sesión
  ↓
App se suscribe a: locosxcerveza.reservations
  ↓
Cualquier trabajador escanea un QR
  ↓
Admin ve la nueva reserva INSTANTÁNEAMENTE sin recargar
```

---

## 🗄️ **ESTRUCTURA DE BASE DE DATOS**

### **Schema: public (compartido)**

#### Tabla: `businesses`
```sql
id          | uuid      | ID del negocio
name        | text      | "Locos X Cerveza"
schema_name | text      | "locosxcerveza"
active      | boolean   | true/false
```

#### Tabla: `users`
```sql
id          | uuid      | ID del usuario
email       | text      | Email único
password    | text      | Contraseña
full_name   | text      | Nombre completo
role        | text      | 'admin' o 'worker'
business_id | uuid      | Referencia a businesses
schema_name | text      | "locosxcerveza"
active      | boolean   | true/false
```

---

### **Schema: locosxcerveza (por negocio)**

#### Tabla: `reservations`
```sql
id              | uuid      | ID de reserva
customer_name   | text      | Nombre del cliente
customer_email  | text      | Email del cliente
qr_code         | text      | Código QR
total_duration  | integer   | Duración total (minutos)
actual_duration | integer   | Duración real
start_time      | timestamp | Inicio
end_time        | timestamp | Fin
status          | text      | 'active', 'completed', 'cancelled'
worker_name     | text      | Nombre del trabajador
worker_id       | uuid      | ID del trabajador
group_size      | integer   | Tamaño del grupo
extensions      | integer   | Extensiones
```

#### Tabla: `customers`
```sql
id           | uuid      | ID del cliente
name         | text      | Nombre
email        | text      | Email
phone        | text      | Teléfono
total_visits | integer   | Visitas totales
```

#### Tabla: `daily_stats`
```sql
id                      | uuid    | ID
date                    | date    | Fecha
total_reservations      | integer | Total de reservas
completed_reservations  | integer | Completadas
cancelled_reservations  | integer | Canceladas
total_time              | integer | Tiempo total
average_duration        | integer | Duración promedio
```

---

## 📊 **FLUJO DE DATOS**

### **Flujo Completo: Escanear QR**

```
┌─────────────────────────────────────────┐
│ 1. TRABAJADOR ABRE APP                  │
│    - Inicia sesión                      │
│    - localStorage guarda schema_name    │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│ 2. TRABAJADOR ESCANEA QR                │
│    - Botón "Escanear"                   │
│    - Cámara lee QR                      │
│    - Obtiene: nombre, email, duración   │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│ 3. APP LLAMA A SUPABASE                 │
│    save_reservation(                    │
│      schema_name: "locosxcerveza",      │
│      customer_name: "Juan",             │
│      duration: 240,                     │
│      worker_name: "Carlos"              │
│    )                                    │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│ 4. SUPABASE GUARDA EN BD                │
│    INSERT INTO locosxcerveza.reservations│
│    - ID generado automáticamente        │
│    - Timestamp de inicio: NOW()         │
│    - Status: 'active'                   │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│ 5. REALTIME SE ACTIVA                   │
│    - Detecta INSERT en reservations     │
│    - Notifica a TODAS las sesiones      │
│      suscritas a locosxcerveza          │
└──────────────┬──────────────────────────┘
               │
               ├─────────────────┬─────────────────┐
               ▼                 ▼                 ▼
         ┌─────────┐       ┌─────────┐      ┌─────────┐
         │ ADMIN   │       │TRABAJADOR│      │TRABAJADOR│
         │ VE      │       │ 1 VE     │      │ 2 VE    │
         │ RESERVA │       │ RESERVA  │      │ RESERVA │
         └─────────┘       └─────────┘      └─────────┘
     (Sin recargar)     (Sin recargar)   (Sin recargar)
```

---

## ⚡ **REALTIME**

### **Cómo funciona Supabase Realtime:**

```javascript
// En el código React (useStore.js)

// 1. Suscribirse al canal
const channel = supabase
  .channel('reservations')
  .on(
    'postgres_changes',
    {
      event: '*',  // INSERT, UPDATE, DELETE
      schema: user.schema_name,  // 'locosxcerveza'
      table: 'reservations'
    },
    (payload) => {
      console.log('🔄 Cambio detectado:', payload)
      
      if (payload.eventType === 'INSERT') {
        // Nueva reserva escaneada
        addReservationToState(payload.new)
      }
      
      if (payload.eventType === 'UPDATE') {
        // Reserva actualizada (extendida, completada, etc.)
        updateReservationInState(payload.new)
      }
      
      if (payload.eventType === 'DELETE') {
        // Reserva eliminada
        removeReservationFromState(payload.old.id)
      }
    }
  )
  .subscribe()

// 2. Cuando trabajador escanea QR
await saveReservation(reservationData)
// → TODOS los usuarios ven el cambio instantáneamente
```

### **Ventajas:**
- ✅ Sin necesidad de recargar (F5)
- ✅ Sin polling (no hace consultas cada X segundos)
- ✅ Actualización instantánea
- ✅ Eficiente (usa WebSockets)

---

## 🚀 **SETUP**

### **Script Único: `RESET_TOTAL_Y_MULTI_TENANT_COMPLETO.sql`**

Este script hace TODO:

1. ✅ Elimina TODO lo existente (limpieza completa)
2. ✅ Crea tabla `businesses`
3. ✅ Crea tabla `users`
4. ✅ Crea negocio "Locos X Cerveza"
5. ✅ Crea schema `locosxcerveza`
6. ✅ Crea tablas: `reservations`, `customers`, `daily_stats`
7. ✅ Habilita Realtime en `reservations`
8. ✅ Crea funciones RPC multi-tenant
9. ✅ Crea usuarios de prueba
10. ✅ Configura permisos

### **Ejecución:**

```sql
-- En Supabase SQL Editor:
1. Copiar RESET_TOTAL_Y_MULTI_TENANT_COMPLETO.sql
2. Pegar
3. RUN
4. Esperar "Success"
5. Verificar resultados
```

**Tiempo: 2 minutos**

---

## 🧪 **TESTING**

### **Paso 1: Iniciar sesión como Trabajador**

```
1. chronelia.online
2. Iniciar sesión:
   Email: trabajador@locosxcerveza.com
   Password: Chronelia@2025
3. Verificar en consola (F12):
   JSON.parse(localStorage.getItem('chronelia_user')).schema_name
   → Debe mostrar: "locosxcerveza"
```

### **Paso 2: Escanear QR**

```
1. Clic en botón "Escanear"
2. Escanear código QR de prueba
3. Verificar en consola:
   💾 Guardando reserva en schema locosxcerveza
   ✅ Reserva guardada exitosamente
4. Verificar que aparece tarjeta en dashboard
```

### **Paso 3: Testing Realtime (2 ventanas)**

```
VENTANA 1: Admin
  1. Iniciar sesión: admin@locosxcerveza.com
  2. Ver dashboard vacío

VENTANA 2: Trabajador
  1. Iniciar sesión: trabajador@locosxcerveza.com
  2. Escanear QR
  
VENTANA 1: Admin
  3. ✅ Ver reserva aparecer AUTOMÁTICAMENTE sin recargar
```

---

## 📝 **AGREGAR NUEVO NEGOCIO**

```sql
-- 1. Crear negocio
INSERT INTO public.businesses (name, schema_name, active)
VALUES ('Bar El Refugio', 'elrefugio', true);

-- 2. Crear schema
CREATE SCHEMA elrefugio;

-- 3. Copiar estructura de tablas
CREATE TABLE elrefugio.reservations (LIKE locosxcerveza.reservations INCLUDING ALL);
CREATE TABLE elrefugio.customers (LIKE locosxcerveza.customers INCLUDING ALL);
CREATE TABLE elrefugio.daily_stats (LIKE locosxcerveza.daily_stats INCLUDING ALL);

-- 4. Habilitar Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE elrefugio.reservations;

-- 5. Crear admin
INSERT INTO public.users (email, password, full_name, role, business_id, schema_name)
SELECT 
  'admin@elrefugio.com',
  'Chronelia@2025',
  'Admin Refugio',
  'admin',
  id,
  'elrefugio'
FROM public.businesses WHERE schema_name = 'elrefugio';
```

---

## ✅ **CHECKLIST DE VERIFICACIÓN**

```
[ ] Script RESET_TOTAL_Y_MULTI_TENANT_COMPLETO.sql ejecutado
[ ] Tabla businesses tiene registros
[ ] Tabla users tiene admin y trabajador
[ ] Schema locosxcerveza existe
[ ] Tabla locosxcerveza.reservations existe
[ ] Funciones RPC creadas (save_reservation, etc.)
[ ] Realtime habilitado en reservations
[ ] Login funciona con trabajador@locosxcerveza.com
[ ] schema_name se guarda en localStorage
[ ] Escáner QR funciona
[ ] Reserva se guarda en BD
[ ] Reserva aparece en dashboard
[ ] Realtime funciona (2 ventanas)
```

---

## 🎯 **RESULTADO FINAL**

Después del setup:

- ✅ **Multi-tenant funcionando:** Cada negocio tiene sus datos separados
- ✅ **Login correcto:** Usuarios se asocian a su negocio
- ✅ **Escáner funciona:** Reservas se guardan en el schema correcto
- ✅ **Realtime activo:** Admin ve reservas instantáneamente
- ✅ **Escalable:** Fácil agregar nuevos negocios

---

## 📞 **SOPORTE**

Si algo no funciona:
1. Verificar que ejecutaste el script completo
2. Verificar en consola que `schema_name` existe
3. Verificar que las funciones RPC están creadas
4. Verificar que Realtime está habilitado

---

**Tiempo total de setup: 5 minutos** ⏱️

