import 'package:flutter/material.dart';
import 'package:mantenimientovehiculos/features/admin/side_menu.dart';
import 'package:mantenimientovehiculos/core/services/session_manager.dart';

final session = SessionManager().user;

class OperadorHome extends StatelessWidget {
  const OperadorHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideMenu(
        role: session?.rol ?? 'operador',
        nombreCompleto: session?.nombreCompleto ?? '',
        selectedRoute: ModalRoute.of(context)?.settings.name ?? '',
        onItemSelected: (route) {
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, '/$route');
        },
      ),
      appBar: AppBar(title: const Text('Panel Operador')),
      body: const Center(child: Text('Bienvenido Operador')),
    );
  }
}
