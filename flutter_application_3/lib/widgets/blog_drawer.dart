import 'package:flutter/material.dart';
// Permite cerrar la sesión desde el menú.
import '../services/auth_service.dart';

class BlogDrawer extends StatelessWidget {
  final Map<String, dynamic> usuario;
  final bool esAdmin;
  final String rutaActual;

  const BlogDrawer({
    super.key,
    required this.usuario,
    required this.esAdmin,
    required this.rutaActual,
  });

  @override
  Widget build(BuildContext context) {
    final nombre = usuario['nom_usr']?.toString() ?? 'Visitante';
    final correo = usuario['mail']?.toString() ?? '';

    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFC9F2F9), Color(0xFFA8E0D8)]),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.4),
                  border: Border(
                      bottom: BorderSide(
                          color: Colors.white.withValues(alpha: 0.6),
                          width: 1.5)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.8)),
                      child: const CircleAvatar(
                          radius: 30,
                          backgroundColor: Color(0xFF1A365D),
                          child: Icon(Icons.person,
                              color: Colors.white, size: 35)),
                    ),
                    const SizedBox(height: 12),
                    Text(nombre,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A365D))),
                    Text(correo,
                        style: TextStyle(
                            fontSize: 13,
                            color: const Color(0xFF1A365D)
                                .withValues(alpha: 0.7))),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              _opcion(context, Icons.home, 'Inicio (Blog)', '/blog'),

              // Solo se muestra si es Administrador
              if (esAdmin)
                _opcion(context, Icons.people_alt_outlined,
                    'Gestión de usuarios', '/users'),

              const Spacer(),
              const Divider(color: Colors.white54),

              ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFFE53935)),
                title: Text(
                    usuario.isEmpty ? 'Iniciar sesión' : 'Cerrar sesión',
                    style: const TextStyle(
                        color: Color(0xFFE53935), fontWeight: FontWeight.w600)),
                onTap: () {
                  AuthService.cerrarSesion();
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (route) => false);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _opcion(
      BuildContext context, IconData icono, String titulo, String ruta) {
    final seleccionado = ruta == rutaActual;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: seleccionado
              ? Colors.white.withValues(alpha: 0.6)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: seleccionado
              ? Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1)
              : null,
        ),
        child: ListTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          leading: Icon(icono,
              color: seleccionado
                  ? const Color(0xFF1A365D)
                  : const Color(0xFF1A365D).withValues(alpha: 0.6)),
          title: Text(titulo,
              style: TextStyle(
                  color: const Color(0xFF1A365D),
                  fontWeight:
                      seleccionado ? FontWeight.bold : FontWeight.w500)),
          onTap: () {
            // Cierra el menú antes de abrir la pantalla elegida.
            Navigator.pop(context);
            if (ruta == rutaActual) return;
            Navigator.pushReplacementNamed(context, ruta, arguments: usuario);
          },
        ),
      ),
    );
  }
}
