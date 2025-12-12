import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { ArrowLeft, CheckCircle, Camera, AlertCircle } from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/Card'
import { Button } from '@/components/ui/Button'
import { Input } from '@/components/ui/Input'
import useStore from '@/store/useStore'
import { toast } from 'sonner'
import { Camera as CapacitorCamera } from '@capacitor/camera'
import { CameraResultType, CameraSource } from '@capacitor/camera'
import jsQR from 'jsqr'

export default function QRScanner() {
  const [manualCode, setManualCode] = useState('')
  const navigate = useNavigate()
  const { addReservation, user } = useStore()

  // USAR LA CÁMARA NATIVA Y PROCESAR LA IMAGEN
  const takePictureAndScan = async () => {
    console.log('📸 MÉTODO ALTERNATIVO: Tomar foto y escanear')
    
    try {
      toast.info('📷 Abriendo cámara...', { duration: 2000 })
      
      // Tomar una foto con la cámara nativa
      const image = await CapacitorCamera.getPhoto({
        quality: 90,
        resultType: CameraResultType.Base64,
        source: CameraSource.Camera,
        correctOrientation: true,
      })
      
      console.log('📸 Foto tomada, procesando...')
      toast.info('🔍 Procesando imagen...', { duration: 2000 })
      
      // Convertir base64 a imagen y buscar QR
      const img = new Image()
      img.src = 'data:image/jpeg;base64,' + image.base64String
      
      img.onload = () => {
        const canvas = document.createElement('canvas')
        canvas.width = img.width
        canvas.height = img.height
        const ctx = canvas.getContext('2d')
        ctx.drawImage(img, 0, 0)
        
        const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height)
        const code = jsQR(imageData.data, imageData.width, imageData.height)
        
        if (code) {
          console.log('✅ QR detectado:', code.data)
          processQRCode(code.data)
          toast.success('¡Código QR detectado!')
        } else {
          console.log('❌ No se detectó QR en la imagen')
          toast.error('No se detectó código QR', {
            description: 'Intenta tomar la foto más cerca del código',
          })
        }
      }
      
    } catch (error) {
      console.error('❌ Error:', error)
      
      if (error.message?.includes('User cancelled')) {
        toast.info('Foto cancelada')
      } else {
        toast.error('Error: ' + error.message)
      }
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
            Método alternativo: Tomar foto del QR
          </p>
        </div>
      </div>

      <div className="grid gap-6 md:grid-cols-2">
        {/* Método de foto */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Camera className="h-5 w-5" />
              Tomar Foto del QR
            </CardTitle>
            <CardDescription>
              Toma una foto del código QR y la app lo escaneará automáticamente
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
              <div className="flex items-start gap-3">
                <AlertCircle className="h-5 w-5 text-blue-600 mt-0.5" />
                <div>
                  <p className="text-sm font-medium text-blue-800">
                    Método Alternativo
                  </p>
                  <p className="text-xs text-blue-700">
                    Este método toma una foto del QR y lo procesa. Más simple y confiable.
                  </p>
                </div>
              </div>
            </div>

            <Button 
              onClick={takePictureAndScan} 
              className="w-full" 
              size="lg"
            >
              <Camera className="mr-2 h-5 w-5" />
              📷 Tomar Foto del QR
            </Button>

            <div className="text-xs text-muted-foreground space-y-1">
              <p><strong>Cómo usar:</strong></p>
              <p>1️⃣ Presiona el botón</p>
              <p>2️⃣ Toma una foto del código QR</p>
              <p>3️⃣ La app lo escaneará automáticamente</p>
              <p>4️⃣ Si no funciona, acércate más al QR</p>
            </div>
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

      {/* Ventajas del método */}
      <Card className="bg-green-50 border-green-200">
        <CardHeader>
          <CardTitle className="text-sm text-green-800">✨ Ventajas de este método</CardTitle>
        </CardHeader>
        <CardContent className="text-xs space-y-1 text-green-700">
          <p>✅ Usa la cámara nativa de Android (más compatible)</p>
          <p>✅ No requiere permisos especiales de ML Kit</p>
          <p>✅ Procesa la imagen localmente con jsQR</p>
          <p>✅ Funciona aunque el QR esté un poco borroso</p>
          <p>✅ Puedes revisar la foto antes de que se procese</p>
        </CardContent>
      </Card>
    </div>
  )
}











