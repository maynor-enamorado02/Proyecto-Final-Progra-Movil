import 'package:PokeStats/utils/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:PokeStats/Screens/email_login_form.dart';
import 'package:PokeStats/Screens/user_info_form.dart';
import 'homepage.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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

    await Provider.of<ThemeProvider>(context, listen: false).loadUserPreferences();

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

  Future<void> _signInAnonymously() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    await FirebaseAuth.instance.signInAnonymously();

    await Provider.of<ThemeProvider>(context, listen: false).loadUserPreferences();

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
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PokemonDetail &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}


Future<List<PokemonDetail>> fetchPokemonDetailsBatch(int offset, int limit) async {
  final url = Uri.parse('https://pokeapi.co/api/v2/pokemon?offset=$offset&limit=$limit');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final List results = data['results'];

    List<Future<PokemonDetail?>> futures = results.map((item) async {
      try {
        final detailResponse = await http.get(Uri.parse(item['url']));
        if (detailResponse.statusCode == 200) {
          final detailData = json.decode(detailResponse.body);
          return PokemonDetail.fromJson(detailData);
        }
      } catch (_) {}
      return null;
    }).toList();

    final details = await Future.wait(futures);
    return details.whereType<PokemonDetail>().toList();
  } else {
    throw Exception('Error al cargar los Pokémon');
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
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: const Text("Registrarse con Correo"),
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const UserInfoForm()),
                          );
                        },
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
    icon: const Icon(Icons.email_outlined),
    label: const Text("Iniciar sesión con Correo"),
    onPressed: _isLoading
        ? null
        : () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EmailLoginForm()),
            );
          },
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.teal,
    ),
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