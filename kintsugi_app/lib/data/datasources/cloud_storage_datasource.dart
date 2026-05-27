import 'package:kintsugi_app/data/repositories/image_repository.dart';

/// Datasource que obtiene URLs desde Google Cloud Storage (bucket público).
/// Responsabilidad única: construir URLs válidas de GCS para los avatares
/// de los arquetipos en sus 3 fases visuales.
class CloudStorageDatasource implements ImageRepository {
  static const String _bucketUrl =
      'https://storage.googleapis.com/kintsugipublico';

  @override
  String getAvatarUrl(String arquetipoId, int fase) {
    final folderName = _mapArquetipoToFolder(arquetipoId);
    final fileName = '${arquetipoId.toLowerCase()}_fase$fase.png';
    // Uri.encodeComponent maneja los espacios en nombres como "Ippo Makunouchi"
    final encodedFolder = Uri.encodeComponent(folderName);
    return '$_bucketUrl/$encodedFolder/$fileName';
  }

  /// Mapea el ID interno del arquetipo al nombre exacto de carpeta en el bucket.
  /// Los nombres con espacios o sin doble letra reflejan el contenido real del bucket.
  String _mapArquetipoToFolder(String arquetipoId) {
    const mapping = {
      'thorfinn': 'Thorfin',          // Sin doble 'n' en el bucket
      'rocklee': 'Rock Lee',          // Con espacio
      'rock_lee': 'Rock Lee',         // Alias por consistencia
      'ippo': 'Ippo Makunouchi',      // Nombre completo
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