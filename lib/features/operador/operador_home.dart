import 'package:flutter/material.dart';
import 'package:mantenimientovehiculos/features/admin/side_menu.dart';

class OperadorHome extends StatelessWidget {
  const OperadorHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideMenu(
        role: 'operador',
        selectedRoute: ModalRoute.of(context)?.settings.name ?? '',
        onItemSelected: (route) {
          Navigator.pop(context); // Cierra el drawer
          Navigator.pushReplacementNamed(context, '/$route');
        }, 
      ),
      appBar: AppBar(title: const Text('Panel Operador')),
      body: const Center(child: Text('Bienvenido Operador')),
    );
  }
}
