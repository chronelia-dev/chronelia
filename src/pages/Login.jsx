import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { motion } from 'framer-motion'
import { Button } from '@/components/ui/Button'
import { Input } from '@/components/ui/Input'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/Card'
import { auth } from '@/lib/supabase'
import useStore from '@/store/useStore'
import { toast } from 'sonner'
import { LogIn, Loader2, Monitor, Smartphone } from 'lucide-react'
import { canAccessPlatform, getAccessDeniedMessage, APP_CONFIG } from '@/config/appConfig'

export default function Login() {
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const navigate = useNavigate()

  const handleLogin = async (e) => {
    e.preventDefault()
    setLoading(true)

    try {
      const { data, error } = await auth.signIn(username, password)
      
      if (error) {
        toast.error('Error al iniciar sesión', {
          description: error.message,
        })
      } else {
        const userRole = data.user?.user_metadata?.role
        
        // Validar acceso según plataforma
        if (!canAccessPlatform(userRole)) {
          toast.error('Acceso denegado', {
            description: getAccessDeniedMessage(userRole),
            duration: 6000,
          })
          return
        }
        
        useStore.setState({ user: data.user })
        toast.success('¡Bienvenido!', {
          description: `Has iniciado sesión como ${userRole === 'admin' ? 'Administrador' : 'Trabajador'}`,
        })
        navigate('/')
      }
    } catch (error) {
      toast.error('Error inesperado', {
        description: 'Hubo un problema al iniciar sesión',
      })
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-gradient-to-br from-pink-50 via-purple-50 to-blue-50 px-4 py-8">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
        className="w-full max-w-md"
      >
        <div className="mb-8 flex flex-col items-center space-y-4">
          <motion.img
            src="/logo.png"
            alt="Chronelia"
            className="h-24 w-24 object-contain"
            animate={{ rotate: [0, 5, -5, 0] }}
            transition={{ duration: 2, repeat: Infinity, repeatDelay: 3 }}
          />
          <div className="text-center">
            <h1 className="text-4xl font-bold bg-gradient-to-r from-pink-500 to-purple-600 bg-clip-text text-transparent" style={{ fontFamily: 'Sora, sans-serif', fontWeight: 700 }}>
              chronelia
            </h1>
            <p className="mt-2 text-sm text-muted-foreground">
              Sistema de Gestión de Reservas
            </p>
            <div className="mt-3 inline-flex items-center gap-2 px-3 py-1 rounded-full bg-gradient-to-r from-pink-500 to-purple-600 text-white text-xs font-semibold">
              {APP_CONFIG.platform === 'web' ? (
                <>
                  <Monitor className="h-3 w-3" />
                  Panel Web Administrativo
                </>
              ) : (
                <>
                  <Smartphone className="h-3 w-3" />
                  App Móvil para Trabajadores
                </>
              )}
            </div>
          </div>
        </div>

        <Card>
          <CardHeader>
            <CardTitle>Iniciar Sesión</CardTitle>
            <CardDescription>
              Ingresa tus credenciales para acceder al sistema
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleLogin} className="space-y-5">
              <div className="space-y-2">
                <label htmlFor="username" className="text-sm font-medium block">
                  Nombre de Usuario
                </label>
                <Input
                  id="username"
                  type="text"
                  placeholder="usuario"
                  value={username}
                  onChange={(e) => setUsername(e.target.value)}
                  required
                  disabled={loading}
                  autoComplete="username"
                />
              </div>
              <div className="space-y-2">
                <label htmlFor="password" className="text-sm font-medium block">
                  Contraseña
                </label>
                <Input
                  id="password"
                  type="password"
                  placeholder="••••••••"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                  disabled={loading}
                />
              </div>
              <Button type="submit" className="w-full" disabled={loading}>
                {loading ? (
                  <>
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                    Iniciando sesión...
                  </>
                ) : (
                  <>
                    <LogIn className="mr-2 h-4 w-4" />
                    Iniciar Sesión
                  </>
                )}
              </Button>
            </form>
          </CardContent>
        </Card>
      </motion.div>
    </div>
  )
}

