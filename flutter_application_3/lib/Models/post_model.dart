// Completa la dirección de las imágenes que vienen de la API.
import '../services/api_config.dart';

class PostModel {
  final int id;
  final String titulo;
  final String descripcion;
  final String imagen;
  final String tags;
  // Guarda los contadores y si el usuario ya dio like.
  final int cantLikes;
  final int cantComentarios;
  final bool meGusta;

  PostModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.imagen,
    required this.tags,
    this.cantLikes = 0,
    this.cantComentarios = 0,
    this.meGusta = false,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id_blog'] as int,
      titulo: json['titulo'] as String,
      descripcion: (json['desc'] ?? json['descripcion']) as String? ?? '',
      imagen: ApiConfig.imagenUrl(json['img'] as String? ?? ''),
      tags: json['tags'] as String? ?? '',
      cantLikes: (json['cant_likes'] as num?)?.toInt() ?? 0,
      cantComentarios: (json['cant_comentarios'] as num?)?.toInt() ?? 0,
      meGusta: json['me_gusta'] == true,
    );
  }
}
