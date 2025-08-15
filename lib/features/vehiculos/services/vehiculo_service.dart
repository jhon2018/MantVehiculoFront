//ARCHVIVO build/lib/features/vehiculos/services/vehiculo_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class VehiculoService {
  final String _baseUrl = 'https://proxy-serverestoy.onrender.com/proxy';

  Future<Map<String, dynamic>> registrarVehiculo({
    required String placa,
    required String marca,
    required String modelo,
    required DateTime fechaCompraUtc,
  }) async {
    final url = Uri.parse(_baseUrl);

    final body = {
      "endpoint": "/api/Vehiculo/registrar",
      "method": "POST",
      "body": {
        "placa": placa,
        "marca": marca,
        "modelo": modelo,
        "fecha_compra": fechaCompraUtc.toIso8601String(),
      }
    };

    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

if (resp.statusCode == 200 || resp.statusCode == 201 || resp.statusCode == 400) {
  final decoded = json.decode(resp.body);

  // Si viene dentro de "details", lo tomamos de ahí
  final Map<String, dynamic> details =
      (decoded['details'] is Map<String, dynamic>) ? decoded['details'] : {};

  // Primero buscamos en details, luego en la raíz
  final bool exito = (details['existe'] ?? decoded['existe']) == true;

  final String mensaje = (details['mensaje'] ??
                           decoded['mensaje'] ??
                           '')
                          .toString();

  return {
    'exito': exito,
    'mensaje': mensaje,
  };
} else {
  throw Exception('Error ${resp.statusCode}: ${resp.body}');
}




  }
}

