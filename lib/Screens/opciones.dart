import 'package:flutter/material.dart';

class OpcionesPage extends StatefulWidget {
  const OpcionesPage({super.key});

  @override
  OpcionesPageState createState() => OpcionesPageState();
}

class OpcionesPageState extends State<OpcionesPage> {
  bool _isDarkMode = false; // Valor local para el switch, sin afectar tema global

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Opciones')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Modo Oscuro'),
            trailing: Switch(
              value: _isDarkMode,
              onChanged: (bool value) {
                setState(() {
                  _isDarkMode = value;
                  // Aquí puedes hacer algo más si quieres, por ahora solo cambia el switch
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
