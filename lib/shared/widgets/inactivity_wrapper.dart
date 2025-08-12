// ARCHIVO lib/shared/widgets/inactivity_wrapper.dart
//captura toques y ciclo de vida
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mantenimientovehiculos/core/services/inactivity_service.dart';
import 'package:mantenimientovehiculos/core/services/session_manager.dart';
import 'package:mantenimientovehiculos/core/navigation/material.dart';

class InactivityWrapper extends StatefulWidget {
  final Widget child;
  final Duration totalTimeout;
  final Duration warnBefore;

  const InactivityWrapper({
    super.key,
    required this.child,
    this.totalTimeout = const Duration(minutes: 5),
    this.warnBefore = const Duration(seconds: 10),
  });

  @override
  State<InactivityWrapper> createState() => _InactivityWrapperState();
}

final FocusNode _focusNode = FocusNode();

class _InactivityWrapperState extends State<InactivityWrapper>
    with WidgetsBindingObserver {


  final _service = InactivityService();
  bool _warningVisible = false;
  Timer? _countdownTimer;
  late final ValueNotifier<int> _secondsLeftNotifier;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _secondsLeftNotifier = ValueNotifier<int>(0);

    _service.configure(total: widget.totalTimeout, warn: widget.warnBefore);
    _service.onWarn = _showWarningDialog;
    _service.onTimeout = _autoLogout;

    _maybeStartTimers();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _hideWarningDialog();
    _service.stop();
    _countdownTimer?.cancel();
    _secondsLeftNotifier.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _maybeStartTimers() {
    if (SessionManager().isLoggedIn) {
      _service.start();
    } else {
      _service.stop();
    }
  }

  void _onUserInteraction() {
    if (!SessionManager().isLoggedIn) return;
    _service.reset();
    _hideWarningDialog();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!SessionManager().isLoggedIn) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _service.stop();
      _hideWarningDialog();
    } else if (state == AppLifecycleState.resumed) {
      _service.start();
    }
  }

  void _showWarningDialog() {
    if (_warningVisible) return;

    final ctx = appNavigatorKey.currentContext;
    if (ctx == null) return; // no hay contexto navegable

    _warningVisible = true;
    _secondsLeftNotifier.value = _service.warnBefore.inSeconds;

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      final next = _secondsLeftNotifier.value - 1;
      if (next >= 0) {
        _secondsLeftNotifier.value = next;
      }
    });

    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'Inactividad detectada',
            style: TextStyle(color: Color(0xFFDB7018)),
          ),
          content: ValueListenableBuilder<int>(
            valueListenable: _secondsLeftNotifier,
            builder: (_, seconds, __) {
              return Text(
                'Serás desconectado en $seconds segundos.\n¿Deseas continuar activo?',
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx, rootNavigator: true).pop(); // cierra diálogo
                _manualLogout();
              },
              child: const Text(
                'Salir ahora',
                style: TextStyle(color: Color(0xFFDB7018)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx, rootNavigator: true).pop();
                _service.reset();
                _hideWarningDialog();
              },
              child: const Text(
                'Seguir activo',
                style: TextStyle(color: Color(0xFFDB7018)),
              ),
            ),
          ],
        );
      },
    ).then((_) => _hideWarningDialog());
  }

  void _hideWarningDialog() {
    _warningVisible = false;
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  void _manualLogout() {
    SessionManager().clear();
    _service.stop();
    _hideWarningDialog();

    final ctx = appNavigatorKey.currentContext;
    if (ctx != null) {
      Navigator.of(ctx).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  void _autoLogout() {
    _manualLogout();
  }

@override
Widget build(BuildContext context) {
  return Focus(
    autofocus: true,
    focusNode: _focusNode,
    onKey: (_, __) {
      _onUserInteraction();
      return KeyEventResult.ignored; // no intercepta el evento
    },
    child: Listener(
      behavior: HitTestBehavior.deferToChild,
      onPointerDown: (_) => _onUserInteraction(),
      onPointerSignal: (_) => _onUserInteraction(),
      child: widget.child,
    ),
  );
}
}

/*
Listener captura toques, scroll, drag; suficiente para móvil. Si quisieras cubrir teclado en web/desktop, podemos añadir un Focus/Shortcuts para keys.

El wrapper pausa los timers cuando la app va a background.
*/ 