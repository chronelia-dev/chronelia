import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { motion } from 'framer-motion'
import { QrCode, ArrowLeft, CheckCircle, Camera, AlertCircle } from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/Card'
import { Button } from '@/components/ui/Button'
import { Input } from '@/components/ui/Input'
import useStore from '@/store/useStore'
import { toast } from 'sonner'
import { BarcodeScanner } from '@capacitor-mlkit/barcode-scanning'
import { Capacitor } from '@capacitor/core'

export default function QRScanner() {
  const [scanning, setScanning] = useState(false)
  const [manualCode, setManualCode] = useState('')
  const [isSupported, setIsSupported] = useState(false)
  const navigate = useNavigate()
  const { addReservation, user } = useStore()

  useEffect(() => {
    const platform = Capacitor.getPlatform()
    console.log('📱 Plataforma:', platform)
    setIsSupported(platform === 'android' || platform === 'ios')
  }, [])

  // FUNCIÓN ULTRA SIMPLIFICADA - SOLO ABRE LA CÁMARA
  const startScanSimple = async () => {
    console.log('🎯 INICIO: Botón presionado')
    console.log('🎯 Platform:', Capacitor.getPlatform())
    console.log('🎯 isSupported:', isSupported)
    
    if (!isSupported) {
      toast.error('Escáner no disponible en web')
      return
    }

    try {
      setScanning(true)
      
      // PRIMERO: Solicitar permisos explícitamente
      console.log('🔐 PASO 1: Solicitando permisos explícitamente...')
      const permissionResult = await BarcodeScanner.requestPermissions()
      console.log('🔐 PASO 1 Resultado:', permissionResult)
      
      if (permissionResult.camera !== 'granted' && permissionResult.camera !== 'limited') {
        throw new Error('Permiso de cámara denegado. Ve a Ajustes y activa los permisos.')
      }
      
      // SEGUNDO: Preparar la UI
      console.log('📷 PASO 2: Preparando UI...')
      document.body.classList.add('scanner-active')
      document.querySelector('html')?.classList.add('scanner-active')
      
      // Pequeño delay para asegurar que la UI está lista
      await new Promise(resolve => setTimeout(resolve, 100))
      
      console.log('📷 PASO 3: Abriendo escáner...')
      
      // TERCERO: Abrir el escáner
      const result = await BarcodeScanner.scan()
      
      console.log('📷 PASO 4: Resultado:', result)
      
      if (result && result.barcodes && result.barcodes.length > 0) {
        const code = result.barcodes[0].rawValue
        console.log('✅ Código escaneado:', code)
        processQRCode(code)
        toast.success('¡Código detectado!')
      } else {
        console.log('⚠️ No se detectó código')
        toast.info('No se detectó código QR')
      }
      
    } catch (error) {
      console.error('❌ ERROR:', error)
      console.error('❌ Mensaje:', error.message)
      
      // Mostrar error específico
      if (error.message?.includes('permission')) {
        toast.error('Permiso de cámara denegado', {
          description: 'Ve a Ajustes → Apps → Chronelia → Permisos y activa la cámara',
        })
      } else if (error.message?.includes('User cancelled')) {
        toast.info('Escaneo cancelado')
      } else {
        toast.error('Error: ' + error.message)
      }
    } finally {
      console.log('🏁 Limpiando...')
      document.body.classList.remove('scanner-active')
      document.querySelector('html')?.classList.remove('scanner-active')
      setScanning(false)
    }
  }

  const processQRCode = (qrData) => {
    try {
      const data = JSON.parse(qrData)
      
      if (!data.clientName || !data.duration) {
        throw new Error('Datos incompletos')
      }

      addReservation({
        clientName: data.clientName,
        clientEmail: data.clientEmail || 'sin-email@ejemplo.com',
        qrCode: data.code || qrData,
        totalDuration: data.duration * 60,
        groupSize: data.groupSize || 1,
        worker: user?.user_metadata?.full_name || user?.email || 'Trabajador',
      })

      toast.success('¡Reserva activada!', {
        description: `${data.clientName} - ${data.duration} minutos`,
      })

      navigate('/')
    } catch (error) {
      toast.error('Código QR inválido', {
        description: 'El formato no es correcto',
      })
    }
  }

  const handleManualSubmit = (e) => {
    e.preventDefault()
    if (manualCode.trim()) {
      processQRCode(manualCode)
    }
  }

  // PRUEBA DIRECTA SIN NADA - MÁXIMA SIMPLICIDAD
  const testDirectScan = async () => {
    console.log('🧪 TEST DIRECTO - SIN VERIFICACIONES')
    try {
      const result = await BarcodeScanner.scan()
      console.log('🧪 Resultado:', result)
      if (result?.barcodes?.[0]?.rawValue) {
        processQRCode(result.barcodes[0].rawValue)
      }
    } catch (error) {
      console.error('🧪 Error:', error)
      alert('Error: ' + error.message)
    }
  }

  const handleTestReservation = () => {
    const testData = {
      clientName: 'Cliente Prueba',
      clientEmail: 'test@chronelia.com',
      code: 'TEST' + Date.now(),
      duration: 45,
      groupSize: 2,
    }
    processQRCode(JSON.stringify(testData))
  }

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      <div className="flex items-center space-x-4">
        <Button variant="ghost" size="icon" onClick={() => navigate('/')}>
          <ArrowLeft className="h-5 w-5" />
        </Button>
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Escanear QR</h1>
          <p className="text-muted-foreground">
            Versión simplificada - Abre la cámara directamente
          </p>
        </div>
      </div>

      <div className="grid gap-6 md:grid-cols-2">
        {/* Escáner simplificado */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Camera className="h-5 w-5" />
              Escanear con Cámara
            </CardTitle>
            <CardDescription>
              {isSupported 
                ? 'Presiona el botón para abrir la cámara'
                : 'Solo funciona en la app móvil'
              }
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            {!isSupported ? (
              <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4">
                <div className="flex items-start gap-3">
                  <AlertCircle className="h-5 w-5 text-yellow-600 mt-0.5" />
                  <div>
                    <p className="text-sm font-medium text-yellow-800">
                      Escáner no disponible en web
                    </p>
                    <p className="text-xs text-yellow-700">
                      Instala la APK para usar el escáner
                    </p>
                  </div>
                </div>
              </div>
            ) : (
              <div className="space-y-4">
                <Button 
                  onClick={startScanSimple} 
                  className="w-full" 
                  size="lg"
                  disabled={scanning}
                >
                  {scanning ? (
                    <>
                      <Camera className="mr-2 h-5 w-5 animate-pulse" />
                      Escaneando...
                    </>
                  ) : (
                    <>
                      <Camera className="mr-2 h-5 w-5" />
                      🚀 Abrir Cámara QR
                    </>
                  )}
                </Button>

                <div className="text-xs text-muted-foreground space-y-1">
                  <p>📱 Esta versión abre la cámara directamente</p>
                  <p>🔐 Android pedirá permisos la primera vez</p>
                  <p>📷 Apunta al código QR para escanear</p>
                  <p>❌ Toca fuera para cancelar</p>
                </div>

                <div className="pt-4 border-t border-red-200">
                  <p className="text-xs text-red-600 font-bold mb-2">⚠️ SI NADA FUNCIONA:</p>
                  <Button 
                    onClick={testDirectScan} 
                    variant="destructive"
                    className="w-full" 
                    size="sm"
                  >
                    🆘 PRUEBA EXTREMA (Sin UI, sin checks)
                  </Button>
                  <p className="text-xs text-muted-foreground mt-1">
                    Llama directamente al plugin sin preparación
                  </p>
                </div>
              </div>
            )}
          </CardContent>
        </Card>

        {/* Entrada manual */}
        <Card>
          <CardHeader>
            <CardTitle>Entrada Manual</CardTitle>
            <CardDescription>
              O ingresa el código manualmente
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleManualSubmit} className="space-y-4">
              <div className="space-y-2">
                <label htmlFor="qrCode" className="text-sm font-medium">
                  Código QR (JSON)
                </label>
                <Input
                  id="qrCode"
                  placeholder='{"clientName":"Juan","duration":30,"clientEmail":"juan@email.com"}'
                  value={manualCode}
                  onChange={(e) => setManualCode(e.target.value)}
                />
              </div>
              <Button type="submit" className="w-full">
                <CheckCircle className="mr-2 h-4 w-4" />
                Activar Reserva
              </Button>
            </form>

            <div className="mt-6 pt-6 border-t">
              <Button
                variant="secondary"
                onClick={handleTestReservation}
                className="w-full"
              >
                🧪 Crear Reserva de Prueba
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Información de depuración */}
      <Card className="bg-muted">
        <CardHeader>
          <CardTitle className="text-sm">ℹ️ Información de Debug</CardTitle>
        </CardHeader>
        <CardContent className="text-xs space-y-1">
          <p>• Plataforma: {Capacitor.getPlatform()}</p>
          <p>• Escáner soportado: {isSupported ? '✅ Sí' : '❌ No'}</p>
          <p>• Estado: {scanning ? '🟢 Escaneando' : '⚪ Listo'}</p>
          <p>• Plugin: @capacitor-mlkit/barcode-scanning</p>
        </CardContent>
      </Card>
    </div>
  )
}

