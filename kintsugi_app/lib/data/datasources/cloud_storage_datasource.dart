import 'package:kintsugi_app/data/repositories/image_repository.dart';

/// Datasource que obtiene URLs desde Google Cloud Storage
/// Responsabilidad única: construir URLs válidas de GCS
class CloudStorageDatasource implements ImageRepository {
  static const String _bucketUrl = 'https://storage.googleapis.com/kintsugi--app-storage';

  @override
  String getAvatarUrl(String arquetipoId, int fase) {
    final folderName = _mapArquetipoToFolder(arquetipoId);
    final fileName = '${arquetipoId.toLowerCase()}_fase$fase.png';
    return '$_bucketUrl/$folderName/$fileName';
  }

  /// Mapea el ID del arquetipo al nombre de carpeta en Storage
  /// Responsabilidad: traducir entre el dominio de la app y Storage
  String _mapArquetipoToFolder(String arquetipoId) {
    const mapping = {
      'thorfinn': 'Thorfin',
      'rocklee': 'Rock-Lee',
      'ippo': 'Ippo',
      'mob': 'Mob',
      'asta': 'Asta',
    };

    final folder = mapping[arquetipoId.toLowerCase()];
    if (folder == null) {
      throw ArgumentError('Arquetipo no reconocido: $arquetipoId');
    }
    return folder;
  }
}