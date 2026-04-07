# Kintsugi — App Flutter de hábitos para Gen Z

## Qué es
App móvil Flutter para desarrollo de hábitos mediante
narrativa adaptativa y arquetipos de anime.

## Lee estos archivos antes de escribir código
1. .claude/architecture.md
2. .claude/entities.md
3. .claude/features/ (el que corresponda a la tarea)

## Stack
- Flutter + Dart + BLoC
- Firebase Auth + Firestore + FCM
- Hive (offline-first)
- get_it (inyección de dependencias)
- connectivity_plus

## Design System
- Fondo: #0D0D0D
- Acento dorado: #C9A84C
- Texto principal: #F5F5F0
- Texto secundario: #9E9E9E
- Error: #CF6679
- Éxito: #4CAF7D
- Fuentes: Cinzel (títulos) + Inter (cuerpo)
- Material Design 3

## Colores emocionales
- frustracion: #EF5350
- vacio: #5C6BC0
- motivacion: #FFB300
- calma: #26A69A
- ansiedad: #AB47BC

## Reglas de negocio críticas
- Contraseña: mínimo 8 caracteres, 1 mayúscula, 1 número
- Check-in: máximo 3 interacciones, menos de 30 segundos
- Motor de recomendación responde en menos de 2 segundos
- Fallback local si motor tarda más de 2 segundos
- Misión expira después de 48 horas sin interacción
- Nunca penalizar al usuario por inactividad
- Racha se afecta solo por misiones EXPIRADAS
- Sin recuperación de contraseña en esta versión