// lib/data/local/hive_boxes.dart

/// Nombres de las cajas de Hive.
/// Centralizados aquí para evitar typos y tener un solo lugar de referencia.
class HiveBoxes {
  HiveBoxes._();

  /// Perfil del usuario (cache).
  static const String perfil = 'perfil_box';

  /// Check-ins realizados (offline-first).
  /// Cada entrada tiene un campo 'sincronizado' (bool).
  static const String checkins = 'checkins_box';

  /// Misiones asignadas y su estado (offline-first).
  static const String misiones = 'misiones_box';

  /// Datos de progreso (cache).
  static const String progreso = 'progreso_box';

  /// Cola de operaciones pendientes de sincronización.
  /// Cada entrada describe una acción: { tipo, datos, timestamp }.
  static const String syncQueue = 'sync_queue_box';
}