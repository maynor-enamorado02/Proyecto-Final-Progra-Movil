import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login_page.dart';

class OpcionesPage extends StatefulWidget {
  const OpcionesPage({super.key});

  @override
  OpcionesPageState createState() => OpcionesPageState();
}

class OpcionesPageState extends State<OpcionesPage> {
  bool _isDarkMode = false;
  User? _usuario;

  @override
  void initState() {
    super.initState();
    _usuario = FirebaseAuth.instance.currentUser;
  }

  Future<void> _cerrarSesion() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil de Usuario')),
      body: _usuario == null
          ? const Center(child: Text("No hay usuario autenticado"))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(_usuario!.photoURL ??
                            'https://cdn-icons-png.flaticon.com/512/149/149071.png'),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _usuario!.isAnonymous
                            ? 'Usuario anónimo'
                            : _usuario!.displayName ?? 'Nombre no disponible',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _usuario!.isAnonymous
                            ? 'No has iniciado sesión'
                            : _usuario!.email ?? 'Correo no disponible',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Divider(),

                // Si el usuario es anónimo, mostramos el botón para iniciar sesión
                if (_usuario!.isAnonymous)
                  ListTile(
                    leading: const Icon(Icons.login),
                    title: const Text('Iniciar Sesión'),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                  )
                else ...[
                  ListTile(
                    leading: const Icon(Icons.dark_mode),
                    title: const Text('Modo Oscuro'),
                    trailing: Switch(
                      value: _isDarkMode,
                      onChanged: (bool value) {
                        setState(() {
                          _isDarkMode = value;
                        });
                      },
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Cerrar sesión'),
                    onTap: _cerrarSesion,
                  ),
                ],
              ],
            ),
    );
  }
}
