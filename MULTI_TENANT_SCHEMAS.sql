-- ============================================
-- CHRONELIA - MULTI-TENANT CON SCHEMAS
-- ============================================
-- Arquitectura limpia donde cada negocio tiene su propio schema
-- Cada schema es como una "carpeta" independiente con sus propias tablas

-- ============================================
-- 1. TABLA MAESTRA DE NEGOCIOS (en schema public)
-- ============================================

CREATE TABLE IF NOT EXISTS public.businesses (
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

CREATE INDEX IF NOT EXISTS idx_businesses_schema ON public.businesses(schema_name);
CREATE INDEX IF NOT EXISTS idx_businesses_active ON public.businesses(active);

-- ============================================
-- 2. FUNCIÓN PARA CREAR NUEVO NEGOCIO
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
-- 3. FUNCIÓN PARA CREAR USUARIO EN UN NEGOCIO
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
  
  RETURN v_user_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 4. CREAR NEGOCIOS DE EJEMPLO
-- ============================================

-- Negocio 1: Demo Chronelia
SELECT create_business_schema(
  'business_demo',
  'Demo Chronelia',
  'demo@chronelia.com',
  '+34 600 000 000',
  'Calle Demo 123, Madrid',
  'premium',
  20
);

-- Negocio 2: Restaurante La Bella Vista
SELECT create_business_schema(
  'business_bella',
  'Restaurante La Bella Vista',
  'contacto@labellavista.com',
  '+34 91 555 1234',
  'Plaza Mayor 15, Madrid',
  'basic',
  5
);

-- Negocio 3: Spa & Wellness Center
SELECT create_business_schema(
  'business_spa',
  'Spa & Wellness Center',
  'info@spawellness.com',
  '+34 93 444 5678',
  'Avenida Diagonal 500, Barcelona',
  'premium',
  15
);

-- ============================================
-- 5. CREAR USUARIOS PARA CADA NEGOCIO
-- ============================================

-- Usuarios para Demo Chronelia (schema: business_demo)
SELECT create_business_user('business_demo', 'admin', 'admin@chronelia.com', 'chronelia2025', 'Administrador Demo', 'admin');
SELECT create_business_user('business_demo', 'trabajador', 'trabajador@chronelia.com', 'trabajador123', 'Juan Trabajador', 'worker');

-- Usuarios para Restaurante La Bella Vista (schema: business_bella)
SELECT create_business_user('business_bella', 'admin_bella', 'admin@labellavista.com', 'bella2025', 'Admin Bella Vista', 'admin');
SELECT create_business_user('business_bella', 'mesero_carlos', 'carlos@labellavista.com', 'carlos123', 'Carlos Mesero', 'worker');

-- Usuarios para Spa & Wellness (schema: business_spa)
SELECT create_business_user('business_spa', 'admin_spa', 'admin@spawellness.com', 'spa2025', 'Admin Spa Wellness', 'admin');
SELECT create_business_user('business_spa', 'terapeuta_ana', 'ana@spawellness.com', 'ana123', 'Ana Terapeuta', 'worker');

-- ============================================
-- 6. TABLA DE MAPEO USUARIO → SCHEMA (para login rápido)
-- ============================================

CREATE TABLE IF NOT EXISTS public.user_business_map (
  username TEXT PRIMARY KEY,
  schema_name TEXT NOT NULL,
  business_name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_user_business_map_schema ON public.user_business_map(schema_name);

-- Poblar el mapeo
INSERT INTO public.user_business_map (username, schema_name, business_name) VALUES
  ('admin', 'business_demo', 'Demo Chronelia'),
  ('trabajador', 'business_demo', 'Demo Chronelia'),
  ('admin_bella', 'business_bella', 'Restaurante La Bella Vista'),
  ('mesero_carlos', 'business_bella', 'Restaurante La Bella Vista'),
  ('admin_spa', 'business_spa', 'Spa & Wellness Center'),
  ('terapeuta_ana', 'business_spa', 'Spa & Wellness Center')
ON CONFLICT (username) DO NOTHING;

-- ============================================
-- 7. FUNCIÓN DE LOGIN (retorna schema y datos del usuario)
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
  
  -- Verificar contraseña y obtener datos del usuario
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
-- 8. VERIFICAR CONFIGURACIÓN
-- ============================================

-- Ver todos los negocios creados
SELECT 
  '=== NEGOCIOS CREADOS ===' as info,
  schema_name,
  business_name,
  plan_type,
  active,
  max_workers
FROM public.businesses
ORDER BY created_at;

-- Ver usuarios por negocio
SELECT 
  '=== USUARIOS DEMO CHRONELIA ===' as info,
  username, email, full_name, role, active
FROM business_demo.users;

SELECT 
  '=== USUARIOS RESTAURANTE ===' as info,
  username, email, full_name, role, active
FROM business_bella.users;

SELECT 
  '=== USUARIOS SPA ===' as info,
  username, email, full_name, role, active
FROM business_spa.users;

-- ============================================
-- 9. EJEMPLO DE CÓMO AGREGAR NUEVO CLIENTE
-- ============================================

/*

PARA AGREGAR UN NUEVO CLIENTE, SOLO HAZ ESTO:

-- Paso 1: Crear el negocio y sus tablas
SELECT create_business_schema(
  'business_tucliente',           -- Nombre del schema (sin espacios)
  'Nombre del Negocio',            -- Nombre visible
  'contacto@negocio.com',          -- Email
  '+34 123 456 789',               -- Teléfono
  'Dirección del negocio',         -- Dirección
  'basic',                         -- Plan: basic, premium, enterprise
  10                               -- Máximo de trabajadores
);

-- Paso 2: Crear admin para el negocio
SELECT create_business_user(
  'business_tucliente',            -- Schema del negocio
  'admin_cliente',                 -- Username
  'admin@negocio.com',             -- Email
  'password123',                   -- Contraseña
  'Nombre del Admin',              -- Nombre completo
  'admin'                          -- Rol
);

-- Paso 3: Agregar al mapeo de login
INSERT INTO public.user_business_map (username, schema_name, business_name)
VALUES ('admin_cliente', 'business_tucliente', 'Nombre del Negocio');

¡Y LISTO! Nuevo cliente configurado en 3 pasos.

*/

-- ============================================
-- INSTRUCCIONES DE USO
-- ============================================

/*

✅ ARQUITECTURA LIMPIA CON SCHEMAS

VENTAJAS:
1. Cada negocio tiene su propio "espacio" en Supabase (schema)
2. Los datos están FÍSICAMENTE separados
3. Puedes ver claramente cada negocio en Supabase Table Editor
4. Fácil agregar nuevos clientes (3 pasos)
5. Mayor seguridad: imposible mezclar datos entre negocios

CÓMO FUNCIONA:
1. Cada negocio tiene un schema: business_demo, business_bella, business_spa
2. Dentro de cada schema están las tablas: users, reservations, daily_stats
3. El login usa la función login_user() que automáticamente determina el schema
4. La app solo conecta al schema del negocio del usuario

USUARIOS DE PRUEBA:

Demo Chronelia (schema: business_demo):
  - admin / chronelia2025
  - trabajador / trabajador123

Restaurante La Bella Vista (schema: business_bella):
  - admin_bella / bella2025
  - mesero_carlos / carlos123

Spa & Wellness (schema: business_spa):
  - admin_spa / spa2025
  - terapeuta_ana / ana123

CÓMO VER EN SUPABASE:
1. Ve a Table Editor
2. En la parte superior, verás un selector de "Schema"
3. Cambia entre: business_demo, business_bella, business_spa
4. Verás las tablas de cada negocio por separado

CÓMO AGREGAR NUEVO CLIENTE:
1. Usa create_business_schema() para crear el schema
2. Usa create_business_user() para crear usuarios
3. Agrega al mapeo user_business_map
4. ¡Listo!

*/








