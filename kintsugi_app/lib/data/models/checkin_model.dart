class CheckinModel {
  final String estadoEmocional;
  final String fecha;
  final DateTime? creadoEn;

  const CheckinModel({
    required this.estadoEmocional,
    required this.fecha,
    this.creadoEn,
  });

  factory CheckinModel.fromJson(Map<String, dynamic> json) {
    return CheckinModel(
      estadoEmocional: json['estadoEmocional']?.toString() ?? '',
      fecha: json['fecha']?.toString() ?? '',
      creadoEn: json['creadoEn'] != null ? DateTime.tryParse(json['creadoEn'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'estadoEmocional': estadoEmocional};
  }

  String get emoji {
    const emojis = {'vacio': '🌑', 'frustracion': '🔥', 'motivacion': '⚡', 'ansiedad': '🌊', 'calma': '☁️'};
    return emojis[estadoEmocional] ?? '❓';
  }

  String get label {
    const labels = {'vacio': 'Vacío', 'frustracion': 'Frustrado', 'motivacion': 'Motivado', 'ansiedad': 'Ansioso', 'calma': 'Calma'};
    return labels[estadoEmocional] ?? estadoEmocional;
  }
}
