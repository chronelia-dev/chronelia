import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { motion } from 'framer-motion'
import { QrCode, ArrowLeft, CheckCircle, Camera, Scan, AlertCircle } from 'lucide-react'
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
  const [permissionStatus, setPermissionStatus] = useState('prompt')
  const navigate = useNavigate()
  const { addReservation, user } = useStore()

  // Verificar si el escáner está disponible
  useEffect(() => {
    checkScannerSupport()
  }, [])

  const checkScannerSupport = async () => {
    // Solo funciona en plataformas nativas (Android/iOS)
    const platform = Capacitor.getPlatform()
    console.log('Plataforma detectada:', platform)
    
    if (platform === 'android' || platform === 'ios') {
      setIsSupported(true)
      
      // Verificar el estado de los permisos
      try {
        const result = await BarcodeScanner.checkPermissions()
        console.log('Estado de permisos:', result)
        setPermissionStatus(result.camera)
      } catch (error) {
        console.error('Error al verificar permisos:', error)
      }
    } else {
      setIsSupported(false)
      console.log('Escáner no disponible en web, usa entrada manual')
    }
  }

  // Solicitar permisos de cámara - MÉTODO SIMPLE
  const requestPermissions = async () => {
    try {
      console.log('🔐 [PASO 1] Solicitando permisos de cámara...')
      
      const result = await BarcodeScanner.requestPermissions()
      console.log('📋 [PASO 2] Resultado completo:', JSON.stringify(result))
      console.log('📷 [PASO 3] Estado de cámara:', result.camera)
      
      setPermissionStatus(result.camera)
      
      if (result.camera === 'granted' || result.camera === 'limited') {
        console.log('✅ [PASO 4] Permisos CONCEDIDOS')
        toast.success('✅ Permiso concedido', {
          description: 'La cámara está lista para usar',
        })
        // Actualizar inmediatamente
        await checkScannerSupport()
        return true
      } else if (result.camera === 'denied') {
        console.log('❌ [PASO 4] Permisos DENEGADOS')
        toast.error('❌ Permiso denegado', {
          description: 'Ve a: Ajustes > Apps > Chronelia > Permisos > Cámara',
        })
        return false
      } else {
        console.log('⚠️ [PASO 4] Estado:', result.camera)
        toast.warning('Permiso no concedido', {
          description: 'Estado: ' + result.camera,
        })
        return false
      }
    } catch (error) {
      console.error('💥 [ERROR] Error al solicitar permisos:', error)
      console.error('💥 [ERROR] Mensaje:', error.message)
      console.error('💥 [ERROR] Stack:', error.stack)
      toast.error('Error de permisos', {
        description: error.message || 'Error desconocido',
      })
      return false
    }
  }

  // Test DIRECTO sin verificaciones previas
  const testCameraDirect = async () => {
    try {
      console.log('🧪 [TEST] Prueba DIRECTA de cámara...')
      console.log('🧪 [TEST] Llamando a BarcodeScanner.scan() sin verificaciones previas')
      
      setScanning(true)
      document.body.classList.add('scanner-active')
      document.querySelector('html')?.classList.add('scanner-active')
      
      const result = await BarcodeScanner.scan()
      
      console.log('🧪 [TEST] Resultado:', JSON.stringify(result))
      
      if (result && result.barcodes && result.barcodes.length > 0) {
        console.log('🧪 [TEST] ¡Código detectado!', result.barcodes[0].rawValue)
        processQRCode(result.barcodes[0].rawValue)
      }
      
    } catch (error) {
      console.error('🧪 [TEST] Error:', error.message)
      toast.error('Error en test directo: ' + error.message)
    } finally {
      document.body.classList.remove('scanner-active')
      document.querySelector('html')?.classList.remove('scanner-active')
      setScanning(false)
    }
  }

  // Iniciar escaneo - Método ULTRA simplificado
  const startScan = async () => {
    if (!isSupported) {
      toast.error('Escáner no disponible', {
        description: 'El escáner de QR solo funciona en la app móvil. Usa entrada manual.',
      })
      return
    }

    try {
      console.log('📱 [SCAN 1] Iniciando escaneo...')
      console.log('📱 [SCAN 2] Plataforma:', Capacitor.getPlatform())
      console.log('📱 [SCAN 3] Estado de permisos actual:', permissionStatus)

      // SIEMPRE solicitar permisos justo antes de escanear
      console.log('📱 [SCAN 4] Solicitando permisos...')
      const permResult = await BarcodeScanner.requestPermissions()
      console.log('📱 [SCAN 5] Resultado permisos:', permResult.camera)
      
      if (permResult.camera !== 'granted' && permResult.camera !== 'limited') {
        toast.error('Se necesita permiso de cámara', {
          description: 'Por favor acepta el permiso cuando Android lo solicite',
        })
        return
      }

      setScanning(true)
      
      console.log('📱 [SCAN 6] Configurando UI transparente...')
      document.body.classList.add('scanner-active')
      document.querySelector('html')?.classList.add('scanner-active')
      
      console.log('📱 [SCAN 7] Llamando a BarcodeScanner.scan()...')
      
      const result = await BarcodeScanner.scan()
      
      console.log('📱 [SCAN 8] Resultado completo:', JSON.stringify(result))
      
      if (result && result.barcodes && result.barcodes.length > 0) {
        const barcode = result.barcodes[0]
        console.log('📱 [SCAN 9] ✅ Código escaneado:', barcode.rawValue)
        processQRCode(barcode.rawValue)
        toast.success('¡Código QR detectado!')
      } else {
        console.log('📱 [SCAN 9] ⚠️ No se detectaron códigos')
        toast.info('No se detectó código QR', {
          description: 'Intenta de nuevo',
        })
      }
      
    } catch (error) {
      console.error('📱 [SCAN ERROR] Error completo:', error)
      console.error('📱 [SCAN ERROR] Mensaje:', error.message)
      console.error('📱 [SCAN ERROR] Tipo:', error.name)
      
      // Manejar diferentes tipos de errores
      if (error.message?.toLowerCase().includes('cancel')) {
        console.log('📱 [SCAN ERROR] Cancelado por usuario')
        toast.info('Escaneo cancelado')
      } else if (error.message?.toLowerCase().includes('permission')) {
        console.log('📱 [SCAN ERROR] Error de permisos')
        toast.error('Error de permisos', {
          description: 'Ve a: Ajustes > Apps > Chronelia > Permisos > Cámara y actívala',
        })
      } else {
        console.log('📱 [SCAN ERROR] Error desconocido')
        toast.error('Error al escanear', {
          description: error.message || 'Error desconocido',
        })
      }
    } finally {
      console.log('📱 [SCAN FINAL] Limpiando...')
      document.body.classList.remove('scanner-active')
      document.querySelector('html')?.classList.remove('scanner-active')
      setScanning(false)
      console.log('📱 [SCAN FINAL] ✅ Proceso completado')
    }
  }

  // Detener escaneo
  const stopScan = async () => {
    try {
      console.log('Deteniendo escaneo...')
      await BarcodeScanner.stopScan()
    } catch (error) {
      console.error('Error al detener escáner:', error)
    }
    
    document.body.classList.remove('scanner-active')
    document.querySelector('html')?.classList.remove('scanner-active')
    setScanning(false)
  }

  const processQRCode = (qrData) => {
    try {
      // Intentar parsear como JSON
      const data = JSON.parse(qrData)
      
      // Validar datos requeridos
      if (!data.clientName || !data.duration) {
        throw new Error('Datos incompletos en el QR')
      }

      // Crear nueva reserva
      addReservation({
        clientName: data.clientName,
        clientEmail: data.clientEmail || 'sin-email@ejemplo.com',
        qrCode: data.code || qrData,
        totalDuration: data.duration * 60, // convertir minutos a segundos
        groupSize: data.groupSize || 1,
        worker: user?.user_metadata?.full_name || user?.email || 'Trabajador',
      })

      toast.success('¡Reserva activada!', {
        description: `${data.clientName} - ${data.duration} minutos`,
      })

      navigate('/')
    } catch (error) {
      toast.error('Código QR inválido', {
        description: 'El código no tiene el formato correcto',
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
    // Crear una reserva de prueba
    const testData = {
      clientName: 'María García',
      clientEmail: 'maria.garcia@email.com',
      code: 'TEST' + Date.now(),
      duration: 45, // 45 minutos
      groupSize: 3,
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
            Escanea el código QR del cliente para activar su reserva
          </p>
        </div>
      </div>

      <div className="grid gap-6 md:grid-cols-2">
        {/* Escáner de cámara */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Camera className="h-5 w-5" />
              Escanear con Cámara
            </CardTitle>
            <CardDescription>
              {isSupported 
                ? 'Utiliza la cámara de tu dispositivo para escanear el código QR'
                : 'El escáner solo funciona en la aplicación móvil'
              }
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            {!isSupported ? (
              <div className="bg-yellow-50 dark:bg-yellow-900/20 border border-yellow-200 dark:border-yellow-800 rounded-lg p-4">
                <div className="flex items-start gap-3">
                  <AlertCircle className="h-5 w-5 text-yellow-600 dark:text-yellow-500 mt-0.5" />
                  <div className="space-y-1">
                    <p className="text-sm font-medium text-yellow-800 dark:text-yellow-200">
                      Escáner no disponible en navegador web
                    </p>
                    <p className="text-xs text-yellow-700 dark:text-yellow-300">
                      Para usar el escáner de cámara, instala la aplicación móvil. 
                      Mientras tanto, puedes usar la entrada manual.
                    </p>
                  </div>
                </div>
              </div>
            ) : (
              <div className="space-y-4">
                {/* Estado de permisos */}
                <div className={`p-3 rounded-lg border ${
                  permissionStatus === 'granted' || permissionStatus === 'limited'
                    ? 'bg-green-50 dark:bg-green-900/20 border-green-200 dark:border-green-800'
                    : permissionStatus === 'denied'
                    ? 'bg-red-50 dark:bg-red-900/20 border-red-200 dark:border-red-800'
                    : 'bg-blue-50 dark:bg-blue-900/20 border-blue-200 dark:border-blue-800'
                }`}>
                  <p className="text-xs font-medium">
                    Estado de permisos: {
                      permissionStatus === 'granted' ? '✅ Concedidos' :
                      permissionStatus === 'limited' ? '⚠️ Limitados' :
                      permissionStatus === 'denied' ? '❌ Denegados' :
                      '❓ No solicitados'
                    }
                  </p>
                </div>

                {/* Botón para solicitar permisos */}
                {(permissionStatus !== 'granted' && permissionStatus !== 'limited') && (
                  <Button 
                    onClick={requestPermissions} 
                    variant="outline"
                    className="w-full" 
                    size="lg"
                  >
                    <AlertCircle className="mr-2 h-5 w-5" />
                    Solicitar Permisos de Cámara
                  </Button>
                )}

                {/* Botón principal de escaneo */}
                <Button 
                  onClick={startScan} 
                  className="w-full" 
                  size="lg"
                  disabled={scanning}
                >
                  {scanning ? (
                    <>
                      <Scan className="mr-2 h-5 w-5 animate-pulse" />
                      Escaneando...
                    </>
                  ) : (
                    <>
                      <Camera className="mr-2 h-5 w-5" />
                      Abrir Escáner QR
                    </>
                  )}
                </Button>

                {/* Botón de PRUEBA DIRECTA */}
                <div className="pt-2 border-t">
                  <p className="text-xs text-muted-foreground mb-2 text-center">
                    🧪 Si el botón normal no funciona, prueba esto:
                  </p>
                  <Button 
                    onClick={testCameraDirect} 
                    variant="secondary"
                    className="w-full" 
                    size="sm"
                    disabled={scanning}
                  >
                    🧪 Prueba Directa (sin verificaciones)
                  </Button>
                </div>

                <p className="text-xs text-muted-foreground text-center">
                  {scanning 
                    ? '📷 La cámara está activa. Apunta al código QR para escanearlo.'
                    : permissionStatus === 'denied'
                    ? '⚙️ Ve a configuración de la app y habilita el acceso a la cámara.'
                    : permissionStatus === 'granted' || permissionStatus === 'limited'
                    ? '✅ Permisos listos. Presiona el botón para escanear.'
                    : '🔐 Primero solicita los permisos de cámara.'
                  }
                </p>

                {scanning && (
                  <Button
                    variant="destructive"
                    onClick={stopScan}
                    className="w-full"
                    size="sm"
                  >
                    Cancelar Escaneo
                  </Button>
                )}
              </div>
            )}
          </CardContent>
        </Card>

        {/* Entrada manual */}
        <Card>
          <CardHeader>
            <CardTitle>Entrada Manual</CardTitle>
            <CardDescription>
              Ingresa manualmente el código QR o datos de la reserva
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
                  placeholder='{"clientName":"Juan Pérez","duration":30,"clientEmail":"juan@email.com"}'
                  value={manualCode}
                  onChange={(e) => setManualCode(e.target.value)}
                />
                <p className="text-xs text-muted-foreground">
                  Formato: JSON con clientName, duration (minutos) y clientEmail
                </p>
              </div>
              <Button type="submit" className="w-full">
                <CheckCircle className="mr-2 h-4 w-4" />
                Activar Reserva
              </Button>
            </form>

            <div className="mt-6 pt-6 border-t">
              <p className="text-sm font-medium mb-2">Prueba rápida</p>
              <Button
                variant="secondary"
                onClick={handleTestReservation}
                className="w-full"
              >
                Crear Reserva de Prueba (45 min)
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Ejemplo de QR */}
      <Card>
        <CardHeader>
          <CardTitle>Formato del Código QR</CardTitle>
          <CardDescription>
            Los códigos QR deben contener la siguiente información en formato JSON
          </CardDescription>
        </CardHeader>
        <CardContent>
          <pre className="bg-muted p-4 rounded-lg overflow-x-auto text-sm">
{`{
  "clientName": "Nombre del Cliente",
  "clientEmail": "email@ejemplo.com",
  "duration": 30,
  "code": "CODIGO_UNICO"
}`}
          </pre>
        </CardContent>
      </Card>
    </div>
  )
}




