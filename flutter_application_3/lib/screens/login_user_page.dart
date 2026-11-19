import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();

  bool ocultarPassword = true;
  bool cargando = false;

  @override
  void dispose() {
    usuarioController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> iniciarSesion() async {
    if (cargando) return;
    final mensaje = authService.validarLogin(
      usuario: usuarioController.text,
      password: passwordController.text,
    );

    if (mensaje != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensaje)));
      return;
    }

    setState(() => cargando = true);

    try {
      final usuario = await authService.autenticar(
        correo: usuarioController.text,
        password: passwordController.text,
      );

      if (!mounted) return;

      final String tipoUsuario =
          usuario['tip_usu']?.toString().toLowerCase() ?? '2';

      final bool esAdmin = tipoUsuario == '1' || tipoUsuario == 'admin';

      if (esAdmin) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/users',
          (route) => false,
          arguments: usuario,
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/blog',
          (route) => false,
          arguments: usuario,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  // Lleva el correo al formulario de la nueva contraseña.
  Future<void> recuperarPassword() async {
    final correo = usuarioController.text.trim();
    if (!correo.contains('@') || correo.contains(' ')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Escribe tu correo arriba para identificar tu cuenta'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    final actualizado = await Navigator.pushNamed(
      context,
      '/recovery',
      arguments: correo,
    );
    // Muestra el aviso solo si se guardó la contraseña y seguimos aquí.
    if (!mounted || actualizado != true) return;
    passwordController.clear();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Contraseña actualizada. Ya puedes iniciar sesión'),
      backgroundColor: Color(0xFF7CB342),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.8), width: 2),
                    ),
                    child: const Icon(Icons.sports_esports,
                        size: 50, color: Color(0xFF1A365D)),
                  ),
                  const SizedBox(height: 15),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5),
                      children: [
                        TextSpan(
                            text: 'Game',
                            style: TextStyle(color: Color(0xFF1A365D))),
                        TextSpan(
                            text: 'D',
                            style: TextStyle(color: Color(0xFFE53935))),
                        TextSpan(
                            text: 'A',
                            style: TextStyle(color: Color(0xFF1E88E5))),
                        TextSpan(
                            text: 'P',
                            style: TextStyle(color: Color(0xFFFFB74D))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tu siguiente partida empieza aquí',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A365D).withValues(alpha: 0.8)),
                  ),
                  const SizedBox(height: 30),
                  AuthCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.5)),
                          ),
                          child: const Text('INICIO DE SESIÓN',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A365D))),
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: usuarioController,
                          label: 'Correo electrónico',
                          hintText: 'nombre@correo.com',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 15),
                        CustomTextField(
                          controller: passwordController,
                          label: 'Contraseña',
                          hintText: '********',
                          prefixIcon: Icons.lock_outline,
                          obscureText: ocultarPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                                ocultarPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: const Color(0xFF1A365D)
                                    .withValues(alpha: 0.6)),
                            onPressed: () => setState(
                                () => ocultarPassword = !ocultarPassword),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: cargando ? null : recuperarPassword,
                            child: Text('¿Olvidaste tu contraseña?',
                                style: TextStyle(
                                    color: const Color(0xFF1A365D)
                                        .withValues(alpha: 0.7),
                                    fontSize: 13)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        PrimaryButton(
                          text: cargando ? 'Validando...' : 'Iniciar sesión',
                          onPressed: cargando ? null : iniciarSesion,
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text('¿Aún no tienes cuenta?',
                                style: TextStyle(
                                    color: const Color(0xFF1A365D)
                                        .withValues(alpha: 0.7),
                                    fontSize: 14)),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/register'),
                              child: const Text('Crear una cuenta',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A365D))),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: cargando
                              ? null
                              : () {
                                  // Abre el blog sin una cuenta guardada.
                                  AuthService.continuarComoVisitante();
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/blog',
                                    (route) => false,
                                  );
                                },
                          child: const Text('Continuar como visitante'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
