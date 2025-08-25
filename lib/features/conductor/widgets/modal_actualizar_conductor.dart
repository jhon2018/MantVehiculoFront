// lib/features/conductor/widgets/modal_registrar_conductor.dart

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
// import 'package:intl/intl.dart';
import '../services/conductor_service.dart';

class ModalActualizarConductor extends StatefulWidget {
  final Map<String, dynamic> conductor;
  final VoidCallback onRefresh;

  const ModalActualizarConductor({
    super.key,
    required this.conductor,
    required this.onRefresh,
  });

  @override
  State<ModalActualizarConductor> createState() => _ModalActualizarConductor();
}

class _ModalActualizarConductor extends State<ModalActualizarConductor> {
  final _formKey = GlobalKey<FormState>();
  final _idConductor = TextEditingController();
  final _idPersonal = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _licenciaCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();

  bool _isLoading = false;
  String? _errorGeneral;
  final Map<String, dynamic> _erroresCampo = {};

  @override
  void initState() {
    super.initState();
    final c = widget.conductor;
    _idConductor.text = c['id_Conductor'].toString();
    _idPersonal.text = c['id_Personal'].toString();
    _nombreCtrl.text = c['nombre'] ?? '';
    _licenciaCtrl.text = c['licencia'] ?? '';
    _telefonoCtrl.text = c['telefono'] ?? '';
  }

  @override
  void dispose() {
    _idConductor.dispose();
    _idPersonal.dispose();
    _nombreCtrl.dispose();
    _licenciaCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) {
if (!mounted) return;
    setState(() {
      _errorGeneral = 'Completa todos los campos requeridos';
    });
    return;}

      setState(() {
    _isLoading = true;
    _errorGeneral = null;
    _erroresCampo.clear();
  });
try {
    // Confirmación
    final confirmar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Confirmar actualización?',
            style: TextStyle(color: Color(0xFFDB7018))),
        content: Text(
            '¿Actualizar la licencia del conductor con DNI: ${_idPersonal.text}?'),
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
      final resultado = await ConductorService().actualizarConductor(
        id_Conductor: int.parse(_idConductor.text),
        id_Personal: int.parse(_idPersonal.text),
        licencia: _licenciaCtrl.text.trim(),
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
            content: Text(exito
                ? 'ID Conductor: ${_idConductor.text}\n$mensaje'
                : mensaje.isNotEmpty
                    ? mensaje
                    : 'No se pudo actualizar la licencia.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Aceptar',
                    style: TextStyle(color: Color(0xFFDB7018))),
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

    // Definir el borde FUERA de la lista de children
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
                    style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
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
                    child: Text(_errorGeneral!,
                        style: const TextStyle(color: Colors.red)),
                  ),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  controller: _idConductor,
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
                  controller: _idPersonal,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Nombre Personal',
                    border: _bordeNaranja,
                    enabledBorder: _bordeNaranja,
                    focusedBorder: _bordeNaranja,
                    errorText: _erroresCampo['placa'],
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _licenciaCtrl,
                  decoration: InputDecoration(
                    labelText: 'Licencia',
                    border: _bordeNaranja,
                    enabledBorder: _bordeNaranja,
                    focusedBorder: _bordeNaranja,
                    errorText: _erroresCampo['marca'],
                  ),
                ),
                const SizedBox(height: 12),
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
