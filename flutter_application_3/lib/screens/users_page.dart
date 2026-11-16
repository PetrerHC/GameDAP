import 'package:flutter/material.dart';

import '../Models/user_model.dart';
import '../services/user_service.dart';
import '../widgets/admin_drawer.dart';
import '../widgets/auth_background.dart';
import '../widgets/custom_text_field.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final UserService userService = UserService();

  final nombreController = TextEditingController();
  final correoController = TextEditingController();
  final passwordController = TextEditingController();
  final direccionController = TextEditingController();

  late Future<List<UserModel>> futuroUsuarios;
  Map<String, dynamic> usuarioActual = {};
  bool argumentoLeido = false;

  @override
  void initState() {
    super.initState();
    futuroUsuarios = userService.obtenerUsuarios();
  }

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
    direccionController.dispose();
    super.dispose();
  }

  void recargarUsuarios() {
    setState(() {
      futuroUsuarios = userService.obtenerUsuarios();
    });
  }

  void mostrarMensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: const Color(0xFF7CB342), // Verde GameDAP
      ),
    );
  }

  Future<void> mostrarFormulario({UserModel? usuario}) async {
    final esEdicion = usuario != null;

    nombreController.text = usuario?.nombre ?? '';
    correoController.text = usuario?.correo ?? '';
    direccionController.text = usuario?.direccion ?? '';
    passwordController.clear();

    final resultado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        bool guardando = false;

        return StatefulBuilder(
          builder: (contextDialogo, actualizarDialogo) {
            return AlertDialog(
              backgroundColor: const Color(0xFFE6F6FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.8), width: 2),
              ),
              title: Text(
                esEdicion ? 'Editar usuario' : 'Nuevo usuario',
                style: const TextStyle(
                  color: Color(0xFF1A365D),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: nombreController,
                      label: 'Nombre completo',
                      hintText: 'Ej. Juan Pérez',
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
                    if (!esEdicion) ...[
                      const SizedBox(height: 15),
                      CustomTextField(
                        controller: passwordController,
                        label: 'Contraseña',
                        hintText: '********',
                        prefixIcon: Icons.lock_outline,
                        obscureText: true,
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: guardando
                      ? null
                      : () => Navigator.pop(dialogContext, false),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Color(0xFF1A365D)),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA9E05A),
                    foregroundColor: const Color(0xFF1A365D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: guardando
                      ? null
                      : () async {
                          final nombre = nombreController.text.trim();
                          final correo = correoController.text.trim();
                          final direccion = direccionController.text.trim();
                          final password = passwordController.text;

                          if (nombre.isEmpty || correo.isEmpty) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                  content: Text('Ingresa nombre y correo')),
                            );
                            return;
                          }

                          if (!correo.contains('@')) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                  content: Text('Ingresa un correo valido')),
                            );
                            return;
                          }

                          if (!esEdicion && password.length < 8) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'La contrasena debe tener al menos 8 caracteres'),
                              ),
                            );
                            return;
                          }

                          actualizarDialogo(() {
                            guardando = true;
                          });

                          try {
                            if (esEdicion) {
                              final actualizado = UserModel(
                                id: usuario.id,
                                nombre: nombre,
                                correo: correo,
                                direccion: direccion.isEmpty ? null : direccion,
                                tipoUsuario: usuario.tipoUsuario,
                              );

                              await userService.actualizarUsuario(actualizado);
                            } else {
                              final nuevo = UserModel(
                                id: 0,
                                nombre: nombre,
                                correo: correo,
                                password: password,
                                direccion: direccion.isEmpty ? null : direccion,
                                tipoUsuario:
                                    '1', // --- CAMBIO: Enviamos '1' como String (Admin por defecto) ---
                              );

                              await userService.agregarUsuario(nuevo);
                            }

                            if (!dialogContext.mounted) return;

                            Navigator.pop(dialogContext, true);
                          } catch (e) {
                            if (!dialogContext.mounted) return;

                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(content: Text('No se pudo guardar: $e')),
                            );

                            actualizarDialogo(() {
                              guardando = false;
                            });
                          }
                        },
                  child: Text(esEdicion ? 'Actualizar' : 'Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (resultado == true && mounted) {
      recargarUsuarios();

      mostrarMensaje(
        esEdicion
            ? 'Usuario actualizado correctamente'
            : 'Usuario registrado correctamente',
      );
    }
  }

  Future<void> eliminarUsuario(UserModel usuario) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFFE6F6FF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side:
              BorderSide(color: Colors.white.withValues(alpha: 0.8), width: 2),
        ),
        title: const Text(
          'Eliminar usuario',
          style:
              TextStyle(color: Color(0xFF1A365D), fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Deseas eliminar a ${usuario.nombre}?',
          style: const TextStyle(color: Color(0xFF1A365D)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF1A365D)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    try {
      await userService.eliminarUsuario(usuario.id);

      if (!mounted) return;

      recargarUsuarios();
      mostrarMensaje('Usuario eliminado correctamente');
    } catch (e) {
      mostrarMensaje('No se pudo eliminar: $e');
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
          'Gestión de usuarios',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: recargarUsuarios,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar lista',
          ),
        ],
      ),
      drawer: usuarioActual.isEmpty
          ? null
          : AdminDrawer(usuario: usuarioActual, rutaActual: '/users'),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFA9E05A), Color(0xFF7CB342)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.8), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () => mostrarFormulario(),
          child: const Icon(Icons.add, color: Color(0xFF1A365D)),
        ),
      ),
      body: AuthBackground(
        child: SafeArea(
          child: FutureBuilder<List<UserModel>>(
            future: futuroUsuarios,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF1A365D)),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off,
                            size: 48, color: Color(0xFF1A365D)),
                        const SizedBox(height: 12),
                        const Text(
                          'No se pudieron cargar los usuarios.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Color(0xFF1A365D),
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF1A365D)),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFA9E05A),
                            foregroundColor: const Color(0xFF1A365D),
                          ),
                          onPressed: recargarUsuarios,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final usuarios = snapshot.data ?? [];

              if (usuarios.isEmpty) {
                return const Center(
                  child: Text(
                    'No hay usuarios registrados',
                    style: TextStyle(color: Color(0xFF1A365D), fontSize: 16),
                  ),
                );
              }

              return RefreshIndicator(
                color: const Color(0xFF1A365D),
                onRefresh: () async {
                  final nuevoFuturo = userService.obtenerUsuarios();
                  setState(() {
                    futuroUsuarios = nuevoFuturo;
                  });
                  await nuevoFuturo;
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: usuarios.length,
                  itemBuilder: (context, index) {
                    final usuario = usuarios[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.8),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.withValues(alpha: 0.2),
                          child: const Icon(Icons.person,
                              color: Color(0xFF1A365D)),
                        ),
                        title: Text(
                          usuario.nombre,
                          style: const TextStyle(
                            color: Color(0xFF1A365D),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          usuario.correo,
                          style: TextStyle(
                            color:
                                const Color(0xFF1A365D).withValues(alpha: 0.7),
                          ),
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert,
                              color: Color(0xFF1A365D)),
                          onSelected: (opcion) {
                            if (opcion == 'editar') {
                              mostrarFormulario(usuario: usuario);
                            } else if (opcion == 'eliminar') {
                              eliminarUsuario(usuario);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'editar',
                              child: Text('Editar'),
                            ),
                            PopupMenuItem(
                              value: 'eliminar',
                              child: Text('Eliminar',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
