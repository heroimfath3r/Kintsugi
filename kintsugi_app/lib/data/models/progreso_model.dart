// Reemplaza TODO el contenido de:
// lib/data/models/progreso_model.dart

class ProgresoModel {
  final int xp;
  final int fase;
  final int racha;
  final int misionesCompletadas;
  final int xpSiguienteFase;

  const ProgresoModel({
    this.xp = 0,
    this.fase = 1,
    this.racha = 0,
    this.misionesCompletadas = 0,
    this.xpSiguienteFase = 100,
  });

  factory ProgresoModel.fromJson(Map<String, dynamic> json) {
    int xpNext = 100;
    if (json['siguienteFase'] is Map) {
      xpNext = json['siguienteFase']['xpNecesario'] ?? 100;
    }
    return ProgresoModel(
      xp: _parseInt(json['xp']),
      fase: _parseInt(json['fase'], defaultValue: 1),
      racha: _parseInt(json['racha']),
      misionesCompletadas: _parseInt(json['misionesCompletadas']),
      xpSiguienteFase: xpNext,
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
}

/// Modelo del resumen semanal.
/// La API devuelve checkins y misiones como listas separadas.
/// Este modelo las combina en una lista de 7 días (Lun-Dom)
/// para que la UI pueda renderizar los círculos fácilmente.
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
    // La API devuelve: { checkins: [...], misiones: [...], estadoFrecuente, ... }
    final checkins = (json['checkins'] as List?) ?? [];
    final misiones = (json['misiones'] as List?) ?? [];

    // Construir mapa de misiones completadas por fecha (YYYY-MM-DD)
    final misionesMap = <String, bool>{};
    for (final m in misiones) {
      if (m is Map<String, dynamic>) {
        final fecha = _extraerFecha(m['fecha']?.toString() ?? '');
        misionesMap[fecha] = m['completada'] == true;
      }
    }

    // Construir mapa de check-ins por fecha (YYYY-MM-DD)
    final checkinsMap = <String, String>{};
    for (final c in checkins) {
      if (c is Map<String, dynamic>) {
        final fecha = _extraerFecha(c['fecha']?.toString() ?? '');
        checkinsMap[fecha] = c['estadoEmocional']?.toString() ?? '';
      }
    }

    // Generar los 7 días de la semana actual (Lun a Dom)
    final now = DateTime.now();
    // weekday: 1=Lun, 7=Dom
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

    // Contar días activos (días con check-in)
    final diasActivos = dias.where((d) => d.estadoEmocional != null).length;

    return ProgresoWeeklyModel(
      estadoMasFrecuente: json['estadoFrecuente']?.toString() ?? '',
      misionesCompletadas: json['misionesCompletadas'] ?? 0,
      diasActivos: diasActivos,
      dias: dias,
    );
  }

  /// Extrae YYYY-MM-DD de un string ISO datetime.
  static String _extraerFecha(String isoString) {
    if (isoString.length >= 10) {
      return isoString.substring(0, 10);
    }
    return isoString;
  }

  /// Formatea un DateTime como YYYY-MM-DD.
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