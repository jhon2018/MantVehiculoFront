// lib/core/services/inactivity_service.dart
import 'dart:async';

class InactivityService {
  static final InactivityService _instance = InactivityService._internal();
  factory InactivityService() => _instance;
  InactivityService._internal();

  Duration totalTimeout = const Duration(minutes: 5);//tiempo total de inactividad
  Duration warnBefore = const Duration(seconds: 10);//tiempo de aviso

  Timer? _warnTimer;
  Timer? _logoutTimer;

  void Function()? onWarn;
  void Function()? onTimeout;

  bool get isRunning => _logoutTimer != null;

  void configure({Duration? total, Duration? warn}) {
    if (total != null) totalTimeout = total;
    if (warn != null) warnBefore = warn;
  }

  void start() {
    reset();
  }

  void reset() {
    _cancelTimers();
    // Programa aviso
    _warnTimer = Timer(totalTimeout - warnBefore, () {
      if (onWarn != null) onWarn!();
    });
    // Programa logout
    _logoutTimer = Timer(totalTimeout, () {
      if (onTimeout != null) onTimeout!();
    });
  }

  void stop() {
    _cancelTimers();
  }

  void _cancelTimers() {
    _warnTimer?.cancel();
    _logoutTimer?.cancel();
    _warnTimer = null;
    _logoutTimer = null;
  }
}
