-- ============================================
-- CHRONELIA - MULTI-TENANT CON SCHEMAS
-- PARTE 1: TABLAS BASE
-- ============================================

-- Limpiar si existe algo previo
DROP TABLE IF EXISTS public.user_business_map CASCADE;
DROP TABLE IF EXISTS public.businesses CASCADE;

-- Tabla maestra de negocios
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

-- Tabla de mapeo usuario → schema
CREATE TABLE public.user_business_map (
  username TEXT PRIMARY KEY,
  schema_name TEXT NOT NULL,
  business_name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_businesses_schema ON public.businesses(schema_name);
CREATE INDEX idx_businesses_active ON public.businesses(active);
CREATE INDEX idx_user_business_map_schema ON public.user_business_map(schema_name);

-- ============================================
-- PARTE 2: FUNCIÓN PARA CREAR NUEVO NEGOCIO
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
  
  -- Crear tabla users
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
  
  -- Crear tabla reservations
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
  
  -- Crear tabla daily_stats
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
  
  -- Crear tabla ai_insights
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
-- PARTE 3: FUNCIÓN PARA CREAR USUARIOS
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
BEGIN
  EXECUTE format('
    INSERT INTO %I.users (username, email, password_hash, full_name, role)
    VALUES ($1, $2, $3, $4, $5)
    RETURNING id
  ', p_schema_name)
  USING p_username, p_email, p_password, p_full_name, p_role
  INTO v_user_id;
  
  -- Agregar al mapeo
  INSERT INTO public.user_business_map (username, schema_name, business_name)
  VALUES (p_username, p_schema_name, (SELECT business_name FROM public.businesses WHERE schema_name = p_schema_name))
  ON CONFLICT (username) DO NOTHING;
  
  RETURN v_user_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- PARTE 4: FUNCIÓN DE LOGIN
-- ============================================

CREATE OR REPLACE FUNCTION login_user(
  p_username TEXT,
  p_password TEXT
)
RETURNS TABLE (
  success BOOLEAN,
  user_id UUID,
  username TEXT,
  email TEXT,
  full_name TEXT,
  role TEXT,
  schema_name TEXT,
  business_name TEXT,
  message TEXT
) AS $$
DECLARE
  v_schema TEXT;
  v_business TEXT;
BEGIN
  -- Buscar el schema del usuario
  SELECT ubm.schema_name, ubm.business_name
  INTO v_schema, v_business
  FROM public.user_business_map ubm
  WHERE ubm.username = p_username;
  
  IF v_schema IS NULL THEN
    RETURN QUERY SELECT false, NULL::UUID, NULL, NULL, NULL, NULL, NULL, NULL, 'Usuario no encontrado';
    RETURN;
  END IF;
  
  -- Verificar contraseña y obtener datos
  RETURN QUERY EXECUTE format('
    SELECT 
      CASE WHEN u.password_hash = $2 AND u.active THEN true ELSE false END as success,
      u.id,
      u.username,
      u.email,
      u.full_name,
      u.role,
      $3 as schema_name,
      $4 as business_name,
      CASE 
        WHEN u.password_hash != $2 THEN ''Contraseña incorrecta''
        WHEN NOT u.active THEN ''Usuario inactivo''
        ELSE ''Login exitoso''
      END as message
    FROM %I.users u
    WHERE u.username = $1
  ', v_schema)
  USING p_username, p_password, v_schema, v_business;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- ✅ CONFIGURACIÓN COMPLETADA
-- ============================================

SELECT '✅ Tablas y funciones creadas correctamente' as status;




