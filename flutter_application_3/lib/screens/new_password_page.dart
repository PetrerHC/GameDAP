import 'package:flutter/material.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class RegisterPasswordPage extends StatefulWidget {
  const RegisterPasswordPage({super.key});

  @override
  State<RegisterPasswordPage> createState() => _RegisterPasswordPageState();
}

class _RegisterPasswordPageState extends State<RegisterPasswordPage> {
  final TextEditingController correoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordController2 = TextEditingController();

  bool ocultarPassword = true;
  bool ocultarPassword2 = true;

  @override
  void dispose() {
    correoController.dispose();
    passwordController.dispose();
    passwordController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1A365D),
        title: const Text(
          'Recuperar cuenta',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
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
                        color: Colors.white.withValues(alpha: 0.8),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lock_reset,
                      size: 55,
                      color: Color(0xFF1A365D),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'RECUPERAR CUENTA',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A365D),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 25),

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
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                          child: const Text(
                            'RESTABLECER CONTRASEÑA',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A365D),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Campo de Correo
                        CustomTextField(
                          controller: correoController,
                          label: 'Correo electrónico',
                          hintText: 'nombre@correo.com',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 15),

                        // Campo de Nueva Contrasena
                        CustomTextField(
                          controller: passwordController2,
                          label: 'Nueva contraseña',
                          hintText: '********',
                          prefixIcon: Icons.lock_outline,
                          obscureText: ocultarPassword2,
                          suffixIcon: IconButton(
                            icon: Icon(
                              ocultarPassword2
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: const Color(0xFF1A365D)
                                  .withValues(alpha: 0.6),
                            ),
                            onPressed: () {
                              setState(() {
                                ocultarPassword2 = !ocultarPassword2;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Campo de Confirmar Contrasena
                        CustomTextField(
                          controller: passwordController,
                          label: 'Confirmar contraseña',
                          hintText: '********',
                          prefixIcon: Icons.lock_outline,
                          obscureText: ocultarPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              ocultarPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: const Color(0xFF1A365D)
                                  .withValues(alpha: 0.6),
                            ),
                            onPressed: () {
                              setState(() {
                                ocultarPassword = !ocultarPassword;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Botón Principal
                        PrimaryButton(
                          text: 'Restablecer contraseña',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Cuenta recuperada correctamente'),
                                backgroundColor:
                                    Color(0xFF7CB342), // Verde del botón
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Botón para volver
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Ya tengo una cuenta',
                      style: TextStyle(
                        color: Color(0xFF1A365D),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
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
