/// Contrato para obtener URLs de imágenes
/// Respeta Dependency Inversion Principle: depende de abstracción, no de implementación
abstract class ImageRepository {
  /// Obtiene la URL pública de un avatar del arquetipo
  String getAvatarUrl(String arquetipoId, int fase);
}