// lib/data/models/progreso_model.dart

class ProgresoModel {
  final int xp;
  final int fase;
  final int racha;
  final int misionesCompletadas;
  final int xpSiguienteFase;

  // HU-14: lista legada de nombres de hitos (se mantiene por compatibilidad).
  final List<String> hitosDesbloqueados;

  // HU-14: catálogo de hitos con estado, calculado por el backend.
  // La UI solo pinta esto; no decide qué está desbloqueado.
  final List<HitoModel> hitos;

  // Aliases del checklist HU-14
  int get puntosAcumulados => xp;
  int get faseVisualActual => fase;
  int get rachaActual => racha;

  // Conteo derivado de hitos efectivamente desbloqueados.
  int get totalHitosDesbloqueados =>
      hitos.where((h) => h.desbloqueado).length;

  const ProgresoModel({
    this.xp = 0,
    this.fase = 1,
    this.racha = 0,
    this.misionesCompletadas = 0,
    this.xpSiguienteFase = 100,
    this.hitosDesbloqueados = const [],
    this.hitos = const [],
  });

  factory ProgresoModel.fromJson(Map<String, dynamic> json) {
    int xpNext = 100;
    if (json['siguienteFase'] is Map) {
      xpNext = json['siguienteFase']['xpNecesario'] ?? 100;
    }

    // Compatibilidad: lista legada de nombres (si el backend aún la manda).
    final hitosRaw = json['hitosDesbloqueados'];
    final List<String> hitosLegado = [];
    if (hitosRaw is List) {
      for (final h in hitosRaw) {
        if (h is String) {
          hitosLegado.add(h);
        } else if (h is Map) {
          hitosLegado.add(h['nombre']?.toString() ?? h['id']?.toString() ?? '');
        }
      }
    }

    // HU-14: catálogo de hitos con estado (nuevo formato del backend).
    final hitosCatalogoRaw = json['hitos'];
    final List<HitoModel> hitosCatalogo = [];
    if (hitosCatalogoRaw is List) {
      for (final h in hitosCatalogoRaw) {
        if (h is Map<String, dynamic>) {
          hitosCatalogo.add(HitoModel.fromJson(h));
        }
      }
    }

    return ProgresoModel(
      xp: _parseInt(json['xp']),
      fase: _parseInt(json['fase'], defaultValue: 1),
      racha: _parseInt(json['racha']),
      misionesCompletadas: _parseInt(json['misionesCompletadas']),
      xpSiguienteFase: xpNext,
      hitosDesbloqueados: hitosLegado,
      hitos: hitosCatalogo,
    );
  }

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  double get progresoPorcentaje {
    if (xpSiguienteFase <= 0) return 1.0;
    return (xp / xpSiguienteFase).clamp(0.0, 1.0);
  }

  String get faseLabel => 'Fase $fase';

  ProgresoModel copyWith({
    int? xp,
    int? fase,
    int? racha,
    int? misionesCompletadas,
    int? xpSiguienteFase,
    List<String>? hitosDesbloqueados,
    List<HitoModel>? hitos,
  }) {
    return ProgresoModel(
      xp: xp ?? this.xp,
      fase: fase ?? this.fase,
      racha: racha ?? this.racha,
      misionesCompletadas: misionesCompletadas ?? this.misionesCompletadas,
      xpSiguienteFase: xpSiguienteFase ?? this.xpSiguienteFase,
      hitosDesbloqueados: hitosDesbloqueados ?? this.hitosDesbloqueados,
      hitos: hitos ?? this.hitos,
    );
  }
}

/// HU-14: representa un hito del catálogo con su estado para el usuario.
/// Los datos vienen del backend (Firestore catalogo_hitos + cálculo de estado).
/// La UI solo pinta; no decide qué está desbloqueado.
class HitoModel {
  final String id;
  final String nombre;
  final String emoji;
  final int misionesRequeridas;
  final String imagenUrl;
  final bool desbloqueado;

  const HitoModel({
    required this.id,
    required this.nombre,
    required this.emoji,
    required this.misionesRequeridas,
    required this.imagenUrl,
    required this.desbloqueado,
  });

  factory HitoModel.fromJson(Map<String, dynamic> json) {
    return HitoModel(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      emoji: json['emoji']?.toString() ?? '🏅',
      misionesRequeridas: ProgresoModel._parseInt(json['misionesRequeridas']),
      imagenUrl: json['imagenUrl']?.toString() ?? '',
      desbloqueado: json['desbloqueado'] == true,
    );
  }
}

class ProgresoWeeklyModel {
  final String estadoMasFrecuente;
  final int misionesCompletadas;
  final int diasActivos;
  final List<CheckinDiaModel> dias;

  const ProgresoWeeklyModel({
    this.estadoMasFrecuente = '',
    this.misionesCompletadas = 0,
    this.diasActivos = 0,
    this.dias = const [],
  });

  factory ProgresoWeeklyModel.fromJson(Map<String, dynamic> json) {
    final checkins = (json['checkins'] as List?) ?? [];
    final misiones = (json['misiones'] as List?) ?? [];

    final misionesMap = <String, bool>{};
    for (final m in misiones) {
      if (m is Map<String, dynamic>) {
        final fecha = _extraerFecha(m['fecha']?.toString() ?? '');
        misionesMap[fecha] = m['completada'] == true;
      }
    }

    final checkinsMap = <String, String>{};
    for (final c in checkins) {
      if (c is Map<String, dynamic>) {
        final fecha = _extraerFecha(c['fecha']?.toString() ?? '');
        checkinsMap[fecha] = c['estadoEmocional']?.toString() ?? '';
      }
    }

    final now = DateTime.now();
    final lunes = now.subtract(Duration(days: now.weekday - 1));
    final dias = List.generate(7, (i) {
      final dia = lunes.add(Duration(days: i));
      final fechaKey = _formatFecha(dia);
      return CheckinDiaModel(
        fecha: fechaKey,
        estadoEmocional: checkinsMap[fechaKey],
        misionCompletada: misionesMap[fechaKey] ?? false,
      );
    });

    final diasActivos = dias.where((d) => d.estadoEmocional != null).length;

    return ProgresoWeeklyModel(
      estadoMasFrecuente: json['estadoFrecuente']?.toString() ?? '',
      misionesCompletadas: json['misionesCompletadas'] ?? 0,
      diasActivos: diasActivos,
      dias: dias,
    );
  }

  static String _extraerFecha(String isoString) {
    if (isoString.length >= 10) return isoString.substring(0, 10);
    return isoString;
  }

  static String _formatFecha(DateTime fecha) {
    final y = fecha.year.toString().padLeft(4, '0');
    final m = fecha.month.toString().padLeft(2, '0');
    final d = fecha.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

class CheckinDiaModel {
  final String fecha;
  final String? estadoEmocional;
  final bool misionCompletada;

  const CheckinDiaModel({
    required this.fecha,
    this.estadoEmocional,
    this.misionCompletada = false,
  });

  factory CheckinDiaModel.fromJson(Map<String, dynamic> json) {
    return CheckinDiaModel(
      fecha: json['fecha']?.toString() ?? '',
      estadoEmocional: json['estadoEmocional']?.toString(),
      misionCompletada: json['misionCompletada'] == true,
    );
  }
}