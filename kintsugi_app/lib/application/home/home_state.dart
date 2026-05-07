//C:\Proyectos\Kintsugi\kintsugi_app\lib\application\home\home_state.dart
import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';
import '../../data/models/checkin_model.dart';
import '../../data/models/mision_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

/// Estado principal del Home con todos los datos cargados.
class HomeLoaded extends HomeState {
  final UserModel user;
  final CheckinModel? checkinHoy;
  final MisionModel? misionHoy;
  final bool misionCompletada;

  const HomeLoaded({
    required this.user,
    this.checkinHoy,
    this.misionHoy,
    this.misionCompletada = false,
  });

  bool get yaHizoCheckin => checkinHoy != null;

  HomeLoaded copyWith({
    UserModel? user,
    CheckinModel? checkinHoy,
    MisionModel? misionHoy,
    bool? misionCompletada,
    bool setCheckin = false,
    bool setMision = false,
  }) {
    return HomeLoaded(
      user: user ?? this.user,
      checkinHoy: setCheckin ? checkinHoy : (checkinHoy ?? this.checkinHoy),
      misionHoy: setMision ? misionHoy : (misionHoy ?? this.misionHoy),
      misionCompletada: misionCompletada ?? this.misionCompletada,
    );
  }

  @override
  List<Object?> get props => [
        user.uid,
        user.racha,
        user.xp,
        checkinHoy?.estadoEmocional,
        misionHoy?.id,
        misionCompletada,
      ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}