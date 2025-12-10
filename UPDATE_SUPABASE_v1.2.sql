-- ============================================
-- SCRIPT DE ACTUALIZACIÓN PARA CHRONELIA v1.2
-- ============================================
-- Ejecuta este script en el SQL Editor de Supabase

-- OPCIÓN 1: Si ya tienes la tabla users (RECOMENDADO)
-- ============================================

-- Agregar columna username (si no existe)
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS username TEXT UNIQUE;

-- Crear índice para username
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);

-- Asignar username temporal a usuarios existentes (basado en email)
-- Solo si el usuario no tiene username asignado
UPDATE users 
SET username = LOWER(SPLIT_PART(email, '@', 1))
WHERE username IS NULL;

-- Hacer username obligatorio después de asignar valores
ALTER TABLE users 
ALTER COLUMN username SET NOT NULL;

-- Verificar que todo esté correcto
SELECT id, username, email, full_name, role, active 
FROM users 
ORDER BY created_at DESC;


-- ============================================
-- OPCIÓN 2: Recrear tabla users (⚠️ BORRA DATOS)
-- ============================================
-- Solo usa esto si quieres empezar de cero

/*
-- Eliminar tabla existente
DROP TABLE IF EXISTS users CASCADE;

-- Recrear tabla con username
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  username TEXT UNIQUE NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  full_name TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('admin', 'worker')),
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);

-- Insertar usuario admin de prueba
INSERT INTO users (username, email, password_hash, full_name, role, active)
VALUES 
  ('admin', 'admin@chronelia.com', 'admin123', 'Administrador', 'admin', true),
  ('trabajador', 'trabajador@chronelia.com', 'worker123', 'Juan Trabajador', 'worker', true);

-- Verificar
SELECT * FROM users;
*/














