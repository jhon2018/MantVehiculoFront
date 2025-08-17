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

    if (resp.statusCode == 200 ||
        resp.statusCode == 201 ||
        resp.statusCode == 400) {
      final decoded = json.decode(resp.body);

      // Si viene dentro de "details", lo tomamos de ahí
      final Map<String, dynamic> details =
          (decoded['details'] is Map<String, dynamic>)
              ? decoded['details']
              : {};

      // Primero buscamos en details, luego en la raíz
      final bool exito = (details['existe'] ?? decoded['existe']) == true;

      final String mensaje =
          (details['mensaje'] ?? decoded['mensaje'] ?? '').toString();

      return {
        'exito': exito,
        'mensaje': mensaje,
      };
    } else {
      throw Exception('Error Service ${resp.statusCode}: ${resp.body}');
    }
  }




Future<Map<String, dynamic>> actualizarVehiculo({
  required int id_Vehiculo,
  required String placa,
  required String marca,
  required String modelo,
  required DateTime fechaCompraUtc,
}) async {
  final url = Uri.parse(_baseUrl);

  final body = {
    "endpoint": "/api/Vehiculo/Actualizar/$id_Vehiculo",
    "method": "PUT",
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

  final decoded = json.decode(resp.body);

  // 🛑 Validación fallida (status 400 con estructura RFC)
  if (resp.statusCode == 400 && decoded['details'] is Map) {
    final details = decoded['details'] as Map<String, dynamic>;
    final erroresRaw = details['errors'];

    final Map<String, List<String>> erroresCampo = {};

    if (erroresRaw is Map) {
      erroresRaw.forEach((campo, mensajes) {
        final clave = campo.toString();
        if (mensajes is List) {
          erroresCampo[clave] = mensajes.map((e) => e.toString()).toList();
        } else {
          erroresCampo[clave] = [mensajes.toString()];
        }
      });
    }

    return {
      'exito': false,
      'mensaje': decoded['error']?.toString() ?? 'Error en el backend',
      'errores': erroresCampo,
    };
  }

  // ✅ Registro exitoso (existe == true)
  final bool exito = decoded['existe'] == true;
  final String mensaje = decoded['mensaje']?.toString() ?? 'Sin mensaje';

  return {
    'exito': exito,
    'mensaje': mensaje,
    'errores': {}, // estructura uniforme para el modal
  };
}




  
}
