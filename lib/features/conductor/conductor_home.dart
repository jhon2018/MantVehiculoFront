//ARCHIVO lib/features/conductor/conductor_home.dart
import 'package:flutter/material.dart';
import 'package:mantenimientovehiculos/features/admin/side_menu.dart';
import 'package:mantenimientovehiculos/core/services/session_manager.dart';


  final session = SessionManager().user;

class ConductorHome extends StatelessWidget {
  const ConductorHome({super.key});
  
  @override
  Widget build(BuildContext context) {
return Scaffold(
  drawer: SideMenu(
    role: session?.rol ?? 'conductor',
    nombreCompleto: session?.nombreCompleto ?? '',
    selectedRoute: ModalRoute.of(context)?.settings.name ?? '',
    onItemSelected: (route) {
      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, '/$route');
    },
      ),
      appBar: AppBar(title: const Text('PANEL CONDUCTOR')),
      body: const Center(child: Text('Bienvenido Conductor')),
    );
  }
}
