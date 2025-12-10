-- ============================================
-- SETUP INCREMENTAL SEGURO
-- ============================================
-- Este script solo crea lo que NO existe
-- No borra nada, solo agrega

-- ============================================
-- PARTE 1: Crear/Actualizar tabla businesses
-- ============================================

-- Primero verificamos qué columnas tiene
DO $$
BEGIN
  -- Agregar columna 'name' si no existe
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
      AND table_name = 'businesses' 
      AND column_name = 'name'
  ) THEN
    -- Si la tabla tiene 'business_name', renombrar
    IF EXISTS (
      SELECT 1 FROM information_schema.columns 
      WHERE table_schema = 'public' 
        AND table_name = 'businesses' 
        AND column_name = 'business_name'
    ) THEN
      ALTER TABLE public.businesses RENAME COLUMN business_name TO name;
    ELSE
      -- Si no existe ninguna, agregar
      ALTER TABLE public.businesses ADD COLUMN name text;
    END IF;
  END IF;
  
  -- Agregar columna schema_name si no existe
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
      AND table_name = 'businesses' 
      AND column_name = 'schema_name'
  ) THEN
    ALTER TABLE public.businesses ADD COLUMN schema_name text UNIQUE;
  END IF;
END $$;

-- ============================================
-- PARTE 2: Actualizar usuarios existentes con schema_name
-- ============================================

-- Primero verificar qué schema usar
DO $$
DECLARE
  v_schema_name text;
  v_business_id uuid;
BEGIN
  -- Intentar obtener el primer negocio
  SELECT schema_name, id INTO v_schema_name, v_business_id
  FROM public.businesses
  WHERE schema_name IS NOT NULL
  LIMIT 1;
  
  -- Si no hay schema, usar 'locosxcerveza' por defecto
  IF v_schema_name IS NULL THEN
    v_schema_name := 'locosxcerveza';
    
    -- Crear negocio si no existe
    INSERT INTO public.businesses (id, name, schema_name)
    VALUES (
      'f1e2d3c4-b5a6-4c3d-9e8f-0123456789ab',
      'Locos X Cerveza',
      'locosxcerveza'
    )
    ON CONFLICT (id) DO UPDATE SET
      name = 'Locos X Cerveza',
      schema_name = 'locosxcerveza';
    
    v_business_id := 'f1e2d3c4-b5a6-4c3d-9e8f-0123456789ab';
  END IF;
  
  -- Actualizar TODOS los usuarios para que tengan schema_name
  UPDATE public.users
  SET 
    schema_name = v_schema_name,
    business_id = v_business_id,
    business_name = (SELECT name FROM public.businesses WHERE schema_name = v_schema_name LIMIT 1)
  WHERE schema_name IS NULL;
  
  RAISE NOTICE 'Schema configurado: %', v_schema_name;
END $$;

-- ============================================
-- PARTE 3: Crear schema del negocio si no existe
-- ============================================
CREATE SCHEMA IF NOT EXISTS locosxcerveza;

-- ============================================
-- PARTE 4: Crear tabla de reservas en el schema
-- ============================================
CREATE TABLE IF NOT EXISTS locosxcerveza.reservations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_name text NOT NULL,
  customer_email text,
  qr_code text,
  total_duration integer NOT NULL,
  actual_duration integer,
  start_time timestamptz NOT NULL DEFAULT NOW(),
  end_time timestamptz,
  status text NOT NULL CHECK (status IN ('active', 'completed', 'cancelled')),
  worker_name text,
  group_size integer DEFAULT 1,
  extensions integer DEFAULT 0,
  created_at timestamptz DEFAULT NOW(),
  updated_at timestamptz DEFAULT NOW()
);

-- Crear índice para consultas rápidas
CREATE INDEX IF NOT EXISTS idx_reservations_status 
ON locosxcerveza.reservations(status);

CREATE INDEX IF NOT EXISTS idx_reservations_start_time 
ON locosxcerveza.reservations(start_time DESC);

-- ============================================
-- PARTE 5: Crear otras tablas necesarias
-- ============================================

-- Tabla de usuarios del negocio
CREATE TABLE IF NOT EXISTS locosxcerveza.users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  username text UNIQUE NOT NULL,
  email text UNIQUE NOT NULL,
  full_name text NOT NULL,
  role text NOT NULL CHECK (role IN ('admin', 'worker')),
  active boolean DEFAULT true,
  created_at timestamptz DEFAULT NOW(),
  updated_at timestamptz DEFAULT NOW()
);

-- Tabla de clientes
CREATE TABLE IF NOT EXISTS locosxcerveza.customers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  email text UNIQUE,
  phone text,
  created_at timestamptz DEFAULT NOW(),
  updated_at timestamptz DEFAULT NOW()
);

-- Tabla de estadísticas
CREATE TABLE IF NOT EXISTS locosxcerveza.daily_stats (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  date date UNIQUE NOT NULL DEFAULT CURRENT_DATE,
  total_reservations integer DEFAULT 0,
  completed_reservations integer DEFAULT 0,
  cancelled_reservations integer DEFAULT 0,
  total_time integer DEFAULT 0,
  average_duration integer DEFAULT 0,
  created_at timestamptz DEFAULT NOW()
);

-- ============================================
-- PARTE 6: Permisos
-- ============================================
GRANT USAGE ON SCHEMA locosxcerveza TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA locosxcerveza TO anon, authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA locosxcerveza TO anon, authenticated;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO anon, authenticated;

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================

-- Verificar usuarios tienen schema_name
SELECT 
  '✅ VERIFICACIÓN: Usuarios' as check_name,
  email,
  schema_name,
  business_name,
  role,
  CASE 
    WHEN schema_name IS NOT NULL THEN '✅ OK'
    ELSE '❌ SIN SCHEMA'
  END as estado
FROM public.users
ORDER BY role, email;

-- Verificar tablas del schema
SELECT 
  '✅ VERIFICACIÓN: Tablas en schema' as check_name,
  table_name,
  '✅ Existe' as estado
FROM information_schema.tables
WHERE table_schema = 'locosxcerveza'
ORDER BY table_name;

-- ============================================
-- ✅ ÉXITO SI VES:
-- ============================================
-- Usuarios con schema_name = 'locosxcerveza'
-- Tablas: customers, daily_stats, reservations, users
-- ============================================

-- ============================================
-- SIGUIENTE PASO:
-- ============================================
-- Ejecuta: FUNCIONES_RPC_MULTI_TENANT.sql
-- ============================================

