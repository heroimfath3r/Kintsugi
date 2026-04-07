# Entidades del Dominio

## Usuario
- uid: String
- nombre: String
- email: String
- arquetipoId: String
- nivelProgresion: int
- fechaRegistro: DateTime

## Arquetipo
- id: String (thorfinn, rocklee, ippo, mob, asta)
- nombre: String
- origen: String (nombre del anime)
- filosofia: String
- descripcionLucha: String
- colorPrimario: String (hex)
- faseActual: int (1, 2 o 3)

## Mision
- id: String
- arquetipoId: String
- titulo: String
- descripcion: String
- fragmentoNarrativo: String
- tipo: enum MisionTipo (reflexion, accion, respiracion)
- dificultad: int (1, 2, 3)
- estadoEmocional: enum EstadoEmocional
- estado: enum MisionEstado
- timestampAsignacion: DateTime?
- timestampCompletado: DateTime?
- puntos: int

## MisionEstado (enum)
disponible, asignada, enProgreso, 
completada, pospuesta, expirada

## MisionTipo (enum)
reflexion, accion, respiracion

## EstadoEmocional (enum)
frustracion, vacio, motivacion, calma, ansiedad

## RegistroEmocional
- id: String
- usuarioId: String
- estadoEmocional: EstadoEmocional
- timestamp: DateTime
- misionId: String?
- sincronizado: bool

## Progresion
- id: String
- usuarioId: String
- puntosAcumulados: int
- faseVisualActual: int (1, 2 o 3)
- rachaActual: int
- mejorRacha: int
- hitosDesbloqueados: List<String>
- ultimaActividad: DateTime

## Hito
- id: String
- nombre: String
- descripcion: String
- requisito: String
- puntosRequeridos: int
- icono: String

## Sistema de puntos
- Misión reflexión: 8 pts
- Misión acción: 12 pts
- Misión respiración: 5 pts
- Racha 7 días: +20 pts bonus
- Racha 14 días: +40 pts bonus
- Racha 30 días: +80 pts bonus

## Fases del avatar
- Fase 1: 0-99 puntos
- Fase 2: 100-299 puntos
- Fase 3: 300+ puntos