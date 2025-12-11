-- ============================================
-- PASO 4: AGREGAR TRABAJADOR
-- ============================================
-- 
-- INSTRUCCIONES:
-- 1. Reemplaza estos valores:
--    - 'minegocio' → El schema de tu negocio (el mismo del PASO 3)
--    - 'trabajador@minegocio.com' → Email del trabajador
--    - 'Password123' → Contraseña del trabajador
--    - 'Carlos López' → Nombre del trabajador
-- 
-- 2. Ejecuta este script
-- 
-- 3. Puedes ejecutarlo múltiples veces para agregar más trabajadores
--    (solo cambia el email y nombre cada vez)
-- 
-- ============================================

-- ============================================
-- CONFIGURACIÓN - EDITA ESTOS VALORES
-- ============================================
DO $$
DECLARE
  -- 🔧 EDITA ESTOS VALORES:
  v_schema_name text := 'minegocio';                      -- Schema de tu negocio
  v_worker_email text := 'trabajador@minegocio.com';      -- Email del trabajador
  v_worker_password text := 'Password123';                -- Contraseña
  v_worker_name text := 'Carlos López';                   -- Nombre del trabajador
  
  -- Variables internas
  v_business_id uuid;
BEGIN

  -- Obtener el ID del negocio
  SELECT id INTO v_business_id
  FROM public.businesses
  WHERE schema_name = v_schema_name;

  -- Verificar que el negocio existe
  IF v_business_id IS NULL THEN
    RAISE EXCEPTION 'ERROR: No existe un negocio con schema "%". Verifica el nombre.', v_schema_name;
  END IF;

  -- Crear trabajador
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
    v_worker_email,
    v_worker_password,
    v_worker_name,
    'worker',
    v_business_id,
    v_schema_name,
    true
  );
  
  RAISE NOTICE '✅ Trabajador creado exitosamente';
  RAISE NOTICE '   Email: %', v_worker_email;
  RAISE NOTICE '   Nombre: %', v_worker_name;
  RAISE NOTICE '   Schema: %', v_schema_name;

END $$;

-- ============================================
-- VERIFICACIÓN
-- ============================================

-- Ver todos los usuarios del negocio
SELECT 
  '✅ USUARIOS DEL NEGOCIO' as tipo,
  email,
  full_name,
  role,
  schema_name,
  active,
  created_at
FROM public.users
WHERE schema_name = 'minegocio'  -- 🔧 Cambia 'minegocio' por tu schema
ORDER BY role DESC, created_at;

-- ============================================
-- ✅ TRABAJADOR AGREGADO
-- ============================================
-- 
-- Ahora puedes iniciar sesión con:
-- Email: (el que configuraste)
-- Password: (el que configuraste)
-- 
-- ============================================

