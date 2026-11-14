import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/post_service.dart';
import '../widgets/admin_drawer.dart';

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
    if (tituloController.text.trim().length < 2 ||
        descripcionController.text.trim().isEmpty ||
        foto == null ||
        imagenBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa el título, la descripción y toma una foto.'),
        ),
      );
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
        const SnackBar(content: Text('Publicación guardada correctamente')),
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
        ),
      );
    } finally {
      if (mounted) setState(() => guardando = false);
    }
  }

  // --- MÉTODO PARA CREAR LOS CAMPOS DE TEXTO CON ESTILO ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int minLines = 1,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF005662)),
        // Efecto cristal en los inputs
        filled: true,
        fillColor: Colors.white.withOpacity(0.7),
        alignLabelWithHint: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF80DEEA), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF80DEEA), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF00ACC1), width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final argumentos = ModalRoute.of(context)?.settings.arguments;
    final usuario = argumentos is Map<String, dynamic>
        ? Map<String, dynamic>.from(argumentos)
        : <String, dynamic>{};

    return Scaffold(
      // Hacemos el fondo del AppBar transparente para que se mezcle con el degradado
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Agregar publicación',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: usuario.isEmpty
          ? null
          : AdminDrawer(
              usuario: usuario,
              rutaActual: '/add-blog',
            ),
      // FONDO DEGRADADO (Estilo Frutiger Aero: Azul cielo a verde agua)
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF39A9C9), // Azul mockup
              Color(0xFFB2EBF2), // Celeste claro
              Color(0xFFB2DFDB), // Verde agua claro
            ],
          ),
        ),
        child: Stack(
          children: [
            // BURBUJAS DECORATIVAS DE FONDO (Para dar el toque Frutiger Aero)
            Positioned(
              top: 80,
              right: 30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.5), width: 2),
                ),
              ),
            ),
            Positioned(
              bottom: 150,
              left: 20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.4), width: 2),
                ),
              ),
            ),

            // CONTENIDO PRINCIPAL
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // TARJETA PRINCIPAL ESTILO CRISTAL (Glassmorphism)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.65), // Transparencia
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.8),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTextField(
                          controller: tituloController,
                          label: 'Título',
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: descripcionController,
                          label: 'Descripción',
                          minLines: 4,
                          maxLines: 8,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: tagsController,
                          label: 'Etiquetas (opcional)',
                        ),
                        const SizedBox(height: 20),

                        // BOTÓN DE FOTO (Estilo botón azul de los mockups)
                        ElevatedButton.icon(
                          onPressed: guardando ? null : tomarFoto,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00BCD4),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: Text(
                            foto == null ? 'Tomar foto' : 'Cambiar foto',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // VISTA PREVIA DE LA FOTO
                  if (imagenBytes != null)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
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

                  const SizedBox(height: 24),

                  // BOTÓN DE GUARDAR (Estilo Frutiger Aero: Verde brillante)
                  // Usamos un Container con degradado para simular el efecto "Glossy"
                  Container(
                    height: 55,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFAED581), // Verde claro (brillo arriba)
                          Color(0xFF4CAF50), // Verde oscuro abajo
                        ],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      border:
                          Border.all(color: const Color(0xFF2E7D32), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: guardando ? null : guardarPublicacion,
                        child: Center(
                          child: guardando
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Text(
                                  'Guardar publicación',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black45,
                                        offset: Offset(1, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
