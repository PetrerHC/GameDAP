import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    // Lee la dirección indicada al ejecutar Flutter, si se proporcionó.
    const configurada = String.fromEnvironment('API_BASE_URL');
    if (configurada.isNotEmpty) {
      // Quita la barra final para no repetirla al agregar una ruta.
      if (configurada.endsWith('/')) {
        return configurada.substring(0, configurada.length - 1);
      }
      return configurada;
    }
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      // Android Emulator -> computadora anfitriona.
      return 'http://10.0.2.2:8000';
    }

    return 'http://127.0.0.1:8000';
  }

  // Completa la dirección de la foto para que Image.network pueda abrirla.
  static String imagenUrl(String ruta) {
    if (ruta.isEmpty) return '';
    final uri = Uri.parse(ruta);
    // Las fotos locales usan el mismo servidor que la API, también en Android.
    if (!uri.hasScheme ||
        (['localhost', '127.0.0.1', '10.0.2.2'].contains(uri.host) &&
            uri.path.startsWith('/uploads/'))) {
      return Uri.parse('$baseUrl/').resolve(uri.path).toString();
    }
    return ruta;
  }
}
