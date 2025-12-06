// Sistema de Recomendaciones con IA para chronelia.
// Analiza datos y genera insights inteligentes

/**
 * Genera recomendaciones inteligentes basadas en las estadísticas de la app
 */
export function generateRecommendations(store) {
  const {
    activeReservations,
    reservationHistory,
    todayStats,
    workers,
    user,
  } = store

  const recommendations = []
  const now = new Date()
  const currentHour = now.getHours()
  const currentDay = now.getDay() // 0 = Domingo, 6 = Sábado

  // 1. ANÁLISIS DE CAPACIDAD ACTUAL
  const activeCount = activeReservations.length
  const activeWorkers = workers.filter(w => w.active).length
  
  if (activeCount === 0 && currentHour >= 9 && currentHour <= 20) {
    recommendations.push({
      id: 'no-reservations',
      type: 'alert',
      priority: 'high',
      category: 'demanda',
      icon: '🚨',
      title: 'Sin clientes activos',
      description: 'No hay reservas activas en este momento. Considera enviar una promoción flash.',
      action: 'Crear Promoción',
      actionType: 'promotion',
      insights: [
        'Hora actual: ' + formatHour(currentHour),
        'Trabajadores disponibles: ' + activeWorkers,
        'Potencial de ingresos perdido: $' + (activeWorkers * 25)
      ]
    })
  }

  if (activeCount > activeWorkers && activeCount > 3) {
    recommendations.push({
      id: 'capacity-warning',
      type: 'warning',
      priority: 'high',
      category: 'capacidad',
      icon: '⚠️',
      title: 'Capacidad al límite',
      description: `Tienes ${activeCount} clientes activos con solo ${activeWorkers} trabajadores. Considera activar más personal.`,
      action: 'Ver Trabajadores',
      actionType: 'workers',
      insights: [
        `Ratio cliente/trabajador: ${(activeCount / activeWorkers).toFixed(1)}:1`,
        'Riesgo de tiempos de espera largos',
        'Experiencia del cliente podría verse afectada'
      ]
    })
  }

  // 2. ANÁLISIS DE RENDIMIENTO DEL DÍA
  if (todayStats.completedReservations > 0) {
    const avgMinutes = Math.floor(todayStats.averageDuration / 60)
    
    if (avgMinutes > 45) {
      recommendations.push({
        id: 'long-durations',
        type: 'insight',
        priority: 'medium',
        category: 'eficiencia',
        icon: '⏱️',
        title: 'Servicios más largos de lo esperado',
        description: `El tiempo promedio es ${avgMinutes} minutos. Identifica si hay retrasos o servicios complejos.`,
        action: 'Ver Historial',
        actionType: 'history',
        insights: [
          `Promedio hoy: ${avgMinutes} min`,
          `Total completadas: ${todayStats.completedReservations}`,
          'Optimizar procesos podría aumentar capacidad en 20%'
        ]
      })
    }

    if (todayStats.completedReservations >= 10) {
      recommendations.push({
        id: 'great-day',
        type: 'success',
        priority: 'low',
        category: 'rendimiento',
        icon: '🎉',
        title: '¡Excelente día de trabajo!',
        description: `Has completado ${todayStats.completedReservations} reservas hoy. El equipo está haciendo un gran trabajo.`,
        action: 'Ver Estadísticas',
        actionType: 'stats',
        insights: [
          `Tiempo total: ${Math.floor(todayStats.totalTime / 60)} minutos`,
          `Promedio por servicio: ${avgMinutes} min`,
          `Proyección diaria: ${Math.round(todayStats.completedReservations * 1.3)} reservas`
        ]
      })
    }
  }

  // 3. ANÁLISIS DE HORARIOS Y PATRONES
  const hourRecommendation = getHourBasedRecommendation(currentHour, currentDay, activeCount)
  if (hourRecommendation) {
    recommendations.push(hourRecommendation)
  }

  // 4. ANÁLISIS DE TRABAJADORES
  if (activeWorkers < workers.length) {
    const inactiveWorkers = workers.filter(w => !w.active)
    recommendations.push({
      id: 'inactive-workers',
      type: 'info',
      priority: 'low',
      category: 'personal',
      icon: '👥',
      title: 'Personal inactivo disponible',
      description: `Tienes ${inactiveWorkers.length} trabajador(es) marcado(s) como inactivo. Actívalos si están disponibles.`,
      action: 'Gestionar Personal',
      actionType: 'workers',
      insights: [
        `Activos: ${activeWorkers} de ${workers.length}`,
        'Personal disponible para activar: ' + inactiveWorkers.map(w => w.name).join(', '),
        'Aumentar capacidad sin contratar'
      ]
    })
  }

  // 5. ANÁLISIS DE HISTORIAL RECIENTE
  if (reservationHistory.length > 0) {
    const recentReservations = reservationHistory.slice(0, 10)
    const uniqueClients = new Set(recentReservations.map(r => r.clientEmail)).size
    
    if (uniqueClients < recentReservations.length * 0.3) {
      recommendations.push({
        id: 'client-retention',
        type: 'success',
        priority: 'medium',
        category: 'clientes',
        icon: '💎',
        title: 'Alta tasa de clientes recurrentes',
        description: `${Math.round((1 - uniqueClients / recentReservations.length) * 100)}% de tus últimas reservas son clientes que regresan.`,
        action: 'Ver Historial',
        actionType: 'history',
        insights: [
          `Clientes únicos: ${uniqueClients}`,
          `Total reservas recientes: ${recentReservations.length}`,
          'Tu servicio está generando lealtad ✨'
        ]
      })
    }
  }

  // 6. RECOMENDACIONES URGENTES (Tiempo bajo)
  const urgentReservations = activeReservations.filter(r => r.remainingTime <= 300 && r.remainingTime > 0)
  if (urgentReservations.length > 0) {
    recommendations.push({
      id: 'urgent-clients',
      type: 'alert',
      priority: 'critical',
      category: 'urgente',
      icon: '🔔',
      title: `${urgentReservations.length} cliente(s) por terminar`,
      description: 'Algunos clientes tienen menos de 5 minutos. Prepara el proceso de finalización.',
      action: 'Ver Dashboard',
      actionType: 'dashboard',
      insights: urgentReservations.map(r => 
        `${r.clientName}: ${Math.floor(r.remainingTime / 60)} min restantes`
      )
    })
  }

  // 7. PREDICCIÓN Y SUGERENCIAS
  if (reservationHistory.length >= 5) {
    const prediction = predictNextBooking(reservationHistory, currentHour, currentDay)
    if (prediction) {
      recommendations.push(prediction)
    }
  }

  // 8. CONSEJOS GENERALES - GARANTIZAR MÍNIMO 5 RECOMENDACIONES
  const allTips = getAllTips()
  
  // Agregar consejos hasta tener al menos 5 recomendaciones
  while (recommendations.length < 5 && allTips.length > 0) {
    const randomIndex = Math.floor(Math.random() * allTips.length)
    const tip = allTips[randomIndex]
    
    // Evitar duplicados por ID
    if (!recommendations.find(r => r.id === tip.id)) {
      recommendations.push(tip)
    }
    
    // Remover el consejo usado para evitar loop infinito
    allTips.splice(randomIndex, 1)
  }

  // Ordenar por prioridad
  const priorityOrder = { critical: 0, high: 1, medium: 2, low: 3 }
  return recommendations.sort((a, b) => 
    priorityOrder[a.priority] - priorityOrder[b.priority]
  )
}

/**
 * Recomendaciones basadas en la hora del día
 */
function getHourBasedRecommendation(hour, day, activeCount) {
  // Mañana (6-12)
  if (hour >= 6 && hour < 12) {
    if (activeCount === 0) {
      return {
        id: 'morning-promo',
        type: 'suggestion',
        priority: 'medium',
        category: 'marketing',
        icon: '☀️',
        title: 'Oportunidad de promoción matutina',
        description: 'Las mañanas suelen ser tranquilas. Considera ofrecer un descuento del 15% para atraer clientes.',
        action: 'Crear Promoción',
        actionType: 'promotion',
        insights: [
          'Horario ideal para clientes madrugadores',
          'Menos competencia de otros negocios',
          'Cliente matutino suele ser más puntual'
        ]
      }
    }
  }

  // Mediodía (12-14)
  if (hour >= 12 && hour < 14) {
    return {
      id: 'lunch-time',
      type: 'info',
      priority: 'low',
      category: 'horario',
      icon: '🍽️',
      title: 'Hora de almuerzo',
      description: 'Es hora de almuerzo. Considera turnos rotativos para mantener cobertura.',
      action: null,
      actionType: null,
      insights: [
        'Mantén al menos 1-2 trabajadores activos',
        'Planifica pausas escalonadas',
        'Evita reservas muy largas en este horario'
      ]
    }
  }

  // Tarde-noche (17-21) - Horario PICO
  if (hour >= 17 && hour <= 21 && activeCount < 3) {
    return {
      id: 'peak-hours',
      type: 'warning',
      priority: 'high',
      category: 'demanda',
      icon: '🌆',
      title: 'Horario pico con baja demanda',
      description: 'Este suele ser un horario de alta demanda. Considera promocionar para llenarlo.',
      action: 'Enviar Recordatorios',
      actionType: 'marketing',
      insights: [
        'Horario típico de salida del trabajo',
        'Mayor disponibilidad de clientes',
        'Oportunidad de maximizar ingresos'
      ]
    }
  }

  // Fin de semana (Sábado/Domingo)
  if ((day === 0 || day === 6) && activeCount === 0) {
    return {
      id: 'weekend-opportunity',
      type: 'suggestion',
      priority: 'high',
      category: 'demanda',
      icon: '🎯',
      title: 'Fin de semana sin reservas',
      description: 'Los fines de semana suelen tener alta demanda. Promociona activamente en redes sociales.',
      action: 'Estrategia Marketing',
      actionType: 'marketing',
      insights: [
        'Clientes tienen más tiempo libre',
        'Menor presión de horarios',
        'Ideal para servicios más largos'
      ]
    }
  }

  return null
}

/**
 * Predice próxima reserva basado en patrones históricos
 */
function predictNextBooking(history, currentHour, currentDay) {
  if (history.length < 5) return null

  // Analizar reservas por hora
  const bookingsByHour = {}
  history.forEach(booking => {
    const hour = new Date(booking.startTime).getHours()
    bookingsByHour[hour] = (bookingsByHour[hour] || 0) + 1
  })

  // Encontrar hora con más reservas
  const peakHour = Object.entries(bookingsByHour)
    .sort((a, b) => b[1] - a[1])[0]

  if (peakHour && parseInt(peakHour[0]) > currentHour) {
    return {
      id: 'prediction',
      type: 'insight',
      priority: 'medium',
      category: 'predicción',
      icon: '🔮',
      title: 'Predicción de demanda',
      description: `Basado en tu historial, espera más reservas alrededor de las ${peakHour[0]}:00.`,
      action: 'Ver Estadísticas',
      actionType: 'stats',
      insights: [
        `Hora pico típica: ${peakHour[0]}:00`,
        `Frecuencia: ${peakHour[1]} reservas históricas`,
        'Prepara al equipo con anticipación'
      ]
    }
  }

  return null
}

/**
 * Obtiene TODOS los consejos disponibles
 */
function getAllTips() {
  return [
    {
      id: 'general-1',
      type: 'tip',
      priority: 'low',
      category: 'mejora',
      icon: '💡',
      title: 'Consejo: Comunicación proactiva',
      description: 'Envía recordatorios a tus clientes 24h antes de su cita para reducir no-shows.',
      action: 'Configurar Recordatorios',
      actionType: 'settings',
      insights: [
        'Reduce cancelaciones hasta 40%',
        'Mejora experiencia del cliente',
        'Mantiene tu agenda completa'
      ]
    },
    {
      id: 'general-2',
      type: 'tip',
      priority: 'low',
      category: 'mejora',
      icon: '⭐',
      title: 'Consejo: Solicita reseñas',
      description: 'Después de cada servicio, pide a tus clientes que dejen una reseña. Aumenta tu visibilidad.',
      action: 'Sistema de Reseñas',
      actionType: 'settings',
      insights: [
        'Reseñas positivas aumentan conversión',
        'Feedback ayuda a mejorar servicio',
        'Clientes satisfechos son embajadores'
      ]
    },
    {
      id: 'general-3',
      type: 'tip',
      priority: 'low',
      category: 'mejora',
      icon: '📊',
      title: 'Consejo: Analiza tus datos',
      description: 'Revisa regularmente tus estadísticas para identificar patrones y oportunidades.',
      action: 'Ver Estadísticas',
      actionType: 'stats',
      insights: [
        'Identifica horas de baja demanda',
        'Detecta servicios más populares',
        'Optimiza asignación de personal'
      ]
    },
    {
      id: 'general-4',
      type: 'tip',
      priority: 'low',
      category: 'mejora',
      icon: '🎁',
      title: 'Consejo: Programa de lealtad',
      description: 'Considera implementar un programa de puntos para clientes recurrentes.',
      action: 'Ideas de Lealtad',
      actionType: 'settings',
      insights: [
        'Aumenta retención de clientes',
        'Mayor valor de vida del cliente',
        'Diferenciación de competencia'
      ]
    },
    {
      id: 'general-5',
      type: 'tip',
      priority: 'low',
      category: 'mejora',
      icon: '📱',
      title: 'Consejo: Presencia en redes sociales',
      description: 'Comparte fotos de antes/después (con permiso) para atraer más clientes.',
      action: 'Marketing Digital',
      actionType: 'settings',
      insights: [
        'Contenido visual genera más engagement',
        'Muestra la calidad de tu trabajo',
        'Atrae clientes potenciales orgánicamente'
      ]
    },
    {
      id: 'general-6',
      type: 'tip',
      priority: 'low',
      category: 'mejora',
      icon: '🎯',
      title: 'Consejo: Especialización de servicios',
      description: 'Identifica tu servicio estrella y conviértelo en tu diferenciador competitivo.',
      action: 'Analizar Servicios',
      actionType: 'stats',
      insights: [
        'Especialización aumenta reputación',
        'Permite cobrar precios premium',
        'Facilita el marketing focalizado'
      ]
    },
    {
      id: 'general-7',
      type: 'tip',
      priority: 'low',
      category: 'mejora',
      icon: '🕒',
      title: 'Consejo: Gestión de tiempos muertos',
      description: 'Usa los espacios sin clientes para capacitación del equipo o mejoras del local.',
      action: 'Optimizar Tiempos',
      actionType: 'settings',
      insights: [
        'Maximiza productividad del día',
        'Mejora continua del equipo',
        'Invierte en el negocio constantemente'
      ]
    },
    {
      id: 'general-8',
      type: 'tip',
      priority: 'low',
      category: 'mejora',
      icon: '💰',
      title: 'Consejo: Estrategia de precios dinámicos',
      description: 'Considera precios diferenciados por horario para equilibrar la demanda.',
      action: 'Revisar Precios',
      actionType: 'settings',
      insights: [
        'Horarios de baja demanda: precios reducidos',
        'Horarios pico: precios regulares o premium',
        'Maximiza ocupación y rentabilidad'
      ]
    },
    {
      id: 'general-9',
      type: 'tip',
      priority: 'low',
      category: 'mejora',
      icon: '🤝',
      title: 'Consejo: Alianzas estratégicas',
      description: 'Forma alianzas con negocios complementarios para referencias cruzadas.',
      action: 'Networking',
      actionType: 'settings',
      insights: [
        'Amplía tu base de clientes',
        'Sin costo de marketing adicional',
        'Fortalece relaciones empresariales'
      ]
    },
    {
      id: 'general-10',
      type: 'tip',
      priority: 'low',
      category: 'mejora',
      icon: '🎓',
      title: 'Consejo: Capacitación continua',
      description: 'Invierte en cursos y certificaciones para tu equipo. La calidad es tu mejor publicidad.',
      action: 'Plan de Capacitación',
      actionType: 'workers',
      insights: [
        'Mejora la calidad del servicio',
        'Aumenta la satisfacción del equipo',
        'Justifica precios más altos'
      ]
    }
  ]
}

/**
 * Formatea hora en formato 12h
 */
function formatHour(hour) {
  const period = hour >= 12 ? 'PM' : 'AM'
  const hour12 = hour > 12 ? hour - 12 : hour === 0 ? 12 : hour
  return `${hour12}:00 ${period}`
}

/**
 * Obtiene el color según el tipo de recomendación
 */
export function getRecommendationColor(type) {
  const colors = {
    alert: 'border-red-500 bg-red-50 dark:bg-red-950',
    warning: 'border-orange-500 bg-orange-50 dark:bg-orange-950',
    success: 'border-green-500 bg-green-50 dark:bg-green-950',
    info: 'border-blue-500 bg-blue-50 dark:bg-blue-950',
    insight: 'border-purple-500 bg-purple-50 dark:bg-purple-950',
    suggestion: 'border-pink-500 bg-pink-50 dark:bg-pink-950',
    tip: 'border-gray-500 bg-gray-50 dark:bg-gray-950'
  }
  return colors[type] || colors.info
}

/**
 * Obtiene el badge según la prioridad
 */
export function getPriorityBadge(priority) {
  const badges = {
    critical: { label: 'Crítico', class: 'bg-red-500 text-white' },
    high: { label: 'Alta', class: 'bg-orange-500 text-white' },
    medium: { label: 'Media', class: 'bg-blue-500 text-white' },
    low: { label: 'Baja', class: 'bg-gray-500 text-white' }
  }
  return badges[priority] || badges.low
}


