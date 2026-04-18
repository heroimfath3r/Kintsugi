# Kintsugi — App Flutter de hábitos para Gen Z

## Idioma
- Siempre responde en español.
- Nombres de variables, clases y funciones en inglés.
- Comentarios en el código en español.
- Commits en español.

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

## Estructura del proyecto
```
lib/
├── core/           # Tema, constantes, utilidades, rutas
├── data/           # Modelos, repositorios, datasources
├── domain/         # Entidades, casos de uso, interfaces
├── presentation/   # Pantallas, widgets, BLoCs
├── services/       # Firebase, Hive, notificaciones
└── main.dart
```

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

## Convenciones de código
- Usar BLoC para manejo de estado (no setState, no Provider)
- Nombres de BLoC events: verbo en pasado (e.g. LoginRequested, HabitCreated)
- Nombres de BLoC states: sustantivo + estado (e.g. LoginLoading, LoginSuccess, LoginFailure)
- Un archivo por clase
- Máximo 300 líneas por archivo; si crece, dividir
- Siempre usar const donde sea posible
- No usar print(), usar log() o debugPrint()
- Manejar errores con Either (dartz) o try/catch explícito
- Todo texto visible al usuario va en español

## Convenciones de nombres
- Archivos: snake_case (e.g. habit_repository.dart)
- Clases: PascalCase (e.g. HabitRepository)
- Variables y funciones: camelCase (e.g. getUserHabits)
- Constantes: kPascalCase (e.g. kPrimaryGold)
- BLoC: NombreBloc, NombreEvent, NombreState

## Testing
- Tests unitarios para BLoCs y repositorios
- Usar mocktail para mocks
- Nombrar tests en español describiendo el comportamiento esperado

## Git
- Commits en español, formato: "tipo: descripción"
- Tipos: feat, fix, refactor, docs, style, test, chore
- Ejemplo: "feat: agregar pantalla de check-in emocional"
- Una funcionalidad por commit

## Qué NO hacer
- No crear archivos fuera de lib/ sin preguntar
- No cambiar dependencias en pubspec.yaml sin confirmar
- No modificar configuración de Firebase sin avisar
- No borrar código comentado sin preguntar (puede ser WIP)
- No usar paquetes nuevos sin justificar por qué