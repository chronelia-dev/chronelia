-- ============================================
-- 🏢 EJEMPLO: PELUQUERÍA BELLA VISTA
-- ============================================
-- Este es un ejemplo completo de cómo agregar un nuevo negocio
-- Puedes copiar esto y modificar los valores según tu cliente
-- ============================================

-- ============================================
-- PASO 1: CREAR EL NEGOCIO Y SUS TABLAS
-- ============================================

SELECT create_business_schema(
  'business_bellavista',           -- Schema único para este negocio
  'Peluquería Bella Vista',       -- Nombre visible del negocio
  'info@bellavista.com',          -- Email de contacto
  '+34 91 555 1234',              -- Teléfono
  'Calle Mayor 45, Madrid',       -- Dirección
  'premium',                      -- Plan: basic, premium o enterprise
  8                               -- Máximo 8 trabajadores
);

-- ============================================
-- PASO 2: CREAR USUARIO ADMINISTRADOR
-- ============================================

SELECT create_business_user(
  'business_bellavista',          -- Schema del negocio
  'admin_bella',                  -- Username para login
  'admin@bellavista.com',         -- Email del admin
  'bella2025',                    -- Contraseña
  'María García',                 -- Nombre completo
  'admin'                         -- Rol de administrador
);

-- ============================================
-- PASO 3: CREAR TRABAJADORES
-- ============================================

-- Estilista 1
SELECT create_business_user(
  'business_bellavista',
  'carlos',
  'carlos@bellavista.com',
  'carlos123',
  'Carlos Rodríguez',
  'worker'
);

-- Estilista 2
SELECT create_business_user(
  'business_bellavista',
  'ana',
  'ana@bellavista.com',
  'ana123',
  'Ana López',
  'worker'
);

-- Estilista 3
SELECT create_business_user(
  'business_bellavista',
  'juan',
  'juan@bellavista.com',
  'juan123',
  'Juan Martínez',
  'worker'
);

-- ============================================
-- PASO 4: VERIFICAR
-- ============================================

-- Ver negocio
SELECT 
  '=== NEGOCIO CREADO ===' as info,
  *
FROM public.businesses
WHERE schema_name = 'business_bellavista';

-- Ver usuarios mapeados
SELECT 
  '=== USUARIOS MAPEADOS ===' as info,
  username,
  schema_name,
  business_name
FROM public.user_business_map
WHERE schema_name = 'business_bellavista';

-- Ver usuarios del negocio
SELECT 
  '=== USUARIOS DEL NEGOCIO ===' as info,
  username,
  email,
  full_name,
  role,
  active,
  password_hash as contraseña
FROM business_bellavista.users;

-- ============================================
-- PASO 5: PROBAR LOGINS
-- ============================================

-- Login del admin
SELECT * FROM login_user('admin_bella', 'bella2025');

-- Login de trabajador
SELECT * FROM login_user('carlos', 'carlos123');

-- ============================================
-- ✅ CREDENCIALES GENERADAS
-- ============================================
/*
NEGOCIO: Peluquería Bella Vista
SCHEMA: business_bellavista
PLAN: Premium (hasta 8 trabajadores)

ADMINISTRADOR:
- Usuario: admin_bella
- Contraseña: bella2025
- Email: admin@bellavista.com
- Acceso: Completo (panel admin, estadísticas, gestión de trabajadores)

TRABAJADORES:
- Usuario: carlos | Contraseña: carlos123 | Nombre: Carlos Rodríguez
- Usuario: ana    | Contraseña: ana123    | Nombre: Ana López
- Usuario: juan   | Contraseña: juan123   | Nombre: Juan Martínez

URL: https://chronelia.vercel.app
*/




