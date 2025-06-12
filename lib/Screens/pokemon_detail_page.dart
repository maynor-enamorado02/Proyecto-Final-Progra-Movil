// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PokemonDetailPage extends StatefulWidget {
  final String url;
  final String name;
  final Color selectedColor;

  const PokemonDetailPage({super.key, required this.url, required this.name, required this.selectedColor,});

  @override
  _PokemonDetailPageState createState() => _PokemonDetailPageState();

}

class _PokemonDetailPageState extends State<PokemonDetailPage> {
  late Future<PokemonDetail> _pokemonDetailFuture;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isFavorite = false;
  bool isAnonymous = false;
  Color _darken(Color color, [double amount = .3]) {
  final hsl = HSLColor.fromColor(color);
  final darker = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
  return darker.toColor();
}
  @override
  void initState() {
    super.initState();
    _pokemonDetailFuture = fetchPokemonDetail(widget.url);
    final user = _auth.currentUser;
    isAnonymous = user == null || user.isAnonymous;
    checkIfFavorite();
  }

  Future<void> checkIfFavorite() async {
    final user = _auth.currentUser;
    if (user != null && !user.isAnonymous) {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(widget.name)
          .get();

      if (doc.exists) {
        setState(() {
          isFavorite = true;
        });
      }
    }
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

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
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

  Future<void> addToFavorites(PokemonDetail pokemon) async {
    final user = _auth.currentUser;

    if (user == null || user.isAnonymous) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Debes iniciar sesión para guardar favoritos')),
      );
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(pokemon.name)
          .set({
        'name': pokemon.name,
        'imageUrl': pokemon.imageUrl,
        'stats': pokemon.stats,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        isFavorite = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_capitalize(pokemon.name)} agregado a favoritos')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
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
                  SizedBox(height: 24),
                  ElevatedButton.icon(
  icon: Icon(
    isFavorite ? Icons.favorite : Icons.favorite_border,
    color: Colors.white,
  ),
  label: Text(
    isAnonymous
        ? "Inicia sesión para agregar"
        : (isFavorite ? "Ya en Favoritos" : "Agregar a Favoritos"),
    style: TextStyle(
      color: _darken(widget.selectedColor), // texto más oscuro basado en el color base
      fontWeight: FontWeight.bold,
    ),
  ),
  onPressed: isAnonymous || isFavorite
      ? null
      : () => addToFavorites(pokemon),
  style: ElevatedButton.styleFrom(
    backgroundColor: widget.selectedColor,
    disabledBackgroundColor: Colors.grey,
  ),
),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
