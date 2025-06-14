import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:PokeStats/Screens/favoritos.dart';
import 'package:PokeStats/Screens/opciones.dart';
import 'package:PokeStats/Screens/pokemon_list_page.dart';
import 'package:PokeStats/utils/theme_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final int _visitCount = 0;
  User? _user;

  final List<Widget> _screens = [
    const PokemonListPage(),
    FavoritosPage(),
    const OpcionesPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      _checkVisitCount();
    }
  }

// code para verificar si el usuario ya tiene sesiones iniciadas
  Future<void> _checkVisitCount() async {
    final uid = _user?.uid;

    if (uid != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;

        int currentVisitCount = data['visitCount'] ?? 0;

        if (currentVisitCount < 3) {
          _showWelcomeDialog();
          await FirebaseFirestore.instance.collection('users').doc(uid).update({
            'visitCount': currentVisitCount + 1,
          });
        } else {
          print("El contador ha superado el límite de 3.");
        }
      } else {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'visitCount': 1,
        });
        _showWelcomeDialog();
      }
    }
  }

  // mostrar mensaje bienvenida
  void _showWelcomeDialog() {
    print("Mostrando el cuadro de diálogo...");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bienvenido a PokéStats'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('¡Gracias por iniciar sesión!'),
              const SizedBox(height: 10),
              Image.network(
                'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png', // URL de la imagen de Pikachu
                width: 100,
                height: 100,
                errorBuilder: (context, error, stackTrace) {
                  return const Text('No se pudo cargar la imagen');
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final primaryColor = themeProvider.primaryColor;

    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false,
        title: const Text("PokéStats"),
        backgroundColor: primaryColor,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: primaryColor,
        unselectedItemColor: isDarkMode ? Colors.white70 : Colors.black54,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Lista Pokémon',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Opciones',
          ),
        ],
      ),
    );
  }
}