import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';

class OpcionesPage extends StatefulWidget {
  const OpcionesPage({super.key});

  @override
  OpcionesPageState createState() => OpcionesPageState();
}

class OpcionesPageState extends State<OpcionesPage> {
  bool _isDarkMode = false;
  User? _usuario;
  Map<String, dynamic>? _datosUsuario;

  @override
  void initState() {
    super.initState();
    _usuario = FirebaseAuth.instance.currentUser;
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    final uid = _usuario?.uid;
    if (uid != null) {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        setState(() {
          _datosUsuario = doc.data();
        });
      }
    }
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
                      const SizedBox(height: 16),
                      if (_datosUsuario != null) ...[
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: Text("Nombre: ${_datosUsuario!['nombre'] ?? 'N/D'}"),
                        ),
                        ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: Text("Apellido: ${_datosUsuario!['apellido'] ?? 'N/D'}"),
                        ),
                        ListTile(
                          leading: const Icon(Icons.phone),
                          title: Text("Teléfono: ${_datosUsuario!['telefono'] ?? 'N/D'}"),
                        ),
                        ListTile(
                          leading: const Icon(Icons.flag),
                          title: Text("País: ${_datosUsuario!['pais'] ?? 'N/D'}"),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Divider(),

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