import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:PokeStats/Screens/login_page.dart';
import 'package:PokeStats/Screens/homepage.dart';
import 'package:PokeStats/utils/theme_provider.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final themeProvider = ThemeProvider();
  await themeProvider.loadUserPreferences(); // carga inicial
  runApp(
    ChangeNotifierProvider.value(
      value: themeProvider,
      child: const PokemonApp(),
    ),
  );
}

class PokemonApp extends StatelessWidget {
  const PokemonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Pokémon App',
          theme: themeProvider.themeData,
          home: FirebaseAuth.instance.currentUser == null
              ? const LoginPage()
              : const HomePage(),
        );
      },
    );
  }
}
