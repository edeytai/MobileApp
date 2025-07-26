import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Vista que permite editar el perfil del usuario
/// Incluye edición de nombre, username, biografía y foto de perfil
class ProfileEditView extends StatefulWidget {
  final Map<String, dynamic> userData;
  const ProfileEditView({super.key, required this.userData});

  @override
  State<ProfileEditView> createState() => _ProfileEditViewState();
}

class _ProfileEditViewState extends State<ProfileEditView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  String? _photoURL;
  bool _isLoading = false;
  bool _isUsernameTaken = false;
  bool _isCheckingUsername = false;
  String? _errorMessage;
  Timer? _usernameDebounceTimer;

  @override
  void initState() {
    super.initState();
    // Inicializar controladores con datos actuales del usuario
    _nameController = TextEditingController(text: widget.userData['name'] ?? '');
    _usernameController = TextEditingController(text: widget.userData['username'] ?? '');
    _bioController = TextEditingController(text: widget.userData['bio'] ?? '');
    _photoURL = widget.userData['photoURL'] as String?;
    _usernameController.addListener(_onUsernameChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.removeListener(_onUsernameChanged);
    _usernameController.dispose();
    _bioController.dispose();
    _usernameDebounceTimer?.cancel();
    super.dispose();
  }

  /// Valida el username en tiempo real con debounce
  /// Verifica disponibilidad y limpia caracteres no válidos
  void _onUsernameChanged() async {
    final cleaned = _usernameController.text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9._]'), '');
    if (cleaned != _usernameController.text) {
      _usernameController.value = TextEditingValue(
        text: cleaned,
        selection: TextSelection.collapsed(offset: cleaned.length),
      );
    }
    
    setState(() {});
    
    _usernameDebounceTimer?.cancel();
    
    final username = cleaned;
    // No validar si es el mismo username actual
    if (username == widget.userData['username']) {
      setState(() {
        _isUsernameTaken = false;
        _isCheckingUsername = false;
      });
      return;
    }
    
    if (username.isEmpty || !_isUsernameValid(username)) {
      setState(() {
        _isUsernameTaken = false;
        _isCheckingUsername = false;
      });
      return;
    }
    
    _usernameDebounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return;
      
      setState(() { _isCheckingUsername = true; });
      
      // Verificar disponibilidad del username en Firestore
      final query = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('username', isEqualTo: username)
          .get();
      
      if (mounted) {
        setState(() {
          _isUsernameTaken = query.docs.isNotEmpty;
          _isCheckingUsername = false;
        });
      }
    });
  }

  /// Valida el formato del username
  bool _isUsernameValid(String username) {
    return RegExp(r'^[a-z0-9._]{3,24}$').hasMatch(username);
  }

  /// Guarda los cambios del perfil en Firestore
  /// Actualiza nombre, username y biografía
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _isUsernameTaken || _isCheckingUsername) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user logged in');
      final navigator = Navigator.of(context);
      
      // Actualizar datos del usuario en Firestore
      await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).update({
        'name': _nameController.text.trim(),
        'username': _usernameController.text.trim(),
        'bio': _bioController.text.trim(),
      });
      
      if (!mounted) return;
      navigator.pop(true);
    } catch (e) {
      setState(() { _errorMessage = e.toString(); });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  /// Permite cambiar la foto de perfil
  /// Sube la imagen a Firebase Storage y actualiza el perfil
  Future<void> _changeProfilePhoto() async {
    final messenger = ScaffoldMessenger.of(context);
    final picker = ImagePicker();
    
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    setState(() { _isLoading = true; });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user logged in');
      
      // Referencia al archivo en Firebase Storage
      final ref = FirebaseStorage.instance.ref().child('profile_photos/${user.uid}.jpg');
      
      // Subir la imagen
      await ref.putData(await picked.readAsBytes());
      
      // Obtener la URL de descarga
      final url = await ref.getDownloadURL();
      
      // Actualizar el documento del usuario en Firestore
      await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).update({'photoURL': url});
      
      if (!mounted) return;
      setState(() { _photoURL = url; });
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Error al subir la foto: $e')));
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar perfil'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Foto de perfil con botón de cambio
                  Center(
                    child: Stack(
                      children: [
                        _photoURL != null && _photoURL!.isNotEmpty
                            ? CircleAvatar(
                                radius: 48,
                                backgroundImage: NetworkImage(_photoURL!),
                              )
                            : CircleAvatar(
                                radius: 48,
                                backgroundColor: AppColors.appGreen,
                                child: Text(
                                  _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : '?',
                                  style: const TextStyle(fontSize: 36, color: Colors.white),
                                ),
                              ),
                        // Botón de cámara para cambiar foto
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, color: AppColors.appGreen),
                              onPressed: _isLoading ? null : _changeProfilePhoto,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Campo de nombre
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'El nombre es requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  // Campo de username con validación en tiempo real
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre de usuario',
                      border: const OutlineInputBorder(),
                      prefixText: '@',
                      suffixIcon: _isCheckingUsername
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : _usernameController.text.isNotEmpty && _isUsernameValid(_usernameController.text) && !_isUsernameTaken
                              ? const Icon(Icons.check_circle, color: AppColors.success)
                              : _isUsernameTaken
                                  ? const Icon(Icons.cancel, color: Colors.red)
                                  : null,
                    ),
                    autocorrect: false,
                    enableSuggestions: false,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9._]')),
                    ],
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'El username es requerido';
                      if (!_isUsernameValid(val.trim())) return 'Solo minúsculas, números, "." y "_", mínimo 3 caracteres.';
                      if (_isUsernameTaken) return 'El nombre de usuario ya está en uso.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Campo de biografía
                  TextFormField(
                    controller: _bioController,
                    decoration: const InputDecoration(
                      labelText: 'Biografía',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  // Mensaje de error general
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                    ),
                  // Botón de guardar cambios
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading || _isUsernameTaken || _isCheckingUsername ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.appGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Guardar cambios',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 