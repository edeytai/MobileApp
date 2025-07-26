import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_colors.dart';
import '../utils/route_transitions.dart';
import 'menu_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Vista que muestra el perfil del usuario actual
/// Permite ver información del usuario y cambiar foto de perfil
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  User? _user;
  Map<String, dynamic>? _userData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _fetchUserData();
  }

  /// Obtiene los datos del usuario desde Firestore
  Future<void> _fetchUserData() async {
    if (_user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(_user!.uid)
        .get();
    setState(() {
      _userData = doc.data();
      _loading = false;
    });
  }

  /// Permite al usuario cambiar su foto de perfil
  /// Sube la imagen a Firebase Storage y actualiza el perfil
  Future<void> _changeProfilePhoto() async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null || _user == null) return;
    setState(() {
      _loading = true;
    });
    try {
      // Referencia al archivo en Firebase Storage
      final ref = FirebaseStorage.instance.ref().child(
        'profile_photos/${_user!.uid}.jpg',
      );

      final bytes = await picked.readAsBytes();

      // Subir la imagen
      await ref.putData(bytes);

      // Obtener la URL de descarga
      final url = await ref.getDownloadURL();

      // Actualizar el documento del usuario en Firestore
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(_user!.uid)
          .update({'photoURL': url});

      if (!mounted) return;
      setState(() {
        _userData?['photoURL'] = url;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al subir la foto: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  /// Muestra el menú modal con opciones del perfil
  void _showMenuModal(BuildContext context) {
    showMenuModal(
      context,
      GestureDetector(
        onTap: () {
        },
        child: MenuView(
          onClose: () => Navigator.pop(context),
          userData: _userData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_userData == null) {
      return const Scaffold(
        body: Center(child: Text('No se encontraron datos de usuario.')),
      );
    }
    
    // Extraer datos del usuario
    final name = _userData!['name'] ?? '';
    final username = _userData!['username'] ?? '';
    final email = _userData!['email'] ?? '';
    final bio = _userData!['bio'] ?? '';
    final photoURL = _userData!['photoURL'] as String?;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        actions: [
          // Botón para abrir el menú
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _showMenuModal(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchUserData,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            children: [
              // Foto de perfil
              Center(
                child: GestureDetector(
                  onTap: _loading ? null : _changeProfilePhoto,
                  child: photoURL != null && photoURL.isNotEmpty
                      ? CircleAvatar(
                          radius: 48,
                          backgroundImage: NetworkImage(photoURL),
                        )
                      : CircleAvatar(
                          radius: 48,
                          backgroundColor: AppColors.appGreen,
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: const TextStyle(
                              fontSize: 36,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
              ),
              // Indicador de carga al cambiar foto
              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              const SizedBox(height: 18),
              // Nombre del usuario
              Center(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Username
              Center(
                child: Text(
                  '@$username',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 6),
              // Email
              Center(
                child: Text(
                  email,
                  style: const TextStyle(fontSize: 15, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 18),
              // Biografía (si existe)
              if (bio.isNotEmpty)
                Center(
                  child: Text(
                    bio,
                    style: const TextStyle(fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
