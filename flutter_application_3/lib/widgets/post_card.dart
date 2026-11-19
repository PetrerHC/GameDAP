import 'package:flutter/material.dart';
import '../Models/post_model.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onTap;
  // Recibe la acción del corazón; si está vacío, el botón se desactiva.
  final VoidCallback? onLike;

  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
    this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.1),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.5),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.imagen.isNotEmpty)
                  Image.network(
                    post.imagen,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(
                        height: 110,
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: Color(0xFF1A365D),
                          ),
                        ),
                      );
                    },
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (post.tags.isNotEmpty) ...[
                        Text(
                          post.tags,
                          style: const TextStyle(
                            color: Color(0xFF2196F3),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Text(
                        post.titulo,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A365D),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        post.descripcion,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF1A365D).withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Divider(color: Colors.black12, height: 1),
                      const SizedBox(height: 10),
                      // Si falta espacio, los contadores pasan a otra línea.
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 16,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip:
                                    post.meGusta ? 'Quitar like' : 'Dar like',
                                onPressed: onLike,
                                icon: Icon(
                                  post.meGusta
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 22,
                                  color: post.meGusta
                                      ? Colors.red
                                      : const Color(0xFF2196F3),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '${post.cantLikes}',
                                style: const TextStyle(
                                    color: Color(0xFF1A365D),
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.chat_bubble_outline,
                                  size: 18, color: Color(0xFF2196F3)),
                              const SizedBox(width: 5),
                              Text(
                                '${post.cantComentarios} comentarios',
                                style: const TextStyle(
                                    color: Color(0xFF1A365D),
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
