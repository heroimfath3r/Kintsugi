// lib/data/local/local_storage_service.dart

import 'package:hive/hive.dart';
import 'hive_boxes.dart';

/// Servicio de almacenamiento local con Hive.
/// Proporciona operaciones CRUD sobre las cajas y maneja
/// la cola de sincronización para operaciones offline.
class LocalStorageService {
  // ── Perfil ──────────────────────────────────────────────────────────

  /// Guarda el perfil del usuario como cache.
  Future<void> guardarPerfil(Map<String, dynamic> data) async {
    final box = Hive.box(HiveBoxes.perfil);
    await box.put('current', data);
  }

  /// Lee el perfil cacheado. Retorna null si no hay cache.
  Map<String, dynamic>? obtenerPerfil() {
    final box = Hive.box(HiveBoxes.perfil);
    final data = box.get('current');
    if (data == null) return null;
    return Map<String, dynamic>.from(data as Map);
  }

  /// Limpia el perfil cacheado (al cerrar sesión).
  Future<void> limpiarPerfil() async {
    final box = Hive.box(HiveBoxes.perfil);
    await box.clear();
  }

  // ── Check-ins ───────────────────────────────────────────────────────

  /// Guarda un check-in localmente.
  /// [fecha] es la clave en formato YYYY-MM-DD.
  /// [sincronizado] indica si ya se envió a la API.
  Future<void> guardarCheckin(
      String fecha, Map<String, dynamic> data, bool sincronizado) async {
    final box = Hive.box(HiveBoxes.checkins);
    data['_sincronizado'] = sincronizado;
    data['_fecha_key'] = fecha;
    await box.put(fecha, data);
  }

  /// Lee el check-in de una fecha específica.
  Map<String, dynamic>? obtenerCheckin(String fecha) {
    final box = Hive.box(HiveBoxes.checkins);
    final data = box.get(fecha);
    if (data == null) return null;
    return Map<String, dynamic>.from(data as Map);
  }

  /// Lee el check-in de hoy.
  Map<String, dynamic>? obtenerCheckinHoy() {
    final hoy = _fechaHoy();
    return obtenerCheckin(hoy);
  }

  /// Obtiene todos los check-ins no sincronizados.
  List<Map<String, dynamic>> obtenerCheckinsPendientes() {
    final box = Hive.box(HiveBoxes.checkins);
    final pendientes = <Map<String, dynamic>>[];
    for (final key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        final map = Map<String, dynamic>.from(data as Map);
        if (map['_sincronizado'] != true) {
          pendientes.add(map);
        }
      }
    }
    // Ordenar cronológicamente
    pendientes.sort((a, b) =>
        (a['_fecha_key'] ?? '').compareTo(b['_fecha_key'] ?? ''));
    return pendientes;
  }

  /// Marca un check-in como sincronizado.
  Future<void> marcarCheckinSincronizado(String fecha) async {
    final box = Hive.box(HiveBoxes.checkins);
    final data = box.get(fecha);
    if (data != null) {
      final map = Map<String, dynamic>.from(data as Map);
      map['_sincronizado'] = true;
      await box.put(fecha, map);
    }
  }

  // ── Misiones ────────────────────────────────────────────────────────

  /// Guarda la misión del día localmente.
  Future<void> guardarMision(
      String fecha, Map<String, dynamic> data, bool sincronizado) async {
    final box = Hive.box(HiveBoxes.misiones);
    data['_sincronizado'] = sincronizado;
    data['_fecha_key'] = fecha;
    await box.put(fecha, data);
  }

  /// Lee la misión de una fecha específica.
  Map<String, dynamic>? obtenerMision(String fecha) {
    final box = Hive.box(HiveBoxes.misiones);
    final data = box.get(fecha);
    if (data == null) return null;
    return Map<String, dynamic>.from(data as Map);
  }

  /// Lee la misión de hoy.
  Map<String, dynamic>? obtenerMisionHoy() {
    final hoy = _fechaHoy();
    return obtenerMision(hoy);
  }

  /// Marca la misión de hoy como completada localmente.
  /// [sincronizado] indica si ya se envió a la API.
  Future<void> completarMisionLocal(String fecha, bool sincronizado) async {
    final box = Hive.box(HiveBoxes.misiones);
    final data = box.get(fecha);
    if (data != null) {
      final map = Map<String, dynamic>.from(data as Map);
      map['completada'] = true;
      map['_sincronizado'] = sincronizado;
      await box.put(fecha, map);
    }
  }

  /// Obtiene misiones completadas pero no sincronizadas.
  List<Map<String, dynamic>> obtenerMisionesCompletadasPendientes() {
    final box = Hive.box(HiveBoxes.misiones);
    final pendientes = <Map<String, dynamic>>[];
    for (final key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        final map = Map<String, dynamic>.from(data as Map);
        if (map['completada'] == true && map['_sincronizado'] != true) {
          pendientes.add(map);
        }
      }
    }
    pendientes.sort((a, b) =>
        (a['_fecha_key'] ?? '').compareTo(b['_fecha_key'] ?? ''));
    return pendientes;
  }

  /// Marca una misión como sincronizada.
  Future<void> marcarMisionSincronizada(String fecha) async {
    final box = Hive.box(HiveBoxes.misiones);
    final data = box.get(fecha);
    if (data != null) {
      final map = Map<String, dynamic>.from(data as Map);
      map['_sincronizado'] = true;
      await box.put(fecha, map);
    }
  }

  /// Obtiene el historial de misiones guardadas localmente.
  List<Map<String, dynamic>> obtenerHistorialMisiones() {
    final box = Hive.box(HiveBoxes.misiones);
    final lista = <Map<String, dynamic>>[];
    for (final key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        lista.add(Map<String, dynamic>.from(data as Map));
      }
    }
    lista.sort((a, b) =>
        (b['_fecha_key'] ?? '').compareTo(a['_fecha_key'] ?? ''));
    return lista;
  }

  // ── Progreso ────────────────────────────────────────────────────────

  /// Guarda datos de progreso como cache.
  Future<void> guardarProgreso(Map<String, dynamic> data) async {
    final box = Hive.box(HiveBoxes.progreso);
    await box.put('current', data);
  }

  /// Lee el progreso cacheado.
  Map<String, dynamic>? obtenerProgreso() {
    final box = Hive.box(HiveBoxes.progreso);
    final data = box.get('current');
    if (data == null) return null;
    return Map<String, dynamic>.from(data as Map);
  }

  /// Guarda el resumen semanal como cache.
  Future<void> guardarResumenSemanal(Map<String, dynamic> data) async {
    final box = Hive.box(HiveBoxes.progreso);
    await box.put('weekly', data);
  }

  /// Lee el resumen semanal cacheado.
  Map<String, dynamic>? obtenerResumenSemanal() {
    final box = Hive.box(HiveBoxes.progreso);
    final data = box.get('weekly');
    if (data == null) return null;
    return Map<String, dynamic>.from(data as Map);
  }

  // ── Limpieza general (logout) ───────────────────────────────────────

  /// Limpia todos los datos locales. Se llama al cerrar sesión.
  Future<void> limpiarTodo() async {
    await Hive.box(HiveBoxes.perfil).clear();
    await Hive.box(HiveBoxes.checkins).clear();
    await Hive.box(HiveBoxes.misiones).clear();
    await Hive.box(HiveBoxes.progreso).clear();
    await Hive.box(HiveBoxes.syncQueue).clear();
  }

  // ── Helpers ─────────────────────────────────────────────────────────

  String _fechaHoy() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}