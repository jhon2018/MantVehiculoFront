//ARCHIVO modal_registrar_vehiculo.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/vehiculo_service.dart';
import 'package:flutter/scheduler.dart';

class ModalRegistrarVehiculo extends StatefulWidget {
  final VoidCallback? onRegistroExitoso;

  const ModalRegistrarVehiculo({super.key, this.onRegistroExitoso});

  @override
  State<ModalRegistrarVehiculo> createState() => _ModalRegistrarVehiculoState();
}

class _ModalRegistrarVehiculoState extends State<ModalRegistrarVehiculo> {
  final _formKey = GlobalKey<FormState>();
  final _placaCtrl = TextEditingController();
  final _marcaCtrl = TextEditingController();
  final _modeloCtrl = TextEditingController();
  DateTime? _fechaCompra;

  bool _isLoading = false;
  String? _errorGeneral;

  @override
  void dispose() {
    _placaCtrl.dispose();
    _marcaCtrl.dispose();
    _modeloCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaCompra ?? now,
      firstDate: DateTime(1970),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFFDB7018),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _fechaCompra = picked;
      });
    }
  }

Future<void> _guardar() async {
  if (!_formKey.currentState!.validate() || _fechaCompra == null) {
    if (!mounted) return;
    setState(() {
      _errorGeneral = 'Completa todos los campos requeridos';
    });
    return;
  }

  if (!mounted) return;
  setState(() {
    _isLoading = true;
    _errorGeneral = null;
  });

  try {
    final fechaUtc = DateTime.utc(
      _fechaCompra!.year,
      _fechaCompra!.month,
      _fechaCompra!.day,
    );

    final resultado = await VehiculoService().registrarVehiculo(
      placa: _placaCtrl.text.trim().toUpperCase(),
      marca: _marcaCtrl.text.trim(),
      modelo: _modeloCtrl.text.trim(),
      fechaCompraUtc: fechaUtc,
    );

    if (!mounted) return;

if (resultado['exito'] == true) {
  final mensaje = (resultado['mensaje'] is String)
      ? resultado['mensaje'] as String
      : resultado['mensaje']?.toString() ?? '';

  await showDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: const Text(
        'Registro exitoso',
        style: TextStyle(color: Color(0xFFDB7018)),
      ),
      content: Text(
        mensaje.isNotEmpty
            ? mensaje
            : 'El vehículo se registró correctamente.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text(
            'Aceptar',
            style: TextStyle(color: Color(0xFFDB7018)),
          ),
        ),
      ],
    ),
  );

  await Future.delayed(const Duration(milliseconds: 100));
  if (!mounted) return;
  widget.onRegistroExitoso?.call();
  Navigator.of(context).pop(true);

} else {
  final mensajeError = (resultado['mensaje'] is String)
      ? resultado['mensaje'] as String
      : resultado['mensaje']?.toString() ?? '';

  // Detectamos duplicado sin depender de mayúsculas/minúsculas
  if (mensajeError.toLowerCase().contains('ya existe un vehículo con esa placa')) {
    await showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Registro duplicado',
          style: TextStyle(color: Color(0xFFDBA60000)),
        ),
        content: Text(mensajeError),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Aceptar',
              style: TextStyle(color: Color(0xFFDBFF2E2E)),
            ),
          ),
        ],
      ),
    );
  } else {
    setState(() {
      _errorGeneral = mensajeError.isNotEmpty
          ? mensajeError
          : 'No se pudo registrar el vehículo, intente nuevamente o contacte al administrador.'; // mensaje genérico
    });
  }
}




  } catch (e) {
    if (!mounted) return;
    setState(() {
      _errorGeneral = 'Error: ${e.toString()}';
    });
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}





  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    // Definir el borde FUERA de la lista de children
    final _bordeNaranja = const OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFDB7018)),
    );

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDB7018),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    'Registrar Vehículo',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 21),

                if (_errorGeneral != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _errorGeneral!,
                      style: const TextStyle(
                          color: Colors.red), // error text color
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Placa
                TextFormField(
                  controller: _placaCtrl,
                  decoration: InputDecoration(
                    labelText: 'Placa',
                    border: _bordeNaranja,
                    enabledBorder: _bordeNaranja,
                    focusedBorder: _bordeNaranja,
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 12),

                // Marca
                TextFormField(
                  controller: _marcaCtrl,
                  decoration: InputDecoration(
                    labelText: 'Marca',
                    border: _bordeNaranja,
                    enabledBorder: _bordeNaranja,
                    focusedBorder: _bordeNaranja,
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 12),

                // Modelo
                TextFormField(
                  controller: _modeloCtrl,
                  decoration: InputDecoration(
                    labelText: 'Modelo',
                    border: _bordeNaranja,
                    enabledBorder: _bordeNaranja,
                    focusedBorder: _bordeNaranja,
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 12),

                // Fecha de compra
                InkWell(
                  onTap: _seleccionarFecha,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Fecha de compra',
                      border: _bordeNaranja,
                      enabledBorder: _bordeNaranja,
                      focusedBorder: _bordeNaranja,
                    ),
                    child: Text(
                      _fechaCompra == null
                          ? 'Seleccionar fecha'
                          : DateFormat('yyyy-MM-dd').format(_fechaCompra!),
                      style: TextStyle(
                        color: _fechaCompra == null
                            ? Colors.black
                            : Colors.black.withOpacity(0.8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Botones
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                      OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Color(0xFFDB7018)),
                      ),
                        onPressed: _isLoading
                            ? null
                            : () {
                                SchedulerBinding.instance
                                    .addPostFrameCallback((_) {
                                  if (mounted) Navigator.of(context).pop();
                                });
                              },
                        child: const Text('Cancelar'),
                      ),
                    
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDB7018),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _isLoading ? null : _guardar,
                      child: _isLoading
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Guardar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }




}
