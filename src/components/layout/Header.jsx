import { Menu, LogOut, User, Shield, Building2 } from 'lucide-react'
import { Button } from '@/components/ui/Button'
import { Badge } from '@/components/ui/Badge'
import useStore from '@/store/useStore'
import { useNavigate } from 'react-router-dom'
import { mockAuth } from '@/lib/supabase'

export default function Header() {
  const { toggleSidebar, user } = useStore()
  const navigate = useNavigate()
  const isAdmin = user?.user_metadata?.role === 'admin'
  const businessName = user?.business_name || null

  const handleLogout = async () => {
    // Detener sincronización automática
    useStore.getState().stopAutoSync()
    // Limpiar datos del negocio
    useStore.getState().clearBusinessData()
    // Cerrar sesión
    await mockAuth.signOut()
    useStore.setState({ user: null })
    navigate('/login')
  }

  return (
    <header className="sticky top-0 z-50 w-full theme-header">
      <div className="flex h-16 items-center px-3 md:px-4">
        {/* Botón menú: Admin siempre, Trabajador solo en desktop */}
        <Button
          variant="ghost"
          size="icon"
          onClick={toggleSidebar}
          className={`mr-4 ${!isAdmin ? 'hidden md:flex' : ''}`}
        >
          <Menu className="h-6 w-6" />
        </Button>
        
        <div className="flex items-center space-x-3">
          <img src="/logo.png" alt="chronelia." className="h-10 w-10 object-contain drop-shadow-lg" />
          <div className="flex flex-col">
            <h1 className="text-2xl font-bold theme-logo-text drop-shadow-md leading-none" style={{ fontFamily: 'Sora, sans-serif', fontWeight: 700 }}>
              chronelia.
            </h1>
            {businessName && (
              <span className="text-xs text-muted-foreground flex items-center gap-1 mt-0.5">
                <Building2 className="h-3 w-3" />
                {businessName}
              </span>
            )}
          </div>
        </div>

        <div className="ml-auto flex items-center gap-2 md:gap-4">
          <div className="flex items-center gap-2">
            {isAdmin && (
              <Badge variant="default" className="hidden md:flex">
                <Shield className="h-3 w-3 mr-1" />
                Admin
              </Badge>
            )}
            <div className="flex items-center space-x-2 text-sm">
              <User className="h-4 w-4" />
              <span className="hidden sm:inline truncate max-w-[150px]">
                {user?.user_metadata?.full_name || user?.email || 'Usuario'}
              </span>
            </div>
          </div>
          <Button variant="ghost" size="icon" onClick={handleLogout}>
            <LogOut className="h-4 w-4 md:h-5 md:w-5" />
          </Button>
        </div>
      </div>
    </header>
  )
}

