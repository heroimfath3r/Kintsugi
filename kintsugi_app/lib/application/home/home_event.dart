//C:\Proyectos\Kintsugi\kintsugi_app\lib\application\home\home_event.dart
import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar todos los datos del Home: perfil, check-in de hoy, misión.
class HomeLoadData extends HomeEvent {
  const HomeLoadData();
}

/// Realizar check-in emocional.
class HomeCheckinRequested extends HomeEvent {
  final String estadoEmocional;

  const HomeCheckinRequested({required this.estadoEmocional});

  @override
  List<Object?> get props => [estadoEmocional];
}

/// Completar la misión del día.
class HomeMisionCompleted extends HomeEvent {
  final String misionId;

  const HomeMisionCompleted({required this.misionId});

  @override
  List<Object?> get props => [misionId];
}