//C:\Proyectos\Kintsugi\kintsugi_app\lib\data\models\user_model.dart
class UserModel {
  final String uid;
  final String email;
  final String? arquetipo;
  final int racha;
  final int misionesCompletadas;
  final int xp;
  final int fase;
  final DateTime? creadoEn;

  const UserModel({
    required this.uid,
    required this.email,
    this.arquetipo,
    this.racha = 0,
    this.misionesCompletadas = 0,
    this.xp = 0,
    this.fase = 1,
    this.creadoEn,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      arquetipo: json['arquetipo']?.toString(),
      racha: _parseInt(json['racha']),
      misionesCompletadas: _parseInt(json['misionesCompletadas']),
      xp: _parseInt(json['xp']),
      fase: _parseInt(json['fase'], defaultValue: 1),
      creadoEn: json['creadoEn'] != null ? DateTime.tryParse(json['creadoEn'].toString()) : null,
    );
  }

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  bool get tieneArquetipo => arquetipo != null && arquetipo!.isNotEmpty;

  String get nombreArquetipo {
    const nombres = {
      'thorfinn': 'Thorfinn',
      'rocklee': 'Rock Lee',
      'ippo': 'Ippo',
      'mob': 'Mob',
      'asta': 'Asta',
    };
    return nombres[arquetipo] ?? arquetipo?.toUpperCase() ?? 'Sin guía';
  }
}
