import 'package:flutter/material.dart';
import 'pokemon_list_page.dart';
import 'package:prueba/Screens/favoritos.dart';
import 'package:prueba/Screens/comparar.dart';
import 'package:prueba/Screens/opciones.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    PokemonListPage(),
    FavoritosPage(),
    CompararPage(),
    OpcionesPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pokémon App"),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.white70,
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
            icon: Icon(Icons.compare_arrows),
            label: 'Comparar',
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
