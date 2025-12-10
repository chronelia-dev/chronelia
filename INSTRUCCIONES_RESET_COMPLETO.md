# 🔄 Instrucciones: Reset Completo y Setup desde Cero

## ⚠️ ADVERTENCIA
Este script **ELIMINARÁ TODOS LOS DATOS** existentes en Supabase y creará la estructura desde cero.

---

## 📋 **Paso a Paso:**

### **1. Abrir Supabase SQL Editor**
1. Ve a https://supabase.com/dashboard
2. Selecciona tu proyecto chronelia
3. Click en **SQL Editor** (menú izquierdo)
4. Click en **New query**

---

### **2. Ejecutar el Script Completo**

1. Abre el archivo: **`RESET_Y_SETUP_COMPLETO.sql`**
2. **Copia TODO el contenido** (Ctrl+A, Ctrl+C)
3. Pégalo en el SQL Editor de Supabase
4. Click en **RUN** (o presiona Ctrl+Enter)
5. ⏳ Espera 5-10 segundos mientras se ejecuta

---

### **3. Verificar que Funcionó**

Al final del script deberías ver:

```
=== NEGOCIOS ===
1 row

=== MAPEO DE USUARIOS ===
2 rows

=== USUARIOS DEL NEGOCIO ===
2 rows

=== PRUEBA DE LOGIN ===
success: true
user_id: [UUID]
username: admin
business_name: Negocio de Prueba
schema_name: business_prueba
```

✅ Si ves esto, **¡funcionó perfectamente!**

---

## 🎯 **Credenciales Creadas:**

### **Administrador:**
```
Usuario: admin
Contraseña: admin123
```

### **Trabajador:**
```
Usuario: trabajador
Contraseña: trabajo123
```

---

## 🔍 **Si Algo Sale Mal:**

### **Error: "permission denied"**
**Solución:** Tu usuario de Supabase necesita permisos de superusuario.
1. Ve a: Settings → Database → Connection pooling
2. Usa la cadena de conexión de "postgres" (no "pgbouncer")

### **Error: "schema already exists"**
**Solución:** El script intenta limpiar primero, pero si falla:
```sql
-- Ejecuta esto primero (ajusta los nombres de schemas si tienes otros)
DROP SCHEMA IF EXISTS business_prueba CASCADE;
DROP SCHEMA IF EXISTS business_demo CASCADE;
DROP SCHEMA IF EXISTS business_bella CASCADE;
```

### **Error: "function does not exist"**
**Solución:** Esto es normal en la primera ejecución, ignóralo.

---

## ✅ **Después del Setup:**

### **Probar el Login:**
1. Ve a tu app chronelia
2. Refresca la página (Ctrl+F5)
3. Intenta login con: `admin` / `admin123`
4. ✅ Debería funcionar

---

## 🆕 **Agregar Nuevos Negocios:**

Una vez que funcione, usa este script para agregar más negocios:

```sql
-- 1. Crear negocio
SELECT create_business_schema(
  'business_cliente1',
  'Cliente 1 SPA',
  'info@cliente1.com',
  '+34 666 111 222',
  'Dirección del Cliente',
  'premium',
  15
);

-- 2. Crear admin
SELECT create_business_user(
  'business_cliente1',
  'admin_cliente1',
  'admin@cliente1.com',
  'pass123',
  'Admin Cliente 1',
  'admin'
);
```

---

## 📊 **Estructura Creada:**

```
public (schema maestro)
├── businesses (tabla de negocios)
└── user_business_map (mapeo de usuarios)

business_prueba (schema del negocio)
├── users (usuarios del negocio)
├── reservations (reservas)
├── daily_stats (estadísticas)
└── ai_insights (insights de IA)
```

---

## 🎯 **Verificar en Supabase:**

1. Ve a **Table Editor**
2. En el selector de schema (arriba a la izquierda) verás:
   - `public` ← Tablas maestras
   - `business_prueba` ← Tu negocio de prueba

3. Cambia a `business_prueba` y verás las tablas:
   - `users` (2 usuarios)
   - `reservations` (vacía)
   - `daily_stats` (vacía)
   - `ai_insights` (vacía)

---

## 🚀 **Todo Listo:**

Después de ejecutar este script:
- ✅ Base de datos limpia
- ✅ Estructura con schemas creada
- ✅ Funciones de login y gestión funcionando
- ✅ Negocio de prueba con 2 usuarios
- ✅ Listo para usar la app

---

**¿Ejecutaste el script? Dime qué resultado te dio y te ayudo con el siguiente paso.** 🎉





