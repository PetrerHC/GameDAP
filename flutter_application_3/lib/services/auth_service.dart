// Representa los datos de una cuenta.
import '../Models/user_model.dart';
// Envía las peticiones de login, registro y recuperación.
import 'api_client.dart';

class AuthService {
  // Guarda los datos del usuario mientras usa la app.
  static Map<String, dynamic>? usuarioActual;

  static bool get esAdmin {
    if (usuarioActual == null) {
      return false;
    }
    return usuarioActual!['tip_usu'].toString() == '1';
  }

  String? validarLogin({required String usuario, required String password}) {
    if (usuario.trim().isEmpty || password.isEmpty) {
      return 'Ingresa tu correo y contraseña';
    }
    return null;
  }

  // Revisa la longitud y que las dos contraseñas sean iguales.
  String? validarPassword(String password, String confirmacion) {
    if (password.length < 8 || password.length > 128) {
      return 'La contraseña debe tener entre 8 y 128 caracteres';
    }
    if (password != confirmacion) return 'Las contraseñas no coinciden';
    return null;
  }

  String? validarRegistro({
    required String nombre,
    required String correo,
    required String password,
    required String confirmarpassword,
  }) {
    if (nombre.trim().length < 2 || nombre.trim().length > 100) {
      return 'El nombre debe tener entre 2 y 100 caracteres';
    }
    if (!correo.contains('@') || correo.contains(' ') || correo.length > 150) {
      return 'Ingresa un correo válido';
    }
    return validarPassword(password, confirmarpassword);
  }

  Future<Map<String, dynamic>> autenticar({
    required String correo,
    required String password,
  }) async {
    final datos = await ApiClient.post('/login', {
      'mail': correo.trim().toLowerCase(),
      'pass': password,
    }) as Map<String, dynamic>;
    // Conservamos el usuario completo para pasarlo entre pantallas.
    ApiClient.usuarioId = datos['id_usr'] as int;
    usuarioActual = datos;
    return datos;
  }

  Future<UserModel> registrar(UserModel usuario) async {
    final datos = usuario.toJsonCrear();
    // La API asigna el tipo 2 al registro público.
    datos.remove('tip_usu');
    final respuesta = await ApiClient.post('/register', datos);
    return UserModel.fromJson(respuesta as Map<String, dynamic>);
  }

  Future<void> recuperarPassword({
    required String correo,
    required String password,
    required String confirmacion,
  }) async {
    final error = validarPassword(password, confirmacion);
    if (error != null) throw Exception(error);
    // Actualiza la contraseña de la cuenta indicada por su correo.
    await ApiClient.post('/recuperar-password', {
      'mail': correo.trim().toLowerCase(),
      'password': password,
      'confirmar_password': confirmacion,
    });
    continuarComoVisitante();
  }

  // Borra los datos de la cuenta guardados en la app.
  static void continuarComoVisitante() {
    usuarioActual = null;
    ApiClient.usuarioId = null;
  }

  static void cerrarSesion() {
    continuarComoVisitante();
  }
}
