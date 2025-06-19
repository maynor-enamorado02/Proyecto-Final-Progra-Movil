// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'package:PokeStats/utils/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart';
import 'models.dart';
import 'pokemon_detail_page.dart';
import 'comparar.dart';
import 'package:provider/provider.dart';

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

  return LayoutBuilder(
    builder: (context, constraints) {
      final isTablet = constraints.maxWidth > 600;
      final imageSize = isTablet ? 120.0 : 70.0;
      final fontSize = isTablet ? 20.0 : 14.0;

      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.7,
          ),
          itemCount: _filteredPokemons.length,
          itemBuilder: (context, index) {
            final pokemon = _filteredPokemons[index];
            return GestureDetector(
              onTap: () {
                final primaryColor = Provider.of<ThemeProvider>(context, listen: false).primaryColor;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PokemonDetailPage(
                      url: pokemon.url,
                      name: pokemon.name,
                      selectedColor: primaryColor,
                    ),
                  ),
                );
              },
              child: Card(
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FutureBuilder<String?>(
                        future: pokemon.getImageUrl(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                            return Image.network(
                              snapshot.data!,
                              width: imageSize,
                              height: imageSize,
                              fit: BoxFit.contain,
                            );
                          } else {
                            return SizedBox(
                              width: imageSize,
                              height: imageSize,
                              child: const Center(
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
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
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
    },
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
      appBar: AppBar(automaticallyImplyLeading: false,
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
  fillColor: Theme.of(context).cardColor,
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
