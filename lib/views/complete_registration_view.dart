import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_colors.dart';

/// Vista que permite completar el registro de usuarios que se autenticaron con Google
/// Se muestra cuando un usuario de Google no tiene perfil completo en Firestore
class CompleteRegistrationView extends StatefulWidget {
  final User user;
  const CompleteRegistrationView({super.key, required this.user});

  @override
  State<CompleteRegistrationView> createState() => _CompleteRegistrationViewState();
}

class _CompleteRegistrationViewState extends State<CompleteRegistrationView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  DateTime? _birthday;
  String? _gender;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isUsernameTaken = false;
  bool _isCheckingUsername = false;
  Timer? _usernameDebounceTimer;

  final List<String> _genders = ['Masculino', 'Femenino', 'Otro'];

  /// Valida el formato del username
  bool get _isUsernameValid => RegExp(r'^[a-z0-9._]{3,}').hasMatch(_usernameController.text);
  
  /// Verifica si el formulario está completo y válido
  bool get _isFormValid =>
      _nameController.text.isNotEmpty &&
      _usernameController.text.isNotEmpty &&
      _isUsernameValid &&
      _gender != null &&
      _birthday != null &&
      !_isUsernameTaken &&
      !_isCheckingUsername;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_onUsernameChanged);
  }

  @override
  void dispose() {
    _usernameController.removeListener(_onUsernameChanged);
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
    if (username.isEmpty) {
      setState(() {
        _isUsernameTaken = false;
        _isCheckingUsername = false;
      });
      return;
    }
    
    if (!_isUsernameValid) {
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

  /// Guarda los datos del usuario en Firestore
  /// Completa el registro y navega a la aplicación principal
  void _saveData() async {
    if (!_isFormValid) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final userData = {
        'uid': widget.user.uid,
        'email': widget.user.email,
        'name': _nameController.text.trim(),
        'username': _usernameController.text.trim(),
        'birthday': _birthday?.toIso8601String(),
        'gender': _gender,
        'onboardingCompleted': true,
        'registrationCompleted': true,
        'createdAt': FieldValue.serverTimestamp(),
      };
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.user.uid)
          .set(userData);
      if (!mounted) return;
      // No necesitamos navegar manualmente, el _RootFlow en main.dart se encargará
      // de detectar el cambio de estado y navegar correctamente
    } catch (e) {
      setState(() { _errorMessage = e.toString(); });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  /// Maneja la cancelación del registro
  /// Elimina la cuenta del usuario si confirma
  Future<void> _handleCancel() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cancelar registro?'),
        content: const Text('Si cancelas, tu cuenta y datos serán eliminados. ¿Seguro que deseas continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sí')),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _isLoading = true);
    try {
      // Eliminar documento del usuario en Firestore
      await FirebaseFirestore.instance.collection('usuarios').doc(widget.user.uid).delete();
    } catch (_) {}
    try {
      // Eliminar cuenta de Firebase Auth
      await widget.user.delete();
    } catch (_) {}
    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completa tu registro'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isLoading ? null : _handleCancel,
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          // Gesture para cancelar con swipe
          onHorizontalDragUpdate: (details) async {
            if (details.delta.dx > 15 && !_isLoading) {
              await _handleCancel();
            }
          },
          child: SizedBox.expand(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 18),
                  const Text('Por favor completa los siguientes datos para continuar.',
                      style: TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  // Campo de nombre
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      hintText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Campo de username con validación en tiempo real
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.alternate_email),
                      hintText: 'Nombre de usuario',
                      border: const OutlineInputBorder(),
                      suffixIcon: _isCheckingUsername
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : _usernameController.text.isNotEmpty && _isUsernameValid && !_isUsernameTaken
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
                  ),
                  // Mensajes de error para username
                  if (!_isUsernameValid && _usernameController.text.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0, top: 2),
                      child: Text('Solo minúsculas, números, "." y "_", mínimo 3 caracteres.', style: TextStyle(color: Colors.red, fontSize: 12)),
                    ),
                  if (_isUsernameTaken)
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0, top: 2),
                      child: Text('El nombre de usuario ya está en uso.', style: TextStyle(color: Colors.red, fontSize: 12)),
                    ),
                  const SizedBox(height: 14),
                  // Selector de fecha de nacimiento
                  ListTile(
                    leading: const Icon(Icons.cake, color: Colors.grey),
                    title: Text(_birthday == null
                        ? 'Cumpleaños'
                        : '${_birthday!.day}/${_birthday!.month}/${_birthday!.year}'),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime(2000, 1, 1),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() => _birthday = picked);
                    },
                  ),
                  const SizedBox(height: 14),
                  // Selector de género
                  DropdownButtonFormField<String>(
                    value: _gender,
                    hint: const Text('Género'),
                    items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                    onChanged: (val) => setState(() => _gender = val),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.people),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Mensaje de error general
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                    ),
                  // Botón de guardar
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveData,
                    child: _isLoading
                        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Guardar y continuar', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
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

 