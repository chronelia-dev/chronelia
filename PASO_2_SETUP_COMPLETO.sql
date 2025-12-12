-- ============================================
-- 🚀 SETUP COMPLETO DESDE CERO - CHRONELIA
-- ============================================
-- Sistema Multi-Tenant con UN solo negocio de prueba
-- Ejecuta DESPUÉS de PASO_1_LIMPIEZA_TOTAL.sql
-- ============================================

-- ============================================
-- PASO 1: Crear tabla de negocios
-- ============================================
CREATE TABLE public.businesses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  schema_name TEXT UNIQUE NOT NULL,
  business_name TEXT NOT NULL,
  business_email TEXT,
  business_phone TEXT,
  business_address TEXT,
  plan_type TEXT DEFAULT 'basic',
  active BOOLEAN DEFAULT true,
  max_workers INTEGER DEFAULT 10,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_businesses_schema ON public.businesses(schema_name);
CREATE INDEX idx_businesses_active ON public.businesses(active);

-- ============================================
-- PASO 2: Crear tabla de mapeo usuario-negocio
-- ============================================
CREATE TABLE public.user_business_map (
  username TEXT PRIMARY KEY,
  business_id UUID NOT NULL REFERENCES public.businesses(id) ON DELETE CASCADE,
  schema_name TEXT NOT NULL,
  business_name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_user_business_map_schema ON public.user_business_map(schema_name);
CREATE INDEX idx_user_business_map_business_id ON public.user_business_map(business_id);

-- ============================================
-- PASO 3: Crear función para crear negocios
-- ============================================
CREATE OR REPLACE FUNCTION create_business_schema(
  p_schema_name TEXT,
  p_business_name TEXT,
  p_business_email TEXT DEFAULT NULL,
  p_business_phone TEXT DEFAULT NULL,
  p_business_address TEXT DEFAULT NULL,
  p_plan_type TEXT DEFAULT 'basic',
  p_max_workers INTEGER DEFAULT 10
)
RETURNS UUID AS $$
DECLARE
  v_business_id UUID;
BEGIN
  -- Crear el schema
  EXECUTE format('CREATE SCHEMA IF NOT EXISTS %I', p_schema_name);
  
  -- Registrar el negocio
  INSERT INTO public.businesses (
    schema_name,
    business_name,
    business_email,
    business_phone,
    business_address,
    plan_type,
    max_workers
  ) VALUES (
    p_schema_name,
    p_business_name,
    p_business_email,
    p_business_phone,
    p_business_address,
    p_plan_type,
    p_max_workers
  ) RETURNING id INTO v_business_id;
  
  -- Crear tabla users en el schema del negocio
  EXECUTE format('
    CREATE TABLE IF NOT EXISTS %I.users (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      username TEXT UNIQUE NOT NULL,
      email TEXT UNIQUE NOT NULL,
      password_hash TEXT NOT NULL,
      full_name TEXT NOT NULL,
      role TEXT NOT NULL CHECK (role IN (''admin'', ''worker'')),
      active BOOLEAN DEFAULT true,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    )', p_schema_name);
  
  -- Crear tabla reservations en el schema del negocio
  EXECUTE format('
    CREATE TABLE IF NOT EXISTS %I.reservations (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      customer_name TEXT NOT NULL,
      customer_email TEXT NOT NULL,
      qr_code TEXT,
      total_duration INTEGER NOT NULL,
      actual_duration INTEGER,
      start_time TIMESTAMP WITH TIME ZONE NOT NULL,
      end_time TIMESTAMP WITH TIME ZONE,
      status TEXT NOT NULL CHECK (status IN (''active'', ''completed'', ''cancelled'')),
      worker_name TEXT,
      group_size INTEGER DEFAULT 1,
      extensions INTEGER DEFAULT 0,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    )', p_schema_name);
  
  -- Crear tabla daily_stats en el schema del negocio
  EXECUTE format('
    CREATE TABLE IF NOT EXISTS %I.daily_stats (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      date DATE NOT NULL UNIQUE,
      total_reservations INTEGER DEFAULT 0,
      completed_reservations INTEGER DEFAULT 0,
      cancelled_reservations INTEGER DEFAULT 0,
      total_time INTEGER DEFAULT 0,
      average_duration INTEGER DEFAULT 0,
      total_revenue DECIMAL(10,2) DEFAULT 0,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    )', p_schema_name);
  
  -- Crear tabla ai_insights en el schema del negocio
  EXECUTE format('
    CREATE TABLE IF NOT EXISTS %I.ai_insights (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      type TEXT NOT NULL,
      category TEXT NOT NULL,
      title TEXT NOT NULL,
      description TEXT NOT NULL,
      priority TEXT NOT NULL,
      data JSONB,
      status TEXT DEFAULT ''active'',
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      expires_at TIMESTAMP WITH TIME ZONE
    )', p_schema_name);
  
  -- Crear índices
  EXECUTE format('CREATE INDEX IF NOT EXISTS idx_users_username ON %I.users(username)', p_schema_name);
  EXECUTE format('CREATE INDEX IF NOT EXISTS idx_users_email ON %I.users(email)', p_schema_name);
  EXECUTE format('CREATE INDEX IF NOT EXISTS idx_reservations_status ON %I.reservations(status)', p_schema_name);
  EXECUTE format('CREATE INDEX IF NOT EXISTS idx_reservations_start_time ON %I.reservations(start_time)', p_schema_name);
  EXECUTE format('CREATE INDEX IF NOT EXISTS idx_daily_stats_date ON %I.daily_stats(date)', p_schema_name);
  
  RETURN v_business_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- PASO 4: Crear función para crear usuarios
-- ============================================
CREATE OR REPLACE FUNCTION create_business_user(
  p_schema_name TEXT,
  p_username TEXT,
  p_email TEXT,
  p_password TEXT,
  p_full_name TEXT,
  p_role TEXT DEFAULT 'worker'
)
RETURNS UUID AS $$
DECLARE
  v_user_id UUID;
  v_business_id UUID;
  v_business_name TEXT;
BEGIN
  -- Obtener información del negocio
  SELECT id, business_name INTO v_business_id, v_business_name
  FROM public.businesses
  WHERE schema_name = p_schema_name;
  
  IF v_business_id IS NULL THEN
    RAISE EXCEPTION 'El negocio con schema % no existe', p_schema_name;
  END IF;
  
  -- Crear usuario en el schema del negocio
  EXECUTE format('
    INSERT INTO %I.users (username, email, password_hash, full_name, role)
    VALUES ($1, $2, $3, $4, $5)
    RETURNING id
  ', p_schema_name)
  USING p_username, p_email, p_password, p_full_name, p_role
  INTO v_user_id;
  
  -- Agregar al mapeo
  INSERT INTO public.user_business_map (username, business_id, schema_name, business_name)
  VALUES (p_username, v_business_id, p_schema_name, v_business_name)
  ON CONFLICT (username) DO UPDATE 
  SET business_id = EXCLUDED.business_id,
      schema_name = EXCLUDED.schema_name,
      business_name = EXCLUDED.business_name;
  
  RETURN v_user_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- PASO 5: Crear función de login
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
-- PASO 6: Crear negocio de prueba
-- ============================================
SELECT create_business_schema(
  'business_chronelia',           -- Schema name
  'Chronelia Demo',               -- Business name
  'admin@chronelia.com',          -- Email
  '+34 666 777 888',              -- Phone
  'Calle Principal 123, Madrid',  -- Address
  'premium',                      -- Plan type
  20                              -- Max workers
);

-- ============================================
-- PASO 7: Crear usuario admin
-- ============================================
SELECT create_business_user(
  'business_chronelia',           -- Schema
  'admin',                        -- Username
  'admin@chronelia.com',          -- Email
  'chronelia2025',                -- Password
  'Administrador Chronelia',      -- Full name
  'admin'                         -- Role
);

-- ============================================
-- PASO 8: Crear un trabajador de prueba
-- ============================================
SELECT create_business_user(
  'business_chronelia',
  'trabajador',
  'trabajador@chronelia.com',
  'trabajador123',
  'Juan Trabajador',
  'worker'
);

-- ============================================
-- VERIFICACIÓN COMPLETA
-- ============================================

-- Ver el negocio creado
SELECT 
  '=== NEGOCIO CREADO ===' as info,
  id,
  business_name,
  schema_name,
  active,
  plan_type,
  max_workers
FROM public.businesses;

-- Ver usuarios en el mapeo
SELECT 
  '=== USUARIOS EN MAPEO ===' as info,
  username,
  schema_name,
  business_name
FROM public.user_business_map
ORDER BY username;

-- Ver usuarios en el schema del negocio
SELECT 
  '=== USUARIOS EN business_chronelia ===' as info,
  username,
  email,
  full_name,
  role,
  active,
  password_hash as contraseña
FROM business_chronelia.users
ORDER BY role, username;

-- Ver tablas creadas en el schema
SELECT 
  '=== TABLAS EN business_chronelia ===' as info,
  table_name
FROM information_schema.tables
WHERE table_schema = 'business_chronelia'
ORDER BY table_name;

-- ============================================
-- PRUEBA DE LOGIN
-- ============================================

-- Probar login con admin
SELECT 
  '=== PRUEBA: Login con admin ===' as test,
  success,
  message,
  username,
  business_name,
  schema_name,
  role
FROM login_user('admin', 'chronelia2025');

-- Probar login con trabajador
SELECT 
  '=== PRUEBA: Login con trabajador ===' as test,
  success,
  message,
  username,
  business_name,
  schema_name,
  role
FROM login_user('trabajador', 'trabajador123');

-- Probar login con contraseña incorrecta
SELECT 
  '=== PRUEBA: Contraseña incorrecta ===' as test,
  success,
  message
FROM login_user('admin', 'password_malo');

-- ============================================
-- RESULTADO ESPERADO
-- ============================================
/*
✅ Deberías ver:

1. NEGOCIO CREADO:
   - business_name: Chronelia Demo
   - schema_name: business_chronelia
   - active: true

2. USUARIOS EN MAPEO:
   - admin → business_chronelia
   - trabajador → business_chronelia

3. USUARIOS EN business_chronelia:
   - admin (role: admin) - contraseña: chronelia2025
   - trabajador (role: worker) - contraseña: trabajador123

4. TABLAS EN business_chronelia:
   - ai_insights
   - daily_stats
   - reservations
   - users

5. PRUEBA LOGIN ADMIN:
   - success: true ✅
   - message: "Login exitoso"
   - username: admin
   - business_name: Chronelia Demo
   - role: admin

6. PRUEBA LOGIN TRABAJADOR:
   - success: true ✅
   - message: "Login exitoso"
   - username: trabajador
   - role: worker

7. PRUEBA CONTRASEÑA INCORRECTA:
   - success: false ✅
   - message: "Contraseña incorrecta"

¡Si ves esto, todo está configurado correctamente! 🎉

CREDENCIALES PARA LA APP:
========================

ADMINISTRADOR:
Usuario: admin
Contraseña: chronelia2025

TRABAJADOR:
Usuario: trabajador
Contraseña: trabajador123
*/







