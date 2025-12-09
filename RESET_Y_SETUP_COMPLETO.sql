-- ============================================
-- CHRONELIA - RESET COMPLETO Y SETUP CON SCHEMAS
-- ============================================
-- Este script limpia TODO y crea la estructura desde cero
-- ADVERTENCIA: Esto eliminará TODOS los datos existentes

-- ============================================
-- PASO 1: LIMPIEZA COMPLETA
-- ============================================

-- Eliminar funciones existentes
DROP FUNCTION IF EXISTS login_user(text, text);
DROP FUNCTION IF EXISTS create_business_schema(text, text, text, text, text, text, integer);
DROP FUNCTION IF EXISTS create_business_user(text, text, text, text, text, text);

-- Eliminar schemas de negocios (agregar aquí los que tengas)
DROP SCHEMA IF EXISTS business_demo CASCADE;
DROP SCHEMA IF EXISTS business_bella CASCADE;
DROP SCHEMA IF EXISTS business_prueba CASCADE;
DROP SCHEMA IF EXISTS business_spa CASCADE;
-- Agrega aquí cualquier otro schema que tengas

-- Eliminar tablas del schema public
DROP TABLE IF EXISTS public.user_business_map CASCADE;
DROP TABLE IF EXISTS public.ai_insights CASCADE;
DROP TABLE IF EXISTS public.daily_stats CASCADE;
DROP TABLE IF EXISTS public.reservations CASCADE;
DROP TABLE IF EXISTS public.customers CASCADE;
DROP TABLE IF EXISTS public.users CASCADE;
DROP TABLE IF EXISTS public.businesses CASCADE;

-- ============================================
-- PASO 2: CREAR TABLA MAESTRA DE NEGOCIOS
-- ============================================

CREATE TABLE public.businesses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  schema_name TEXT UNIQUE NOT NULL,
  business_name TEXT NOT NULL,
  contact_email TEXT,
  contact_phone TEXT,
  address TEXT,
  plan_type TEXT DEFAULT 'basic',
  max_workers INTEGER DEFAULT 5,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_businesses_schema ON businesses(schema_name);
CREATE INDEX idx_businesses_active ON businesses(active);

-- ============================================
-- PASO 3: CREAR TABLA DE MAPEO DE USUARIOS
-- ============================================
-- Esta tabla mapea usernames a sus schemas correspondientes

CREATE TABLE public.user_business_map (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  username TEXT UNIQUE NOT NULL,
  schema_name TEXT NOT NULL REFERENCES businesses(schema_name) ON DELETE CASCADE,
  business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  business_name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_user_business_map_username ON user_business_map(username);
CREATE INDEX idx_user_business_map_schema ON user_business_map(schema_name);

-- ============================================
-- PASO 4: FUNCIÓN PARA CREAR NEGOCIOS
-- ============================================

CREATE OR REPLACE FUNCTION create_business_schema(
  schema_name TEXT,
  business_name TEXT,
  contact_email TEXT DEFAULT NULL,
  contact_phone TEXT DEFAULT NULL,
  address TEXT DEFAULT NULL,
  plan_type TEXT DEFAULT 'basic',
  max_workers INTEGER DEFAULT 5
) RETURNS UUID AS $$
DECLARE
  business_id UUID;
BEGIN
  -- Validar nombre del schema
  IF schema_name !~ '^business_[a-z0-9_]+$' THEN
    RAISE EXCEPTION 'El nombre del schema debe empezar con "business_" y contener solo minúsculas, números y guiones bajos';
  END IF;

  -- Crear el negocio en la tabla maestra
  INSERT INTO public.businesses (
    schema_name,
    business_name,
    contact_email,
    contact_phone,
    address,
    plan_type,
    max_workers,
    active
  ) VALUES (
    schema_name,
    business_name,
    contact_email,
    contact_phone,
    address,
    plan_type,
    max_workers,
    true
  ) RETURNING id INTO business_id;

  -- Crear el schema
  EXECUTE format('CREATE SCHEMA IF NOT EXISTS %I', schema_name);

  -- Crear tabla de usuarios en el schema del negocio
  EXECUTE format('
    CREATE TABLE %I.users (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      username TEXT UNIQUE NOT NULL,
      email TEXT,
      password_hash TEXT NOT NULL,
      full_name TEXT,
      role TEXT DEFAULT ''worker'',
      active BOOLEAN DEFAULT true,
      created_at TIMESTAMPTZ DEFAULT NOW(),
      updated_at TIMESTAMPTZ DEFAULT NOW()
    )', schema_name);

  -- Crear tabla de reservas
  EXECUTE format('
    CREATE TABLE %I.reservations (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      customer_name TEXT NOT NULL,
      customer_email TEXT,
      qr_code TEXT,
      total_duration INTEGER NOT NULL,
      actual_duration INTEGER,
      start_time TIMESTAMPTZ NOT NULL,
      end_time TIMESTAMPTZ,
      status TEXT DEFAULT ''active'',
      worker_name TEXT,
      group_size INTEGER DEFAULT 1,
      extensions INTEGER DEFAULT 0,
      created_at TIMESTAMPTZ DEFAULT NOW()
    )', schema_name);

  -- Crear tabla de estadísticas diarias
  EXECUTE format('
    CREATE TABLE %I.daily_stats (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      date DATE NOT NULL UNIQUE,
      total_reservations INTEGER DEFAULT 0,
      completed_reservations INTEGER DEFAULT 0,
      cancelled_reservations INTEGER DEFAULT 0,
      total_time INTEGER DEFAULT 0,
      average_duration INTEGER DEFAULT 0,
      total_revenue DECIMAL(10,2) DEFAULT 0,
      created_at TIMESTAMPTZ DEFAULT NOW()
    )', schema_name);

  -- Crear tabla de insights de IA
  EXECUTE format('
    CREATE TABLE %I.ai_insights (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      insight_type TEXT NOT NULL,
      title TEXT NOT NULL,
      description TEXT,
      priority TEXT DEFAULT ''medium'',
      data JSONB,
      created_at TIMESTAMPTZ DEFAULT NOW()
    )', schema_name);

  -- Crear índices
  EXECUTE format('CREATE INDEX idx_%I_users_username ON %I.users(username)', schema_name, schema_name);
  EXECUTE format('CREATE INDEX idx_%I_reservations_status ON %I.reservations(status)', schema_name, schema_name);
  EXECUTE format('CREATE INDEX idx_%I_reservations_start ON %I.reservations(start_time)', schema_name, schema_name);
  EXECUTE format('CREATE INDEX idx_%I_daily_stats_date ON %I.daily_stats(date)', schema_name, schema_name);

  RETURN business_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- PASO 5: FUNCIÓN PARA CREAR USUARIOS
-- ============================================

CREATE OR REPLACE FUNCTION create_business_user(
  p_schema_name TEXT,
  p_username TEXT,
  p_email TEXT,
  p_password TEXT,
  p_full_name TEXT,
  p_role TEXT DEFAULT 'worker'
) RETURNS UUID AS $$
DECLARE
  user_id UUID;
  v_business_id UUID;
  v_business_name TEXT;
  v_max_workers INTEGER;
  v_current_workers INTEGER;
BEGIN
  -- Validar que el negocio existe
  SELECT id, business_name, max_workers
  INTO v_business_id, v_business_name, v_max_workers
  FROM public.businesses
  WHERE schema_name = p_schema_name AND active = true;

  IF v_business_id IS NULL THEN
    RAISE EXCEPTION 'El negocio con schema "%" no existe o está inactivo', p_schema_name;
  END IF;

  -- Verificar límite de trabajadores
  EXECUTE format('SELECT COUNT(*) FROM %I.users', p_schema_name) INTO v_current_workers;
  
  IF v_current_workers >= v_max_workers THEN
    RAISE EXCEPTION 'Se alcanzó el límite máximo de trabajadores (%) para este negocio', v_max_workers;
  END IF;

  -- Validar que el username no existe en el mapeo global
  IF EXISTS (SELECT 1 FROM public.user_business_map WHERE username = p_username) THEN
    RAISE EXCEPTION 'El username "%" ya está en uso', p_username;
  END IF;

  -- Crear el usuario en el schema del negocio
  EXECUTE format('
    INSERT INTO %I.users (username, email, password_hash, full_name, role, active)
    VALUES ($1, $2, $3, $4, $5, true)
    RETURNING id
  ', p_schema_name) USING p_username, p_email, p_password, p_full_name, p_role
  INTO user_id;

  -- Agregar al mapeo global de usuarios
  INSERT INTO public.user_business_map (username, schema_name, business_id, business_name)
  VALUES (p_username, p_schema_name, v_business_id, v_business_name);

  RETURN user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- PASO 6: FUNCIÓN DE LOGIN
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
-- PASO 7: CREAR NEGOCIO Y USUARIO DE PRUEBA
-- ============================================

-- Crear negocio de prueba
SELECT create_business_schema(
  'business_prueba',
  'Negocio de Prueba',
  'info@prueba.com',
  '+34 666 777 888',
  'Calle Principal 123',
  'premium',
  10
);

-- Crear usuario admin
SELECT create_business_user(
  'business_prueba',
  'admin',
  'admin@prueba.com',
  'admin123',
  'Administrador',
  'admin'
);

-- Crear un trabajador de prueba
SELECT create_business_user(
  'business_prueba',
  'trabajador',
  'trabajador@prueba.com',
  'trabajo123',
  'Trabajador de Prueba',
  'worker'
);

-- ============================================
-- PASO 8: VERIFICACIÓN
-- ============================================

-- Ver negocios creados
SELECT '=== NEGOCIOS ===' as info;
SELECT * FROM public.businesses;

-- Ver mapeo de usuarios
SELECT '=== MAPEO DE USUARIOS ===' as info;
SELECT * FROM public.user_business_map;

-- Ver usuarios del negocio de prueba
SELECT '=== USUARIOS DEL NEGOCIO ===' as info;
SELECT * FROM business_prueba.users;

-- Probar login
SELECT '=== PRUEBA DE LOGIN ===' as info;
SELECT * FROM login_user('admin', 'admin123');

-- ============================================
-- ✅ SETUP COMPLETO
-- ============================================

/*

CREDENCIALES CREADAS:

Admin:
  Usuario: admin
  Contraseña: admin123

Trabajador:
  Usuario: trabajador
  Contraseña: trabajo123

VERIFICACIÓN:
- Negocios creados: ✓
- Usuarios creados: ✓
- Función de login: ✓

PRÓXIMOS PASOS:
1. Prueba el login en la app
2. Si funciona, crea más negocios con create_business_schema()
3. Agrega más usuarios con create_business_user()

*/




