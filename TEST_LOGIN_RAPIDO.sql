-- ============================================
-- 🚀 TEST RÁPIDO DE LOGIN (1 minuto)
-- ============================================
-- Copia y pega TODO este script en Supabase SQL Editor
-- Te dirá EXACTAMENTE qué está mal y cómo arreglarlo

-- ============================================
-- TEST 1: ¿Existe la función?
-- ============================================
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'login_user') THEN
    RAISE NOTICE '❌ TEST 1 FALLÓ: La función login_user() NO existe';
    RAISE NOTICE '→ SOLUCIÓN: Ejecuta MULTI_TENANT_SCHEMAS.sql';
    RAISE NOTICE '';
  ELSE
    RAISE NOTICE '✅ TEST 1 OK: La función login_user() existe';
    RAISE NOTICE '';
  END IF;
END $$;

-- ============================================
-- TEST 2: ¿Parámetros correctos?
-- ============================================
DO $$
DECLARE
  v_params TEXT;
BEGIN
  SELECT pg_get_function_arguments(p.oid) INTO v_params
  FROM pg_proc p
  WHERE p.proname = 'login_user';
  
  IF v_params LIKE '%input_username%' THEN
    RAISE NOTICE '✅ TEST 2 OK: Los parámetros son correctos (input_username, input_password)';
    RAISE NOTICE '';
  ELSIF v_params LIKE '%p_username%' THEN
    RAISE NOTICE '❌ TEST 2 FALLÓ: Los parámetros son antiguos (p_username, p_password)';
    RAISE NOTICE '→ SOLUCIÓN: Ejecuta FIX_LOGIN_PARAMETROS.sql';
    RAISE NOTICE '';
  ELSE
    RAISE NOTICE '⚠️ TEST 2 ADVERTENCIA: Parámetros desconocidos: %', v_params;
    RAISE NOTICE '';
  END IF;
END $$;

-- ============================================
-- TEST 3: ¿Existe la tabla de mapeo?
-- ============================================
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'user_business_map'
  ) THEN
    RAISE NOTICE '❌ TEST 3 FALLÓ: La tabla user_business_map NO existe';
    RAISE NOTICE '→ SOLUCIÓN: Ejecuta MULTI_TENANT_SCHEMAS.sql';
    RAISE NOTICE '';
  ELSE
    RAISE NOTICE '✅ TEST 3 OK: La tabla user_business_map existe';
    RAISE NOTICE '';
  END IF;
END $$;

-- ============================================
-- TEST 4: ¿Existe el usuario admin?
-- ============================================
DO $$
DECLARE
  v_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_count
  FROM public.user_business_map
  WHERE username = 'admin';
  
  IF v_count = 0 THEN
    RAISE NOTICE '❌ TEST 4 FALLÓ: El usuario admin NO está en user_business_map';
    RAISE NOTICE '→ SOLUCIÓN: Ejecuta el script de crear usuario (ver INSTRUCCIONES_RESOLVER_LOGIN.md)';
    RAISE NOTICE '';
  ELSE
    RAISE NOTICE '✅ TEST 4 OK: El usuario admin existe en user_business_map';
    RAISE NOTICE '';
  END IF;
END $$;

-- ============================================
-- TEST 5: ¿Existe el schema del negocio?
-- ============================================
DO $$
DECLARE
  v_schema TEXT;
BEGIN
  SELECT schema_name INTO v_schema
  FROM public.user_business_map
  WHERE username = 'admin';
  
  IF v_schema IS NULL THEN
    RAISE NOTICE '⚠️ TEST 5 SKIP: No se puede verificar (usuario admin no existe)';
    RAISE NOTICE '';
  ELSIF NOT EXISTS (
    SELECT 1 FROM information_schema.schemata 
    WHERE schema_name = v_schema
  ) THEN
    RAISE NOTICE '❌ TEST 5 FALLÓ: El schema % NO existe', v_schema;
    RAISE NOTICE '→ SOLUCIÓN: Ejecuta MULTI_TENANT_SCHEMAS.sql';
    RAISE NOTICE '';
  ELSE
    RAISE NOTICE '✅ TEST 5 OK: El schema % existe', v_schema;
    RAISE NOTICE '';
  END IF;
END $$;

-- ============================================
-- TEST 6: ¿Existe el usuario en su schema?
-- ============================================
DO $$
DECLARE
  v_schema TEXT;
  v_exists BOOLEAN;
BEGIN
  SELECT schema_name INTO v_schema
  FROM public.user_business_map
  WHERE username = 'admin';
  
  IF v_schema IS NULL THEN
    RAISE NOTICE '⚠️ TEST 6 SKIP: No se puede verificar (usuario admin no existe en mapeo)';
    RAISE NOTICE '';
  ELSE
    EXECUTE format('SELECT EXISTS(SELECT 1 FROM %I.users WHERE username = ''admin'')', v_schema)
    INTO v_exists;
    
    IF NOT v_exists THEN
      RAISE NOTICE '❌ TEST 6 FALLÓ: El usuario admin NO existe en %.users', v_schema;
      RAISE NOTICE '→ SOLUCIÓN: Ejecuta el script de crear usuario (Paso 3)';
      RAISE NOTICE '';
    ELSE
      RAISE NOTICE '✅ TEST 6 OK: El usuario admin existe en %.users', v_schema;
      RAISE NOTICE '';
    END IF;
  END IF;
END $$;

-- ============================================
-- TEST 7: Prueba de login completa
-- ============================================
DO $$
DECLARE
  v_result RECORD;
  v_error TEXT;
BEGIN
  BEGIN
    -- Intentar el login
    SELECT * INTO v_result
    FROM login_user('admin', 'chronelia2025')
    LIMIT 1;
    
    IF v_result.success THEN
      RAISE NOTICE '✅ TEST 7 OK: Login exitoso con admin / chronelia2025';
      RAISE NOTICE '   → Usuario: %', v_result.username;
      RAISE NOTICE '   → Negocio: %', v_result.business_name;
      RAISE NOTICE '   → Schema: %', v_result.schema_name;
      RAISE NOTICE '';
    ELSE
      RAISE NOTICE '❌ TEST 7 FALLÓ: Login rechazado';
      RAISE NOTICE '   → Mensaje: %', v_result.message;
      IF v_result.message = 'Usuario no encontrado' THEN
        RAISE NOTICE '→ SOLUCIÓN: El usuario no está en user_business_map o los parámetros están mal';
        RAISE NOTICE '   Revisa TEST 2 y TEST 4';
      ELSIF v_result.message = 'Contraseña incorrecta' THEN
        RAISE NOTICE '→ SOLUCIÓN: La contraseña no es chronelia2025';
        RAISE NOTICE '   Ejecuta: UPDATE business_demo.users SET password_hash = ''chronelia2025'' WHERE username = ''admin'';';
      ELSIF v_result.message = 'Usuario inactivo' THEN
        RAISE NOTICE '→ SOLUCIÓN: El usuario está desactivado';
        RAISE NOTICE '   Ejecuta: UPDATE business_demo.users SET active = true WHERE username = ''admin'';';
      ELSIF v_result.message = 'Negocio inactivo' THEN
        RAISE NOTICE '→ SOLUCIÓN: El negocio está desactivado';
        RAISE NOTICE '   Ejecuta: UPDATE public.businesses SET active = true WHERE schema_name = ''business_demo'';';
      END IF;
      RAISE NOTICE '';
    END IF;
  EXCEPTION WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS v_error = MESSAGE_TEXT;
    RAISE NOTICE '❌ TEST 7 FALLÓ: Error al ejecutar login_user()';
    RAISE NOTICE '   → Error: %', v_error;
    IF v_error LIKE '%does not exist%' THEN
      RAISE NOTICE '→ SOLUCIÓN: Revisa TEST 1 y TEST 2';
    END IF;
    RAISE NOTICE '';
  END;
END $$;

-- ============================================
-- RESUMEN FINAL
-- ============================================
DO $$
BEGIN
  RAISE NOTICE '═══════════════════════════════════════════════════════';
  RAISE NOTICE '📋 RESUMEN DE TESTS';
  RAISE NOTICE '═══════════════════════════════════════════════════════';
  RAISE NOTICE '';
  RAISE NOTICE 'Revisa los resultados arriba:';
  RAISE NOTICE '';
  RAISE NOTICE '✅ Si todos los tests muestran OK:';
  RAISE NOTICE '   → El login debería funcionar en la app';
  RAISE NOTICE '   → Si no funciona, revisa la consola del navegador (F12)';
  RAISE NOTICE '';
  RAISE NOTICE '❌ Si algún test falló:';
  RAISE NOTICE '   → Sigue la SOLUCIÓN indicada en ese test';
  RAISE NOTICE '   → Luego ejecuta este script de nuevo para verificar';
  RAISE NOTICE '';
  RAISE NOTICE '📄 Documentación completa:';
  RAISE NOTICE '   → INSTRUCCIONES_RESOLVER_LOGIN.md';
  RAISE NOTICE '   → DIAGRAMA_PROBLEMA_LOGIN.md';
  RAISE NOTICE '   → RESUMEN_PROBLEMA_LOGIN.md';
  RAISE NOTICE '';
  RAISE NOTICE '═══════════════════════════════════════════════════════';
END $$;

-- ============================================
-- DATOS ADICIONALES (para debug)
-- ============================================

-- Ver información del usuario admin
SELECT 
  '═══ INFORMACIÓN DEL USUARIO admin ═══' as info,
  m.username,
  m.schema_name,
  m.business_name
FROM public.user_business_map m
WHERE m.username = 'admin';

-- Ver estado del negocio
SELECT 
  '═══ INFORMACIÓN DEL NEGOCIO ═══' as info,
  b.business_name,
  b.schema_name,
  b.active as negocio_activo,
  b.plan_type
FROM public.businesses b
JOIN public.user_business_map m ON b.id = m.business_id
WHERE m.username = 'admin';

-- Ver detalles del usuario en su schema (solo si existe)
DO $$
DECLARE
  v_schema TEXT;
BEGIN
  SELECT schema_name INTO v_schema
  FROM public.user_business_map
  WHERE username = 'admin';
  
  IF v_schema IS NOT NULL THEN
    EXECUTE format('
      SELECT 
        ''═══ DETALLES DEL USUARIO EN %I ═══''::TEXT as info,
        username,
        email,
        full_name,
        role,
        active as usuario_activo,
        password_hash as contraseña_guardada
      FROM %I.users
      WHERE username = ''admin''
    ', v_schema, v_schema);
  END IF;
END $$;

