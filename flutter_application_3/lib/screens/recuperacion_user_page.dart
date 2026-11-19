import 'package:flutter/material.dart';
// Revisa y guarda la nueva contraseña.
import '../services/auth_service.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class RecoveryPage extends StatefulWidget {
  // Recibe el correo que se escribió en el login.
  final String correo;
  const RecoveryPage({super.key, this.correo = ''});

  @override
  State<RecoveryPage> createState() => _RecoveryPageState();
}

class _RecoveryPageState extends State<RecoveryPage> {
  // Estos campos guardan la contraseña nueva y su confirmación.
  final passwordController = TextEditingController();
  final confirmacionController = TextEditingController();
  final authService = AuthService();
  bool ocultarPassword = true;
  // Evita guardar otra vez mientras termina la petición.
  bool guardando = false;

  @override
  void dispose() {
    // Libera los campos cuando se cierra la pantalla.
    passwordController.dispose();
    confirmacionController.dispose();
    super.dispose();
  }

  Future<void> guardarPassword() async {
    if (guardando) return;
    final mensaje = authService.validarPassword(
      passwordController.text,
      confirmacionController.text,
    );
    if (mensaje != null || widget.correo.isEmpty) {
      mostrarError(
          mensaje ?? 'Vuelve al login y escribe el correo de tu cuenta');
      return;
    }
    setState(() => guardando = true);
    try {
      // El correo viene del login; aquí solo pedimos la nueva contraseña.
      await authService.recuperarPassword(
        correo: widget.correo,
        password: passwordController.text,
        confirmacion: confirmacionController.text,
      );
      if (!mounted) return;
      // El valor true avisa al login que la contraseña ya se cambió.
      Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        mostrarError(error.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => guardando = false);
    }
  }

  void mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Recuperar contraseña'),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF1A365D),
      ),
      body: AuthBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: AuthCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_reset,
                        size: 55, color: Color(0xFF1A365D)),
                    const SizedBox(height: 16),
                    const Text('NUEVA CONTRASEÑA',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20)),
                    const SizedBox(height: 8),
                    Text(widget.correo, textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: passwordController,
                      label: 'Nueva contraseña',
                      hintText: 'Al menos 8 caracteres',
                      prefixIcon: Icons.lock_outline,
                      obscureText: ocultarPassword,
                      suffixIcon: IconButton(
                        tooltip: ocultarPassword
                            ? 'Mostrar contraseña'
                            : 'Ocultar contraseña',
                        onPressed: () =>
                            setState(() => ocultarPassword = !ocultarPassword),
                        icon: Icon(ocultarPassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                      ),
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      controller: confirmacionController,
                      label: 'Confirmar contraseña',
                      prefixIcon: Icons.lock_outline,
                      obscureText: ocultarPassword,
                    ),
                    const SizedBox(height: 25),
                    PrimaryButton(
                      text: guardando ? 'Guardando...' : 'Guardar contraseña',
                      onPressed: guardando ? null : guardarPassword,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
