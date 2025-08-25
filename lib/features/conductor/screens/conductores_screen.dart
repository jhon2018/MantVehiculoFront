// lib/features/conductor/screens/conductores_screen.dart
import 'package:flutter/material.dart';
import 'package:mantenimientovehiculos/features/admin/side_menu.dart';
import 'package:mantenimientovehiculos/features/conductor/widgets/conductores_table.dart';
import 'package:mantenimientovehiculos/features/conductor/widgets/modal_registrar_conductor.dart';

class ConductoresScreen extends StatefulWidget {
  const ConductoresScreen({super.key});

  @override
  State<ConductoresScreen> createState() => _ConductoresScreenState();
}

class _ConductoresScreenState extends State<ConductoresScreen> {
  final _searchCtrl = TextEditingController();
  String searchTerm = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Conductores'),
        backgroundColor: const Color(0xFFDB7018),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: SideMenu(
        selectedRoute: 'conductores',
        role: 'admin', // o el rol dinámico del usuario
        nombreCompleto: 'Tu Nombre',
        onItemSelected: (route) {
          Navigator.pushReplacementNamed(context, '/$route');
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    // controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por dni, licencia o nombre',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchTerm = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    // final result = await showDialog<bool>(
                    //   context: context,
                    //   barrierDismissible: false,
                    //   builder: (context) => ModalRegistrarConductor(),
                    // );
                    // if (result == true) {
                    //   setState(() {}); // recargas la tabla
                    // }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDB7018),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ConductoresTable(searchTerm: searchTerm),
            ),
          ],
        ),
      ),
    );
  }
}
