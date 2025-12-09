import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { ArrowLeft, CheckCircle, Camera, Scan } from 'lucide-react'
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

  // ESCANEO EN TIEMPO REAL - SIN MANIPULAR LA UI
  const startScanning = async () => {
    console.log('🎯 Iniciando escaneo en tiempo real')
    
    if (!isSupported) {
      toast.error('Escáner no disponible en web')
      return
    }

    try {
      setScanning(true)
      
      console.log('🔐 Paso 1: Solicitando permisos...')
      const permission = await BarcodeScanner.requestPermissions()
      console.log('🔐 Resultado permisos:', permission)
      
      if (permission.camera !== 'granted' && permission.camera !== 'limited') {
        toast.error('Permiso de cámara denegado', {
          description: 'Ve a Ajustes → Apps → Chronelia → Permisos → Cámara'
        })
        setScanning(false)
        return
      }

      console.log('📷 Paso 2: Preparando escáner...')
      
      // Agregar clase para indicar que estamos escaneando
      // PERO NO vamos a ocultar la UI completamente
      document.body.classList.add('qr-scanning')
      
      toast.info('📷 Escáner abierto - Apunta al código QR', { duration: 3000 })
      
      console.log('📷 Paso 3: Iniciando escaneo...')
      
      // El plugin maneja su propia UI de cámara
      const result = await BarcodeScanner.scan()
      
      console.log('📷 Paso 4: Resultado:', result)
      
      if (result && result.barcodes && result.barcodes.length > 0) {
        const code = result.barcodes[0].rawValue
        console.log('✅ Código detectado:', code)
        processQRCode(code)
        toast.success('¡Código QR detectado!')
      } else {
        console.log('⚠️ No se detectó código')
        toast.info('No se detectó código QR')
      }
      
    } catch (error) {
      console.error('❌ ERROR:', error)
      console.error('❌ Mensaje:', error.message)
      
      if (error.message?.includes('User cancelled')) {
        toast.info('Escaneo cancelado')
      } else if (error.message?.includes('permission')) {
        toast.error('Error de permisos', {
          description: 'Verifica los permisos de cámara en Ajustes'
        })
      } else {
        toast.error('Error al escanear: ' + error.message)
      }
    } finally {
      console.log('🏁 Limpiando...')
      document.body.classList.remove('qr-scanning')
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
            Escaneo en tiempo real con ML Kit
          </p>
        </div>
      </div>

      <div className="grid gap-6 md:grid-cols-2">
        {/* Escáner en tiempo real */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Scan className="h-5 w-5" />
              Escanear en Tiempo Real
            </CardTitle>
            <CardDescription>
              {isSupported 
                ? 'Escanea códigos QR en tiempo real con la cámara'
                : 'Solo funciona en la app móvil'
              }
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            {!isSupported ? (
              <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4">
                <p className="text-sm text-yellow-800">
                  El escáner solo funciona en la app móvil
                </p>
              </div>
            ) : (
              <div className="space-y-4">
                <Button 
                  onClick={startScanning} 
                  className="w-full" 
                  size="lg"
                  disabled={scanning}
                >
                  {scanning ? (
                    <>
                      <Scan className="mr-2 h-5 w-5 animate-pulse" />
                      Escaneando en tiempo real...
                    </>
                  ) : (
                    <>
                      <Camera className="mr-2 h-5 w-5" />
                      📹 Escanear QR (Tiempo Real)
                    </>
                  )}
                </Button>

                <div className="text-xs text-muted-foreground space-y-1">
                  <p><strong>Cómo usar:</strong></p>
                  <p>1️⃣ Presiona el botón</p>
                  <p>2️⃣ Acepta los permisos de cámara</p>
                  <p>3️⃣ Apunta al código QR</p>
                  <p>4️⃣ Se detectará automáticamente</p>
                  {scanning && (
                    <p className="text-green-600 font-bold mt-2">
                      🟢 Escáner activo - Apunta al QR
                    </p>
                  )}
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

      {/* Info */}
      <Card className={`${scanning ? 'bg-green-50 border-green-300' : 'bg-blue-50 border-blue-200'}`}>
        <CardHeader>
          <CardTitle className="text-sm">
            {scanning ? '🟢 Escáner Activo' : 'ℹ️ Información'}
          </CardTitle>
        </CardHeader>
        <CardContent className="text-xs space-y-1">
          {scanning ? (
            <>
              <p className="font-bold text-green-700">El escáner está activo</p>
              <p className="text-green-600">Apunta la cámara al código QR</p>
              <p className="text-green-600">Se detectará automáticamente</p>
              <p className="text-green-600">Toca fuera de la cámara para cancelar</p>
            </>
          ) : (
            <>
              <p>• Plataforma: {Capacitor.getPlatform()}</p>
              <p>• Escáner soportado: {isSupported ? '✅ Sí' : '❌ No'}</p>
              <p>• Plugin: @capacitor-mlkit/barcode-scanning</p>
              <p>• Modo: Escaneo en tiempo real</p>
            </>
          )}
        </CardContent>
      </Card>
    </div>
  )
}







