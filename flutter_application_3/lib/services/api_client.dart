// Permite detectar cuando el servidor tarda demasiado.
import 'dart:async';
// Convierte los datos que se envían y reciben en JSON.
import 'dart:convert';
// Permite hacer las peticiones a la API.
import 'package:http/http.dart' as http;
// Contiene la dirección del servidor.
import 'api_config.dart';

class ApiClient {
  // Guarda el ID del usuario; queda vacío al entrar como visitante.
  static int? usuarioId;

  // Indica que los datos se envían y reciben en JSON.
  static Map<String, String> get headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

  // Une la dirección del servidor con la ruta que se quiere consultar.
  static Uri url(String ruta, [Map<String, String>? parametros]) {
    return Uri.parse('${ApiConfig.baseUrl}$ruta')
        .replace(queryParameters: parametros);
  }

  // Consulta datos sin cambiarlos.
  static Future<dynamic> get(String ruta, {Map<String, String>? parametros}) {
    return recibir(http.get(url(ruta, parametros), headers: headers));
  }

  // Envía los datos de un registro nuevo.
  static Future<dynamic> post(String ruta, Map<String, dynamic> datos) {
    return recibir(
        http.post(url(ruta), headers: headers, body: jsonEncode(datos)));
  }

  // Envía los cambios de un registro.
  static Future<dynamic> put(String ruta, Map<String, dynamic> datos) {
    return recibir(
        http.put(url(ruta), headers: headers, body: jsonEncode(datos)));
  }

  // Pide eliminar el registro indicado.
  static Future<dynamic> delete(String ruta,
      {Map<String, String>? parametros}) {
    return recibir(http.delete(url(ruta, parametros), headers: headers));
  }

  static Future<dynamic> subirImagen(http.MultipartRequest solicitud) {
    return recibir(enviarArchivo(solicitud));
  }

  // Espera a que termine el envío de la foto y reúne la respuesta.
  static Future<http.Response> enviarArchivo(
      http.MultipartRequest solicitud) async {
    final envio = await solicitud.send();
    final respuesta = await http.Response.fromStream(envio);
    return respuesta;
  }

  static Future<dynamic> recibir(Future<http.Response> solicitud) async {
    try {
      final respuesta = await solicitud.timeout(const Duration(seconds: 20));
      dynamic datos;
      try {
        if (respuesta.body.isNotEmpty) {
          datos = jsonDecode(utf8.decode(respuesta.bodyBytes));
        }
      } on FormatException {
        throw Exception('El servidor devolvió una respuesta no válida');
      }
      // Los códigos del 200 al 299 indican que la petición salió bien.
      if (respuesta.statusCode >= 200 && respuesta.statusCode < 300) {
        return datos;
      }
      if (datos is Map && datos['detail'] is String) {
        throw Exception(datos['detail']);
      }
      throw Exception(
          'No se pudo completar la solicitud. Revisa los datos e inténtalo otra vez');
    } on TimeoutException {
      throw Exception('El servidor tardó demasiado. Inténtalo otra vez');
    } on http.ClientException {
      throw Exception('No se pudo conectar con el servidor');
    }
  }
}
