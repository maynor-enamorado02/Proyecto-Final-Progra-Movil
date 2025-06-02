// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart';
import 'models.dart';
import 'pokemon_detail_page.dart';
import 'comparar.dart'; // ⬅️ Asegúrate de que este archivo existe

class PokemonListPage extends StatefulWidget {
  const PokemonListPage({super.key});

  @override
  _PokemonListPageState createState() => _PokemonListPageState();
}

class _PokemonListPageState extends State<PokemonListPage> {
  List<PokemonSummary> _pokemons = [];
  List<PokemonSummary> _filteredPokemons = [];
  bool isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAllPokemons();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredPokemons = List.from(_pokemons);
      } else {
        _filteredPokemons = _pokemons
            .where((p) => p.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  Future<void> _fetchAllPokemons() async {
    setState(() {
      isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=100000&offset=0'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        List<PokemonSummary> allPokemons =
            results.map((item) => PokemonSummary.fromJson(item)).toList();

        setState(() {
          _pokemons = allPokemons;
          _filteredPokemons = List.from(allPokemons);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          _hasError = true;
          _errorMessage = 'Error cargando pokémons';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        _hasError = true;
        _errorMessage = 'Error en conexión';
      });
    }
  }

  Future<List<PokemonDetail>> fetchAllPokemonDetails() async {
    // Puedes limitar la cantidad para evitar demasiadas peticiones
    final pokemonsToFetch = _filteredPokemons.take(20).toList();
    List<PokemonDetail> details = [];
    for (var summary in pokemonsToFetch) {
      try {
        final response = await http.get(Uri.parse(summary.url));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          details.add(PokemonDetail.fromJson(data));
        }
      } catch (_) {
        // Puedes manejar errores individuales aquí si lo deseas
      }
    }
    return details;
  }

  Future<void> _cargarYComparar() async {
    // Mostrar cargando
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      List<PokemonDetail> listaPokemon = await fetchAllPokemonDetails();
      Navigator.of(context).pop(); // cerrar el loader

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
  }

  Widget _buildList() {
    if (_hasError) {
      return Center(
        child: Text(_errorMessage ?? 'Error desconocido'),
      );
    }
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_filteredPokemons.isEmpty) {
      return const Center(
        child: Text('No se encontraron pokémons'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.7,
        ),
        itemCount: _filteredPokemons.length,
        itemBuilder: (context, index) {
          final pokemon = _filteredPokemons[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PokemonDetailPage(url: pokemon.url, name: pokemon.name),
                ),
              );
            },
            child: Card(
              color: Colors.grey[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FutureBuilder<String?>(
                      future: pokemon.getImageUrl(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          return Image.network(
                            snapshot.data!,
                            width: 70,
                            height: 70,
                            fit: BoxFit.contain,
                          );
                        } else {
                          return const SizedBox(
                            width: 70,
                            height: 70,
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _capitalize(pokemon.name),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Future<void> _logout() async {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Pokémon'),
        actions: [
          IconButton(
              tooltip: 'Cerrar sesión',
              onPressed: _logout,
              icon: const Icon(Icons.logout))
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar Pokémon',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: _buildList(),

      // 🔴 Aquí está el nuevo botón para comparar
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _cargarYComparar,
        icon: const Icon(Icons.compare),
        label: const Text("Comparar Pokémon"),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}
