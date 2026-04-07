# Feature: Notificaciones Inteligentes

## HU-26 Recordatorio check-in
### Criterios técnicos
- Enviar via FCM si no hay check-in antes de las 9am
- Verificar registro del día antes de disparar
- Texto usa tono narrativo del arquetipo del usuario
- Al tocar → deep link a pantalla de check-in
- Horario configurable desde preferencias (default 9am)

## HU-27 Racha en riesgo
### Criterios técnicos
- Solo si racha activa de mínimo 2 días consecutivos
- Solo si misión del día no completada
- Enviar antes de las 10pm
- Texto motivacional del arquetipo sin lenguaje punitivo
- Al tocar → deep link a misión del día

## HU-28 Bienvenida de retorno
### Criterios técnicos
- Detectar 48h de inactividad por timestamp local
- Mensaje específico del arquetipo al retornar
- Sin contador de días perdidos ni penalización visible
- Disponible en Hive para funcionar offline también
- Se muestra como pantalla intermedia antes del home

## HU-29 Preferencias de notificación
### Criterios técnicos
- Selector de hora (no campo de texto libre)
- Toggle independiente por tipo: check-in, racha, hitos
- Guardar en Firestore Y Hive local
- Cambios aplican inmediatamente sin reiniciar app
- Botón "Restaurar valores por defecto"

## HU-30 Notificación de hito desbloqueado
### Criterios técnicos
- Solo si usuario NO está usando la app activamente
- Si está en la app → mostrar animación en pantalla
- Texto incluye nombre del hito y fragmento del arquetipo
- Al tocar → deep link a pantalla del hito desbloqueado
- Desactivable independientemente desde preferencias