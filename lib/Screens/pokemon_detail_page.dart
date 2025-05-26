// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'models.dart';

class PokemonDetailPage extends StatefulWidget {
  final String url;
  final String name;

  const PokemonDetailPage({super.key, required this.url, required this.name});

  @override
  _PokemonDetailPageState createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends State<PokemonDetailPage> {
  late Future<PokemonDetail> _pokemonDetailFuture;

  @override
  void initState() {
    super.initState();
    _pokemonDetailFuture = fetchPokemonDetail(widget.url);
  }

  Future<PokemonDetail> fetchPokemonDetail(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return PokemonDetail.fromJson(data);
    } else {
      throw Exception('Error al cargar el detalle del Pokémon');
    }
  }

  Widget _buildStatRow(String statName, int statValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              _capitalize(statName),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: statValue / 150.0,
              backgroundColor: Colors.grey[700],
              color: Colors.redAccent,
              minHeight: 14,
            ),
          ),
          SizedBox(width: 10),
          Text(statValue.toString()),
        ],
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_capitalize(widget.name)),
      ),
      body: FutureBuilder<PokemonDetail>(
        future: _pokemonDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error cargando detalles'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Sin datos'));
          } else {
            final pokemon = snapshot.data!;
            return SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (pokemon.imageUrl != null)
                    Image.network(
                      pokemon.imageUrl!,
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                    )
                  else
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: Center(child: Text('Sin imagen')),
                    ),
                  SizedBox(height: 16),
                  Text(
                    _capitalize(pokemon.name),
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 24),
                  ...pokemon.stats.entries
                      .map((entry) => _buildStatRow(entry.key, entry.value)),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}