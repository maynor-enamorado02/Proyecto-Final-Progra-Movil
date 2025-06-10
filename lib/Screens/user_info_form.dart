import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'homepage.dart';
import 'package:country_picker/country_picker.dart';


class UserInfoForm extends StatefulWidget {
  
  const UserInfoForm({super.key});
  

  @override
  State<UserInfoForm> createState() => _UserInfoFormState();
}

class _UserInfoFormState extends State<UserInfoForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _email = FirebaseAuth.instance.currentUser?.email ?? "";
    Country? _selectedCountry;


  bool _isSaving = false;

 Future<void> _saveUserData() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isSaving = true);

  try {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'nombre': _nameController.text.trim(),
      'apellido': _lastNameController.text.trim(),
      'telefono': _phoneController.text.trim(),
      'pais': _selectedCountry?.name ?? '', 
      'correo': _email,
      'uid': uid,
      'creado': FieldValue.serverTimestamp(),
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error al guardar datos: $e")),
    );
  } finally {
    setState(() => _isSaving = false);
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Datos personales')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Apellido'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
             GestureDetector(
  onTap: () {
    showCountryPicker(
      context: context,
      showPhoneCode:
          false, 
      onSelect: (Country country) {
        setState(() {
          _selectedCountry = country;
        });
      },
    );
  },
  child: AbsorbPointer(
    child: TextFormField(
      decoration: InputDecoration(
        labelText: 'País',
        hintText: 'Selecciona un país',
        prefixIcon: _selectedCountry != null
    ? Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          _selectedCountry!.flagEmoji,
          style: const TextStyle(fontSize: 24),
        ),
      )
    : const Icon(Icons.flag_outlined),
      ),
      validator: (_) =>
          _selectedCountry == null ? 'Debes seleccionar un país' : null,
      controller: TextEditingController(
        text: _selectedCountry?.name ?? '',
      ),
    ),
  ),
),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveUserData,
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Guardar y continuar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}