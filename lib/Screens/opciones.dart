import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:PokeStats/utils/theme_provider.dart';
import 'login_page.dart';

class OpcionesPage extends StatefulWidget {
  const OpcionesPage({super.key});

  @override
  OpcionesPageState createState() => OpcionesPageState();
}

class OpcionesPageState extends State<OpcionesPage> {
  User? _usuario;
  Map<String, dynamic>? _datosUsuario;

  @override
void initState() {
  super.initState();
  _usuario = FirebaseAuth.instance.currentUser;

  if (_usuario == null) {
    // Redirigir al login si no hay sesión
    Future.microtask(() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    });
  } else {
    _cargarDatosUsuario();
  }
}

  Future<void> _cargarDatosUsuario() async {
    final uid = _usuario?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        setState(() {
          _datosUsuario = doc.data();
        });
      }
    }
  }

  Future<void> _cerrarSesion() async {
    try {
    if (!(_usuario?.isAnonymous ?? true)) {
      final providerData = _usuario?.providerData;
      final isGoogle = providerData?.any((info) => info.providerId == 'google.com') ?? false;
      if (isGoogle) {
        await GoogleSignIn().signOut();
      }
    }

    await FirebaseAuth.instance.signOut();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al cerrar sesión: $e')),
    );
  }
}

void _mostrarSelectorColor(ThemeProvider themeProvider) {
  Color pickerColor = themeProvider.primaryColor;

  showDialog(
    context: context,
    builder: (context) {
      final screenWidth = MediaQuery.of(context).size.width;
      final dialogWidth = screenWidth * 0.9; // 90% del ancho de pantalla

      return AlertDialog(
        title: const Text('Selecciona un color primario'),
        content: SizedBox(
          width: dialogWidth,
          child: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (color) => pickerColor = color,
              enableAlpha: false,
              displayThumbColor: true,
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text('Aplicar'),
            onPressed: () async {
              themeProvider.updatePrimaryColor(pickerColor);
              Navigator.of(context).pop();

              final uid = _usuario?.uid;
              if (uid != null) {
                await FirebaseFirestore.instance.collection('users').doc(uid).update({
                  'colorPrimario': pickerColor.value.toRadixString(16),
                });
              }
            },
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false,title: const Text('Perfil de Usuario')),
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
      : (_datosUsuario?['nombre'] != null && _datosUsuario?['apellido'] != null)
          ? '${_datosUsuario!['nombre']} ${_datosUsuario!['apellido']}'
          : (_usuario!.displayName ?? 'Nombre no disponible'),
  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                ListTile(
                  title: const Text(
                    'Configuración de Tema',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  leading: const Icon(Icons.settings),
                  tileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                ),
                ListTile(
                  leading: const Icon(Icons.color_lens),
                  title: const Text('Color del tema'),
                  onTap: () => _mostrarSelectorColor(themeProvider),
                ),
                ListTile(
                  leading: const Icon(Icons.brightness_6),
                  title: const Text('Tema Oscuro'),
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: themeProvider.toggleDarkMode,
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Cerrar sesión'),
                  onTap: _cerrarSesion,
                ),
              ],
            ),
    );
  }
}
