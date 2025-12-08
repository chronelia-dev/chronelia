import { useState } from 'react'
import { motion } from 'framer-motion'
import { Bell, User, Clock, Shield, Save, Check } from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/Card'
import { Button } from '@/components/ui/Button'
import { Input } from '@/components/ui/Input'
import useStore from '@/store/useStore'
import { toast } from 'sonner'

export default function Settings() {
  const { user } = useStore()
  const [saved, setSaved] = useState(false)
  
  // Estados de configuración
  const [notificationsEnabled, setNotificationsEnabled] = useState(true)
  const [soundEnabled, setSoundEnabled] = useState(true)
  const [defaultDuration, setDefaultDuration] = useState('30')
  const [warningTime, setWarningTime] = useState('5')
  // Número de cliente/negocio viene directamente de la BD (no editable)
  const businessName = user?.business_name || 'No asignado'
  const businessId = user?.business_id || null

  const handleSave = () => {
    // Guardar configuración (el número de cliente no se guarda, viene de la BD)
    toast.success('Configuración guardada', {
      description: 'Tus preferencias han sido actualizadas',
    })
    setSaved(true)
    setTimeout(() => setSaved(false), 2000)
  }

  const requestNotificationPermission = async () => {
    if ('Notification' in window) {
      const permission = await Notification.requestPermission()
      if (permission === 'granted') {
        toast.success('Notificaciones activadas', {
          description: 'Recibirás alertas de reservas',
        })
        setNotificationsEnabled(true)
      } else {
        toast.error('Notificaciones bloqueadas', {
          description: 'Activa los permisos en tu navegador',
        })
        setNotificationsEnabled(false)
      }
    }
  }

  return (
    <div className="max-w-4xl space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight">Configuración</h1>
        <p className="text-muted-foreground">
          Personaliza la aplicación según tus preferencias
        </p>
      </div>

      {/* Perfil de usuario */}
      <Card>
        <CardHeader>
          <div className="flex items-center space-x-3">
            <div className="p-2 rounded-full bg-primary/10">
              <User className="h-5 w-5 text-primary" />
            </div>
            <div>
              <CardTitle>Perfil de Usuario</CardTitle>
              <CardDescription>Información de tu cuenta</CardDescription>
            </div>
          </div>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid gap-4 md:grid-cols-2">
            <div className="space-y-2">
              <label className="text-sm font-medium">Nombre</label>
              <Input
                placeholder="Nombre completo"
                defaultValue={user?.user_metadata?.full_name || 'Trabajador Demo'}
              />
            </div>
            <div className="space-y-2">
              <label className="text-sm font-medium">Email</label>
              <Input
                type="email"
                placeholder="email@ejemplo.com"
                defaultValue={user?.email || 'demo@chronelia.com'}
                disabled
              />
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Notificaciones */}
      <Card>
        <CardHeader>
          <div className="flex items-center space-x-3">
            <div className="p-2 rounded-full bg-orange-100">
              <Bell className="h-5 w-5 text-orange-600" />
            </div>
            <div>
              <CardTitle>Notificaciones</CardTitle>
              <CardDescription>Configura las alertas y avisos</CardDescription>
            </div>
          </div>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="flex items-center justify-between">
            <div>
              <p className="font-medium">Notificaciones del navegador</p>
              <p className="text-sm text-muted-foreground">
                Recibe alertas cuando falte poco tiempo
              </p>
            </div>
            <button
              onClick={requestNotificationPermission}
              className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors ${
                notificationsEnabled ? 'bg-primary' : 'bg-gray-300'
              }`}
            >
              <span
                className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${
                  notificationsEnabled ? 'translate-x-6' : 'translate-x-1'
                }`}
              />
            </button>
          </div>

          <div className="flex items-center justify-between">
            <div>
              <p className="font-medium">Sonido de alerta</p>
              <p className="text-sm text-muted-foreground">
                Reproduce un sonido cuando llegue una alerta
              </p>
            </div>
            <button
              onClick={() => setSoundEnabled(!soundEnabled)}
              className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors ${
                soundEnabled ? 'bg-primary' : 'bg-gray-300'
              }`}
            >
              <span
                className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${
                  soundEnabled ? 'translate-x-6' : 'translate-x-1'
                }`}
              />
            </button>
          </div>

          <div className="space-y-2">
            <label className="text-sm font-medium">
              Tiempo de advertencia (minutos)
            </label>
            <Input
              type="number"
              min="1"
              max="15"
              value={warningTime}
              onChange={(e) => setWarningTime(e.target.value)}
              placeholder="5"
            />
            <p className="text-xs text-muted-foreground">
              Tiempo antes de finalizar para mostrar la alerta (actual: 5 minutos)
            </p>
          </div>
        </CardContent>
      </Card>

      {/* Reservas */}
      <Card>
        <CardHeader>
          <div className="flex items-center space-x-3">
            <div className="p-2 rounded-full bg-blue-100">
              <Clock className="h-5 w-5 text-blue-600" />
            </div>
            <div>
              <CardTitle>Reservas</CardTitle>
              <CardDescription>Configuración por defecto de reservas</CardDescription>
            </div>
          </div>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="space-y-2">
            <label className="text-sm font-medium">
              Duración predeterminada (minutos)
            </label>
            <Input
              type="number"
              min="15"
              max="180"
              value={defaultDuration}
              onChange={(e) => setDefaultDuration(e.target.value)}
              placeholder="30"
            />
            <p className="text-xs text-muted-foreground">
              Duración estándar para nuevas reservas sin tiempo especificado
            </p>
          </div>
        </CardContent>
      </Card>

      {/* Información del sistema */}
      <Card>
        <CardHeader>
          <div className="flex items-center space-x-3">
            <div className="p-2 rounded-full bg-purple-100">
              <Shield className="h-5 w-5 text-purple-600" />
            </div>
            <div>
              <CardTitle>Información del Sistema</CardTitle>
              <CardDescription>Detalles de la aplicación</CardDescription>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            <div className="space-y-2">
              <label className="text-sm font-medium">
                Número de Cliente / Negocio
              </label>
              <Input
                type="text"
                value={businessName}
                disabled
                className="bg-muted/50 font-semibold text-primary"
              />
              <p className="text-xs text-muted-foreground">
                Identificador permanente del negocio (no editable). Este nombre se usa en toda la aplicación.
              </p>
            </div>
            
            <div className="border-t pt-4 grid gap-3 text-sm">
              <div className="flex justify-between">
                <span className="text-muted-foreground">Versión</span>
                <span className="font-medium">1.0.0</span>
              </div>
              <div className="flex justify-between">
                <span className="text-muted-foreground">Última actualización</span>
                <span className="font-medium">
                  {new Date().toLocaleDateString('es-ES')}
                </span>
              </div>
              <div className="flex justify-between">
                <span className="text-muted-foreground">Estado</span>
                <span className="font-medium text-green-600">Operativo</span>
              </div>
              {businessName && businessName !== 'No asignado' && (
                <div className="flex justify-between pt-2 border-t">
                  <span className="text-muted-foreground">Negocio</span>
                  <span className="font-medium text-purple-600">{businessName}</span>
                </div>
              )}
              {businessId && (
                <div className="flex justify-between">
                  <span className="text-muted-foreground">ID de Negocio</span>
                  <span className="font-mono text-xs text-muted-foreground">{businessId}</span>
                </div>
              )}
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Botón guardar */}
      <motion.div whileHover={{ scale: 1.02 }} whileTap={{ scale: 0.98 }}>
        <Button onClick={handleSave} className="w-full" size="lg">
          {saved ? (
            <>
              <Check className="mr-2 h-5 w-5" />
              Guardado
            </>
          ) : (
            <>
              <Save className="mr-2 h-5 w-5" />
              Guardar Cambios
            </>
          )}
        </Button>
      </motion.div>
    </div>
  )
}












