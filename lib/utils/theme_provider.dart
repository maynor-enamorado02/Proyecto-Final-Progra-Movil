// lib /utils/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  Color _primaryColor = Colors.red;

  bool get isDarkMode => _isDarkMode;
  Color get primaryColor => _primaryColor;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  ThemeData get themeData => ThemeData(
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        primaryColor: _primaryColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primaryColor,
          brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        ),
        useMaterial3: true,
      );

  /// cargar preferencias al inicio
  Future<void> loadUserPreferences() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && !user.isAnonymous) {
  final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  if (doc.exists) {
    final data = doc.data()!;
    if (data.containsKey('colorPrimario')) {
      final colorHex = data['colorPrimario'];
      try {
        _primaryColor = Color(int.parse(colorHex.replaceFirst('#', '0xff')));
      } catch (e) {
        print('Error al convertir colorPrimario: $colorHex');
        _primaryColor = Colors.blue;
      }
    }
    if (data.containsKey('temaOscuro')) {
      _isDarkMode = data['temaOscuro'] ?? false;
    }
    notifyListeners();
  }
} else {
  final prefs = await SharedPreferences.getInstance();
  _isDarkMode = prefs.getBool('temaOscuro') ?? false;
  final colorHex = prefs.getString('colorPrimario');
  if (colorHex != null) {
    try {
      _primaryColor = Color(int.parse(colorHex.replaceFirst('#', '0xff')));
    } catch (e) {
      print('Error al convertir colorPrimario (anon): $colorHex');
      _primaryColor = Colors.blue;
    }
  }
  notifyListeners();
}
  }

  void toggleDarkMode(bool isDark) async {
    _isDarkMode = isDark;
    notifyListeners();
    await _guardarPreferencias();
  }

  Future<void> updatePrimaryColor(Color color) async {
    _primaryColor = color;
    notifyListeners();
    await _guardarPreferencias();
  }

  Future<void> _guardarPreferencias() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && !user.isAnonymous) {
      // Guardar Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'temaOscuro': _isDarkMode,
        'colorPrimario': _colorToHex(_primaryColor),
      }, SetOptions(merge: true));
    } else {
      // guardar SharedPreferences local
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('temaOscuro', _isDarkMode);
      await prefs.setString('colorPrimario', _colorToHex(_primaryColor));
    }
  }

  String _colorToHex(Color color) =>
      '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
}