import 'package:flutter/material.dart';
import 'package:prueba/Screens/models.dart';
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
    OpcionesPage(), // Eliminamos CompararPage aquí
  ];

  void _onItemTapped(int index) async {
    if (index == 2) {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // Llamar API para obtener pokémon
        List<PokemonDetail> listaPokemon = await fetchAllPokemonDetails();


        // Cerrar indicador de carga
        Navigator.of(context).pop();

        // Navegar a la pantalla Comparar con los datos cargados
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CompararPage(listaPokemones: listaPokemon),
          ),
        );
      } catch (e) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar los Pokémon')),
        );
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pokémon App"),
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
