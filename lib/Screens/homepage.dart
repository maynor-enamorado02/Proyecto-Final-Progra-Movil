import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:PokeStats/Screens/favoritos.dart';
import 'package:PokeStats/Screens/opciones.dart';
import 'package:PokeStats/Screens/pokemon_list_page.dart';
import 'package:PokeStats/utils/theme_provider.dart'; // Asegúrate de importar el ThemeProvider

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

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
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final primaryColor = themeProvider.primaryColor;

    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false,
        title: const Text("Pokémon App"),
        backgroundColor: primaryColor, // AppBar usa el color primario
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
