// lib/features/conductor/widgets/conductores_table.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mantenimientovehiculos/features/conductor/widgets/modal_actualizar_conductor.dart';
import 'package:mantenimientovehiculos/features/conductor/widgets/modal_registrar_conductor.dart';
import 'package:mantenimientovehiculos/features/vehiculos/widgets/modal_actualizar_vehiculo.dart';

class ConductoresTable extends StatefulWidget {
  const ConductoresTable({super.key, required this.searchTerm});
  final String searchTerm;

  @override
  State<ConductoresTable> createState() => _ConductoresTableState();
}

class _ConductoresTableState extends State<ConductoresTable> {
  List<dynamic> conductores = [];
  int currentPage = 1;
  int pageSize = 10;
  int totalRegistros = 0;

  bool isLoading = false;
  String? errorMsg;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    fetchConductores();
  }

  @override
  void didUpdateWidget(covariant ConductoresTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchTerm != widget.searchTerm) {
      setState(() => currentPage = 1);
      _scheduleFetch();
    }
  }

  void _scheduleFetch() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), fetchConductores);
  }

  Future<void> fetchConductores() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });

    try {
      final buscarGlobal = widget.searchTerm.trim().isNotEmpty;

      final response = await http.post(
        Uri.parse('https://proxy-serverestoy.onrender.com/proxy'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'endpoint': '/api/Conductor/listar',
          'method': 'GET',
          'params': buscarGlobal
              ? {'page': 1, 'pageSize': 999999}
              : {'page': currentPage, 'pageSize': pageSize},
        }),
      );

      final decoded = json.decode(response.body);
      if (response.statusCode == 200 && decoded is Map<String, dynamic>) {
        var lista =
            List<Map<String, dynamic>>.from(decoded['conductor'] ?? const []);
        if (buscarGlobal) {
          final term = widget.searchTerm.toLowerCase();
          lista = lista
              .where((c) =>
                  (c['nombre_completo'] ?? '')
                      .toString()
                      .toLowerCase()
                      .contains(term) ||
                  (c['licencia'] ?? '')
                      .toString()
                      .toLowerCase()
                      .contains(term) ||
                  (c['telefono'] ?? '').toString().toLowerCase().contains(term))
              .toList();

          totalRegistros = lista.length;
          final start = (currentPage - 1) * pageSize;
          final end = start + pageSize;
          lista = lista.sublist(start, end > lista.length ? lista.length : end);
        } else {
          totalRegistros = decoded['totalRegistros'] ?? lista.length;
        }

        setState(() => conductores = lista);
      } else {
        setState(() => errorMsg = 'Error del servidor');
      }
    } catch (e) {
      setState(() => errorMsg = 'Error de conexión: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _nextPage() {
    if (currentPage * pageSize < totalRegistros) {
      setState(() => currentPage++);
      fetchConductores();
    }
  }

  void _prevPage() {
    if (currentPage > 1) {
      setState(() => currentPage--);
      fetchConductores();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFDB7018)),
            SizedBox(height: 8),
            Text(
              'Estamos recopilando información...',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2B2626)),
            ),
          ],
        ),
      );
    }

    if (errorMsg != null) {
      return Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            Text(errorMsg!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            ElevatedButton(
                onPressed: fetchConductores, child: const Text('Reintentar')),
          ],
        ),
      );
    }

      return LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: FractionallySizedBox(
              widthFactor: constraints.maxWidth > 800 ? 0.5 : 1,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tabla con scroll horizontal
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 1000),
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('ID')),
                            DataColumn(label: Text('Nombre completo')),
                            DataColumn(label: Text('DNI')),
                            DataColumn(label: Text('Licencia')),
                            DataColumn(label: Text('Cargo')),
                            DataColumn(label: Text('Teléfono')),
                            DataColumn(label: Text('Estado')),
                            DataColumn(label: Text('Acciones')),
                          ],
                          rows: conductores.map<DataRow>((conductor) {
                            final id =
                                (conductor['id_Conductor'] ?? '').toString();
                            final nombre =
                                (conductor['nombre_completo'] ?? '').toString();
                            final dni = (conductor['dni'] ?? '').toString();
                            final licencia =
                                (conductor['licencia'] ?? '').toString();
                            final cargo = (conductor['cargo'] ?? '').toString();
                            final telefono =
                                (conductor['telefono'] ?? '').toString();
                            final activo = conductor['activo'] == true;

                            return DataRow(
                              cells: [
                                DataCell(Text(id)),
                                DataCell(Text(nombre)),
                                DataCell(Text(dni)),
                                DataCell(Text(licencia)),
                                DataCell(Text(cargo)),
                                DataCell(Text(telefono)),
                                DataCell(Text(activo ? 'Activo' : 'Inactivo')),
                                DataCell(Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (_) =>
                                              ModalActualizarConductor(
                                            conductor: conductor,
                                            onRefresh: fetchConductores,
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () {},
                                    ),
                                  ],
                                )),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),

                    // Paginación
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Página $currentPage • Registros: $totalRegistros',
                            style: const TextStyle(color: Color(0xFFDB7018)),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFDB7018),
                              side: const BorderSide(color: Color(0xFFDB7018)),
                            ),
                            onPressed: currentPage > 1 ? _prevPage : null,
                            child: const Text('Anterior'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFDB7018),
                              side: const BorderSide(color: Color(0xFFDB7018)),
                            ),
                            onPressed: (currentPage * pageSize) < totalRegistros
                                ? _nextPage
                                : null,
                            child: const Text('Siguiente'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
  }

