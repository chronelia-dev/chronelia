# 🔍 Diagnóstico del Problema de Login

## 📋 **Paso 1: Ejecutar Diagnóstico**

1. Ve a Supabase → SQL Editor
2. Abre el archivo: **`DIAGNOSTICO_LOGIN.sql`**
3. Copia TODO y pégalo en SQL Editor
4. Click **RUN**
5. Copia TODOS los resultados que aparezcan

---

## 🎯 **Qué Buscar en los Resultados:**

### **✅ Si Todo Está Bien, Verás:**
```
✅ Función login_user() existe
✅ Tabla businesses existe
✅ Tabla user_business_map existe

NEGOCIOS CREADOS:
1 row → business_prueba | Negocio de Prueba

MAPEO DE USUARIOS:
2 rows → admin, trabajador

USUARIOS EN business_prueba:
2 rows → admin (admin123), trabajador (trabajo123)

PRUEBA DE LOGIN:
success: true
username: admin
```

### **❌ Si Hay Problemas, Verás:**
```
❌ Función login_user() NO existe
→ SOLUCIÓN: Ejecutar RESET_Y_SETUP_COMPLETO.sql

O

PRUEBA DE LOGIN:
success: false
message: "Usuario no encontrado"
→ SOLUCIÓN: Los usuarios no se crearon
```

---

## 🔧 **Soluciones Según el Error:**

### **Problema 1: "Función login_user() NO existe"**
**Causa:** El script no se ejecutó o falló  
**Solución:**
```sql
-- Ejecutar de nuevo el script completo
-- Archivo: RESET_Y_SETUP_COMPLETO.sql
```

### **Problema 2: "NEGOCIOS CREADOS" está vacío**
**Causa:** No se creó el negocio de prueba  
**Solución:**
```sql
SELECT create_business_schema(
  'business_prueba',
  'Negocio de Prueba',
  'info@prueba.com',
  '+34 666 777 888',
  'Calle Principal 123',
  'premium',
  10
);
```

### **Problema 3: "MAPEO DE USUARIOS" está vacío**
**Causa:** Los usuarios no se crearon  
**Solución:**
```sql
-- Crear usuario admin
SELECT create_business_user(
  'business_prueba',
  'admin',
  'admin@prueba.com',
  'admin123',
  'Administrador',
  'admin'
);

-- Crear trabajador
SELECT create_business_user(
  'business_prueba',
  'trabajador',
  'trabajador@prueba.com',
  'trabajo123',
  'Trabajador',
  'worker'
);
```

### **Problema 4: "success: false, message: Contraseña incorrecta"**
**Causa:** La contraseña guardada no coincide  
**Solución:**
```sql
-- Ver qué contraseña está guardada
SELECT username, password_hash FROM business_prueba.users;

-- Actualizar la contraseña del admin
UPDATE business_prueba.users 
SET password_hash = 'admin123' 
WHERE username = 'admin';
```

### **Problema 5: "success: false, message: Usuario no encontrado"**
**Causa:** El usuario no existe en el mapeo  
**Solución:**
```sql
-- Ver usuarios en el mapeo
SELECT * FROM public.user_business_map;

-- Si está vacío, recrear:
INSERT INTO public.user_business_map (username, schema_name, business_id, business_name)
SELECT 
  'admin',
  'business_prueba',
  b.id,
  b.business_name
FROM public.businesses b
WHERE b.schema_name = 'business_prueba';
```

---

## 🚨 **Si Nada Funciona - Reset Total:**

Ejecuta estos comandos en orden:

```sql
-- 1. Limpiar TODO
DROP SCHEMA IF EXISTS business_prueba CASCADE;
DROP TABLE IF EXISTS public.user_business_map CASCADE;
DROP TABLE IF EXISTS public.businesses CASCADE;
DROP FUNCTION IF EXISTS login_user(text, text);
DROP FUNCTION IF EXISTS create_business_schema;
DROP FUNCTION IF EXISTS create_business_user;

-- 2. Ejecutar el script completo de nuevo
-- Abre: RESET_Y_SETUP_COMPLETO.sql
-- Copia TODO y ejecuta
```

---

## 📞 **Qué Necesito de Ti:**

Por favor, ejecuta el script `DIAGNOSTICO_LOGIN.sql` y **copia AQUÍ el resultado completo**.

Específicamente necesito ver:
1. ¿Las funciones existen? (✅ o ❌)
2. ¿Cuántos negocios hay?
3. ¿Cuántos usuarios en el mapeo?
4. ¿Qué dice la PRUEBA DE LOGIN?
5. ¿Qué contraseñas están guardadas?

Con esa información puedo decirte exactamente qué está fallando. 🔍








