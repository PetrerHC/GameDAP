import 'package:flutter/material.dart';

import '../Models/user_model.dart';
import '../services/user_service.dart';
import '../widgets/admin_drawer.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService userService = UserService();

  final nombreController = TextEditingController();
  final correoController = TextEditingController();
  final direccionController = TextEditingController();

  Map<String, dynamic> usuarioActual = {};
  bool argumentoLeido = false;
  bool guardando = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (argumentoLeido) return;

    final argumento = ModalRoute.of(context)?.settings.arguments;

    if (argumento is Map<String, dynamic>) {
      usuarioActual = Map<String, dynamic>.from(argumento);
      nombreController.text = usuarioActual['nom_usr']?.toString() ?? '';
      correoController.text = usuarioActual['mail']?.toString() ?? '';
      direccionController.text = usuarioActual['dir_usr']?.toString() ?? '';
    }

    argumentoLeido = true;
  }

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    direccionController.dispose();
    super.dispose();
  }

  Future<void> actualizarPerfil() async {
    final id = usuarioActual['id_usr'];
    final idUsuario = id is num ? id.toInt() : int.tryParse('$id');

    if (idUsuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró el ID del usuario')),
      );
      return;
    }

    final nombre = nombreController.text.trim();
    final correo = correoController.text.trim();
    final direccion = direccionController.text.trim();

    final String tipoUsuario = usuarioActual['tip_usu']?.toString() ?? '2';

    if (nombre.length < 2 || !correo.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Revisa el nombre y el correo electrónico'),
        ),
      );
      return;
    }

    setState(() => guardando = true);

    try {
      final actualizado = UserModel(
        id: idUsuario,
        nombre: nombre,
        correo: correo,
        direccion: direccion.isEmpty ? null : direccion,
        tipoUsuario: tipoUsuario, 
      );

      final respuesta = await userService.actualizarUsuario(actualizado);

      if (!mounted) return;

      setState(() {
        usuarioActual = {
          'id_usr': respuesta.id,
          'nom_usr': respuesta.nombre,
          'mail': respuesta.correo,
          'dir_usr': respuesta.direccion,
          'tip_usu': respuesta.tipoUsuario,
        };
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente'),
          backgroundColor: Color(0xFF7CB342),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar el perfil: $error')),
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
          'Mi perfil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      drawer: usuarioActual.isEmpty
          ? null
          : AdminDrawer(
              usuario: usuarioActual,
              rutaActual: '/profile',
            ),
      body: AuthBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Center(
              child: AuthCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                        Icons.account_circle,
                        size: 60,
                        color: Color(0xFF1A365D),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'DATOS DEL PERFIL',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1A365D),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: nombreController,
                      label: 'Nombre completo',
                      hintText: 'Tu nombre',
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
                      hintText: 'Tu dirección (Opcional)',
                      prefixIcon: Icons.home_outlined,
                    ),
                    const SizedBox(height: 25),
                    PrimaryButton(
                      text: guardando ? 'Actualizando...' : 'Guardar cambios',
                      onPressed: guardando ? () {} : actualizarPerfil,
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
