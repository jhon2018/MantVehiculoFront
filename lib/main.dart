//ARCHIVO buil/lib/main.dart
import 'package:flutter/material.dart';
import 'package:mantenimientovehiculos/routes/app_routes.dart';
import 'package:mantenimientovehiculos/shared/widgets/inactivity_wrapper.dart';
import 'package:mantenimientovehiculos/core/navigation/material.dart'; // <-- importar

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JHT Transport Company',
      debugShowCheckedModeBanner: false,
      navigatorKey: appNavigatorKey, // <-- clave global
      initialRoute: '/',
      routes: AppRoutes.routes,
      builder: (context, child) {
        // el child es el Navigator; InactivityWrapper queda por encima,
        // por eso usaremos appNavigatorKey para navegar
        return InactivityWrapper(
          child: child ?? const SizedBox.shrink(),
          totalTimeout: const Duration(minutes: 5),
          warnBefore: const Duration(seconds: 120),//tiempo de espera notificacion
        );
      },
    );
  }
}
