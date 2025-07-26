import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Servicio que maneja toda la lógica de autenticación de la aplicación
/// Incluye registro, login, logout y autenticación con Google
class AuthService {
  static final AuthService instance = AuthService._();
  AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleSignInInitialized = false;

  /// Inicializa Google Sign In si no ha sido inicializado previamente
  /// Necesario para evitar errores de inicialización múltiple
  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_isGoogleSignInInitialized) {
      await _googleSignIn.initialize();
      _isGoogleSignInInitialized = true;
    }
  }

  /// Registra un nuevo usuario con email y contraseña
  /// Crea el perfil del usuario en Firestore con información básica
  Future<UserCredential> register({
    required String email,
    required String password,
    required String name,
    required String username,
    required DateTime birthday,
    required String gender,
  }) async {
    final result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final user = result.user;
    if (user == null) throw Exception('No user');
    // Crear perfil del usuario en Firestore
    await _db.collection('usuarios').doc(user.uid).set({
      'uid': user.uid,
      'email': email,
      'name': name,
      'username': username,
      'birthday': birthday.toIso8601String(),
      'gender': gender,
      'onboardingCompleted': false,
      'onboardingAnswers': {},
      'createdAt': FieldValue.serverTimestamp(),
    });
    return result;
  }

  /// Inicia sesión con email y contraseña
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Cierra la sesión del usuario actual
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Verifica si un email ya está registrado en la aplicación
  Future<bool> isEmailTaken(String email) async {
    final query = await _db.collection('usuarios').where('email', isEqualTo: email).get();
    return query.docs.isNotEmpty;
  }

  /// Verifica si un nombre de usuario ya está en uso
  Future<bool> isUsernameTaken(String username) async {
    final query = await _db.collection('usuarios').where('username', isEqualTo: username).get();
    return query.docs.isNotEmpty;
  }

  /// Envía un email de restablecimiento de contraseña
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Inicia sesión con Google y verifica si el usuario tiene perfil completo
  /// Maneja diferentes implementaciones para web y móvil
  Future<Map<String, dynamic>> loginWithGoogleAndCheckProfile() async {
    if (kIsWeb) {
      // Implementación para web usando popup
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      final result = await _auth.signInWithPopup(googleProvider);
      final user = result.user;
      if (user == null) throw Exception('No user');
      final doc = await _db.collection('usuarios').doc(user.uid).get();
      final hasProfile = doc.exists;
      return {
        'user': user,
        'hasProfile': hasProfile,
      };
    } else {
      // Implementación para móvil usando Google Sign In
      await _ensureGoogleSignInInitialized();
      final GoogleSignInAccount account = await _googleSignIn.authenticate(
        scopeHint: ['email'],
      );
      final auth = account.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: auth.idToken,
      );
      final result = await _auth.signInWithCredential(credential);
      final user = result.user;
      if (user == null) throw Exception('No user');
      final doc = await _db.collection('usuarios').doc(user.uid).get();
      final hasProfile = doc.exists;
      return {
        'user': user,
        'hasProfile': hasProfile,
      };
    }
  }
} 