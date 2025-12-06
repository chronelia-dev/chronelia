-- ============================================
-- AGREGAR NUEVO CLIENTE A CHRONELIA
-- ============================================
-- Plantilla para agregar un nuevo negocio completo

-- ============================================
-- PASO 1: CREAR EL NEGOCIO Y SUS TABLAS
-- ============================================

SELECT create_business_schema(
  'business_fitlife',              -- Schema name (sin espacios, minúsculas, único)
  'Gimnasio FitLife',              -- Nombre del negocio (como se mostrará)
  'info@fitlife.com',              -- Email de contacto
  '+34 666 777 888',               -- Teléfono
  'Calle Fitness 100, Madrid',     -- Dirección
  'premium',                       -- Plan: 'basic', 'premium', 'enterprise'
  15                               -- Máximo de trabajadores permitidos
);

-- ============================================
-- PASO 2: CREAR USUARIO ADMINISTRADOR
-- ============================================

SELECT create_business_user(
  'business_fitlife',              -- Schema del negocio
  'admin_fitlife',                 -- Username (único en toda la base de datos)
  'admin@fitlife.com',             -- Email
  'fitlife2025',                   -- Contraseña
  'Director FitLife',              -- Nombre completo
  'admin'                          -- Rol: 'admin' o 'worker'
);

-- ============================================
-- PASO 3: CREAR TRABAJADORES (Opcional)
-- ============================================

-- Trabajador 1: Entrenador
SELECT create_business_user(
  'business_fitlife',
  'entrenador_luis',
  'luis@fitlife.com',
  'luis123',
  'Luis Entrenador',
  'worker'
);

-- Trabajador 2: Recepcionista
SELECT create_business_user(
  'business_fitlife',
  'recepcion_maria',
  'maria@fitlife.com',
  'maria123',
  'María Recepcionista',
  'worker'
);

-- ============================================
-- PASO 4: VERIFICAR QUE SE CREÓ CORRECTAMENTE
-- ============================================

-- Ver el negocio creado
SELECT 
  '=== NEGOCIO CREADO ===' as info,
  schema_name,
  business_name,
  plan_type,
  max_workers,
  active
FROM public.businesses
WHERE schema_name = 'business_fitlife';

-- Ver usuarios creados
SELECT 
  '=== USUARIOS DEL NEGOCIO ===' as info,
  username,
  email,
  full_name,
  role,
  active
FROM business_fitlife.users;

-- Ver mapeo de login
SELECT 
  '=== MAPEO DE LOGIN ===' as info,
  username,
  schema_name,
  business_name
FROM public.user_business_map
WHERE schema_name = 'business_fitlife';

-- ============================================
-- ✅ NUEVO CLIENTE LISTO
-- ============================================

/*

✅ CLIENTE CREADO: Gimnasio FitLife

CREDENCIALES:
  Admin:
    - Usuario: admin_fitlife
    - Contraseña: fitlife2025
  
  Trabajadores:
    - Usuario: entrenador_luis | Contraseña: luis123
    - Usuario: recepcion_maria | Contraseña: maria123

CÓMO VERIFICAR EN SUPABASE:
  1. Ve a Table Editor
  2. Cambia Schema a: business_fitlife
  3. Verás las tablas: users, reservations, daily_stats, ai_insights

PRUEBA EL LOGIN:
  SELECT * FROM login_user('admin_fitlife', 'fitlife2025');

DATOS COMPLETAMENTE SEPARADOS:
  - Este negocio NO puede ver datos de otros negocios
  - Otros negocios NO pueden ver datos de este
  - Aislamiento total garantizado

*/

