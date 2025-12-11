-- ============================================
-- PASO 3: AGREGAR TU NEGOCIO
-- ============================================
-- 
-- INSTRUCCIONES:
-- 1. Reemplaza estos valores con los de TU negocio:
--    - 'Mi Negocio' → Nombre de tu negocio
--    - 'minegocio' → Nombre del schema (sin espacios, minúsculas)
--    - 'admin@minegocio.com' → Email del admin
--    - 'MiPassword123' → Tu contraseña
--    - 'Juan Pérez' → Nombre del admin
-- 
-- 2. Ejecuta este script completo
-- 
-- ============================================

-- ============================================
-- CONFIGURACIÓN - EDITA ESTOS VALORES
-- ============================================
DO $$
DECLARE
  -- 🔧 EDITA ESTOS VALORES:
  v_business_name text := 'Mi Negocio';              -- Nombre de tu negocio
  v_schema_name text := 'minegocio';                 -- Schema (sin espacios, minúsculas)
  v_admin_email text := 'admin@minegocio.com';       -- Email del admin
  v_admin_password text := 'MiPassword123';          -- Contraseña
  v_admin_name text := 'Juan Pérez';                 -- Nombre del admin
  
  -- Variables internas
  v_business_id uuid;
BEGIN

  -- ============================================
  -- 1. CREAR NEGOCIO
  -- ============================================
  INSERT INTO public.businesses (name, schema_name, active)
  VALUES (v_business_name, v_schema_name, true)
  RETURNING id INTO v_business_id;
  
  RAISE NOTICE '✅ Negocio creado: % (schema: %)', v_business_name, v_schema_name;

  -- ============================================
  -- 2. CREAR SCHEMA
  -- ============================================
  EXECUTE format('CREATE SCHEMA %I', v_schema_name);
  
  RAISE NOTICE '✅ Schema creado: %', v_schema_name;

  -- ============================================
  -- 3. CREAR TABLA DE RESERVAS
  -- ============================================
  EXECUTE format('
    CREATE TABLE %I.reservations (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      customer_name text NOT NULL,
      customer_email text,
      qr_code text,
      total_duration integer NOT NULL,
      actual_duration integer DEFAULT 0,
      start_time timestamptz NOT NULL DEFAULT NOW(),
      end_time timestamptz,
      status text NOT NULL DEFAULT ''active'' CHECK (status IN (''active'', ''completed'', ''cancelled'')),
      worker_name text NOT NULL,
      worker_id uuid,
      group_size integer DEFAULT 1,
      extensions integer DEFAULT 0,
      created_at timestamptz DEFAULT NOW(),
      updated_at timestamptz DEFAULT NOW()
    )',
    v_schema_name
  );
  
  -- Índices
  EXECUTE format('CREATE INDEX idx_%I_reservations_status ON %I.reservations(status)', 
    v_schema_name, v_schema_name);
  EXECUTE format('CREATE INDEX idx_%I_reservations_start_time ON %I.reservations(start_time DESC)', 
    v_schema_name, v_schema_name);
  EXECUTE format('CREATE INDEX idx_%I_reservations_worker_id ON %I.reservations(worker_id)', 
    v_schema_name, v_schema_name);
  
  RAISE NOTICE '✅ Tabla reservations creada con índices';

  -- ============================================
  -- 4. CREAR TABLA DE CLIENTES
  -- ============================================
  EXECUTE format('
    CREATE TABLE %I.customers (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      name text NOT NULL,
      email text UNIQUE,
      phone text,
      total_visits integer DEFAULT 0,
      created_at timestamptz DEFAULT NOW(),
      updated_at timestamptz DEFAULT NOW()
    )',
    v_schema_name
  );
  
  RAISE NOTICE '✅ Tabla customers creada';

  -- ============================================
  -- 5. CREAR TABLA DE ESTADÍSTICAS
  -- ============================================
  EXECUTE format('
    CREATE TABLE %I.daily_stats (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      date date UNIQUE NOT NULL DEFAULT CURRENT_DATE,
      total_reservations integer DEFAULT 0,
      completed_reservations integer DEFAULT 0,
      cancelled_reservations integer DEFAULT 0,
      total_time integer DEFAULT 0,
      average_duration integer DEFAULT 0,
      created_at timestamptz DEFAULT NOW()
    )',
    v_schema_name
  );
  
  RAISE NOTICE '✅ Tabla daily_stats creada';

  -- ============================================
  -- 6. HABILITAR REALTIME
  -- ============================================
  EXECUTE format('ALTER PUBLICATION supabase_realtime ADD TABLE %I.reservations', v_schema_name);
  
  RAISE NOTICE '✅ Realtime habilitado en reservations';

  -- ============================================
  -- 7. CONFIGURAR PERMISOS
  -- ============================================
  EXECUTE format('GRANT USAGE ON SCHEMA %I TO anon, authenticated', v_schema_name);
  EXECUTE format('GRANT ALL ON ALL TABLES IN SCHEMA %I TO anon, authenticated', v_schema_name);
  EXECUTE format('GRANT ALL ON ALL SEQUENCES IN SCHEMA %I TO anon, authenticated', v_schema_name);
  EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT ALL ON TABLES TO anon, authenticated', v_schema_name);
  EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT ALL ON SEQUENCES TO anon, authenticated', v_schema_name);
  
  RAISE NOTICE '✅ Permisos configurados';

  -- ============================================
  -- 8. CREAR USUARIO ADMIN
  -- ============================================
  INSERT INTO public.users (
    email,
    password,
    full_name,
    role,
    business_id,
    schema_name,
    active
  )
  VALUES (
    v_admin_email,
    v_admin_password,
    v_admin_name,
    'admin',
    v_business_id,
    v_schema_name,
    true
  );
  
  RAISE NOTICE '✅ Usuario admin creado: %', v_admin_email;

  -- ============================================
  -- RESUMEN FINAL
  -- ============================================
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '✅ NEGOCIO CONFIGURADO EXITOSAMENTE';
  RAISE NOTICE '========================================';
  RAISE NOTICE 'Negocio: %', v_business_name;
  RAISE NOTICE 'Schema: %', v_schema_name;
  RAISE NOTICE 'Admin Email: %', v_admin_email;
  RAISE NOTICE 'Admin Password: %', v_admin_password;
  RAISE NOTICE '========================================';

END $$;

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================

-- Ver negocio creado
SELECT 
  '✅ NEGOCIO' as tipo,
  name as nombre,
  schema_name,
  active,
  created_at
FROM public.businesses
ORDER BY created_at DESC
LIMIT 1;

-- Ver admin creado
SELECT 
  '✅ ADMIN' as tipo,
  email,
  full_name,
  role,
  schema_name,
  active
FROM public.users
WHERE role = 'admin'
ORDER BY created_at DESC
LIMIT 1;

-- Ver tablas creadas
SELECT 
  '✅ TABLAS' as tipo,
  schemaname as schema,
  tablename as tabla
FROM pg_tables
WHERE schemaname NOT IN ('pg_catalog', 'information_schema', 'auth', 'storage', 'realtime', 'extensions', 'graphql', 'graphql_public', 'net', 'pgsodium', 'pgsodium_masks', 'supabase_functions', 'vault', 'public')
ORDER BY schemaname, tablename;

-- Ver realtime habilitado
SELECT 
  '✅ REALTIME' as tipo,
  schemaname as schema,
  tablename as tabla
FROM pg_publication_tables
WHERE pubname = 'supabase_realtime'
  AND schemaname != 'public'
ORDER BY schemaname, tablename;

-- ============================================
-- ✅ NEGOCIO LISTO PARA USAR
-- ============================================
-- 
-- SIGUIENTE PASO:
-- 1. Ve a chronelia.online
-- 2. Inicia sesión con:
--    Email: (el que configuraste arriba)
--    Password: (el que configuraste arriba)
-- 3. ¡Prueba el escáner QR!
-- 
-- Para agregar trabajadores, usa:
-- PASO_4_AGREGAR_TRABAJADOR.sql
-- 
-- ============================================

