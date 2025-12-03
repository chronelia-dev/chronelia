import { LocalNotifications } from '@capacitor/local-notifications'
import { Capacitor } from '@capacitor/core'

/**
 * Inicializar y solicitar permisos para notificaciones
 */
export async function initNotifications() {
  if (Capacitor.isNativePlatform()) {
    try {
      const permission = await LocalNotifications.requestPermissions()
      console.log('📢 Permisos de notificaciones:', permission.display)
      return permission.display === 'granted'
    } catch (error) {
      console.error('❌ Error solicitando permisos:', error)
      return false
    }
  } else {
    // Web: usar Notification API
    if ('Notification' in window && Notification.permission === 'default') {
      const permission = await Notification.requestPermission()
      return permission === 'granted'
    }
    return Notification.permission === 'granted'
  }
}

/**
 * Mostrar notificación con sonido personalizado
 */
export async function showNotification({ title, body, sound = true, urgent = false }) {
  if (Capacitor.isNativePlatform()) {
    try {
      await LocalNotifications.schedule({
        notifications: [
          {
            id: Date.now(),
            title: title,
            body: body,
            sound: sound ? 'notification_sound.wav' : undefined,
            smallIcon: 'ic_launcher',
            largeIcon: 'ic_launcher',
            iconColor: urgent ? '#EF4444' : '#8B5CF6',
            channelId: urgent ? 'chronelia-urgent' : 'chronelia-general',
            extra: {
              timestamp: new Date().toISOString()
            }
          }
        ]
      })
      console.log('✅ Notificación enviada:', title)
    } catch (error) {
      console.error('❌ Error mostrando notificación:', error)
    }
  } else {
    // Web: Notificación del navegador
    if ('Notification' in window && Notification.permission === 'granted') {
      new Notification(title, {
        body: body,
        icon: '/logo.png',
        badge: '/logo.png',
        vibrate: urgent ? [200, 100, 200] : [100, 50, 100],
        requireInteraction: urgent
      })
    }
  }
}

/**
 * Crear canales de notificación (solo Android)
 */
export async function createNotificationChannels() {
  if (Capacitor.getPlatform() === 'android') {
    try {
      await LocalNotifications.createChannel({
        id: 'chronelia-general',
        name: 'Notificaciones Generales',
        description: 'Notificaciones del sistema Chronelia',
        importance: 3, // Default
        sound: 'notification_sound.wav',
        vibration: true
      })

      await LocalNotifications.createChannel({
        id: 'chronelia-urgent',
        name: 'Alertas Urgentes',
        description: 'Alertas de reservas por finalizar',
        importance: 5, // High
        sound: 'notification_sound.wav',
        vibration: true,
        lights: true,
        lightColor: '#EF4444'
      })

      console.log('✅ Canales de notificación creados')
    } catch (error) {
      console.error('❌ Error creando canales:', error)
    }
  }
}

/**
 * Notificación de reserva por finalizar (5 minutos)
 */
export async function notifyReservationEnding(clientName) {
  await showNotification({
    title: '⏰ Chronelia - Alerta de Reserva',
    body: `${clientName}: Quedan 5 minutos para finalizar`,
    sound: true,
    urgent: true
  })
}

/**
 * Notificación de reserva finalizada
 */
export async function notifyReservationFinished(clientName) {
  await showNotification({
    title: '⏱️ Chronelia - Tiempo Agotado',
    body: `${clientName}: El tiempo ha finalizado`,
    sound: true,
    urgent: true
  })
}







