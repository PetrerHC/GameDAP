import 'package:flutter/material.dart';
import 'screens/add_blog_page.dart';
import 'screens/blog_page.dart';
import 'screens/login_user_page.dart';
import 'screens/profile_page.dart';
import 'screens/register_user_page.dart';
import 'screens/users_page.dart';
import 'screens/mapa_pages.dart';
import 'screens/recuperacion_user_page.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const LoginApp());
}

class LoginApp extends StatelessWidget {
  const LoginApp({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GameDAP',
      initialRoute: '/login',
      routes: {
        '/blog': (context) => const BlogPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/users': (context) =>
            AuthService.esAdmin ? const UsersPage() : const LoginPage(),
        '/add-blog': (context) => AuthService.usuarioActual != null
            ? const AddBlogPage()
            : const LoginPage(),
        '/profile': (context) =>
            AuthService.esAdmin ? const ProfilePage() : const LoginPage(),
        '/recovery': (context) => RecoveryPage(
              correo:
                  ModalRoute.of(context)?.settings.arguments as String? ?? '',
            ),
        '/mapa': (context) => const MapaPage(),
      },
    );
  }
}
