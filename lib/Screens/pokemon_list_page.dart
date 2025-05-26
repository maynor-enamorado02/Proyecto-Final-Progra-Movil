// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart';
import 'models.dart';
import 'pokemon_detail_page.dart';

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


  Widget _buildList() {
    if (_hasError) {
      return Center(
        child: Text(_errorMessage ?? 'Error desconocido'),
      );
    }
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (_filteredPokemons.isEmpty) {
      return Center(
        child: Text('No se encontraron pokémons'),
      );
    }
    return ListView.builder(
      itemCount: _filteredPokemons.length,
      itemBuilder: (context, index) {
        final pokemon = _filteredPokemons[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: ListTile(
            leading: FutureBuilder<String?>(
              future: pokemon.getImageUrl(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return Image.network(
                    snapshot.data!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.contain,
                  );
                } else {
                  return SizedBox(
                    width: 56,
                    height: 56,
                    child:
                        Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                }
              },
            ),
            title: Text(_capitalize(pokemon.name)),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        PokemonDetailPage(url: pokemon.url, name: pokemon.name)),
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
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Pokémon'),
        actions: [
          IconButton(
              tooltip: 'Cerrar sesión',
              onPressed: _logout,
              icon: Icon(Icons.logout))
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar Pokémon',
                prefixIcon: Icon(Icons.search),
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
    );
  }
}