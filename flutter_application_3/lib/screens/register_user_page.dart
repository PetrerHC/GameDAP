import 'package:flutter/material.dart';

import '../Models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../widgets/admin_drawer.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nombreController = TextEditingController();
  final correoController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmarPasswordController = TextEditingController();
  final direccionController = TextEditingController();

  final AuthService authService = AuthService();
  final UserService userService = UserService();

  // --- CAMBIO: Ahora es String ---
  String tipoUsuario = '2';
  bool guardando = false;

  Map<String, dynamic> usuarioActual = {};
  bool argumentoLeido = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (argumentoLeido) return;

    final argumento = ModalRoute.of(context)?.settings.arguments;
    if (argumento is Map<String, dynamic>) {
      usuarioActual = Map<String, dynamic>.from(argumento);
    }

    argumentoLeido = true;
  }

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    passwordController.dispose();
    confirmarPasswordController.dispose();
    direccionController.dispose();
    super.dispose();
  }

  Future<void> registrarUsuario() async {
    final nombre = nombreController.text.trim();
    final correo = correoController.text.trim();
    final password = passwordController.text;
    final confirmarPassword = confirmarPasswordController.text;
    final direccion = direccionController.text.trim();

    final mensaje = authService.validarRegistro(
      nombre: nombre,
      correo: correo,
      password: password,
      confirmarpassword: confirmarPassword,
    );

    if (mensaje != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje)),
      );
      return;
    }

    setState(() => guardando = true);

    try {
      final usuario = UserModel(
        id: 0,
        nombre: nombre,
        correo: correo,
        password: password,
        direccion: direccion.isEmpty ? null : direccion,
        tipoUsuario: tipoUsuario,
      );

      await userService.agregarUsuario(usuario);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario registrado correctamente'),
          backgroundColor: Color(0xFF7CB342),
        ),
      );

      nombreController.clear();
      correoController.clear();
      passwordController.clear();
      confirmarPasswordController.clear();
      direccionController.clear();

      // --- CAMBIO: Volvemos a '2' como String ---
      setState(() => tipoUsuario = '2');
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo registrar: $error')),
      );
    } finally {
      if (mounted) setState(() => guardando = false);
    }
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
          'Registrar usuario',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      drawer: usuarioActual.isEmpty
          ? null
          : AdminDrawer(
              usuario: usuarioActual,
              rutaActual: '/register',
            ),
      body: AuthBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Center(
              child: AuthCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        'NUEVO USUARIO DEL SISTEMA',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A365D),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: nombreController,
                      label: 'Nombre completo',
                      hintText: 'Ej. Juan Jose Gutierrez',
                      prefixIcon: Icons.person_outline,
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      controller: correoController,
                      label: 'Correo electrónico',
                      hintText: 'correo@ejemplo.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      controller: direccionController,
                      label: 'Dirección',
                      hintText: 'Opcional',
                      prefixIcon: Icons.home_outlined,
                    ),
                    const SizedBox(height: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 4.0, bottom: 6.0),
                          child: Text(
                            'Tipo de usuario',
                            style: TextStyle(
                              color: Color(0xFF1A365D),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        // --- CAMBIO: Dropdown de String ---
                        DropdownButtonFormField<String>(
                          value: tipoUsuario,
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Color(0xFF1A365D)),
                          dropdownColor: const Color(0xFFE6F6FF),
                          style: const TextStyle(
                            color: Color(0xFF1A365D),
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.6),
                            prefixIcon: Icon(
                              Icons.badge_outlined,
                              color: const Color(0xFF1A365D)
                                  .withValues(alpha: 0.7),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.white.withValues(alpha: 0.8),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF2196F3),
                                width: 2.0,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: 16.0,
                            ),
                          ),
                          items: const [
                            // --- CAMBIO: Valores String ---
                            DropdownMenuItem(
                              value: '1',
                              child: Text('Administrador'),
                            ),
                            DropdownMenuItem(
                              value: '2',
                              child: Text('Usuario general'),
                            ),
                          ],
                          onChanged: guardando
                              ? null
                              : (valor) {
                                  if (valor != null) {
                                    setState(() => tipoUsuario = valor);
                                  }
                                },
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      controller: passwordController,
                      label: 'Contraseña',
                      hintText: '********',
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                    ),
                    const SizedBox(height: 15),
                    CustomTextField(
                      controller: confirmarPasswordController,
                      label: 'Confirmar contraseña',
                      hintText: '********',
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                    ),
                    const SizedBox(height: 25),
                    PrimaryButton(
                      text: guardando ? 'Registrando...' : 'Registrar usuario',
                      onPressed: guardando ? () {} : registrarUsuario,
                    ),
                    const SizedBox(height: 10),
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
