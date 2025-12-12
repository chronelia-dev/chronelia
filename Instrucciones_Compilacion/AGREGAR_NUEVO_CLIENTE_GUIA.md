# 🆕 Guía: Agregar Nuevo Cliente a Chronelia

## 📊 Resumen del Proceso

```
1. Ejecutar create_business_schema()    → Crea schema y tablas
2. Ejecutar create_business_user()      → Crea admin y trabajadores
3. ¡Listo! Cliente puede usar la app   → Login y trabajar
```

**Tiempo total:** 2-3 minutos ⏱️

---

## 🎯 **Paso a Paso Detallado**

### **Ejemplo:** Nuevo cliente "Gimnasio FitLife"

---

### **Paso 1: Abrir SQL Editor en Supabase**

1. Ve a tu proyecto en Supabase
2. Clic en **SQL Editor**
3. Clic en **New query**

---

### **Paso 2: Crear el Negocio**

Copia y ejecuta esto:

```sql
SELECT create_business_schema(
  'business_fitlife',              -- Nombre del schema (único, sin espacios)
  'Gimnasio FitLife',              -- Nombre visible del negocio
  'info@fitlife.com',              -- Email
  '+34 666 777 888',               -- Teléfono
  'Calle Fitness 100, Madrid',     -- Dirección
  'premium',                       -- Plan: basic/premium/enterprise
  15                               -- Máximo trabajadores
);
```

**Qué hace esto:**
- ✅ Crea el schema `business_fitlife`
- ✅ Crea las tablas: `users`, `reservations`, `daily_stats`, `ai_insights`
- ✅ Crea todos los índices necesarios
- ✅ Registra el negocio en la tabla maestra

**Resultado:** Retorna un UUID (ID del negocio)

---

### **Paso 3: Crear Administrador**

```sql
SELECT create_business_user(
  'business_fitlife',              -- Schema (debe coincidir con el anterior)
  'admin_fitlife',                 -- Username (único, será para login)
  'admin@fitlife.com',             -- Email
  'fitlife2025',                   -- Contraseña
  'Director FitLife',              -- Nombre completo
  'admin'                          -- Rol: 'admin' o 'worker'
);
```

**Qué hace esto:**
- ✅ Crea el usuario admin en `business_fitlife.users`
- ✅ Lo registra en `user_business_map` para el login
- ✅ El admin puede gestionar todo el negocio

**Credenciales creadas:**
- Usuario: `admin_fitlife`
- Contraseña: `fitlife2025`

---

### **Paso 4: Crear Trabajadores (Opcional)**

```sql
-- Entrenador
SELECT create_business_user(
  'business_fitlife',
  'entrenador_luis',
  'luis@fitlife.com',
  'luis123',
  'Luis Entrenador',
  'worker'
);

-- Recepcionista
SELECT create_business_user(
  'business_fitlife',
  'recepcion_maria',
  'maria@fitlife.com',
  'maria123',
  'María Recepcionista',
  'worker'
);
```

**Puedes agregar tantos trabajadores como permita el plan:**
- Plan basic: hasta 5 trabajadores
- Plan premium: hasta 15 trabajadores
- Plan enterprise: hasta 50 trabajadores

---

### **Paso 5: Verificar**

```sql
-- Ver el negocio creado
SELECT * FROM public.businesses WHERE schema_name = 'business_fitlife';

-- Ver usuarios creados
SELECT * FROM business_fitlife.users;

-- Ver mapeo de login
SELECT * FROM public.user_business_map WHERE schema_name = 'business_fitlife';
```

---

## 🎨 **Visualización en Supabase**

### Antes de crear el cliente:
```
Table Editor → Schema selector:
├─ public
├─ business_demo
├─ business_bella
└─ business_spa
```

### Después de crear el cliente:
```
Table Editor → Schema selector:
├─ public
├─ business_demo
├─ business_bella
├─ business_spa
└─ business_fitlife  ← ¡NUEVO!
    ├─ users         (3 usuarios: admin, luis, maria)
    ├─ reservations  (vacía, lista para usar)
    ├─ daily_stats   (vacía, lista para usar)
    └─ ai_insights   (vacía, lista para usar)
```

---

## 📝 **Plantilla Reutilizable**

Para facilitar, usa este archivo como plantilla:
👉 **`PLANTILLA_NUEVO_CLIENTE.sql`**

Solo cambia:
1. Nombre del schema
2. Nombre del negocio
3. Datos de contacto
4. Usuarios y contraseñas

---

## 🔐 **Nombrar Schemas - Mejores Prácticas**

### ✅ **Buenos nombres:**
```
business_fitlife
business_cafeteria_sol
business_hotel_plaza
business_spa_relax
```

### ❌ **Malos nombres:**
```
FitLife          ← No empieza con business_
business fitlife ← Tiene espacios
business-fitlife ← Guiones pueden causar problemas
fitlife          ← No está prefijado
```

**Regla:** Siempre usar `business_` + nombre en minúsculas sin espacios

---

## 🧪 **Probar el Login del Nuevo Cliente**

Una vez creado, prueba que funcione:

```sql
SELECT * FROM login_user('admin_fitlife', 'fitlife2025');
```

**Resultado esperado:**
```
success: true
user_id: uuid-del-usuario
username: admin_fitlife
schema_name: business_fitlife
business_name: Gimnasio FitLife
message: Login exitoso
```

---

## 📋 **Checklist para Nuevo Cliente**

- [ ] **Paso 1:** Definir nombre del schema (ej: business_cliente)
- [ ] **Paso 2:** Ejecutar `create_business_schema()`
- [ ] **Paso 3:** Ejecutar `create_business_user()` para admin
- [ ] **Paso 4:** Ejecutar `create_business_user()` para trabajadores
- [ ] **Paso 5:** Verificar en Table Editor que existe el schema
- [ ] **Paso 6:** Probar login con `login_user()`
- [ ] **Paso 7:** Entregar credenciales al cliente

---

## 🔄 **Gestión de Clientes**

### **Ver todos los clientes:**
```sql
SELECT 
  business_name,
  schema_name,
  plan_type,
  max_workers,
  active,
  created_at
FROM public.businesses
ORDER BY created_at DESC;
```

### **Contar usuarios por cliente:**
```sql
SELECT 
  b.business_name,
  b.schema_name,
  COUNT(*) as total_usuarios
FROM public.user_business_map ubm
JOIN public.businesses b ON ubm.schema_name = b.schema_name
GROUP BY b.business_name, b.schema_name
ORDER BY total_usuarios DESC;
```

### **Desactivar un cliente:**
```sql
UPDATE public.businesses 
SET active = false 
WHERE schema_name = 'business_cliente';
```

### **Eliminar un cliente completamente:**
```sql
-- ⚠️ CUIDADO: Esto elimina TODOS los datos del cliente
DROP SCHEMA business_cliente CASCADE;
DELETE FROM public.businesses WHERE schema_name = 'business_cliente';
DELETE FROM public.user_business_map WHERE schema_name = 'business_cliente';
```

---

## 💰 **Gestión de Planes**

### **Cambiar plan de un cliente:**
```sql
UPDATE public.businesses 
SET plan_type = 'premium', max_workers = 15
WHERE schema_name = 'business_fitlife';
```

### **Ver límites de trabajadores:**
```sql
SELECT 
  b.business_name,
  b.max_workers as limite,
  COUNT(u.id) as trabajadores_actuales,
  b.max_workers - COUNT(u.id) as disponibles
FROM public.businesses b
LEFT JOIN public.user_business_map ubm ON b.schema_name = ubm.schema_name
LEFT JOIN LATERAL (
  SELECT id FROM business_demo.users -- Nota: esto es un ejemplo
) u ON true
WHERE b.schema_name = 'business_demo'
GROUP BY b.business_name, b.max_workers;
```

---

## 🎯 **Resumen Ultra-Rápido**

Para agregar un cliente nuevo en 30 segundos:

```sql
-- 1. Crear negocio
SELECT create_business_schema('business_nuevo', 'Nuevo Negocio');

-- 2. Crear admin
SELECT create_business_user('business_nuevo', 'admin_nuevo', 'admin@nuevo.com', 'pass123', 'Admin', 'admin');

-- 3. ¡Listo! Entregar credenciales:
--    Usuario: admin_nuevo
--    Contraseña: pass123
```

**Solo 3 líneas de SQL y tienes un cliente nuevo funcionando.** ✅

---

## 📞 **Información a Entregar al Cliente**

Cuando crees un nuevo cliente, entrega esto:

```
📱 CREDENCIALES DE ACCESO - Chronelia

Negocio: Gimnasio FitLife
Plan: Premium (hasta 15 trabajadores)

ADMINISTRADOR:
  Usuario: admin_fitlife
  Contraseña: fitlife2025
  
TRABAJADORES:
  1. Usuario: entrenador_luis | Contraseña: luis123
  2. Usuario: recepcion_maria | Contraseña: maria123

ACCESO:
  Web: https://chronelia.online
  App: Descargar Chronelia desde [link]

NOTAS:
  - Tus datos están completamente separados de otros clientes
  - Puedes agregar más trabajadores desde el panel de admin
  - Para soporte: soporte@chronelia.com
```

---

**Archivo de plantilla listo:** `PLANTILLA_NUEVO_CLIENTE.sql`

¿Quieres que también te muestre cómo modificar la app para que use esta arquitectura con schemas? 🚀








