import 'package:flutter/material.dart';
import 'package:mantenimientovehiculos/features/admin/side_menu.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideMenu(
        role: 'admin',
        selectedRoute: ModalRoute.of(context)?.settings.name ?? '',
        onItemSelected: (route) {
          Navigator.pop(context); // Cierra el drawer
          Navigator.pushReplacementNamed(context, '/$route');
        },
      ),
      appBar: AppBar(title: const Text('Panel Admin')),
      body: const Center(child: Text('Bienvenido Admin')),
    );
  }
}
