# 🔌 INTEGRACIÓN DE SUPABASE - CHRONELIA

## 📋 PASO 1: CREAR PROYECTO EN SUPABASE

### 1. Ve a [https://supabase.com](https://supabase.com)
- Crea una cuenta o inicia sesión

### 2. Crear nuevo proyecto:
- Click en "New Project"
- Nombre: **Chronelia**
- Database Password: (guarda esta contraseña, la necesitarás)
- Region: Elige la más cercana (ej: South America - São Paulo)
- Click "Create Project"

### 3. Obtener credenciales:

Una vez creado el proyecto, ve a **Settings** → **API**:

Necesitas copiar:
- **Project URL** (parecido a: `https://xxxxxx.supabase.co`)
- **anon/public key** (la clave `anon public`)

---

## 📋 PASO 2: CONFIGURAR BASE DE DATOS

Ve a **SQL Editor** en Supabase y ejecuta este script:

```sql
-- CREAR EXTENSIÓN PARA UUIDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- TABLA DE USUARIOS (Workers y Admins)
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('admin', 'worker')),
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- TABLA DE CLIENTES
CREATE TABLE IF NOT EXISTS customers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  phone TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- TABLA DE RESERVAS
CREATE TABLE IF NOT EXISTS reservations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_id UUID REFERENCES customers(id) ON DELETE CASCADE,
  worker_id UUID REFERENCES users(id) ON DELETE SET NULL,
  customer_name TEXT NOT NULL,
  customer_email TEXT NOT NULL,
  qr_code TEXT,
  total_duration INTEGER NOT NULL, -- en segundos
  actual_duration INTEGER, -- duración real al finalizar
  start_time TIMESTAMP WITH TIME ZONE NOT NULL,
  end_time TIMESTAMP WITH TIME ZONE,
  status TEXT NOT NULL CHECK (status IN ('active', 'completed', 'cancelled')),
  extensions INTEGER DEFAULT 0, -- número de veces que se extendió
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- TABLA DE ESTADÍSTICAS DIARIAS
CREATE TABLE IF NOT EXISTS daily_stats (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  date DATE NOT NULL UNIQUE,
  total_reservations INTEGER DEFAULT 0,
  completed_reservations INTEGER DEFAULT 0,
  cancelled_reservations INTEGER DEFAULT 0,
  total_time INTEGER DEFAULT 0, -- en segundos
  average_duration INTEGER DEFAULT 0, -- en segundos
  total_revenue DECIMAL(10,2) DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- TABLA DE RECOMENDACIONES IA (para futuro)
CREATE TABLE IF NOT EXISTS ai_insights (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  type TEXT NOT NULL,
  category TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  priority TEXT NOT NULL,
  data JSONB,
  status TEXT DEFAULT 'active',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  expires_at TIMESTAMP WITH TIME ZONE
);

-- ÍNDICES PARA MEJORAR RENDIMIENTO
CREATE INDEX IF NOT EXISTS idx_reservations_status ON reservations(status);
CREATE INDEX IF NOT EXISTS idx_reservations_start_time ON reservations(start_time);
CREATE INDEX IF NOT EXISTS idx_reservations_worker_id ON reservations(worker_id);
CREATE INDEX IF NOT EXISTS idx_customers_email ON customers(email);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- FUNCIÓN PARA ACTUALIZAR updated_at AUTOMÁTICAMENTE
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- TRIGGERS PARA ACTUALIZAR updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_customers_updated_at BEFORE UPDATE ON customers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reservations_updated_at BEFORE UPDATE ON reservations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_daily_stats_updated_at BEFORE UPDATE ON daily_stats
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- INSERTAR USUARIO ADMIN DE PRUEBA
INSERT INTO users (email, full_name, role, active) VALUES
  ('admin@chronelia.com', 'Administrador', 'admin', true),
  ('trabajador@chronelia.com', 'Juan Trabajador', 'worker', true)
ON CONFLICT (email) DO NOTHING;

-- HABILITAR ROW LEVEL SECURITY (RLS)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE reservations ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_insights ENABLE ROW LEVEL SECURITY;

-- POLÍTICAS DE SEGURIDAD (permitir lectura a todos por ahora)
-- En producción, deberías restringir según autenticación

-- Permitir lectura a todos (temporal para desarrollo)
CREATE POLICY "Allow public read access" ON users FOR SELECT USING (true);
CREATE POLICY "Allow public insert" ON users FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update" ON users FOR UPDATE USING (true);

CREATE POLICY "Allow public read access" ON customers FOR SELECT USING (true);
CREATE POLICY "Allow public insert" ON customers FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update" ON customers FOR UPDATE USING (true);

CREATE POLICY "Allow public read access" ON reservations FOR SELECT USING (true);
CREATE POLICY "Allow public insert" ON reservations FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update" ON reservations FOR UPDATE USING (true);

CREATE POLICY "Allow public read access" ON daily_stats FOR SELECT USING (true);
CREATE POLICY "Allow public insert" ON daily_stats FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update" ON daily_stats FOR UPDATE USING (true);

CREATE POLICY "Allow public read access" ON ai_insights FOR SELECT USING (true);
CREATE POLICY "Allow public insert" ON ai_insights FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update" ON ai_insights FOR UPDATE USING (true);
```

---

## 📋 PASO 3: CONFIGURAR .ENV

Crearé automáticamente el archivo `.env` con el formato correcto.
Solo necesitas **reemplazar las credenciales** con las que copiaste de Supabase.

---

## ✅ CARACTERÍSTICAS QUE SE HABILITARÁN

Una vez integrado Supabase:

1. ✅ **Autenticación real** (en lugar de demo)
2. ✅ **Sincronización en tiempo real** de reservas
3. ✅ **Persistencia de datos** entre sesiones
4. ✅ **Historial guardado en la nube**
5. ✅ **Estadísticas acumulativas**
6. ✅ **Multi-dispositivo** (varios trabajadores al mismo tiempo)
7. ✅ **Backup automático** de toda la información
8. ✅ **Escalabilidad** para múltiples sedes futuras

---

## 🚀 PRÓXIMOS PASOS

1. Crea el proyecto en Supabase
2. Ejecuta el SQL para crear las tablas
3. Copia las credenciales (URL y anon key)
4. Yo crearé el archivo .env y actualizaré el código
5. Probaremos la integración

¿Ya tienes un proyecto en Supabase o necesitas crearlo?















