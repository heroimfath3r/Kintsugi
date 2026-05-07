// lib/data/local/hive_init.dart

import 'package:hive_flutter/hive_flutter.dart';
import 'hive_boxes.dart';

/// Inicializa Hive y abre todas las cajas necesarias.
/// Debe llamarse en main() ANTES de runApp().
Future<void> initHive() async {
  await Hive.initFlutter();

  // Abrir todas las cajas.
  // Usamos cajas genéricas (no tipadas) porque guardamos Maps JSON
  // y reutilizamos los fromJson() de los modelos existentes.
  await Hive.openBox(HiveBoxes.perfil);
  await Hive.openBox(HiveBoxes.checkins);
  await Hive.openBox(HiveBoxes.misiones);
  await Hive.openBox(HiveBoxes.progreso);
  await Hive.openBox(HiveBoxes.syncQueue);
}