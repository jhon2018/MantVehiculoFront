// ARCHIVO auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static Future<Map<String, dynamic>> login(
    String correo,
    String password,
  ) async {
    // final url = Uri.parse('https://jonathanvs-001-site1.mtempurl.com/api/Usuario/Autenticacion/Autenticacion');

    //    final url = Uri.parse('http://jonathanvs-001-site1.mtempurl.com/api/Usuario/Autenticacion');

    try {
      final response = await http.post(
        Uri.parse('https://proxy-serverestoy.onrender.com/proxy'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'endpoint': '/api/Usuario/Autenticacion',
          'data': {'correo': correo, 'password': password},
        }),
      );
      // final response = await http.post(
      //   url,
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({'correo': correo, 'password': password}),
      // );

      if (response.headers['content-type']?.contains('application/json') ??
          false) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        // continuar normalmente
      } else {
        return {
          'exito': false,
          'mensaje': 'Respuesta inesperada del servidor (no es JSON)',
        };
      }

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseBody;
      } else if (response.statusCode == 401 || response.statusCode == 400) {
        // Credenciales incorrectas u otro error controlado
        return {
          'exito': false,
          'mensaje': responseBody['mensaje'] ?? 'Credenciales inválidas',
        };
      } else {
        // Otros errores del backend
        return {
          'exito': false,
          'mensaje': 'Error del servidor (${response.statusCode})',
        };
      }
    } catch (e) {
      // Error de conexión o parsing
      return {'exito': false, 'mensaje': 'Error de conexión: ${e.toString()}'};
    }
  }
}
