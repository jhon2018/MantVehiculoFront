import 'package:flutter/material.dart';
import 'package:mantenimientovehiculos/core/services/auth_service.dart';
import 'package:mantenimientovehiculos/shared/widgets/custom_input.dart'
    as input;
import 'package:mantenimientovehiculos/shared/widgets/custom_button.dart'
    as button;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _loading = false;

  void _showMessage(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final result = await AuthService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    setState(() => _loading = false);

    if (result['exito']) {
      _showMessage('Inicio de sesión exitoso', success: true);
final rol = (result['correo']['rol'] ?? 'admin').toString().toLowerCase();

      if (rol == 'admin') {
        Navigator.pushNamed(context, '/admin');
      } else if (rol == 'operador') {
        Navigator.pushNamed(context, '/operador');
      } else if (rol == 'conductor') {
        Navigator.pushNamed(context, '/conductor');
      }
    } else {
      _showMessage(result['mensaje'] ?? 'Error desconocido');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/loginFondo.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(
                0.4,
              ), // filtro oscuro para contraste
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: screenWidth < 800
                    ? _buildLoginForm(context, width: screenWidth * 0.9)
                    : _buildLoginForm(context, width: 400),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context, {required double width}) {
    return Center(
      // Centra el Container horizontalmente
      child: Container(
        width: width,
        padding: const EdgeInsets.all(35),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.center, // Centra los hijos horizontalmente
            mainAxisSize: MainAxisSize.min, // Ajusta el alto al contenido
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1), // margen superior de 20
                child: Text(
                  'JHT TRANSPORT COMPANY',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30), //separador
              const Text(
                'Iniciar Sesión',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              input.CustomInput(
                controller: _emailController,
                hint: 'Correo',
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Ingrese su correo';
                  if (!value.contains('@')) return 'Correo inválido';
                  return null;
                },
              ),
              const SizedBox(height: 15),
              input.CustomInput(
                controller: _passwordController,
                hint: 'Contraseña',
                obscure: true,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Ingrese su contraseña';
                  if (value.length < 3) return 'Mínimo 3 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 25),
              _loading
                  ? const CircularProgressIndicator()
                  : button.CustomButton(text: 'Ingresar', onPressed: _login),
            ],
          ),
        ),
      ),
    );
  }
}
