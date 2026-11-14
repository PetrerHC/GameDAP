import 'package:flutter/material.dart';

class RecoveryPage extends StatefulWidget {
  const RecoveryPage({super.key});

  @override
  State<RecoveryPage> createState() =>
      _RegisterPageState();
}

class _RegisterPageState
    extends State<RecoveryPage> {

  final TextEditingController nombreController =
      TextEditingController();

  final TextEditingController correoController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recupera tu cuenta apa'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          children: [

            const Icon(
              Icons.mark_email_read,
              size: 70,
              color: Color(0xFFC9A227),
            ),

            const SizedBox(height: 20),

            const Text(
              'Cuenta a recuperar',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF08245C),
              ),
            ),


            const SizedBox(height: 15),

            TextField(
              controller:
                  correoController,

              decoration:
                  const InputDecoration(
                labelText:
                    'Correo electrónico para recuperar',
                prefixIcon:
                    Icon(Icons.email),
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  passwordController,

              obscureText: true,

              decoration:
                  const InputDecoration(
                labelText:
                    'Nueva Contraseña',
                prefixIcon:
                    Icon(Icons.lock),
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () {

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Credenciales recuperadas',
                      ),
                    ),
                  );
                },

                child:
                    const Text('Recuperar'),
              ),
            ),

            const SizedBox(height: 15),

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text(
                'cuenta recuperada',
              ),
            ),
          ],
        ),
      ),
    );
  }
}