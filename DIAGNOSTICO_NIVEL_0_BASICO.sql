-- ============================================
-- DIAGNÓSTICO NIVEL 0 - Verificación Básica
-- ============================================
-- Este script verifica qué existe en tu base de datos

-- ============================================
-- TEST 1: ¿Qué schemas existen?
-- ============================================
SELECT 
  '🔍 Schemas disponibles' as test,
  schema_name as nombre
FROM information_schema.schemata
WHERE schema_name NOT IN ('information_schema', 'pg_catalog', 'pg_toast')
ORDER BY schema_name;

-- ============================================
-- TEST 2: ¿Qué tablas hay en public?
-- ============================================
SELECT 
  '🔍 Tablas en public' as test,
  table_name as tabla
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- ============================================
-- TEST 3: ¿Hay otros schemas con tablas?
-- ============================================
SELECT 
  '🔍 Schemas con tablas' as test,
  table_schema as schema,
  COUNT(*) as num_tablas
FROM information_schema.tables
WHERE table_schema NOT IN ('pg_catalog', 'information_schema', 'pg_toast', '_realtime', 'auth', 'extensions', 'graphql', 'graphql_public', 'net', 'pgsodium', 'pgsodium_masks', 'pgtle', 'realtime', 'storage', 'supabase_functions', 'supabase_migrations', 'vault')
GROUP BY table_schema
ORDER BY table_schema;

-- ============================================
-- TEST 4: ¿Qué funciones RPC existen?
-- ============================================
SELECT 
  '🔍 Funciones disponibles' as test,
  routine_name as funcion
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_type = 'FUNCTION'
ORDER BY routine_name;

-- ============================================
-- RESULTADO ESPERADO
-- ============================================
-- Si la base de datos está configurada correctamente deberías ver:
--
-- TEST 1: Schemas
--   - public
--   - locosxcerveza (o el nombre de tu negocio)
--
-- TEST 2: Tablas en public
--   - businesses
--   - users
--
-- TEST 3: Schemas con tablas
--   - public (2-3 tablas)
--   - locosxcerveza (4-5 tablas)
--
-- TEST 4: Funciones
--   - save_reservation
--   - get_active_reservations
--   - get_reservation_history
--   - get_workers
--
-- ============================================
-- SI NO VES NADA O MUY POCO:
-- ============================================
-- Tu base de datos NO está configurada.
-- Necesitas ejecutar los scripts de setup completo.

