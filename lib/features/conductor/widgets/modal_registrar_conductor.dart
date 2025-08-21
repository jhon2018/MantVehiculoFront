// lib/features/conductor/widgets/modal_registrar_conductor.dart
import 'package:flutter/material.dart';

class ModalRegistrarConductor extends StatefulWidget {
  const ModalRegistrarConductor({super.key});

  @override
  State<ModalRegistrarConductor> createState() => _ModalRegistrarConductorState();
}

class _ModalRegistrarConductorState extends State<ModalRegistrarConductor> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _licenciaCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _licenciaCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      // TODO: llamar a tu proxy para registrar
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar conductor'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            TextFormField(
              controller: _licenciaCtrl,
              decoration: const InputDecoration(labelText: 'Licencia'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            TextFormField(
              controller: _telefonoCtrl,
              decoration: const InputDecoration(labelText: 'Teléfono'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
          ]),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        FilledButton(
          onPressed: _isLoading ? null : _guardar,
          child: _isLoading ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Guardar'),
        ),
      ],
    );
  }
}
