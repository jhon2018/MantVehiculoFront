//ARCHIVO lib/features/vehiculos/widgets/vehiculos_table.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VehiculosTable extends StatefulWidget {
  const VehiculosTable({super.key, required this.searchTerm});
  
  final String searchTerm;

  @override
  State<VehiculosTable> createState() => _VehiculosTableState();
}

class _VehiculosTableState extends State<VehiculosTable> {
  List<dynamic> vehiculos = [];
  int currentPage = 1;
  int pageSize = 10;
  int totalRegistros = 0;

  bool isLoading = false;
  String? errorMsg;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    fetchVehiculos();
  }

  @override
  void didUpdateWidget(covariant VehiculosTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchTerm != widget.searchTerm) {
      // 🔹 Resetea a página 1 siempre que cambie el filtro
      setState(() {
        currentPage = 1;
      });
      _scheduleFetch();
    }
  }

  Future<void> fetchVehiculos() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });

    try {
      final response = await http.post(
        Uri.parse('https://proxy-serverestoy.onrender.com/proxy'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'endpoint': '/api/Vehiculo/listarPaginas',
          'method': 'GET',
          'params': {
            'page': currentPage,
            'pageSize': pageSize,
            'search': widget.searchTerm,
          },
        }),
      );

      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.contains('application/json')) {
        setState(
            () => errorMsg = 'Respuesta inesperada del servidor (no es JSON)');
      } else {
        final decoded = json.decode(response.body);
        if (response.statusCode == 200 && decoded is Map<String, dynamic>) {
          var lista =
              List<Map<String, dynamic>>.from(decoded['vehiculos'] ?? const []);

          // 🔹 Filtro en cliente si backend no implementa search
          if (widget.searchTerm.trim().isNotEmpty) {
            final term = widget.searchTerm.toLowerCase();
            lista = lista.where((v) {
              final placa = (v['placa'] ?? '').toString().toLowerCase();
              final marca = (v['marca'] ?? '').toString().toLowerCase();
              final modelo = (v['modelo'] ?? '').toString().toLowerCase();
              return placa.contains(term) ||
                  marca.contains(term) ||
                  modelo.contains(term);
            }).toList();
          }

          // 🔹 Ordenar por fecha más reciente siempre
          lista.sort((a, b) {
            final fa =
                DateTime.tryParse((a['fecha_compra'] ?? '').toString()) ??
                    DateTime(1900);
            final fb =
                DateTime.tryParse((b['fecha_compra'] ?? '').toString()) ??
                    DateTime(1900);
            return fb.compareTo(fa);
          });

          setState(() {
            totalRegistros = (decoded['totalRegistros'] ?? lista.length) as int;
            vehiculos = lista;
          });
        } else {
          setState(() => errorMsg = decoded is Map && decoded['mensaje'] != null
              ? decoded['mensaje'].toString()
              : 'Error del servidor (${response.statusCode})');
        }
      }
    } catch (e) {
      setState(() => errorMsg = 'Error de conexión: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _scheduleFetch() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), fetchVehiculos);
  }

  void _nextPage() {
    final hasNext = currentPage * pageSize < totalRegistros;
    if (!hasNext) return;
    setState(() => currentPage += 1);
    fetchVehiculos();
  }

  void _prevPage() {
    if (currentPage == 1) return;
    setState(() => currentPage -= 1);
    fetchVehiculos();
  }

  String _formatFecha(dynamic fecha) {
    if (fecha == null) return '';
    final s = fecha.toString();
    try {
      final iso = s.contains('T') ? s : '${s}T00:00:00';
      final d = DateTime.parse(iso);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return s;
    }
  }

  @override
  Widget build(BuildContext context) {
  if (isLoading) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xFFDB7018), // Color del loader
          ),
          SizedBox(height: 8),
          Text(
            'Estamos recopilando información...',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2B2626),
            ),
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
                onPressed: fetchVehiculos, child: const Text('Reintentar')),
          ],
        ),
      );
    }

return LayoutBuilder(
  builder: (context, constraints) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: constraints.maxWidth > 800 ? 0.5 : 1,
        child: SingleChildScrollView( // Scroll vertical si la altura es pequeña
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tabla con scroll horizontal siempre que se requiera
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Placa')),
                    DataColumn(label: Text('Marca')),
                    DataColumn(label: Text('Modelo')),
                    DataColumn(label: Text('Fecha Compra')),
                    DataColumn(label: Text('Acciones')),
                  ],
                  rows: vehiculos.map<DataRow>((vehiculo) {
                    final placa = (vehiculo['placa'] ?? '').toString();
                    final marca = (vehiculo['marca'] ?? '').toString();
                    final modelo = (vehiculo['modelo'] ?? '').toString();
                    final fechaCompra =
                        _formatFecha(vehiculo['fecha_compra']);

                    return DataRow(
                      cells: [
                        DataCell(Text(placa)),
                        DataCell(Text(marca)),
                        DataCell(Text(modelo)),
                        DataCell(Text(fechaCompra)),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {},
                            ),
                          ],
                        )),
                      ],
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 50),

              // Barra de paginación con scroll horizontal en pantallas pequeñas
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
                        foregroundColor: Color(0xFFDB7018),
                        side: const BorderSide(color: Color(0xFFDB7018)),
                      ),
                      onPressed: currentPage > 1 ? _prevPage : null,
                      child: const Text('Anterior'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(0xFFDB7018),
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
