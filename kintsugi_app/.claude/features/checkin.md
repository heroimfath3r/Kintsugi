# Feature: Check-in Diario

## HU-06 Registro del estado emocional
### Criterios técnicos
- Exactamente 5 opciones visuales como cards verticales
- Cada card: emoji + nombre + descripción corta
- Card seleccionada: borde dorado #C9A84C
- Al seleccionar → guardar en Hive INMEDIATAMENTE
- Luego llamar motor de recomendación (timeout 2s)
- Si timeout → usar misión del catálogo local Hive
- Solo 1 check-in por día permitido
- Si ya existe check-in del día → mostrar estado actual
- El registro incluye: estadoEmocional, timestamp, uid

## HU-07 Check-in offline
### Criterios técnicos
- BLoC detecta offline con connectivity_plus
- Escribe directo a Hive sin intentar red
- Indicador sutil de pendiente de sincronización
- Al reconectar → SyncManager sincroniza automático
- Deduplicación por timestamp antes de escribir Firestore

## HU-08 Contexto narrativo post check-in
### Criterios técnicos
- Fragmento narrativo específico por estado emocional
- Máximo 3 líneas de texto
- Si motor tarda más de 2s