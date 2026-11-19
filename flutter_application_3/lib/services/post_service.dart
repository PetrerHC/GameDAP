import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../Models/post_model.dart';
// Hace las llamadas al servidor desde un mismo lugar.
import 'api_client.dart';

class PostService {
  // Agrega el ID para consultar cuáles publicaciones le gustan al usuario.
  Map<String, String> get parametrosUsuario {
    Map<String, String> parametros = {};
    if (ApiClient.usuarioId != null) {
      parametros['id_usuario'] = ApiClient.usuarioId.toString();
    }
    return parametros;
  }

  Future<PostModel> agregarPost({
    required String titulo,
    required String descripcion,
    required Uint8List imagenBytes,
    required String nombreArchivo,
    String? tags,
  }) async {
    // Envía la foto como archivo junto con el texto de la publicación.
    final solicitud = http.MultipartRequest('POST', ApiClient.url('/blogs'));
    solicitud.fields.addAll({
      'titulo': titulo.trim(),
      'desc': descripcion.trim(),
      'tags': tags?.trim() ?? '',
    });
    solicitud.files.add(http.MultipartFile.fromBytes(
      'imagen',
      imagenBytes,
      filename: nombreArchivo,
    ));
    final datos = await ApiClient.subirImagen(solicitud);
    return PostModel.fromJson(datos);
  }

  Future<List<PostModel>> obtenerPosts({String? tag}) async {
    final parametros = parametrosUsuario;
    if (tag != null && tag != 'Todos') {
      parametros['tag'] = tag;
    }
    final datos = await ApiClient.get('/blogs', parametros: parametros) as List;
    List<PostModel> publicaciones = [];
    for (final dato in datos) {
      publicaciones.add(PostModel.fromJson(dato));
    }
    return publicaciones;
  }

  Future<PostModel> obtenerPost(int id) async {
    final datos =
        await ApiClient.get('/blogs/$id', parametros: parametrosUsuario);
    return PostModel.fromJson(datos);
  }

  Future<PostModel> cambiarLike(PostModel post, int usuarioId) async {
    // Si ya tiene like, se quita; en caso contrario, se agrega.
    if (post.meGusta) {
      final datos = await ApiClient.delete('/blogs/${post.id}/likes',
          parametros: {'id_usuario': '$usuarioId'});
      return PostModel.fromJson(datos);
    }
    await ApiClient.post('/likeblog', {
      'id_usuario': usuarioId,
      'id_blog': post.id,
      'like': true,
    });
    return obtenerPost(post.id);
  }
}
