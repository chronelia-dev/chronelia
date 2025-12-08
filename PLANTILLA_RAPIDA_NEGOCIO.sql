-- ============================================
-- ⚡ PLANTILLA RÁPIDA - NUEVO NEGOCIO
-- ============================================
-- Copia esto y reemplaza solo los valores marcados con -->
-- ============================================

-- CREAR NEGOCIO
SELECT create_business_schema(
  'business_XXXXX',              --> Nombre único (sin espacios)
  'Nombre del Negocio',          --> Nombre visible
  'email@negocio.com',           --> Email
  '+34 000 000 000',             --> Teléfono
  'Dirección del negocio',       --> Dirección
  'basic',                       --> Plan: basic, premium, enterprise
  5                              --> Máximo de trabajadores
);

-- CREAR ADMIN
SELECT create_business_user(
  'business_XXXXX',              --> Mismo nombre del schema
  'admin',                       --> Username (o admin_XXXXX)
  'admin@negocio.com',           --> Email del admin
  'password123',                 --> Contraseña del admin
  'Nombre del Admin',            --> Nombre completo
  'admin'
);

-- CREAR TRABAJADOR (opcional)
SELECT create_business_user(
  'business_XXXXX',              --> Mismo nombre del schema
  'trabajador1',                 --> Username del trabajador
  'trabajador@negocio.com',      --> Email
  'pass123',                     --> Contraseña
  'Nombre Trabajador',           --> Nombre completo
  'worker'
);

-- VERIFICAR
SELECT * FROM public.businesses WHERE schema_name = 'business_XXXXX';
SELECT * FROM business_XXXXX.users;

-- PROBAR LOGIN
SELECT * FROM login_user('admin', 'password123');

