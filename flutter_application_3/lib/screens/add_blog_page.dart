import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/post_service.dart';
// Permite saber qué menú mostrar al usuario.
import '../services/auth_service.dart';
// Muestra el menú para los usuarios generales.
import '../widgets/blog_drawer.dart';
import '../widgets/admin_drawer.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class AddBlogPage extends StatefulWidget {
  const AddBlogPage({super.key});

  @override
  State<AddBlogPage> createState() => _AddBlogPageState();
}

class _AddBlogPageState extends State<AddBlogPage> {
  final PostService postService = PostService();
  final ImagePicker picker = ImagePicker();

  final tituloController = TextEditingController();
  final descripcionController = TextEditingController();
  final tagsController = TextEditingController();

  XFile? foto;
  Uint8List? imagenBytes;
  bool guardando = false;

  @override
  void dispose() {
    tituloController.dispose();
    descripcionController.dispose();
    tagsController.dispose();
    super.dispose();
  }

  Future<void> tomarFoto() async {
    try {
      final imagen = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 75,
      );

      if (imagen == null) return;

      final bytes = await imagen.readAsBytes();
      if (!mounted) return;

      setState(() {
        foto = imagen;
        imagenBytes = bytes;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir la cámara: $error')),
      );
    }
  }

  Future<void> guardarPublicacion() async {
    if (guardando) return;
    if (tituloController.text.trim().length < 2 ||
        tituloController.text.trim().length > 150 ||
        tagsController.text.trim().length > 255 ||
        descripcionController.text.trim().isEmpty ||
        foto == null ||
        imagenBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Completa el título (2 a 150 caracteres), la descripción, las etiquetas (máximo 255) y toma una foto.'),
        ),
      );
      return;
    }

    // Revisa que la foto no supere los 8 MB que acepta la API.
    if (imagenBytes!.length > 8 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('La imagen no debe superar 8 MB'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() => guardando = true);

    try {
      await postService.agregarPost(
        titulo: tituloController.text,
        descripcion: descripcionController.text,
        imagenBytes: imagenBytes!,
        nombreArchivo: foto!.name,
        tags: tagsController.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Publicación guardada correctamente'),
          backgroundColor: Color(0xFF7CB342), // Verde GameDAP
        ),
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo guardar: '
            '${error.toString().replaceFirst('Exception: ', '')}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final argumentos = ModalRoute.of(context)?.settings.arguments;
    final usuario = argumentos is Map<String, dynamic>
        ? Map<String, dynamic>.from(argumentos)
        : <String, dynamic>{};

    // Elige el menú según el tipo de cuenta.
    Widget? menu;
    if (usuario.isNotEmpty) {
      if (AuthService.esAdmin) {
        menu = AdminDrawer(usuario: usuario, rutaActual: '/add-blog');
      } else {
        menu = BlogDrawer(
            usuario: usuario, esAdmin: false, rutaActual: '/add-blog');
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1A365D),
        title: const Text(
          'Agregar publicación',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      drawer: menu,
      body: AuthBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Center(
              child: AuthCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'DETALLES DE LA PUBLICACIÓN',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A365D),
                      ),
                    ),
                    const SizedBox(height: 20),

                    CustomTextField(
                      controller: tituloController,
                      label: 'Título',
                      hintText: 'Ej. Mi primer refugio en Minecraft',
                      prefixIcon: Icons.title,
                    ),
                    const SizedBox(height: 15),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 4.0, bottom: 6.0),
                          child: Text(
                            'Descripción',
                            style: TextStyle(
                              color: Color(0xFF1A365D),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        TextField(
                          controller: descripcionController,
                          minLines: 4,
                          maxLines: 8,
                          textCapitalization: TextCapitalization.sentences,
                          style: const TextStyle(color: Color(0xFF1A365D)),
                          decoration: InputDecoration(
                            hintText: 'Escribe de que trata tu publicación...',
                            hintStyle: TextStyle(
                              color: const Color(0xFF1A365D)
                                  .withValues(alpha: 0.5),
                            ),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.6),
                            prefixIcon: Icon(
                              Icons.description_outlined,
                              color: const Color(0xFF1A365D)
                                  .withValues(alpha: 0.7),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.white.withValues(alpha: 0.8),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF2196F3),
                                width: 2.0,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: 16.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    CustomTextField(
                      controller: tagsController,
                      label: 'Etiquetas (opcional)',
                      hintText: 'Ej. Minecraft, Guía, Principiantes',
                      prefixIcon: Icons.tag,
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton.icon(
                      onPressed: guardando ? null : tomarFoto,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF29B6F6),
                        foregroundColor: const Color(0xFF1A365D),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.6),
                            width: 1.5,
                          ),
                        ),
                        elevation: 4,
                        shadowColor: Colors.blue.withValues(alpha: 0.4),
                      ),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: Text(
                        foto == null ? 'Tomar foto' : 'Cambiar foto',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Vista previa de la foto
                    if (imagenBytes != null)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.8),
                              width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            imagenBytes!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                    const SizedBox(height: 25),

                    PrimaryButton(
                      text: guardando ? 'Guardando...' : 'Guardar publicación',
                      onPressed: guardando ? null : guardarPublicacion,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
