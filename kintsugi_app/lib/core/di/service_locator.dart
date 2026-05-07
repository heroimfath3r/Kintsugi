import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/checkin_service.dart';
import '../../data/services/mision_service.dart';
import '../../data/services/progreso_service.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  sl.registerLazySingleton<ApiClient>(() => ApiClient());
  sl.registerLazySingleton<AuthService>(() => AuthService(sl<ApiClient>()));
  sl.registerLazySingleton<CheckinService>(() => CheckinService(sl<ApiClient>()));
  sl.registerLazySingleton<MisionService>(() => MisionService(sl<ApiClient>()));
  sl.registerLazySingleton<ProgresoService>(() => ProgresoService(sl<ApiClient>()));
}
