// lib/core/network/connectivity_service.dart

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';


class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  bool _isOnline = true;

  late final Stream<bool> onConnectivityChanged;

  ConnectivityService() {
    onConnectivityChanged = _connectivity.onConnectivityChanged
        .map((result) => _evaluarResultado(result))
        .distinct();
  }

  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    return _evaluarResultado(result);
  }

  bool get isOnline => _isOnline;

  bool _evaluarResultado(ConnectivityResult result) {
    _isOnline = result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet;
    return _isOnline;
  }
}