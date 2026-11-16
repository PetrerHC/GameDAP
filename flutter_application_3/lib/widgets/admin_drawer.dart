import 'package:flutter/material.dart';

class AdminDrawer extends StatelessWidget {
  final Map<String, dynamic> usuario;
  final String rutaActual;

  const AdminDrawer({
    super.key,
    required this.usuario,
    required this.rutaActual,
  });

  String get nombre => usuario['nom_usr']?.toString() ?? 'Administrador';
  String get correo => usuario['mail']?.toString() ?? '';

  void _navegar(BuildContext context, String ruta) {
    Navigator.pop(context);
    if (ruta == rutaActual) return;
    Navigator.pushReplacementNamed(
      context,
      ruta,
      arguments: usuario,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Container para darle el fondo degradado al Drawer
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFC9F2F9),
              Color(0xFFA8E0D8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color:
                      Colors.white.withValues(alpha: 0.4), // Fondo de cristal
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 35,
                        backgroundColor: Color(0xFF1A365D),
                        child: Icon(
                          Icons.admin_panel_settings,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Nombre
                    Text(
                      nombre,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A365D),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    // Correo
                    Text(
                      correo,
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF1A365D).withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // --- OPCIONES DEL MENÚ ---
              _opcion(context, Icons.people_alt_outlined, 'Gestión de usuarios',
                  '/users'),
              _opcion(context, Icons.person_add_alt_1, 'Registrar usuario',
                  '/register'),
              _opcion(context, Icons.post_add, 'Agregar blog', '/add-blog'),
              _opcion(context, Icons.account_circle_outlined, 'Mi perfil',
                  '/profile'),

              const Spacer(),
              const Divider(color: Colors.white54),

              ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFFE53935)),
                title: const Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    color: Color(0xFFE53935),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // Widget reutilizable para las opciones del menú
  Widget _opcion(
    BuildContext context,
    IconData icono,
    String titulo,
    String ruta,
  ) {
    final seleccionado = ruta == rutaActual;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          // Si está seleccionado, le damos un fondo de cristal
          color: seleccionado
              ? Colors.white.withValues(alpha: 0.6)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: seleccionado
              ? Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1)
              : null,
        ),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          leading: Icon(
            icono,
            color: seleccionado
                ? const Color(0xFF1A365D)
                : const Color(0xFF1A365D).withValues(alpha: 0.6),
          ),
          title: Text(
            titulo,
            style: TextStyle(
              color: const Color(0xFF1A365D),
              fontWeight: seleccionado ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          selected: seleccionado,
          onTap: () => _navegar(context, ruta),
        ),
      ),
    );
  }
}
