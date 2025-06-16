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

  /// Cargar preferencias al inicio
  Future<void> loadUserPreferences() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && !user.isAnonymous) {
      // Cargar preferencias de Firestore si el usuario no es anónimo
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        if (data.containsKey('colorPrimario')) {
          final colorHex = data['colorPrimario'];
          try {
            // Verificar si el color tiene un formato hexadecimal válido
            _primaryColor = _convertHexToColor(colorHex);
          } catch (e) {
            print('Error al convertir colorPrimario: $colorHex. Error: $e');
            _primaryColor = Colors.blue; // Valor predeterminado si la conversión falla
          }
        }
        if (data.containsKey('temaOscuro')) {
          _isDarkMode = data['temaOscuro'] ?? false;
        }
        notifyListeners();
      }
    } else {
      // Cargar preferencias de SharedPreferences para usuarios anónimos
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('temaOscuro') ?? false;
      final colorHex = prefs.getString('colorPrimario');
      if (colorHex != null) {
        try {
          _primaryColor = _convertHexToColor(colorHex);
        } catch (e) {
          print('Error al convertir colorPrimario (anon): $colorHex. Error: $e');
          _primaryColor = Colors.blue; // Valor predeterminado si la conversión falla
        }
      }
      notifyListeners();
    }
  }

  // Convertir un color hexadecimal a Color
  Color _convertHexToColor(String hexColor) {
    if (hexColor.startsWith('#')) {
      hexColor = hexColor.replaceFirst('#', '');
    }
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor'; // Añadir opacidad si no está presente
    }
    if (hexColor.length == 8) {
      return Color(int.parse('0x$hexColor'));
    } else {
      throw FormatException("Formato de color no válido");
    }
  }

  // Cambiar modo oscuro y guardar preferencia
  void toggleDarkMode(bool isDark) async {
    _isDarkMode = isDark;
    notifyListeners();
    await _guardarPreferencias();
  }

  // Cambiar color primario y guardar preferencia
  Future<void> updatePrimaryColor(Color color) async {
    _primaryColor = color;
    notifyListeners();
    await _guardarPreferencias();
  }

  // Guardar preferencias en Firestore o SharedPreferences
  Future<void> _guardarPreferencias() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && !user.isAnonymous) {
      // Guardar preferencias en Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'temaOscuro': _isDarkMode,
        'colorPrimario': _colorToHex(_primaryColor),
      }, SetOptions(merge: true));
    } else {
      // Guardar preferencias en SharedPreferences para usuarios anónimos
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('temaOscuro', _isDarkMode);
      await prefs.setString('colorPrimario', _colorToHex(_primaryColor));
    }
  }

  // Convertir color a formato hexadecimal
  String _colorToHex(Color color) =>
      '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
}