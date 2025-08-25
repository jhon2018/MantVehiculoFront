//ARCHIVO lib/features/conductor/services/conductor_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class ConductorService {
  final String _baseUrl = 'https://proxy-serverestoy.onrender.com/proxy';

  Future<Map<String, dynamic>> actualizarConductor({
    required int id_Conductor,
    required int id_Personal,
    required String licencia,
  }) async {
    final url = Uri.parse(_baseUrl);

    final body = {
      "endpoint": "/api/Conductor/editar",
      "method": "PUT",
      "body": {
        "id_Conductor": id_Conductor,
        "id_Personal": id_Personal,
        "licencia": licencia,
      }
    };

    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    final decoded = json.decode(resp.body);

    // 🛑 Manejo de error (estructura RFC)
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

    // ✅ Caso exitoso
    final bool exito = decoded['exito'] == true;
    final String mensaje = decoded['mensaje']?.toString() ?? 'Sin mensaje desde la Api';

    return {
      'exito': exito,
      'mensaje': mensaje,
      'errores': {}, // mismo contrato de datos
    };
  }
}
