# Feature: Misiones de Mundo Real

## HU-11 Visualizar misión diaria
### Criterios técnicos
- Mostrar primero fragmento narrativo (máx 3 líneas)
- Luego la tarea concreta
- La misión incluye: título, descripción, tipo, dificultad
- Si no hizo check-in → redirigir al check-in primero
- Catálogo cacheado en Hive desde primer login
- Misión cambia estado a ASIGNADA al mostrarse

## HU-12 Completar misión
### Criterios técnicos
- Botón "Completar misión" claro y accesible
- Al completar → animación de celebración no intrusiva
- Actualizar progresión localmente SIN esperar servidor
- Evaluar si se desbloquea hito después de completar
- Botón se deshabilita tras presionarlo (evitar doble tap)
- Historial registra: misionId, timestamp, 
  estadoEmocional del día, arquetipoActivo

## HU-13 Reencuadre positivo
### Criterios técnicos
- Si mis