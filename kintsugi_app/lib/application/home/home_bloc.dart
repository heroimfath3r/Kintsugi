import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_exceptions.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/checkin_service.dart';
import '../../data/services/mision_service.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AuthService _authService;
  final CheckinService _checkinService;
  final MisionService _misionService;

  HomeBloc({
    required AuthService authService,
    required CheckinService checkinService,
    required MisionService misionService,
  })  : _authService = authService,
        _checkinService = checkinService,
        _misionService = misionService,
        super(const HomeInitial()) {
    on<HomeLoadData>(_onLoadData);
    on<HomeCheckinRequested>(_onCheckin);
    on<HomeMisionCompleted>(_onMisionCompleted);
  }

  Future<void> _onLoadData(
    HomeLoadData event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());

    try {
      final user = await _authService.getProfile();
      final checkinHoy = await _checkinService.getCheckinHoy();
      var misionHoy = checkinHoy != null ? await _tryGetMision() : null;

      emit(HomeLoaded(
        user: user,
        checkinHoy: checkinHoy,
        misionHoy: misionHoy,
        misionCompletada: misionHoy?.completada ?? false,
      ));
    } on ApiException catch (e) {
      emit(HomeError(message: e.message));
    } catch (e) {
      emit(HomeError(message: 'Error cargando datos: $e'));
    }
  }

  Future<void> _onCheckin(
    HomeCheckinRequested event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! HomeLoaded) return;

    try {
      final checkin = await _checkinService.realizarCheckin(event.estadoEmocional);
      final mision = await _tryGetMision();
      final user = await _authService.getProfile();

      emit(currentState.copyWith(
        user: user,
        checkinHoy: checkin,
        misionHoy: mision,
        setCheckin: true,
        setMision: true,
      ));
    } on ConflictException {
      add(const HomeLoadData());
    } on ApiException catch (e) {
      emit(HomeError(message: e.message));
    } catch (e) {
      emit(HomeError(message: 'Error registrando check-in: $e'));
    }
  }

  Future<void> _onMisionCompleted(
    HomeMisionCompleted event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! HomeLoaded) return;

    try {
      await _misionService.completarMision(event.misionId);
      final user = await _authService.getProfile();

      emit(currentState.copyWith(
        user: user,
        misionCompletada: true,
      ));
    } on ApiException catch (e) {
      emit(HomeError(message: e.message));
    } catch (e) {
      emit(HomeError(message: 'Error completando misión: $e'));
    }
  }

  Future<dynamic> _tryGetMision() async {
    try {
      return await _misionService.getMisionDiaria();
    } catch (_) {
      return null;
    }
  }
}