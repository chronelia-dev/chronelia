# 🚨 PROBLEMA IDENTIFICADO: Login Falla por Incompatibilidad de Parámetros

## ❌ El Problema Real

El login está fallando porque hay **dos versiones diferentes** de la función `login_user()` en los scripts SQL:

### Versión Antigua (probablemente la que está en Supabase):
```sql
CREATE OR REPLACE FUNCTION login_user(
  p_username TEXT,    -- ❌ Nombre antiguo
  p_password TEXT     -- ❌ Nombre antiguo
)
```

### Versión Nueva (la que el código JavaScript espera):
```sql
CREATE OR REPLACE FUNCTION login_user(
  input_username TEXT,  -- ✅ Nombre nuevo
  input_password TEXT   -- ✅ Nombre nuevo
)
```

### Código JavaScript en `src/lib/supabase.js`:
```javascript
const { data: loginResult, error: loginError } = await supabase
  .rpc('login_user', {
    input_username: username,  // ⚠️ Llama con input_username
    input_password: password   // ⚠️ Llama con input_password
  })
```

## 🔍 Resultado

Cuando intentas hacer login, Supabase recibe los parámetros:
- `input_username: "admin"`
- `input_password: "chronelia2025"`

Pero la función esperaba:
- `p_username`
- `p_password`

Por lo tanto, los valores llegan como `NULL` y el login falla con:
- "Usuario no encontrado" ó
- "Error al procesar login"

---

## ✅ SOLUCIÓN INMEDIATA

### Opción 1: Actualizar la Función en Supabase (RECOMENDADO)

Ejecuta el script: **`FIX_LOGIN_PARAMETROS.sql`**

Este script:
1. ✅ Elimina la versión antigua
2. ✅ Crea la versión correcta con `input_username` e `input_password`
3. ✅ Verifica que está correctamente instalada
4. ✅ Hace una prueba automática

### Opción 2: Cambiar el Código JavaScript (NO RECOMENDADO)

Editar `src/lib/supabase.js` línea 72-76 para usar `p_username` y `p_password`:

```javascript
const { data: loginResult, error: loginError } = await supabase
  .rpc('login_user', {
    p_username: username,      // Cambiar aquí
    p_password: password       // Cambiar aquí
  })
```

**❌ Por qué NO es recomendado:**
- El código ya está actualizado a la versión nueva
- Estarías revirtiendo a una versión antigua
- La versión nueva tiene mejor manejo de errores

---

## 🎯 PASOS PARA RESOLVER

### Paso 1: Ejecutar Diagnóstico
```sql
-- Ejecuta en Supabase SQL Editor: DIAGNOSTICO_LOGIN.sql
```

Esto te dirá:
- ✅ Si la función existe
- ✅ Qué parámetros tiene
- ✅ Si hay usuarios creados
- ✅ Si el schema está bien configurado

### Paso 2: Ejecutar el Fix
```sql
-- Ejecuta en Supabase SQL Editor: FIX_LOGIN_PARAMETROS.sql
```

Esto:
- ✅ Actualiza la función a la versión correcta
- ✅ Hace una prueba automática
- ✅ Te muestra si funcionó

### Paso 3: Probar en la App

Intenta hacer login con:
```
Usuario: admin
Contraseña: chronelia2025
```

O si usaste otro password:
```
Usuario: admin
Contraseña: [la que hayas configurado]
```

---

## 🔍 CÓMO VERIFICAR EN SUPABASE

### Ver la función actual:
```sql
SELECT 
  pg_get_function_arguments(p.oid) as parametros
FROM pg_proc p
WHERE p.proname = 'login_user';
```

**Resultado esperado:**
```
parametros: input_username text, input_password text
```

**Si ves esto (versión antigua):**
```
parametros: p_username text, p_password text
```
→ Necesitas ejecutar `FIX_LOGIN_PARAMETROS.sql`

---

## 📊 ARCHIVOS RELEVANTES

| Archivo | Versión de Parámetros | Estado |
|---------|----------------------|--------|
| `MULTI_TENANT_SCHEMAS.sql` | `p_username` | ❌ Antigua |
| `MULTI_TENANT_SCHEMAS_PASO1.sql` | `p_username` | ❌ Antigua |
| `RESET_Y_SETUP_COMPLETO.sql` | `input_username` | ✅ Nueva |
| `FIX_LOGIN_PARAMETROS.sql` | `input_username` | ✅ Nueva (Corrección) |
| `src/lib/supabase.js` | `input_username` | ✅ Código actualizado |

---

## 🚀 QUICK FIX (3 Minutos)

1. **Abre Supabase** → SQL Editor
2. **Copia y pega**: `FIX_LOGIN_PARAMETROS.sql`
3. **Click**: RUN
4. **Verifica**: Que dice "✅ CORRECTO - Usa input_username"
5. **Prueba**: Login en la app

---

## 🆘 SI TODAVÍA NO FUNCIONA

### Ejecuta el diagnóstico completo:

```sql
-- Ejecuta: DIAGNOSTICO_LOGIN.sql
-- Y comparte TODOS los resultados
```

### Revisa la consola del navegador:

1. Abre la app
2. Presiona F12 (Developer Tools)
3. Ve a la pestaña "Console"
4. Intenta hacer login
5. Busca mensajes que digan:
   - `🔐 Intentando login con: ...`
   - `📊 Resultado de login_user (raw): ...`
   - `❌ Error en login_user: ...`

### Comparte:
- Los resultados de `DIAGNOSTICO_LOGIN.sql`
- Los mensajes de la consola del navegador
- El mensaje de error exacto que ves en la app

---

## ✅ ESTADO ESPERADO DESPUÉS DEL FIX

```
✅ Función: login_user(input_username, input_password)
✅ Código JS: llama con input_username, input_password
✅ Compatibilidad: 100%
✅ Login: Funcionando
```

---

## 📝 RESUMEN

**El problema:**
- Función SQL usa `p_username`, `p_password`
- Código JS llama con `input_username`, `input_password`
- Los parámetros no coinciden → Login falla

**La solución:**
- Ejecutar `FIX_LOGIN_PARAMETROS.sql`
- Actualiza la función a usar `input_username`, `input_password`
- Todo vuelve a funcionar

---

**Ejecuta `FIX_LOGIN_PARAMETROS.sql` y luego prueba el login.** 🚀

Si después de esto sigue sin funcionar, ejecuta `DIAGNOSTICO_LOGIN.sql` y comparte los resultados completos para un diagnóstico más profundo.

