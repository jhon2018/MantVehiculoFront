import 'package:flutter/material.dart';
import 'package:mantenimientovehiculos/features/admin/side_menu.dart';

class ConductorHome extends StatelessWidget {
  const ConductorHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideMenu(
        role: 'conductor',
        selectedRoute: ModalRoute.of(context)?.settings.name ?? '',
        onItemSelected: (route) {
          Navigator.pop(context); // Cierra el drawer
          Navigator.pushReplacementNamed(context, '/$route');
        }, 
      ),
      appBar: AppBar(title: const Text('PANEL CONDUCTOR')),
      body: const Center(child: Text('Bienvenido Conductor')),
    );
  }
}
