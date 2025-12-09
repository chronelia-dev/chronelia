# ✅ SOLUCIÓN: Login Simplificado con Schemas

## ⚠️ **Problema Detectado:**
El login estaba usando dos métodos (dual) y causaba confusión. Ahora usa **SOLO** el sistema con schemas (función `login_user()`).

---

## 🔧 **Cambios Aplicados:**

✅ **Login simplificado** → Solo usa `login_user()`  
✅ **Sin métodos de respaldo** → Más claro y directo  
✅ **Mejor detección de errores** → Te dice si falta ejecutar los scripts SQL

---

## 📋 **IMPORTANTE: Configuración Requerida**

Para que el login funcione, **DEBES ejecutar estos scripts SQL en Supabase**:

### **Paso 1: Ejecutar Script Base**
1. Ve a Supabase → SQL Editor
2. Copia y pega: `MULTI_TENANT_SCHEMAS_PASO1.sql`
3. Click **RUN**

### **Paso 2: Ejecutar Script de Funciones**
1. Copia y pega: `MULTI_TENANT_SCHEMAS_PASO2.sql`
2. Click **RUN**

### **Paso 3: Crear un Usuario de Prueba**
Ejecuta este script para crear tu primer negocio y usuario:

```sql
-- ============================================
-- CREAR NEGOCIO Y USUARIO DE PRUEBA
-- ============================================

-- 1. Crear el negocio
SELECT create_business_schema(
  'business_prueba',           -- Nombre del schema
  'Mi Negocio Prueba',         -- Nombre del negocio
  'info@negocio.com',          -- Email
  '+34 666 777 888',           -- Teléfono
  'Calle Principal 123',       -- Dirección
  'premium',                   -- Plan
  10                           -- Máximo trabajadores
);

-- 2. Crear usuario admin
SELECT create_business_user(
  'business_prueba',           -- Schema (mismo del paso 1)
  'admin',                     -- Username para login
  'admin@negocio.com',         -- Email
  'admin123',                  -- Contraseña
  'Administrador',             -- Nombre completo
  'admin'                      -- Rol
);

-- 3. Verificar que se creó correctamente
SELECT * FROM public.businesses WHERE schema_name = 'business_prueba';
SELECT * FROM business_prueba.users;
SELECT * FROM public.user_business_map WHERE username = 'admin';
```

---

## 🎯 **Credenciales de Prueba Creadas:**

```
Usuario: admin
Contraseña: admin123
```

---

## 🔍 **Verificar si los Scripts están Ejecutados**

Ejecuta esto en Supabase SQL Editor:

```sql
-- Verificar si existe la función login_user
SELECT EXISTS (
  SELECT 1 
  FROM pg_proc 
  WHERE proname = 'login_user'
);

-- Si retorna "true" → Scripts ejecutados correctamente ✅
-- Si retorna "false" → Falta ejecutar los scripts ❌
```

---

## 🚨 **Mensajes de Error y Soluciones:**

### **Error: "Base de datos no configurada"**
**Causa:** No se han ejecutado los scripts SQL  
**Solución:** Ejecuta `MULTI_TENANT_SCHEMAS_PASO1.sql` y `MULTI_TENANT_SCHEMAS_PASO2.sql`

### **Error: "Usuario o contraseña incorrectos"**
**Causa:** Usuario no existe o contraseña incorrecta  
**Solución:** 
1. Verifica que el usuario existe:
   ```sql
   SELECT * FROM public.user_business_map WHERE username = 'admin';
   ```
2. Si no existe, créalo con el script del Paso 3 arriba

### **Error: "Usuario inactivo"**
**Causa:** El usuario existe pero está desactivado  
**Solución:**
```sql
-- Buscar el schema del usuario
SELECT schema_name FROM public.user_business_map WHERE username = 'admin';

-- Activar el usuario (reemplaza 'business_prueba' con tu schema)
UPDATE business_prueba.users 
SET active = true 
WHERE username = 'admin';
```

### **Error: "Negocio inactivo"**
**Causa:** El negocio está desactivado  
**Solución:**
```sql
UPDATE public.businesses 
SET active = true 
WHERE schema_name = 'business_prueba';
```

---

## 📱 **Script Completo: Crear Cliente Nuevo**

Usa este script cada vez que quieras agregar un cliente:

```sql
-- ============================================
-- PLANTILLA: NUEVO CLIENTE
-- ============================================
-- Solo cambia los valores entre comillas

-- 1. Crear negocio
SELECT create_business_schema(
  'business_[NOMBRE]',         -- Nombre único del schema (sin espacios)
  '[Nombre del Negocio]',      -- Nombre visible
  '[email@cliente.com]',       -- Email
  '[teléfono]',                -- Teléfono
  '[dirección]',               -- Dirección
  'premium',                   -- Plan: basic/premium/enterprise
  10                           -- Máximo trabajadores
);

-- 2. Crear admin
SELECT create_business_user(
  'business_[NOMBRE]',         -- Schema (igual que arriba)
  '[username]',                -- Username para login
  '[email]',                   -- Email
  '[password]',                -- Contraseña
  '[Nombre Completo]',         -- Nombre
  'admin'                      -- Rol: admin o worker
);

-- 3. Crear trabajadores (opcional)
SELECT create_business_user(
  'business_[NOMBRE]',
  '[username_trabajador]',
  '[email_trabajador]',
  '[password]',
  '[Nombre Trabajador]',
  'worker'
);
```

---

## ✅ **Flujo de Login Ahora:**

```
Usuario ingresa credenciales
        ↓
Llamada a login_user()
        ↓
¿Función existe?
   ├─ NO → Error: "Base de datos no configurada"
   └─ SÍ → ¿Usuario existe?
           ├─ NO → Error: "Usuario o contraseña incorrectos"
           └─ SÍ → ¿Contraseña correcta?
                   ├─ NO → Error: "Usuario o contraseña incorrectos"
                   └─ SÍ → ✅ Login exitoso
```

---

## 🔄 **Actualizar Git y Desplegar:**

```bash
# 1. Commit
git add src/lib/supabase.js
git commit -m "fix: Simplificar login para usar solo función login_user()"

# 2. Push
git push origin main

# 3. La web se actualizará automáticamente
```

---

## 🎯 **Resumen de Pasos:**

1. ✅ **Ejecutar** `MULTI_TENANT_SCHEMAS_PASO1.sql` en Supabase
2. ✅ **Ejecutar** `MULTI_TENANT_SCHEMAS_PASO2.sql` en Supabase
3. ✅ **Crear usuario de prueba** con el script SQL de arriba
4. ✅ **Probar login** con: `admin` / `admin123`
5. ✅ **Funciona!** 🎉

---

**¿Ya ejecutaste los scripts SQL en Supabase?** Si no, ese es el paso que falta. Te guío paso a paso si necesitas ayuda. 🚀




