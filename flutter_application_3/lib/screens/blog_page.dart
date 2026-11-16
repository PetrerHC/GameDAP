import 'package:flutter/material.dart';
import '../Models/post_model.dart';
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
  final PostService postService = PostService();
  late Future<List<PostModel>> futurePosts;
  String nombreUsuario = 'Usuario';
  Map<String, dynamic> usuarioActual = {
    'nom_usr': 'Usuario',
    'mail': '',
    'tip_usu': '2'
  }; // Ahora '2' es String
  bool argumentoLeido = false;

  @override
  void initState() {
    super.initState();
    futurePosts = postService.obtenerPosts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (argumentoLeido) return;

    final argumento = ModalRoute.of(context)?.settings.arguments;
    if (argumento is Map<String, dynamic>) {
      usuarioActual = Map<String, dynamic>.from(argumento);
      nombreUsuario = usuarioActual['nom_usr']?.toString() ?? 'Usuario';
    } else if (argumento is String && argumento.isNotEmpty) {
      nombreUsuario = argumento;
      usuarioActual = {'nom_usr': nombreUsuario, 'mail': '', 'tip_usu': '2'};
    }
    argumentoLeido = true;
  }

  // --- CAMBIO: Evaluamos el String de la BD ---
  bool get esAdmin {
    final tipo = usuarioActual['tip_usu']?.toString().toLowerCase() ?? '2';
    return tipo == '1' || tipo == 'admin';
  }

  void recargarPosts() {
    setState(() => futurePosts = postService.obtenerPosts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1A365D),
        title: const Text('GameDAP - Home',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
              onPressed: recargarPosts,
              icon: const Icon(Icons.refresh),
              tooltip: 'Actualizar publicaciones'),
        ],
      ),
      // --- CAMBIO: Pasamos 'esAdmin' al Drawer ---
      drawer: BlogDrawer(
        usuario: usuarioActual,
        esAdmin: esAdmin,
        rutaActual: '/blog',
      ),
      body: AuthBackground(
        child: SafeArea(
          child: FutureBuilder<List<PostModel>>(
            future: futurePosts,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF1A365D)));
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off,
                            size: 45, color: Color(0xFF1A365D)),
                        const SizedBox(height: 12),
                        const Text('No fue posible cargar el blog.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xFF1A365D),
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFA9E05A),
                              foregroundColor: const Color(0xFF1A365D)),
                          onPressed: recargarPosts,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final posts = snapshot.data ?? <PostModel>[];
              if (posts.isEmpty) {
                return const Center(
                    child: Text('No hay publicaciones registradas.',
                        style:
                            TextStyle(color: Color(0xFF1A365D), fontSize: 16)));
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('Bienvenido, $nombreUsuario',
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1A365D))),
                  const SizedBox(height: 5),
                  Text('Descubre nuevas ideas',
                      style: TextStyle(
                          fontSize: 16,
                          color: const Color(0xFF1A365D).withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 45,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        CategoryChip(
                            text: 'Todos', selected: true, onTap: () {}),
                        const SizedBox(width: 10),
                        CategoryChip(
                            text: 'Minecraft', selected: false, onTap: () {}),
                        const SizedBox(width: 10),
                        CategoryChip(
                            text: 'Guías', selected: false, onTap: () {}),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...posts.map((post) => PostCard(
                        post: post,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                  builder: (context) =>
                                      PostDetailPage(post: post)));
                        },
                      )),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
