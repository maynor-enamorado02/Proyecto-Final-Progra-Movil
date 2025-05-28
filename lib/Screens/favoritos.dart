import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritosPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FavoritosPage({super.key});

  Future<void> _eliminarFavorito(String userId, String docId, BuildContext context) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eliminado de favoritos')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      return Center(child: Text('Debes iniciar sesión'));
    }

    return Scaffold(
      appBar: AppBar(title: Text("Mis Favoritos")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return Center(child: Text('No tienes favoritos aún.'));

          final favoritos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: favoritos.length,
            itemBuilder: (context, index) {
              final favDoc = favoritos[index];
              final fav = favDoc.data() as Map<String, dynamic>;

              return Dismissible(
                key: Key(favDoc.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) async {
                  await _eliminarFavorito(user.uid, favDoc.id, context);
                },
                child: ListTile(
                  leading: Image.network(
                    fav['imageUrl'] ?? '',
                    width: 50,
                    height: 50,
                    errorBuilder: (_, __, ___) => Icon(Icons.error),
                  ),
                  title: Text(fav['name']),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    color: Colors.red,
                    onPressed: () async {
                      // Confirmación antes de eliminar
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Eliminar favorito'),
                          content: Text('¿Quieres eliminar ${fav['name']} de tus favoritos?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text('Eliminar'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await _eliminarFavorito(user.uid, favDoc.id, context);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
