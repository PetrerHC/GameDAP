import 'package:flutter/material.dart';
// Representa los datos de cada comentario recibido.
import '../Models/comentario_model.dart';
import '../Models/post_model.dart';
// Permite identificar al usuario que comenta o da like.
import '../services/auth_service.dart';
// Consulta y guarda los comentarios en la API.
import '../services/comentario_service.dart';
// Consulta la publicación y cambia sus likes.
import '../services/post_service.dart';

class PostDetailPage extends StatefulWidget {
  final PostModel post;
  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final postService = PostService();
  final comentarioService = ComentarioService();
  // Lee el texto que se escribe en el campo de comentario.
  final comentarioController = TextEditingController();
  late PostModel post;
  // Guarda los comentarios que se muestran debajo de la publicación.
  List<ComentarioModel> comentarios = [];
  // Estas variables evitan repetir acciones mientras la API responde.
  bool cargando = true;
  bool enviando = false;
  bool cambiandoLike = false;
  String? errorCarga;

  int? get usuarioId => AuthService.usuarioActual?['id_usr'] as int?;

  @override
  void initState() {
    super.initState();
    post = widget.post;
    cargarDetalle();
  }

  @override
  void dispose() {
    comentarioController.dispose();
    super.dispose();
  }

  // Trae la publicación y sus comentarios actualizados.
  Future<void> cargarDetalle() async {
    setState(() {
      cargando = true;
      errorCarga = null;
    });
    try {
      final actualizado = await postService.obtenerPost(post.id);
      final lista = await comentarioService.obtenerComentarios(post.id);
      // Si la pantalla ya se cerró, no se cambian sus datos.
      if (!mounted) return;
      setState(() {
        post = actualizado;
        comentarios = lista;
      });
    } catch (error) {
      if (mounted) {
        setState(() =>
            errorCarga = error.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  void mostrarError(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error.toString().replaceFirst('Exception: ', '')),
      backgroundColor: Colors.red,
    ));
  }

  Future<void> cambiarLike() async {
    if (usuarioId == null) {
      mostrarError('Inicia sesión para dar like');
      return;
    }
    if (cambiandoLike) return;
    setState(() => cambiandoLike = true);
    try {
      final actualizado = await postService.cambiarLike(post, usuarioId!);
      if (mounted) setState(() => post = actualizado);
    } catch (error) {
      if (mounted) {
        mostrarError(error);
        await cargarDetalle();
      }
    } finally {
      if (mounted) setState(() => cambiandoLike = false);
    }
  }

  // Guarda el comentario y luego actualiza la lista y el contador.
  Future<void> enviarComentario() async {
    if (usuarioId == null || enviando) return;
    final texto = comentarioController.text.trim();
    if (texto.isEmpty || texto.length > 255) {
      mostrarError('Escribe un comentario de 1 a 255 caracteres');
      return;
    }
    setState(() => enviando = true);
    try {
      await comentarioService.agregarComentario(
        usuarioId: usuarioId!,
        blogId: post.id,
        texto: texto,
      );
      if (!mounted) return;
      comentarioController.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Comentario publicado'),
        backgroundColor: Color(0xFF7CB342),
      ));
      await cargarDetalle();
    } catch (error) {
      if (mounted) mostrarError(error);
    } finally {
      if (mounted) setState(() => enviando = false);
    }
  }

  // Muestra la fecha en el orden día, mes y año.
  String fechaLegible(String valor) {
    final fecha = DateTime.tryParse(valor);
    if (fecha == null) return '';
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle'),
        actions: [
          IconButton(
            tooltip: 'Actualizar publicación',
            onPressed:
                cargando || enviando || cambiandoLike ? null : cargarDetalle,
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: ListView(
        children: [
          if (post.imagen.isNotEmpty)
            Image.network(
              post.imagen,
              height: 230,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const SizedBox(
                height: 150,
                child: Icon(Icons.image_not_supported, size: 48),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.tags.isNotEmpty)
                  Text(post.tags,
                      style: const TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(post.titulo,
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text(post.descripcion,
                    style: const TextStyle(fontSize: 17, height: 1.6)),
                const SizedBox(height: 16),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    IconButton(
                      tooltip: post.meGusta ? 'Quitar like' : 'Dar like',
                      onPressed: cargando || cambiandoLike ? null : cambiarLike,
                      icon: Icon(
                          post.meGusta ? Icons.favorite : Icons.favorite_border,
                          color: post.meGusta ? Colors.red : Colors.blue),
                    ),
                    Text('${post.cantLikes} likes'),
                    Text('${post.cantComentarios} comentarios'),
                  ],
                ),
                const Divider(),
                const Text('Comentarios',
                    style:
                        TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (cargando)
                  const Center(child: CircularProgressIndicator())
                else if (errorCarga != null) ...[
                  Text(errorCarga!),
                  TextButton(
                      onPressed: cargarDetalle,
                      child: const Text('Reintentar')),
                ] else if (comentarios.isEmpty)
                  const Text('Sé el primero en comentar.')
                else
                  for (final comentario in comentarios)
                    Card(
                      child: ListTile(
                        title: Text(comentario.nombreUsuario,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(comentario.texto),
                            const SizedBox(height: 4),
                            Text(fechaLegible(comentario.fecha),
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                const SizedBox(height: 16),
                if (usuarioId == null)
                  TextButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context, '/login', (route) => false),
                    child: const Text('Inicia sesión para comentar'),
                  )
                else ...[
                  TextField(
                    controller: comentarioController,
                    enabled: !enviando,
                    maxLength: 255,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Escribe un comentario',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: enviando || cargando || errorCarga != null
                        ? null
                        : enviarComentario,
                    child: Text(enviando ? 'Enviando...' : 'Enviar'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
