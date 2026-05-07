class ProgresoModel {
  final int xp;
  final int fase;
  final int racha;
  final int misionesCompletadas;
  final int xpSiguienteFase;

  const ProgresoModel({this.xp = 0, this.fase = 1, this.racha = 0, this.misionesCompletadas = 0, this.xpSiguienteFase = 100});

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

class ProgresoWeeklyModel {
  final String estadoMasFrecuente;
  final int misionesCompletadas;
  final int diasActivos;
  final List<CheckinDiaModel> dias;

  const ProgresoWeeklyModel({this.estadoMasFrecuente = '', this.misionesCompletadas = 0, this.diasActivos = 0, this.dias = const []});

  factory ProgresoWeeklyModel.fromJson(Map<String, dynamic> json) {
    final diasList = (json['dias'] as List?)?.map((d) => CheckinDiaModel.fromJson(d as Map<String, dynamic>)).toList() ?? [];
    return ProgresoWeeklyModel(
      estadoMasFrecuente: json['estadoMasFrecuente']?.toString() ?? '',
      misionesCompletadas: json['misionesCompletadas'] ?? 0,
      diasActivos: json['diasActivos'] ?? 0,
      dias: diasList,
    );
  }
}

class CheckinDiaModel {
  final String fecha;
  final String? estadoEmocional;
  final bool misionCompletada;

  const CheckinDiaModel({required this.fecha, this.estadoEmocional, this.misionCompletada = false});

  factory CheckinDiaModel.fromJson(Map<String, dynamic> json) {
    return CheckinDiaModel(
      fecha: json['fecha']?.toString() ?? '',
      estadoEmocional: json['estadoEmocional']?.toString(),
      misionCompletada: json['misionCompletada'] == true,
    );
  }
}
