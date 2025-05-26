import 'package:flutter/material.dart';

class FavoritosPage extends StatefulWidget {
  const FavoritosPage({super.key});

  @override
  _FavoritosPageState createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> {
  List<String> favoritos = [];

  void _agregarFavorito() {
    setState(() {
      favoritos.add('Pokémon ${favoritos.length + 1}');
    });
  }

  void _borrarFavorito(int index) {
    setState(() {
      favoritos.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _agregarFavorito,
          child: Text('Agregar Favorito'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: favoritos.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(favoritos[index]),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _borrarFavorito(index),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
