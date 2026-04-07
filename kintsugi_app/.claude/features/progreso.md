# Feature: Progreso Personal

## HU-16 Panel de progreso
### Criterios técnicos
- Línea de tiempo scrolleable agrupada por día
- Cada entrada: fecha + emoji estado emocional + misión
- Resumen semanal: estado más frecuente + misiones + racha
- Datos desde Hive local
- Si hay conexión → sync con Firestore antes de renderizar
- Con menos de 7 días → mostrar días disponibles sin error

## HU-17 Racha activa
### Criterios técnicos
- Contador visible en HOME (no solo en progreso)
- Se calcula desde Hive local (sin conexión)
- Al romperse → mensaje de reencuadre del arquetipo
- Sin palabras negativas en mensajes de racha rota