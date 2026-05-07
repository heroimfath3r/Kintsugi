//C:\Proyectos\Kintsugi\kintsugi_app\lib\data\models\mision_model.dart
class MisionModel {
  final String id;
  final String titulo;
  final String tipo;
  final String descripcion;
  final String estadoEmocional;
  final String arquetipo;
  final bool completada;
  final String fecha;

  const MisionModel({
    required this.id,
    required this.titulo,
    required this.tipo,
    required this.descripcion,
    required this.estadoEmocional,
    required this.arquetipo,
    this.completada = false,
    required this.fecha,
  });

  factory MisionModel.fromJson(Map<String, dynamic> json) {
    return MisionModel(
      id: json['id']?.toString() ?? json['fecha']?.toString() ?? '',
      titulo: json['titulo']?.toString() ?? '',
      tipo: json['tipo']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      estadoEmocional: json['estadoEmocional']?.toString() ?? '',
      arquetipo: json['arquetipo']?.toString() ?? '',
      completada: json['completada'] == true,
      fecha: json['fecha']?.toString() ?? '',
    );
  }

  String get tipoLabel {
    const labels = {'reflexion': 'Reflexión', 'accion': 'Acción', 'respiracion': 'Respiración'};
    return labels[tipo] ?? tipo;
  }

  MisionModel copyWith({bool? completada}) {
    return MisionModel(
      id: id, titulo: titulo, tipo: tipo, descripcion: descripcion,
      estadoEmocional: estadoEmocional, arquetipo: arquetipo,
      completada: completada ?? this.completada, fecha: fecha,
    );
  }
}
