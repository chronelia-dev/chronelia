-- ============================================
-- VERIFICACIÓN COMPLETA DE CONFIGURACIÓN
-- ============================================
-- Este script verifica que todo esté configurado correctamente
-- Ejecuta esto en Supabase SQL Editor

-- ============================================
-- 1. VERIFICAR NEGOCIOS
-- ============================================
SELECT 
  '🏢 NEGOCIOS REGISTRADOS' as seccion,
  id,
  name as negocio,
  schema_name,
  active as activo,
  created_at as creado
FROM public.businesses
ORDER BY created_at DESC;

-- ============================================
-- 2. VERIFICAR USUARIOS
-- ============================================
SELECT 
  '👥 USUARIOS REGISTRADOS' as seccion,
  email,
  full_name as nombre,
  role as rol,
  schema_name,
  active as activo,
  created_at as creado
FROM public.users
ORDER BY role DESC, created_at;

-- ============================================
-- 3. VERIFICAR SCHEMAS CREADOS
-- ============================================
SELECT 
  '📁 SCHEMAS (negocios)' as seccion,
  schema_name as schema,
  schema_owner as propietario
FROM information_schema.schemata
WHERE schema_name NOT IN (
  'pg_catalog', 'information_schema', 'auth', 'storage', 
  'realtime', 'extensions', 'graphql', 'graphql_public', 
  'net', 'pgsodium', 'pgsodium_masks', 'pgtle', 
  'supabase_functions', 'supabase_migrations', 'vault', 'public', '_realtime'
)
ORDER BY schema_name;

-- ============================================
-- 4. VERIFICAR TABLAS POR SCHEMA
-- ============================================
SELECT 
  '📊 TABLAS POR SCHEMA' as seccion,
  table_schema as schema,
  table_name as tabla,
  (SELECT COUNT(*) FROM information_schema.columns 
   WHERE table_schema = tables.table_schema 
   AND table_name = tables.table_name) as num_columnas
FROM information_schema.tables tables
WHERE table_schema NOT IN (
  'pg_catalog', 'information_schema', 'auth', 'storage', 
  'realtime', 'extensions', 'graphql', 'graphql_public', 
  'net', 'pgsodium', 'pgsodium_masks', 'pgtle', 
  'supabase_functions', 'supabase_migrations', 'vault', '_realtime'
)
  AND table_type = 'BASE TABLE'
ORDER BY table_schema, table_name;

-- ============================================
-- 5. VERIFICAR FUNCIONES RPC
-- ============================================
SELECT 
  '⚙️ FUNCIONES RPC' as seccion,
  routine_name as funcion,
  routine_type as tipo,
  data_type as retorna
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_type = 'FUNCTION'
  AND routine_name IN (
    'save_reservation',
    'get_active_reservations',
    'get_reservation_history',
    'get_workers'
  )
ORDER BY routine_name;

-- ============================================
-- 6. VERIFICAR REALTIME HABILITADO
-- ============================================
SELECT 
  '⚡ REALTIME HABILITADO' as seccion,
  schemaname as schema,
  tablename as tabla,
  'Activo' as estado
FROM pg_publication_tables
WHERE pubname = 'supabase_realtime'
  AND schemaname NOT IN ('public', 'auth', 'storage')
ORDER BY schemaname, tablename;

-- ============================================
-- 7. VERIFICAR ÍNDICES EN RESERVATIONS
-- ============================================
SELECT 
  '🔍 ÍNDICES EN RESERVATIONS' as seccion,
  schemaname as schema,
  tablename as tabla,
  indexname as indice
FROM pg_indexes
WHERE tablename = 'reservations'
  AND schemaname NOT IN ('pg_catalog', 'information_schema', 'public')
ORDER BY schemaname, indexname;

-- ============================================
-- 8. CONTAR RESERVAS POR SCHEMA
-- ============================================
DO $$
DECLARE
  schema_record RECORD;
  reservas_count INTEGER;
  tabla_existe BOOLEAN;
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '============================================';
  RAISE NOTICE '📈 RESERVAS POR NEGOCIO';
  RAISE NOTICE '============================================';
  
  FOR schema_record IN 
    SELECT schema_name 
    FROM information_schema.schemata
    WHERE schema_name NOT IN (
      'pg_catalog', 'information_schema', 'auth', 'storage', 
      'realtime', 'extensions', 'graphql', 'graphql_public', 
      'net', 'pgsodium', 'pgsodium_masks', 'pgtle', 
      'supabase_functions', 'supabase_migrations', 'vault', 'public', '_realtime'
    )
    AND schema_name NOT LIKE 'pg_%'  -- Excluir todos los schemas pg_*
  LOOP
    -- Verificar si la tabla reservations existe en este schema
    SELECT EXISTS (
      SELECT 1 
      FROM information_schema.tables 
      WHERE table_schema = schema_record.schema_name 
        AND table_name = 'reservations'
    ) INTO tabla_existe;
    
    IF tabla_existe THEN
      EXECUTE format(
        'SELECT COUNT(*) FROM %I.reservations',
        schema_record.schema_name
      ) INTO reservas_count;
      
      RAISE NOTICE 'Schema: % → Reservas: %', schema_record.schema_name, reservas_count;
    ELSE
      RAISE NOTICE 'Schema: % → ⚠️ Sin tabla reservations', schema_record.schema_name;
    END IF;
  END LOOP;
  
  RAISE NOTICE '============================================';
END $$;

-- ============================================
-- 9. VERIFICAR PERMISOS
-- ============================================
SELECT 
  '🔐 PERMISOS EN SCHEMAS' as seccion,
  nspname as schema,
  nspacl as permisos
FROM pg_namespace
WHERE nspname NOT IN (
  'pg_catalog', 'information_schema', 'auth', 'storage', 
  'realtime', 'extensions', 'graphql', 'graphql_public', 
  'net', 'pgsodium', 'pgsodium_masks', 'pgtle', 
  'supabase_functions', 'supabase_migrations', 'vault', 'public', '_realtime'
)
ORDER BY nspname;

-- ============================================
-- 10. RESUMEN FINAL
-- ============================================
DO $$
DECLARE
  num_businesses INTEGER;
  num_users INTEGER;
  num_admins INTEGER;
  num_workers INTEGER;
  num_schemas INTEGER;
  num_functions INTEGER;
  num_realtime INTEGER;
BEGIN
  -- Contar negocios
  SELECT COUNT(*) INTO num_businesses FROM public.businesses;
  
  -- Contar usuarios
  SELECT COUNT(*) INTO num_users FROM public.users;
  SELECT COUNT(*) INTO num_admins FROM public.users WHERE role = 'admin';
  SELECT COUNT(*) INTO num_workers FROM public.users WHERE role = 'worker';
  
  -- Contar schemas de negocios
  SELECT COUNT(*) INTO num_schemas
  FROM information_schema.schemata
  WHERE schema_name NOT IN (
    'pg_catalog', 'information_schema', 'auth', 'storage', 
    'realtime', 'extensions', 'graphql', 'graphql_public', 
    'net', 'pgsodium', 'pgsodium_masks', 'pgtle', 
    'supabase_functions', 'supabase_migrations', 'vault', 'public', '_realtime'
  );
  
  -- Contar funciones RPC
  SELECT COUNT(*) INTO num_functions
  FROM information_schema.routines
  WHERE routine_schema = 'public'
    AND routine_type = 'FUNCTION'
    AND routine_name IN (
      'save_reservation',
      'get_active_reservations',
      'get_reservation_history',
      'get_workers'
    );
  
  -- Contar tablas con realtime
  SELECT COUNT(*) INTO num_realtime
  FROM pg_publication_tables
  WHERE pubname = 'supabase_realtime'
    AND tablename = 'reservations'
    AND schemaname NOT IN ('public', 'auth', 'storage');
  
  RAISE NOTICE '';
  RAISE NOTICE '╔════════════════════════════════════════════╗';
  RAISE NOTICE '║     📊 RESUMEN DE CONFIGURACIÓN            ║';
  RAISE NOTICE '╠════════════════════════════════════════════╣';
  RAISE NOTICE '║ 🏢 Negocios:              % %', LPAD(num_businesses::text, 14), '║';
  RAISE NOTICE '║ 📁 Schemas creados:       % %', LPAD(num_schemas::text, 14), '║';
  RAISE NOTICE '║ 👥 Total usuarios:        % %', LPAD(num_users::text, 14), '║';
  RAISE NOTICE '║    → Admins:              % %', LPAD(num_admins::text, 14), '║';
  RAISE NOTICE '║    → Trabajadores:        % %', LPAD(num_workers::text, 14), '║';
  RAISE NOTICE '║ ⚙️  Funciones RPC:         % %', LPAD(num_functions::text, 14), '║';
  RAISE NOTICE '║ ⚡ Realtime activo:        % %', LPAD(num_realtime::text, 14), '║';
  RAISE NOTICE '╠════════════════════════════════════════════╣';
  
  IF num_businesses > 0 AND num_schemas > 0 AND num_users > 0 AND num_functions = 4 AND num_realtime > 0 THEN
    RAISE NOTICE '║ ✅ ESTADO: TODO CONFIGURADO CORRECTAMENTE  ║';
  ELSE
    RAISE NOTICE '║ ⚠️  ESTADO: CONFIGURACIÓN INCOMPLETA       ║';
    IF num_businesses = 0 THEN
      RAISE NOTICE '║    ❌ Falta: Agregar negocio (PASO 3)      ║';
    END IF;
    IF num_users = 0 THEN
      RAISE NOTICE '║    ❌ Falta: Agregar usuarios (PASO 3/4)   ║';
    END IF;
    IF num_functions < 4 THEN
      RAISE NOTICE '║    ❌ Falta: Funciones RPC (PASO 2)        ║';
    END IF;
    IF num_realtime = 0 THEN
      RAISE NOTICE '║    ❌ Falta: Habilitar Realtime (PASO 3)   ║';
    END IF;
  END IF;
  
  RAISE NOTICE '╚════════════════════════════════════════════╝';
  RAISE NOTICE '';
END $$;

-- ============================================
-- ✅ INTERPRETACIÓN DE RESULTADOS
-- ============================================
-- 
-- SI TODO ESTÁ BIEN DEBERÍAS VER:
-- 
-- 🏢 NEGOCIOS REGISTRADOS: Al menos 1
-- 👥 USUARIOS REGISTRADOS: Al menos 1 admin
-- 📁 SCHEMAS: Uno por cada negocio
-- 📊 TABLAS POR SCHEMA: reservations, customers, daily_stats
-- ⚙️ FUNCIONES RPC: 4 funciones
-- ⚡ REALTIME HABILITADO: reservations en cada schema
-- 🔍 ÍNDICES: idx_*_status, idx_*_start_time, idx_*_worker_id
-- 
-- ============================================
-- SI FALTA ALGO:
-- ============================================
-- 
-- ❌ No hay negocios → Ejecuta PASO_3_AGREGAR_NEGOCIO.sql
-- ❌ No hay usuarios → Ejecuta PASO_3 y PASO_4
-- ❌ No hay funciones → Ejecuta PASO_2_CONFIGURAR_BASE_MULTI_TENANT.sql
-- ❌ No hay realtime → Verifica PASO_3 (se habilita automáticamente)
-- 
-- ============================================

