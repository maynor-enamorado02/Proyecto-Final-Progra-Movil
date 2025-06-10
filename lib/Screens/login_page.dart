// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:prueba/Screens/user_info_form.dart';
import 'homepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  void _goToHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() {
          _errorMessage = "Inicio de sesión cancelado";
        });
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      _goToHomePage();
    } catch (e) {
      setState(() {
        _errorMessage = "Error con Google: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithEmail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      _goToHomePage();
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

 Future<void> _registerWithEmail() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    debugPrint("Usuario registrado: ${userCredential.user?.uid}");

    // Ir al formulario de datos personales
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const UserInfoForm()),
    );
  } on FirebaseAuthException catch (e) {
    setState(() {
      _errorMessage = e.message;
    });
    debugPrint("Error FirebaseAuth: ${e.message}");
  } catch (e) {
    debugPrint("Error inesperado: $e");
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}
  Future<void> _signInAnonymously() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.signInAnonymously();
      _goToHomePage();
    } catch (e) {
      setState(() {
        _errorMessage = "Error como invitado: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Pokémon"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              Image.network(
                "https://upload.wikimedia.org/wikipedia/commons/5/51/Pokebola-pokeball-png-0.png",
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Correo'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.email),
                  label: const Text("Iniciar con Correo"),
                  onPressed: _isLoading ? null : _signInWithEmail,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: const Text("Registrarse con Correo"),
                  onPressed: _isLoading ? null : _registerWithEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.login),
                  label: const Text("Iniciar con Google"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _isLoading ? null : _signInWithGoogle,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.person_outline),
                  label: const Text("Entrar como Invitado"),
                  onPressed: _isLoading ? null : _signInAnonymously,
                ),
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
