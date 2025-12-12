-- ============================================
-- SETUP COMPLETO DE CHRONELIA
-- ============================================
-- Este script crea TODA la estructura desde cero
-- ============================================
-- 
-- 📋 INSTRUCCIONES:
-- 1. Abre Supabase SQL Editor
-- 2. Copia y pega TODO este archivo
-- 3. EDITA los valores marcados con *** EDITAR ***
-- 4. Haz clic en "Run"
-- 5. ¡Listo para usar!
-- ============================================

-- ============================================
-- PASO 1: CREAR TABLAS BASE
-- ============================================

-- Tabla de negocios
CREATE TABLE IF NOT EXISTS public.businesses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  schema_name text UNIQUE NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Tabla de usuarios globales
CREATE TABLE IF NOT EXISTS public.users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  username text UNIQUE NOT NULL,
  email text,
  password_hash text NOT NULL,
  full_name text NOT NULL,
  role text NOT NULL DEFAULT 'worker',
  business_id uuid NOT NULL REFERENCES public.businesses(id) ON DELETE CASCADE,
  active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_users_username ON public.users(username);
CREATE INDEX IF NOT EXISTS idx_users_business_id ON public.users(business_id);

-- ============================================
-- PASO 2: CREAR TU NEGOCIO
-- ============================================
-- *** EDITAR ESTOS VALORES ***

DO $$
DECLARE
  v_business_id uuid;
  v_business_name text := 'SomaCafe';                    -- *** EDITAR: Nombre de tu negocio ***
  v_schema_name text := 'somacafe';                      -- *** EDITAR: Schema (sin espacios, minúsculas) ***
  v_admin_username text := 'admin@somacafe.com';         -- *** EDITAR: Usuario admin ***
  v_admin_password text := 'admin123';                   -- *** EDITAR: Contraseña admin ***
  v_admin_fullname text := 'Administrador SomaCafe';     -- *** EDITAR: Nombre completo ***
  v_worker1_username text := 'worker1@somacafe.com';     -- *** EDITAR: Usuario trabajador 1 ***
  v_worker1_password text := 'worker123';                -- *** EDITAR: Contraseña trabajador 1 ***
  v_worker1_fullname text := 'Trabajador 1';             -- *** EDITAR: Nombre trabajador 1 ***
BEGIN
  -- Crear negocio
  INSERT INTO public.businesses (id, name, schema_name)
  VALUES (gen_random_uuid(), v_business_name, v_schema_name)
  ON CONFLICT (schema_name) DO UPDATE SET name = EXCLUDED.name
  RETURNING id INTO v_business_id;
  
  RAISE NOTICE '✅ Negocio creado: % (ID: %)', v_business_name, v_business_id;
  
  -- Crear schema del negocio
  EXECUTE format('CREATE SCHEMA IF NOT EXISTS %I', v_schema_name);
  RAISE NOTICE '✅ Schema creado: %', v_schema_name;
  
  -- Crear tabla de usuarios en el schema del negocio
  EXECUTE format('
    CREATE TABLE IF NOT EXISTS %I.users (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      username text UNIQUE NOT NULL,
      email text,
      password_hash text NOT NULL,
      full_name text NOT NULL,
      role text NOT NULL DEFAULT ''worker'',
      active boolean DEFAULT true,
      created_at timestamptz DEFAULT now(),
      updated_at timestamptz DEFAULT now()
    )', v_schema_name);
  
  -- Crear tabla de reservas en el schema del negocio
  EXECUTE format('
    CREATE TABLE IF NOT EXISTS %I.reservations (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      customer_name text NOT NULL,
      customer_email text,
      qr_code text NOT NULL,
      total_duration integer NOT NULL,
      actual_duration integer,
      start_time timestamptz NOT NULL,
      end_time timestamptz,
      status text NOT NULL DEFAULT ''active'',
      worker_name text,
      worker_id uuid,
      group_size integer DEFAULT 1,
      extensions integer DEFAULT 0,
      created_at timestamptz DEFAULT now(),
      updated_at timestamptz DEFAULT now()
    )', v_schema_name);
  
  RAISE NOTICE '✅ Tablas creadas en schema %', v_schema_name;
  
  -- Crear usuario admin en public.users
  INSERT INTO public.users (username, email, password_hash, full_name, role, business_id, active)
  VALUES (v_admin_username, v_admin_username, v_admin_password, v_admin_fullname, 'admin', v_business_id, true)
  ON CONFLICT (username) DO UPDATE SET 
    password_hash = EXCLUDED.password_hash,
    full_name = EXCLUDED.full_name;
  
  -- Crear usuario admin en el schema del negocio
  EXECUTE format('
    INSERT INTO %I.users (username, email, password_hash, full_name, role, active)
    VALUES ($1, $2, $3, $4, $5, $6)
    ON CONFLICT (username) DO UPDATE SET 
      password_hash = EXCLUDED.password_hash,
      full_name = EXCLUDED.full_name',
    v_schema_name
  ) USING v_admin_username, v_admin_username, v_admin_password, v_admin_fullname, 'admin', true;
  
  RAISE NOTICE '✅ Usuario admin creado: %', v_admin_username;
  
  -- Crear trabajador 1 en public.users
  INSERT INTO public.users (username, email, password_hash, full_name, role, business_id, active)
  VALUES (v_worker1_username, v_worker1_username, v_worker1_password, v_worker1_fullname, 'worker', v_business_id, true)
  ON CONFLICT (username) DO UPDATE SET 
    password_hash = EXCLUDED.password_hash,
    full_name = EXCLUDED.full_name;
  
  -- Crear trabajador 1 en el schema del negocio
  EXECUTE format('
    INSERT INTO %I.users (username, email, password_hash, full_name, role, active)
    VALUES ($1, $2, $3, $4, $5, $6)
    ON CONFLICT (username) DO UPDATE SET 
      password_hash = EXCLUDED.password_hash,
      full_name = EXCLUDED.full_name',
    v_schema_name
  ) USING v_worker1_username, v_worker1_username, v_worker1_password, v_worker1_fullname, 'worker', true;
  
  RAISE NOTICE '✅ Trabajador creado: %', v_worker1_username;
  RAISE NOTICE '🎉 ¡Setup completo! Puedes hacer login ahora.';
END $$;

-- ============================================
-- PASO 3: CREAR FUNCIONES RPC
-- ============================================

-- Eliminar funciones antiguas si existen
DROP FUNCTION IF EXISTS get_workers(text);
DROP FUNCTION IF EXISTS get_active_reservations(text);
DROP FUNCTION IF EXISTS get_reservation_history(text, integer);
DROP FUNCTION IF EXISTS save_reservation(text, uuid, text, text, text, integer, integer, timestamptz, timestamptz, text, text, integer, integer);
DROP FUNCTION IF EXISTS save_reservation(text, uuid, text, text, text, integer, integer, timestamptz, timestamptz, text, text, uuid, integer, integer);
DROP FUNCTION IF EXISTS login_user(text, text);

-- Función: login_user
CREATE OR REPLACE FUNCTION login_user(
  input_username text,
  input_password text
)
RETURNS TABLE (
  success boolean,
  message text,
  user_id uuid,
  username text,
  email text,
  full_name text,
  role text,
  schema_name text,
  business_id uuid,
  business_name text
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user RECORD;
  v_business RECORD;
BEGIN
  SELECT users.id, users.username, users.email, users.full_name, users.role, users.business_id
  INTO v_user
  FROM public.users
  WHERE users.username = input_username 
    AND users.password_hash = input_password
    AND users.active = true;

  IF NOT FOUND THEN
    RETURN QUERY SELECT 
      false, 'Usuario o contraseña incorrectos'::text,
      NULL::uuid, NULL::text, NULL::text, NULL::text, NULL::text, 
      NULL::text, NULL::uuid, NULL::text;
    RETURN;
  END IF;

  SELECT b.id, b.name, b.schema_name
  INTO v_business
  FROM public.businesses b
  WHERE b.id = v_user.business_id;

  IF NOT FOUND THEN
    RETURN QUERY SELECT 
      false, 'Negocio no encontrado'::text,
      NULL::uuid, NULL::text, NULL::text, NULL::text, NULL::text, 
      NULL::text, NULL::uuid, NULL::text;
    RETURN;
  END IF;

  RETURN QUERY SELECT 
    true, 'Login exitoso'::text,
    v_user.id, v_user.username, v_user.email, v_user.full_name, v_user.role,
    v_business.schema_name, v_business.id, v_business.name;
END;
$$;

-- Función: get_workers
CREATE OR REPLACE FUNCTION get_workers(schema_name text)
RETURNS TABLE (
  id uuid, username text, email text, full_name text,
  role text, active boolean, created_at timestamptz
)
LANGUAGE plpgsql SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY EXECUTE format(
    'SELECT id, username, email, full_name, role, active, created_at
     FROM %I.users ORDER BY full_name ASC', schema_name);
END;
$$;

-- Función: get_active_reservations
CREATE OR REPLACE FUNCTION get_active_reservations(schema_name text)
RETURNS TABLE (
  id uuid, customer_name text, customer_email text, qr_code text,
  total_duration integer, actual_duration integer, start_time timestamptz,
  end_time timestamptz, status text, worker_name text, worker_id uuid,
  group_size integer, extensions integer, created_at timestamptz
)
LANGUAGE plpgsql SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY EXECUTE format(
    'SELECT id, customer_name, customer_email, qr_code, total_duration, actual_duration, 
     start_time, end_time, status, worker_name, worker_id, group_size, extensions, created_at
     FROM %I.reservations WHERE status = ''active'' ORDER BY start_time DESC', schema_name);
END;
$$;

-- Función: get_reservation_history
CREATE OR REPLACE FUNCTION get_reservation_history(schema_name text, limit_count integer DEFAULT 50)
RETURNS TABLE (
  id uuid, customer_name text, customer_email text, qr_code text,
  total_duration integer, actual_duration integer, start_time timestamptz,
  end_time timestamptz, status text, worker_name text, worker_id uuid,
  group_size integer, extensions integer, created_at timestamptz
)
LANGUAGE plpgsql SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY EXECUTE format(
    'SELECT id, customer_name, customer_email, qr_code, total_duration, actual_duration, 
     start_time, end_time, status, worker_name, worker_id, group_size, extensions, created_at
     FROM %I.reservations WHERE status = ''completed'' 
     ORDER BY end_time DESC LIMIT $1', schema_name) USING limit_count;
END;
$$;

-- Función: save_reservation
CREATE OR REPLACE FUNCTION save_reservation(
  schema_name text, reservation_id uuid, p_customer_name text,
  p_customer_email text, p_qr_code text, p_total_duration integer,
  p_actual_duration integer, p_start_time timestamptz, p_end_time timestamptz,
  p_status text, p_worker_name text, p_worker_id uuid,
  p_group_size integer, p_extensions integer
)
RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE result_id uuid;
BEGIN
  EXECUTE format(
    'INSERT INTO %I.reservations 
     (id, customer_name, customer_email, qr_code, total_duration, actual_duration, 
      start_time, end_time, status, worker_name, worker_id, group_size, extensions)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
     ON CONFLICT (id) DO UPDATE SET
       customer_name = EXCLUDED.customer_name,
       customer_email = EXCLUDED.customer_email,
       status = EXCLUDED.status,
       end_time = EXCLUDED.end_time,
       actual_duration = EXCLUDED.actual_duration,
       extensions = EXCLUDED.extensions
     RETURNING id', schema_name
  ) USING reservation_id, p_customer_name, p_customer_email, p_qr_code, 
          p_total_duration, p_actual_duration, p_start_time, p_end_time, 
          p_status, p_worker_name, p_worker_id, p_group_size, p_extensions
  INTO result_id;
  RETURN result_id;
END;
$$;

-- ============================================
-- PASO 4: VERIFICACIÓN
-- ============================================

SELECT '=== NEGOCIOS CREADOS ===' as seccion, name, schema_name 
FROM public.businesses;

SELECT '=== USUARIOS GLOBALES ===' as seccion, username, full_name, role, active 
FROM public.users;

SELECT '=== FUNCIONES RPC ===' as seccion, routine_name as funcion
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN ('login_user', 'get_workers', 'get_active_reservations', 
                       'get_reservation_history', 'save_reservation')
ORDER BY routine_name;

-- ============================================
-- ✅ LISTO PARA USAR
-- ============================================
-- Credenciales por defecto (si no editaste):
-- Admin: admin@somacafe.com / admin123
-- Worker: worker1@somacafe.com / worker123
-- ============================================

