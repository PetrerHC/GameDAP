class ComentarioModel {
  final int id;
  final int usuarioId;
  final int blogId;
  final String nombreUsuario;
  final String texto;
  final String fecha;
  final String idStiker;

  ComentarioModel({
    required this.id,
    required this.usuarioId,
    required this.blogId,
    required this.nombreUsuario,
    required this.texto,
    required this.fecha,
    this.idStiker = '',
  });

  // Convierte los datos de la API en un comentario para la pantalla.
  factory ComentarioModel.fromJson(Map<String, dynamic> json) {
    return ComentarioModel(
      id: json['id_comentario'] as int,
      usuarioId: json['id_usuario'] as int,
      blogId: json['id_blog'] as int,
      nombreUsuario: json['nombre_usuario'] as String? ?? 'Usuario',
      texto: json['texto'] as String,
      fecha: json['fecha'] as String,
      idStiker: json['id_stiker'] as String? ?? '',
    );
  }
}
