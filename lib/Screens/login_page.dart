// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'homepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  void _tryLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulate authentication delay
    await Future.delayed(Duration(seconds: 1));

    String username = _userController.text.trim();
    String password = _passController.text;

    if (username == "admin" && password == "1234") {
      
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => const HomePage()),
);
    } else {
      setState(() {
        _errorMessage = "Usuario o contraseña incorrectos";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login Pokémon"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.network(
                  "https://upload.wikimedia.org/wikipedia/commons/5/51/Pokebola-pokeball-png-0.png", width: 100, height: 100,),
                //Icon(Icons.person, size: 100, color: Colors.redAccent),
                SizedBox(height: 24),
                TextFormField(
                  controller: _userController,
                  decoration: InputDecoration(
                    labelText: "Usuario",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Por favor ingresa el usuario";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _passController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Contraseña",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Por favor ingresa la contraseña";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                _errorMessage != null
                    ? Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.redAccent),
                      )
                    : SizedBox.shrink(),
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _tryLogin,
                    child: _isLoading
                        ? CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text("Iniciar sesión", style: TextStyle(fontSize: 20, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}