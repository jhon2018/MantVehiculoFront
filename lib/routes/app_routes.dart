//ARCHIVO lib/routes/app_routes.dart
import 'package:flutter/material.dart';
import 'package:mantenimientovehiculos/features/auth/screens/login_screen.dart';
import 'package:mantenimientovehiculos/features/admin/admin_home.dart';
import 'package:mantenimientovehiculos/features/conductor/conductor_home.dart'; 
import 'package:mantenimientovehiculos/features/operador/operador_home.dart';
import 'package:mantenimientovehiculos/features/vehiculos/screens/vehiculos_screen.dart'; 

class AppRoutes {
  static final routes = <String, WidgetBuilder>{
    '/': (context) => const LoginScreen(),
    '/admin': (context) => const AdminHome(),
    '/conductor': (context) => const ConductorHome(),
    '/operador': (context) => const OperadorHome(),
    
    '/vehicle': (context) => const VehiculosScreen(),

  };
}
