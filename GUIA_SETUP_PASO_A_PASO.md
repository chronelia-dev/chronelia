# 🏗️ SETUP PASO A PASO - CHRONELIA MULTI-TENANT

## 📋 **ÍNDICE DE SCRIPTS**

1. **PASO_1_RESET_TOTAL.sql** → Limpiar base de datos
2. **PASO_2_CONFIGURAR_BASE_MULTI_TENANT.sql** → Crear estructura base
3. **PASO_3_AGREGAR_NEGOCIO.sql** → Agregar TU negocio
4. **PASO_4_AGREGAR_TRABAJADOR.sql** → Agregar trabajadores

---

## ⚡ **EJECUCIÓN PASO A PASO**

### ✅ **PASO 1: Reset Total (2 minutos)**

**Script:** `PASO_1_RESET_TOTAL.sql`

**Qué hace:**
- Elimina TODOS los schemas de negocios existentes
- Elimina todas las tablas en `public`
- Elimina todas las funciones RPC
- Deja la base de datos completamente limpia

**Ejecutar:**
1. Abre Supabase Dashboard
2. Ve a SQL Editor
3. Copia `PASO_1_RESET_TOTAL.sql`
4. Pega y ejecuta (RUN)
5. ✅ Verás: "Base de datos limpia - Lista para configurar"

---

### ✅ **PASO 2: Configurar Base Multi-Tenant (3 minutos)**

**Script:** `PASO_2_CONFIGURAR_BASE_MULTI_TENANT.sql`

**Qué hace:**
- Crea tabla `public.businesses` (para almacenar negocios)
- Crea tabla `public.users` (para usuarios de todos los negocios)
- Crea funciones RPC multi-tenant:
  - `save_reservation()`
  - `get_active_reservations()`
  - `get_reservation_history()`
  - `get_workers()`
- Configura índices y permisos

**Ejecutar:**
1. En Supabase SQL Editor
2. Copia `PASO_2_CONFIGURAR_BASE_MULTI_TENANT.sql`
3. Pega y ejecuta (RUN)
4. ✅ Verás:
   ```
   ✅ Tabla businesses creada
   ✅ Tabla users creada
   ✅ Funciones RPC creadas
   ```

**Resultado:** Base lista para recibir negocios, pero todavía NO hay negocios.

---

### ✅ **PASO 3: Agregar TU Negocio (2 minutos)**

**Script:** `PASO_3_AGREGAR_NEGOCIO.sql`

**QUÉ HACER:**

1. **Abrir el archivo** `PASO_3_AGREGAR_NEGOCIO.sql`

2. **EDITAR estas líneas** (están al inicio del script):

```sql
-- 🔧 EDITA ESTOS VALORES:
v_business_name text := 'Mi Negocio';              -- Nombre de tu negocio
v_schema_name text := 'minegocio';                 -- Schema (sin espacios, minúsculas)
v_admin_email text := 'admin@minegocio.com';       -- Email del admin
v_admin_password text := 'MiPassword123';          -- Contraseña
v_admin_name text := 'Juan Pérez';                 -- Nombre del admin
```

**Ejemplo si tu negocio es "Bar El Refugio":**
```sql
v_business_name text := 'Bar El Refugio';
v_schema_name text := 'elrefugio';
v_admin_email text := 'admin@elrefugio.com';
v_admin_password text := 'Refugio2025';
v_admin_name text := 'María García';
```

3. **Ejecutar en Supabase:**
   - Copia TODO el script (ya editado)
   - Pega en SQL Editor
   - RUN

4. ✅ **Verás:**
```
✅ Negocio creado: Bar El Refugio (schema: elrefugio)
✅ Schema creado: elrefugio
✅ Tabla reservations creada con índices
✅ Tabla customers creada
✅ Tabla daily_stats creada
✅ Realtime habilitado en reservations
✅ Permisos configurados
✅ Usuario admin creado: admin@elrefugio.com

========================================
✅ NEGOCIO CONFIGURADO EXITOSAMENTE
========================================
Negocio: Bar El Refugio
Schema: elrefugio
Admin Email: admin@elrefugio.com
Admin Password: Refugio2025
========================================
```

**Resultado:**
- ✅ Negocio registrado en `public.businesses`
- ✅ Schema `elrefugio` creado con tablas
- ✅ Admin creado y listo para login
- ✅ Realtime habilitado

---

### ✅ **PASO 4: Agregar Trabajadores (1 minuto cada uno)**

**Script:** `PASO_4_AGREGAR_TRABAJADOR.sql`

**QUÉ HACER:**

1. **Abrir** `PASO_4_AGREGAR_TRABAJADOR.sql`

2. **EDITAR:**
```sql
-- 🔧 EDITA ESTOS VALORES:
v_schema_name text := 'minegocio';                      -- Schema de tu negocio
v_worker_email text := 'trabajador@minegocio.com';      -- Email del trabajador
v_worker_password text := 'Password123';                -- Contraseña
v_worker_name text := 'Carlos López';                   -- Nombre del trabajador
```

**Ejemplo:**
```sql
v_schema_name text := 'elrefugio';
v_worker_email text := 'carlos@elrefugio.com';
v_worker_password text := 'Carlos2025';
v_worker_name text := 'Carlos López';
```

3. **Ejecutar en Supabase**

4. ✅ **Verás:**
```
✅ Trabajador creado exitosamente
   Email: carlos@elrefugio.com
   Nombre: Carlos López
   Schema: elrefugio
```

**Para agregar más trabajadores:**
- Ejecuta el mismo script de nuevo
- Solo cambia el `email` y `nombre`
- Puedes agregar tantos como quieras

---

## 🧪 **TESTING**

### **Test 1: Login Admin**

1. Ve a **chronelia.online**
2. Inicia sesión con:
   ```
   Email: (el que configuraste en PASO 3)
   Password: (el que configuraste en PASO 3)
   ```
3. **F12** → Consola:
   ```javascript
   JSON.parse(localStorage.getItem('chronelia_user')).schema_name
   // Debe mostrar tu schema (ej: "elrefugio")
   ```

### **Test 2: Login Trabajador**

1. **Cerrar sesión**
2. Iniciar sesión con:
   ```
   Email: (trabajador del PASO 4)
   Password: (del PASO 4)
   ```
3. Verificar `schema_name` en consola

### **Test 3: Escáner QR**

1. Login como trabajador
2. Clic en "Escanear"
3. Escanear QR de prueba
4. Verificar en consola:
   ```
   💾 Guardando reserva en schema [tu_schema]
   ✅ Reserva guardada exitosamente
   ```
5. Ver tarjeta en dashboard

### **Test 4: Realtime (2 ventanas)**

**Ventana 1: Admin**
```
1. chronelia.online (ventana normal)
2. Login como admin
3. Ver dashboard
4. DEJAR ABIERTA
```

**Ventana 2: Trabajador**
```
1. chronelia.online (ventana incógnito: Ctrl+Shift+N)
2. Login como trabajador
3. Escanear QR
```

**Resultado en Ventana 1:**
```
✅ Reserva aparece AUTOMÁTICAMENTE
✅ SIN recargar página
✅ Realtime funcionando
```

---

## 📊 **CHECKLIST COMPLETO**

```
[ ] PASO 1: Reset total ejecutado
[ ] PASO 2: Base multi-tenant configurada
[ ] PASO 3: Mi negocio agregado con admin
[ ] PASO 4: Al menos 1 trabajador agregado
[ ] Test 1: Admin puede iniciar sesión
[ ] Test 2: Trabajador puede iniciar sesión
[ ] Test 3: schema_name correcto en ambos
[ ] Test 4: Escáner QR funciona
[ ] Test 5: Reserva se guarda
[ ] Test 6: Realtime funciona (2 ventanas)
```

---

## 🎯 **EJEMPLO COMPLETO**

### **Mi negocio: "Bar El Refugio"**

#### PASO 3 - Configuración:
```sql
v_business_name text := 'Bar El Refugio';
v_schema_name text := 'elrefugio';
v_admin_email text := 'admin@elrefugio.com';
v_admin_password text := 'Refugio2025!';
v_admin_name text := 'María García';
```

#### PASO 4 - Trabajador 1:
```sql
v_schema_name text := 'elrefugio';
v_worker_email text := 'carlos@elrefugio.com';
v_worker_password text := 'Carlos2025!';
v_worker_name text := 'Carlos López';
```

#### PASO 4 - Trabajador 2:
```sql
v_schema_name text := 'elrefugio';
v_worker_email text := 'ana@elrefugio.com';
v_worker_password text := 'Ana2025!';
v_worker_name text := 'Ana Martínez';
```

#### Resultado:
```
Negocio: Bar El Refugio
Schema: elrefugio

Usuarios:
- admin@elrefugio.com (admin)
- carlos@elrefugio.com (worker)
- ana@elrefugio.com (worker)

Todos pueden iniciar sesión en chronelia.online
Todos ven SOLO los datos de "Bar El Refugio"
```

---

## ⚠️ **IMPORTANTE**

### **Nombres de Schema:**
- ✅ Sin espacios: `elrefugio` NO `el refugio`
- ✅ Minúsculas: `elrefugio` NO `ElRefugio`
- ✅ Sin caracteres especiales: `elrefugio` NO `el-refugio`
- ✅ Sin números al inicio: `bar123` NO `123bar`

### **Emails:**
- ✅ Únicos por usuario
- ✅ Formato correcto: `usuario@dominio.com`

### **Passwords:**
- ✅ Mínimo 8 caracteres recomendado
- ✅ Usa combinación de letras y números

---

## 📞 **SI ALGO FALLA**

### Error: "schema ya existe"
```
Solución: El schema ya fue creado antes.
1. Ejecuta PASO_1_RESET_TOTAL.sql de nuevo
2. Vuelve a ejecutar PASO 2 y PASO 3
```

### Error: "email ya existe"
```
Solución: Ya hay un usuario con ese email.
1. Cambia el email en el script
2. O ejecuta PASO_1_RESET_TOTAL.sql para empezar de cero
```

### Login no funciona
```
Verificar:
1. ¿Ejecutaste PASO 3 con tus datos?
2. ¿El email y password son correctos?
3. En consola: ¿schema_name está definido?
```

### Escáner no guarda reservas
```
Verificar:
1. En consola: ¿schema_name es correcto?
2. ¿Ejecutaste PASO 2 (funciones RPC)?
3. ¿Hay errores en rojo en consola?
```

---

## ⏱️ **TIEMPO TOTAL**

- PASO 1: 2 minutos
- PASO 2: 3 minutos
- PASO 3: 2 minutos
- PASO 4: 1 minuto
- Testing: 5 minutos

**Total: 13 minutos** para tener tu negocio funcionando completamente.

---

## 🎉 **RESULTADO FINAL**

Después de seguir todos los pasos:

✅ **Tu negocio configurado** con su propio schema  
✅ **Admin y trabajadores** pueden iniciar sesión  
✅ **Escáner QR funcionando** y guardando reservas  
✅ **Realtime activo** - admin ve reservas instantáneamente  
✅ **Sistema multi-tenant** listo para escalar  
✅ **Fácil agregar** más negocios o trabajadores  

---

**¿Listo para empezar? Ejecuta PASO_1_RESET_TOTAL.sql en Supabase** 🚀

