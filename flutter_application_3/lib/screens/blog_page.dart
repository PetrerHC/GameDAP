import 'package:flutter/material.dart';
import '../Models/post_model.dart';
// Permite saber quién está usando la app.
import '../services/auth_service.dart';
import '../services/post_service.dart';
import '../widgets/blog_drawer.dart';
import '../widgets/category_chip.dart';
import '../widgets/post_card.dart';
import '../widgets/auth_background.dart';
import 'post_detail_page.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({super.key});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  final postService = PostService();
  // Guarda la consulta mientras la API devuelve las publicaciones.
  late Future<List<PostModel>> futurePosts;
  // Guarda los IDs que están esperando respuesta para no repetir el like.
  final List<int> likesPendientes = [];
  // Indica cuál de los filtros está seleccionado.
  String categoria = 'Todos';

  @override
  void initState() {
    super.initState();
    futurePosts = postService.obtenerPosts();
  }

  void recargarPosts() {
    setState(() {
      futurePosts = postService.obtenerPosts(tag: categoria);
    });
  }

  // Cambia la categoría y vuelve a consultar las publicaciones.
  void filtrar(String seleccion) {
    if (seleccion == categoria) return;
    setState(() {
      categoria = seleccion;
      futurePosts = postService.obtenerPosts(tag: categoria);
    });
  }

  Future<void> cambiarLike(PostModel post) async {
    final usuarioId = AuthService.usuarioActual?['id_usr'] as int?;
    if (usuarioId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Inicia sesión para dar like'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    if (likesPendientes.contains(post.id)) return;
    setState(() {
      likesPendientes.add(post.id);
    });
    try {
      await postService.cambiarLike(post, usuarioId);
      if (mounted) recargarPosts();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.toString().replaceFirst('Exception: ', '')),
        backgroundColor: Colors.red,
      ));
      recargarPosts();
    } finally {
      // Solo actualiza la pantalla si el usuario sigue en ella.
      if (mounted) {
        setState(() {
          likesPendientes.remove(post.id);
        });
      }
    }
  }

  Future<void> abrirDetalle(PostModel post) async {
    await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => PostDetailPage(post: post),
        ));
    // Vuelve a consultar los contadores al regresar del detalle.
    if (mounted) recargarPosts();
  }

  @override
  Widget build(BuildContext context) {
    final usuario = AuthService.usuarioActual ?? <String, dynamic>{};
    final nombre = usuario['nom_usr']?.toString() ?? 'visitante';
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF1A365D),
        title: const Text('GameDAP - Home'),
        actions: [
          IconButton(
            onPressed: recargarPosts,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar publicaciones',
          )
        ],
      ),
      drawer: BlogDrawer(
          usuario: usuario, esAdmin: AuthService.esAdmin, rutaActual: '/blog'),
      floatingActionButton: usuario.isEmpty
          ? null
          : FloatingActionButton(
              tooltip: 'Crear publicación',
              onPressed: () async {
                await Navigator.pushNamed(context, '/add-blog',
                    arguments: usuario);
                if (mounted) recargarPosts();
              },
              child: const Icon(Icons.add),
            ),
      body: AuthBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                child: Text('Bienvenido, $nombre',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A365D),
                    )),
              ),
              SizedBox(
                height: 45,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    for (final tag in ['Todos', 'Minecraft', 'Guías'])
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: CategoryChip(
                          text: tag,
                          selected: categoria == tag,
                          onTap: () => filtrar(tag),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                // Muestra la espera, el error o la lista según la respuesta.
                child: FutureBuilder<List<PostModel>>(
                  future: futurePosts,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                          child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              snapshot.error
                                  .toString()
                                  .replaceFirst('Exception: ', ''),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          ElevatedButton(
                              onPressed: recargarPosts,
                              child: const Text('Reintentar')),
                        ],
                      ));
                    }
                    final posts = snapshot.data ?? [];
                    if (posts.isEmpty) {
                      return const Center(
                          child:
                              Text('No hay publicaciones en esta categoría.'));
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        recargarPosts();
                        try {
                          await futurePosts;
                        } catch (_) {
                          // El error ya se muestra arriba junto al botón Reintentar.
                        }
                      },
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          return PostCard(
                            post: post,
                            onTap: () => abrirDetalle(post),
                            onLike: likesPendientes.contains(post.id)
                                ? null
                                : () => cambiarLike(post),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
