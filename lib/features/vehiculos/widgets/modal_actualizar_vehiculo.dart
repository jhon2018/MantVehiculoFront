//ARCHIVO lib/features/vehiculos/widgets/modal_actualizar.dart

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import '../services/vehiculo_service.dart';

class ModalActualizarVehiculo extends StatefulWidget {
  final Map<String, dynamic> vehiculo;
  final VoidCallback onRefresh;

  const ModalActualizarVehiculo({
    super.key,
    required this.vehiculo,
    required this.onRefresh,
  });

  @override
  State<ModalActualizarVehiculo> createState() => _ModalActualizarVehiculoState();
}

class _ModalActualizarVehiculoState extends State<ModalActualizarVehiculo> {
  final _formKey = GlobalKey<FormState>();
  final _idVehiculoCtrl = TextEditingController();
  final _placaCtrl = TextEditingController();
  final _marcaCtrl = TextEditingController();
  final _modeloCtrl = TextEditingController();
  DateTime? _fechaCompra;

  bool _isLoading = false;
  String? _errorGeneral;
  final Map<String, String?> _erroresCampo = {};

  @override
  void initState() {
    super.initState();
    final v = widget.vehiculo;
    _idVehiculoCtrl.text = v['id_Vehiculo'].toString();
    _placaCtrl.text = v['placa'] ?? '';
    _marcaCtrl.text = v['marca'] ?? '';
    _modeloCtrl.text = v['modelo'] ?? '';
    final fechaStr = v['fecha_compra']?.toString().substring(0, 10);
    if (fechaStr != null) {
      _fechaCompra = DateTime.tryParse(fechaStr);
    }
  }

  @override
  void dispose() {
    _idVehiculoCtrl.dispose();
    _placaCtrl.dispose();
    _marcaCtrl.dispose();
    _modeloCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaCompra ?? DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFDB7018),
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

  setState(() {
    _isLoading = true;
    _errorGeneral = null;
    _erroresCampo.clear();
  });

  try {
    // 🔹 Paso nuevo: confirmación antes de actualizar
    final confirmar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text(
          '¿Confirmar actualización?',
          style: TextStyle(color: Color(0xFFDB7018)),
        ),
        content: Text(
          '¿Está seguro de actualizar los campos del vehículo con placa: ${_placaCtrl.text}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No', style: TextStyle(color: Color(0xFFDB7018))),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sí', style: TextStyle(color: Color(0xFFDB7018))),
          ),
        ],
      ),
    );

    if (confirmar != true) {
      // ❌ Cancelado por el usuario
      setState(() => _isLoading = false);
      return;
    }

    // 🔹 Si confirma, procede a llamar al servicio
    final resultado = await VehiculoService().actualizarVehiculo(
      id_Vehiculo: int.parse(_idVehiculoCtrl.text),
      placa: _placaCtrl.text.trim(),
      marca: _marcaCtrl.text.trim(),
      modelo: _modeloCtrl.text.trim(),
      fechaCompraUtc: DateTime.utc(
        _fechaCompra!.year,
        _fechaCompra!.month,
        _fechaCompra!.day,
      ),
    );

    final exito = resultado['exito'] == true;
    final mensaje = resultado['mensaje']?.toString() ?? '';

    final erroresRaw = resultado['errores'];
    final Map<String, List<String>> errores = {};
    if (erroresRaw is Map) {
      erroresRaw.forEach((campo, mensajes) {
        final clave = campo.toString();
        if (mensajes is List) {
          errores[clave] = mensajes.map((e) => e.toString()).toList();
        } else {
          errores[clave] = [mensajes.toString()];
        }
      });
    }

    if (!exito && errores.isNotEmpty) {
      setState(() {
        errores.forEach((campo, mensajes) {
          _erroresCampo[campo] = mensajes.join('\n');
        });
      });
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          exito ? 'Actualización Exitosa' : 'Error al Actualizar',
          style: const TextStyle(color: Color(0xFFDB7018)),
        ),
        content: Text(
          exito
              ? 'ID Vehículo: ${_idVehiculoCtrl.text}\n$mensaje'
              : mensaje.isNotEmpty
                  ? mensaje
                  : 'No se pudo actualizar el vehículo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Aceptar', style: TextStyle(color: Color(0xFFDB7018))),
          ),
        ],
      ),
    );

    if (exito) {
      widget.onRefresh();
      Navigator.of(context).pop();
    }

  } catch (e) {
    setState(() {
      _errorGeneral = 'Error Modal: ${e.toString()}';
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

  final _bordeNaranja = const OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xFFDB7018)),
  );

  return Dialog(
    insetPadding: const EdgeInsets.all(16),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 380),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFDB7018),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  'Editar Vehículo',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.w500, color: Colors.white),
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
                  child: Text(_errorGeneral!, style: const TextStyle(color: Colors.red)),
                ),
                const SizedBox(height: 12),
              ],

              TextFormField(
                controller: _idVehiculoCtrl,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'ID Vehículo',
                  border: _bordeNaranja,
                  enabledBorder: _bordeNaranja,
                  focusedBorder: _bordeNaranja,
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _placaCtrl,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Placa',
                  border: _bordeNaranja,
                  enabledBorder: _bordeNaranja,
                  focusedBorder: _bordeNaranja,
                  errorText: _erroresCampo['placa'],
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _marcaCtrl,
                decoration: InputDecoration(
                  labelText: 'Marca',
                  border: _bordeNaranja,
                  enabledBorder: _bordeNaranja,
                  focusedBorder: _bordeNaranja,
                  errorText: _erroresCampo['marca'],
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _modeloCtrl,
                decoration: InputDecoration(
                  labelText: 'Modelo',
                  border: _bordeNaranja,
                  enabledBorder: _bordeNaranja,
                  focusedBorder: _bordeNaranja,
                  errorText: _erroresCampo['modelo'],
                ),
              ),
              const SizedBox(height: 12),

              InkWell(
                onTap: _seleccionarFecha,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Fecha de compra',
                    border: _bordeNaranja,
                    enabledBorder: _bordeNaranja,
                    focusedBorder: _bordeNaranja,
                    errorText: _erroresCampo['fecha_compra'],
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
                            SchedulerBinding.instance.addPostFrameCallback((_) {
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
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
