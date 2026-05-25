import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import '../network/connectivity_service.dart';
import '../sync/sync_manager.dart';
import '../../data/local/local_storage_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/checkin_service.dart';
import '../../data/services/mision_service.dart';
import '../../data/services/progreso_service.dart';
import '../../data/repositories/image_repository.dart';
import '../../data/datasources/cloud_storage_datasource.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  // ── Core ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<ApiClient>(() => ApiClient());
  sl.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
  sl.registerLazySingleton<LocalStorageService>(() => LocalStorageService());

  // ── Servicios (reciben localStorage y connectivity) ─────────────────────
  sl.registerLazySingleton<AuthService>(
    () => AuthService(
      sl<ApiClient>(),
      sl<LocalStorageService>(),
      sl<ConnectivityService>(),
    ),
  );
  sl.registerLazySingleton<CheckinService>(
    () => CheckinService(
      sl<ApiClient>(),
      sl<LocalStorageService>(),
      sl<ConnectivityService>(),
    ),
  );
  sl.registerLazySingleton<MisionService>(
    () => MisionService(
      sl<ApiClient>(),
      sl<LocalStorageService>(),
      sl<ConnectivityService>(),
    ),
  );
  sl.registerLazySingleton<ProgresoService>(
    () => ProgresoService(
      sl<ApiClient>(),
      sl<LocalStorageService>(),
      sl<ConnectivityService>(),
    ),
  );

  // ── Sync Manager ──────────────────────────────────────────────────────
  sl.registerLazySingleton<SyncManager>(
    () => SyncManager(
      connectivity: sl<ConnectivityService>(),
      apiClient: sl<ApiClient>(),
      localStorage: sl<LocalStorageService>(),
    ),
  );

  // ── Image Repository (para imágenes de Google Cloud Storage) ───────────
  sl.registerLazySingleton<ImageRepository>(
    () => CloudStorageDatasource(),
  );
}