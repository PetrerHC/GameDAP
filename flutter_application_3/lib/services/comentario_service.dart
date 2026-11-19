import '../Models/comentario_model.dart';
// Permite consultar y guardar comentarios en la API.
import 'api_client.dart';

class ComentarioService {
  // Consulta solo los comentarios de esta publicación.
  Future<List<ComentarioModel>> obtenerComentarios(int blogId) async {
    final datos = await ApiClient.get('/blogs/$blogId/comentarios') as List;
    List<ComentarioModel> comentarios = [];
    for (final dato in datos) {
      comentarios.add(ComentarioModel.fromJson(dato));
    }
    return comentarios;
  }

  Future<ComentarioModel> agregarComentario({
    required int usuarioId,
    required int blogId,
    required String texto,
    String idStiker = '',
  }) async {
    // El servidor completa el nombre y la fecha del comentario.
    final datos = await ApiClient.post('/comentarios', {
      'id_usuario': usuarioId,
      'id_blog': blogId,
      'texto': texto.trim(),
      'id_stiker': idStiker,
    });
    return ComentarioModel.fromJson(datos);
  }
}
