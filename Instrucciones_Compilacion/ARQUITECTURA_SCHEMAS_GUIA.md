# 🏗️ Nueva Arquitectura: Schemas por Negocio

## 📊 Comparación: Antes vs Ahora

### ❌ Arquitectura Anterior (Confusa)
```
Supabase - Schema: public
├── users (TODOS los usuarios mezclados)
│   ├── admin (business_id: 001)
│   ├── admin_bella (business_id: 002)
│   ├── admin_spa (business_id: 003)
│   ├── mesero_carlos (business_id: 002)
│   └── terapeuta_ana (business_id: 003)
│
├── reservations (TODAS las reservas mezcladas)
│   ├── Reserva 1 (business_id: 001)
│   ├── Reserva 2 (business_id: 002)
│   └── Reserva 3 (business_id: 003)
│
└── daily_stats (TODAS las estadísticas mezcladas)
    ├── Stats 1 (business_id: 001)
    └── Stats 2 (business_id: 002)

😕 Problema: Todo mezclado, difícil de ver en Supabase
```

### ✅ Nueva Arquitectura (Clara y Organizada)
```
Supabase
│
├── Schema: business_demo 📁 (Demo Chronelia)
│   ├── users
│   │   ├── admin
│   │   └── trabajador
│   ├── reservations
│   │   ├── Reserva 1
│   │   └── Reserva 2
│   └── daily_stats
│       └── Stats del día
│
├── Schema: business_bella 📁 (Restaurante)
│   ├── users
│   │   ├── admin_bella
│   │   └── mesero_carlos
│   ├── reservations
│   │   ├── Reserva 1
│   │   └── Reserva 2
│   └── daily_stats
│       └── Stats del día
│
└── Schema: business_spa 📁 (Spa)
    ├── users
    │   ├── admin_spa
    │   └── terapeuta_ana
    ├── reservations
    │   ├── Reserva 1
    │   └── Reserva 2
    └── daily_stats
        └── Stats del día

✅ Beneficio: Cada negocio en su propia "carpeta"
```

---

## 🎯 Ventajas de la Nueva Arquitectura

### 1. **Visualización Clara en Supabase**
```
En Table Editor de Supabase:
┌─────────────────────────────┐
│ Schema: [business_demo ▼]  │ ← Selector de negocio
├─────────────────────────────┤
│ Tables:                     │
│  ├─ users                   │
│  ├─ reservations            │
│  ├─ daily_stats             │
│  └─ ai_insights             │
└─────────────────────────────┘

Cambias el schema y ves otro negocio:
┌─────────────────────────────┐
│ Schema: [business_bella ▼] │
├─────────────────────────────┤
│ Tables:                     │
│  ├─ users                   │
│  ├─ reservations            │
│  └─ ...                     │
└─────────────────────────────┘
```

### 2. **Separación Física de Datos**
- ✅ Los datos NO están mezclados
- ✅ Cada negocio tiene sus propias tablas
- ✅ Imposible acceder a datos de otro negocio
- ✅ Mayor seguridad

### 3. **Agregar Nuevo Cliente es Súper Fácil**
```sql
-- Solo 3 líneas para crear un nuevo negocio completo:

-- 1. Crear el negocio y sus tablas
SELECT create_business_schema(
  'business_nuevocliente',
  'Nombre del Nuevo Cliente'
);

-- 2. Crear admin
SELECT create_business_user(
  'business_nuevocliente',
  'admin_nuevo',
  'admin@nuevo.com',
  'password123',
  'Admin Nuevo',
  'admin'
);

-- 3. Mapear usuario
INSERT INTO user_business_map VALUES 
  ('admin_nuevo', 'business_nuevocliente', 'Nuevo Cliente');

¡LISTO! Nuevo cliente funcionando.
```

---

## 📋 Cómo Ejecutar el Nuevo Script

### Paso 1: Limpiar (Opcional)
Si ya ejecutaste el script anterior, primero limpia:

```sql
-- En SQL Editor de Supabase:
DROP TABLE IF EXISTS public.businesses CASCADE;
DROP TABLE IF EXISTS public.user_business_map CASCADE;
```

### Paso 2: Ejecutar Nuevo Script
1. Abre **SQL Editor** en Supabase
2. Copia TODO el contenido de `MULTI_TENANT_SCHEMAS.sql`
3. Pega y ejecuta
4. Espera 10-15 segundos

### Paso 3: Verificar en Supabase
1. Ve a **Table Editor**
2. Arriba verás: `Schema: [public ▼]`
3. Cámbialo a `Schema: [business_demo ▼]`
4. ¡Verás las tablas del negocio Demo!
5. Cambia a `business_bella` para ver el restaurante
6. Cambia a `business_spa` para ver el spa

---

## 👥 Usuarios de Prueba

| Negocio | Schema | Usuario | Contraseña |
|---------|--------|---------|------------|
| Demo Chronelia | business_demo | admin | chronelia2025 |
| Demo Chronelia | business_demo | trabajador | trabajador123 |
| Restaurante | business_bella | admin_bella | bella2025 |
| Restaurante | business_bella | mesero_carlos | carlos123 |
| Spa | business_spa | admin_spa | spa2025 |
| Spa | business_spa | terapeuta_ana | ana123 |

---

## 🔍 Cómo Funciona el Login

### Antes (Complejo):
```javascript
1. Usuario ingresa username/password
2. Buscar en tabla users con business_id
3. Verificar password
4. Guardar business_id
5. En cada consulta, filtrar por business_id
```

### Ahora (Simple):
```javascript
1. Usuario ingresa username/password
2. Llamar función: login_user(username, password)
3. Función retorna: schema_name, business_name, role
4. App se conecta directamente al schema correcto
5. ¡Todas las consultas van automáticamente al schema correcto!
```

### Ejemplo de Login:
```sql
-- En Supabase:
SELECT * FROM login_user('admin_bella', 'bella2025');

-- Retorna:
{
  success: true,
  user_id: "uuid",
  username: "admin_bella",
  email: "admin@labellavista.com",
  full_name: "Admin Bella Vista",
  role: "admin",
  schema_name: "business_bella",      ← Aquí está el schema
  business_name: "Restaurante La Bella Vista",
  message: "Login exitoso"
}
```

---

## 🆕 Agregar Nuevo Cliente - Tutorial Paso a Paso

Imagina que llega un nuevo cliente: **"Gimnasio FitLife"**

### Paso 1: Crear el Negocio
```sql
SELECT create_business_schema(
  'business_fitlife',              -- Nombre del schema (sin espacios)
  'Gimnasio FitLife',               -- Nombre del negocio
  'info@fitlife.com',               -- Email
  '+34 666 777 888',                -- Teléfono
  'Calle Fitness 100, Madrid',      -- Dirección
  'premium',                        -- Plan
  15                                -- Máximo trabajadores
);
```

### Paso 2: Crear Admin
```sql
SELECT create_business_user(
  'business_fitlife',               -- Schema
  'admin_fitlife',                  -- Username
  'admin@fitlife.com',              -- Email
  'fitlife2025',                    -- Contraseña
  'Director FitLife',               -- Nombre
  'admin'                           -- Rol
);
```

### Paso 3: Crear Trabajadores
```sql
SELECT create_business_user(
  'business_fitlife',
  'entrenador_luis',
  'luis@fitlife.com',
  'luis123',
  'Luis Entrenador',
  'worker'
);
```

### Paso 4: Mapear Usuarios
```sql
INSERT INTO public.user_business_map (username, schema_name, business_name) VALUES
  ('admin_fitlife', 'business_fitlife', 'Gimnasio FitLife'),
  ('entrenador_luis', 'business_fitlife', 'Gimnasio FitLife');
```

### ¡Listo!
Ahora en Table Editor de Supabase verás:
- Schema: `business_fitlife` 📁
  - users (admin_fitlife, entrenador_luis)
  - reservations (vacía, lista para usar)
  - daily_stats (vacía, lista para usar)

---

## 🎨 Cómo se Ve en Supabase

### Vista Anterior (Confusa):
```
Table Editor → users
┌──────────────┬──────────────┬──────────────┐
│ username     │ business_id  │ full_name    │
├──────────────┼──────────────┼──────────────┤
│ admin        │ 001          │ Admin Demo   │
│ admin_bella  │ 002          │ Admin Bella  │
│ admin_spa    │ 003          │ Admin Spa    │
│ mesero...    │ 002          │ Carlos...    │
└──────────────┴──────────────┴──────────────┘
😕 Todo mezclado, difícil de gestionar
```

### Vista Nueva (Clara):
```
Table Editor → Schema: business_demo → users
┌──────────────┬──────────────────────────┐
│ username     │ full_name                │
├──────────────┼──────────────────────────┤
│ admin        │ Administrador Demo       │
│ trabajador   │ Juan Trabajador          │
└──────────────┴──────────────────────────┘

Table Editor → Schema: business_bella → users
┌──────────────┬──────────────────────────┐
│ username     │ full_name                │
├──────────────┼──────────────────────────┤
│ admin_bella  │ Admin Bella Vista        │
│ mesero_carlos│ Carlos Mesero            │
└──────────────┴──────────────────────────┘

✅ Cada negocio separado, fácil de gestionar
```

---

## 💡 Casos de Uso

### Caso 1: Ver Reservas de un Negocio Específico
```
Antes: 
- Abrir tabla reservations
- Ver TODAS las reservas
- Filtrar mentalmente por business_id
😕 Confuso

Ahora:
- Cambiar a Schema: business_bella
- Abrir tabla reservations
- Ver SOLO las reservas del restaurante
✅ Claro
```

### Caso 2: Backup de un Solo Negocio
```
Antes:
- Exportar tabla completa
- Filtrar por business_id manualmente
😕 Complejo

Ahora:
- Exportar solo el schema business_bella
✅ Simple
```

### Caso 3: Eliminar un Negocio
```
Antes:
- DELETE FROM users WHERE business_id = '002'
- DELETE FROM reservations WHERE business_id = '002'
- DELETE FROM daily_stats WHERE business_id = '002'
- ...
😕 Muchas queries

Ahora:
- DROP SCHEMA business_bella CASCADE
✅ Una sola línea
```

---

## ✅ Resumen

| Característica | Arquitectura Anterior | Nueva Arquitectura |
|----------------|----------------------|-------------------|
| Visualización | 😕 Todo mezclado | ✅ Separado por schema |
| Agregar cliente | ⚠️ Complejo | ✅ 3 pasos |
| Seguridad | ⚠️ Filtros por business_id | ✅ Separación física |
| Gestión en Supabase | 😕 Difícil | ✅ Muy fácil |
| Backup | ⚠️ Filtrar manualmente | ✅ Exportar schema |
| Escalabilidad | ⚠️ Limitada | ✅ Excelente |

---

## 🚀 Próximo Paso

**Ejecuta el script `MULTI_TENANT_SCHEMAS.sql` en Supabase**

Luego te mostraré cómo modificar la app para que use esta nueva arquitectura.

¿Listo para ejecutarlo? 🎯




