-- ============================================
-- 🔧 FIX CRÍTICO: ACTUALIZAR FUNCIÓN login_user
-- ============================================
-- PROBLEMA: La función login_user() en Supabase tiene parámetros antiguos
-- pero el código JavaScript llama con parámetros nuevos
--
-- Versión antigua: p_username, p_password
-- Versión nueva:   input_username, input_password
--
-- SOLUCIÓN: Actualizar la función a la versión correcta
-- ============================================

-- ============================================
-- PASO 1: ELIMINAR VERSIÓN ANTIGUA (si existe)
-- ============================================
DROP FUNCTION IF EXISTS login_user(TEXT, TEXT);

-- ============================================
-- PASO 2: CREAR FUNCIÓN CORRECTA
-- ============================================
CREATE OR REPLACE FUNCTION login_user(
  input_username TEXT,
  input_password TEXT
) RETURNS TABLE (
  success BOOLEAN,
  message TEXT,
  user_id UUID,
  username TEXT,
  email TEXT,
  full_name TEXT,
  role TEXT,
  schema_name TEXT,
  business_id UUID,
  business_name TEXT
) AS $$
DECLARE
  v_schema TEXT;
  v_business_id UUID;
  v_business_name TEXT;
  v_user_record RECORD;
  v_business_active BOOLEAN;
BEGIN
  -- Buscar el schema del usuario en el mapeo
  SELECT ubm.schema_name, ubm.business_id, ubm.business_name, b.active
  INTO v_schema, v_business_id, v_business_name, v_business_active
  FROM public.user_business_map ubm
  JOIN public.businesses b ON ubm.business_id = b.id
  WHERE ubm.username = input_username;

  -- Verificar si el usuario existe
  IF v_schema IS NULL THEN
    RETURN QUERY SELECT false, 'Usuario no encontrado'::TEXT, NULL::UUID, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::UUID, NULL::TEXT;
    RETURN;
  END IF;

  -- Verificar si el negocio está activo
  IF NOT v_business_active THEN
    RETURN QUERY SELECT false, 'Negocio inactivo'::TEXT, NULL::UUID, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::UUID, NULL::TEXT;
    RETURN;
  END IF;

  -- Buscar el usuario en su schema y verificar contraseña
  EXECUTE format('
    SELECT id, username, email, password_hash, full_name, role, active
    FROM %I.users
    WHERE username = $1
  ', v_schema) USING input_username INTO v_user_record;

  -- Verificar que el usuario existe en su schema
  IF v_user_record IS NULL THEN
    RETURN QUERY SELECT false, 'Usuario no encontrado en el negocio'::TEXT, NULL::UUID, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::UUID, NULL::TEXT;
    RETURN;
  END IF;

  -- Verificar que el usuario está activo
  IF NOT v_user_record.active THEN
    RETURN QUERY SELECT false, 'Usuario inactivo'::TEXT, NULL::UUID, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::UUID, NULL::TEXT;
    RETURN;
  END IF;

  -- Verificar contraseña (comparación directa - en producción usar bcrypt)
  IF v_user_record.password_hash != input_password THEN
    RETURN QUERY SELECT false, 'Contraseña incorrecta'::TEXT, NULL::UUID, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::UUID, NULL::TEXT;
    RETURN;
  END IF;

  -- Login exitoso
  RETURN QUERY SELECT 
    true,
    'Login exitoso'::TEXT,
    v_user_record.id,
    v_user_record.username,
    v_user_record.email,
    v_user_record.full_name,
    v_user_record.role,
    v_schema,
    v_business_id,
    v_business_name;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- PASO 3: VERIFICAR QUE LA FUNCIÓN ESTÁ CORRECTA
-- ============================================
SELECT 
  '=== VERIFICAR FUNCIÓN ===' as check,
  pg_get_function_arguments(p.oid) as parametros_actuales,
  CASE 
    WHEN pg_get_function_arguments(p.oid) LIKE '%input_username%' 
    THEN '✅ CORRECTO - Usa input_username'
    ELSE '❌ INCORRECTO - Usa p_username (versión antigua)'
  END as estado
FROM pg_proc p
WHERE p.proname = 'login_user';

-- ============================================
-- PASO 4: PROBAR LA FUNCIÓN
-- ============================================
-- Prueba con el usuario admin (ajusta la contraseña si es diferente)
SELECT 
  '=== PRUEBA DE LOGIN ===' as test,
  success,
  message,
  username,
  business_name,
  schema_name
FROM login_user('admin', 'chronelia2025');

-- ============================================
-- 📋 INSTRUCCIONES
-- ============================================
/*
✅ EJECUTA ESTE SCRIPT EN SUPABASE:

1. Ve a Supabase → SQL Editor
2. Copia y pega TODO este script
3. Click en "RUN"
4. Verifica que los resultados muestran:
   - "✅ CORRECTO - Usa input_username"
   - La prueba de login muestra success = true

5. Si la prueba de login muestra success = false:
   - Lee el mensaje de error
   - Puede ser que la contraseña sea diferente
   - Ejecuta el DIAGNÓSTICO para ver qué contraseña tiene guardada

6. Después de ejecutar este script, prueba el login en la app

❓ SI EL LOGIN SIGUE FALLANDO:
   → Ejecuta: DIAGNOSTICO_LOGIN.sql
   → Y comparte los resultados completos
*/

-- ============================================
-- 🆘 OPCIÓN ALTERNATIVA: CAMBIAR LA CONTRASEÑA
-- ============================================
-- Si no estás seguro de la contraseña actual, ejecuta esto:
/*
-- Primero encuentra el schema del usuario
SELECT schema_name 
FROM public.user_business_map 
WHERE username = 'admin';

-- Luego actualiza la contraseña (reemplaza 'business_demo' con tu schema)
UPDATE business_demo.users 
SET password_hash = 'chronelia2025'
WHERE username = 'admin';

-- Verifica que se actualizó
SELECT username, password_hash, active 
FROM business_demo.users 
WHERE username = 'admin';
*/

