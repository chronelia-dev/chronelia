import { useEffect } from 'react'
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import { Toaster } from 'sonner'
import Layout from '@/components/layout/Layout'
import Login from '@/pages/Login'
import Dashboard from '@/pages/Dashboard'
import QRScanner from '@/pages/QRScanner'
import Statistics from '@/pages/Statistics'
import History from '@/pages/History'
import Settings from '@/pages/Settings'
import AdminPanel from '@/pages/AdminPanel'
import Workers from '@/pages/Workers'
import Recommendations from '@/pages/Recommendations'
import OpenAITest from '@/components/OpenAITest'
import useStore from '@/store/useStore'
import { mockAuth } from '@/lib/supabase'

function ProtectedRoute({ children }) {
  const { user } = useStore()
  return user ? children : <Navigate to="/login" replace />
}

function AdminRoute({ children }) {
  const { user } = useStore()
  const isAdmin = user?.user_metadata?.role === 'admin'
  return user && isAdmin ? children : <Navigate to="/" replace />
}

function App() {
  const { user, setUser } = useStore()

  useEffect(() => {
    // Verificar si hay un usuario autenticado al cargar la app
    const checkUser = async () => {
      const { data } = await mockAuth.getUser()
      if (data.user) {
        setUser(data.user)
      }
    }
    checkUser()
  }, [setUser])

  return (
    <BrowserRouter>
      <Toaster position="top-right" richColors closeButton />
      <Routes>
        <Route path="/login" element={<Login />} />
        {/* Ruta temporal para pruebas de OpenAI */}
        <Route path="/test-openai" element={<OpenAITest />} />
        <Route
          path="/"
          element={
            <ProtectedRoute>
              <Layout />
            </ProtectedRoute>
          }
        >
          <Route index element={<Dashboard />} />
          <Route path="scan" element={<QRScanner />} />
          <Route path="stats" element={<Statistics />} />
          <Route path="history" element={<History />} />
          <Route path="settings" element={<Settings />} />
          <Route
            path="admin"
            element={
              <AdminRoute>
                <AdminPanel />
              </AdminRoute>
            }
          />
          <Route
            path="workers"
            element={
              <AdminRoute>
                <Workers />
              </AdminRoute>
            }
          />
          <Route
            path="recommendations"
            element={
              <AdminRoute>
                <Recommendations />
              </AdminRoute>
            }
          />
        </Route>
      </Routes>
    </BrowserRouter>
  )
}

export default App

