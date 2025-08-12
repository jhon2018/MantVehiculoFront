//ARCHIVO lib/features/admin/side_menu.dart
import 'package:flutter/material.dart';

class SideMenu extends StatelessWidget {
  final String selectedRoute;
  final String role;
  final String nombreCompleto;
  final Function(String route) onItemSelected;

  const SideMenu({
    super.key,
    required this.selectedRoute,
    required this.role,
    required this.nombreCompleto,
    required this.onItemSelected,
  });
  
String _getRolLabel(String rol) {
  switch (rol) {
    case 'admin':
      return 'Administrador';
    case 'operador':
      return 'Operador';
    case 'conductor':
      return 'Conductor';
    default:
      return 'Usuario';
  }
}

  @override
  Widget build(BuildContext context) {
    final allItems = [
      _MenuItem('Conductor', 'conductor', 'assets/icons/driver.png',['admin', 'conductor']),
      _MenuItem('Detalle Reparación', 'repair_detail','assets/icons/repair_detail.png', ['admin', 'conductor']),
      _MenuItem('Mantenimiento', 'maintenance', 'assets/icons/maintenance.png',['admin', 'conductor', 'operador']),
      _MenuItem('Proveedor', 'supplier', 'assets/icons/supplier.png',['admin', 'conductor']),
      _MenuItem('Tipo Reparación', 'repair_type','assets/icons/repair_type.png', ['admin', 'conductor']),
      _MenuItem('Usuario', 'user', 'assets/icons/user.png', ['admin']),
      _MenuItem('Vehículo', 'vehicle', 'assets/icons/vehicle.png',['admin', 'conductor']),
    ];

    final visibleItems =
        allItems.where((item) => item.roles.contains(role)).toList();

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 0),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Image.asset(
                'assets/icons/Logo.png',
                width: 150,
                height: 150,
              ),
            ),
            
_buildHeader(context, 'Bienvenido: $nombreCompleto | Menú ${_getRolLabel(role)}'),

           
            ...visibleItems.map((item) {
              final isSelected = selectedRoute.contains(item.route);
              return Container(
                decoration: isSelected
                    ? BoxDecoration(
                        color: const Color(0xFFF3C095),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      )
                    : null,
                child: ListTile(
                  leading: Image.asset(item.iconPath, width: 25, height: 25),
                  title: Text(item.label),
                  selected: isSelected,
                  onTap: () => onItemSelected(item.route),
                ),
              );
            }).toList(),
            const Divider(height: 50, thickness: 2),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 0, vertical: 12.0),
              child: ListTile(
                leading:
                    Image.asset('assets/icons/exit.png', width: 24, height: 24),
                title: const Text('Salir'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('¿Deseás salir?'),
                        content: const Text('Se cerrará tu sesión actual.'),
                        actions: [
                          TextButton(
                            child: Text(
                              'Cancelar',
                              style: TextStyle(color: Color(0xFFDB7018)),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          TextButton(
                            child: const Text(
                              'Salir',
                              style: TextStyle(color: Color(0xFFDB7018)),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.pushReplacementNamed(context, '/');
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        color: const Color(0xFFDB7018),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final String label;
  final String route;
  final String iconPath;
  final List<String> roles;

  _MenuItem(this.label, this.route, this.iconPath, this.roles);
}
