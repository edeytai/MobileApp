import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';

/// Gestor que maneja las recetas favoritas del usuario
/// Extiende ChangeNotifier para notificar cambios a los widgets
class FavoriteRecipesManager extends ChangeNotifier {
  static final FavoriteRecipesManager instance = FavoriteRecipesManager._();
  FavoriteRecipesManager._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Lista de IDs de recetas favoritas del usuario actual
  List<String> favoriteRecipeIDs = [];

  /// Obtiene el ID del usuario actual
  String? get currentUserId => _auth.currentUser?.uid;

  /// Carga las recetas favoritas desde Firestore
  /// Sincroniza la lista local con la base de datos
  Future<void> loadFavoritesFromFirestore() async {
    final uid = currentUserId;
    if (uid == null) {
      favoriteRecipeIDs = [];
      notifyListeners();
      return;
    }
    final doc = await _db.collection('usuarios').doc(uid).get();
    final data = doc.data();
    if (data != null && data['favoriteRecipeIDs'] != null) {
      favoriteRecipeIDs = List<String>.from(data['favoriteRecipeIDs']);
    } else {
      favoriteRecipeIDs = [];
    }
    notifyListeners();
  }

  /// Actualiza la lista de favoritos en Firestore
  /// Persiste los cambios en la base de datos
  Future<void> updateFavoritesInFirestore() async {
    final uid = currentUserId;
    if (uid == null) return;
    await _db.collection('usuarios').doc(uid).update({
      'favoriteRecipeIDs': favoriteRecipeIDs,
    });
  }

  /// Obtiene la lista completa de IDs de recetas favoritas
  Future<List<String>> getFavorites() async {
    await loadFavoritesFromFirestore();
    return favoriteRecipeIDs;
  }

  /// Agrega una receta a favoritos
  /// Evita duplicados y actualiza la base de datos
  Future<void> addToFavorites(String recipeId) async {
    if (!favoriteRecipeIDs.contains(recipeId)) {
      favoriteRecipeIDs.add(recipeId);
      await updateFavoritesInFirestore();
      notifyListeners();
    }
  }

  /// Remueve una receta de favoritos
  /// Actualiza la base de datos y notifica a los widgets
  Future<void> removeFromFavorites(String recipeId) async {
    if (favoriteRecipeIDs.contains(recipeId)) {
      favoriteRecipeIDs.remove(recipeId);
      await updateFavoritesInFirestore();
      notifyListeners();
    }
  }

  /// Verifica si una receta está en favoritos
  Future<bool> isFavorite(String recipeId) async {
    await loadFavoritesFromFirestore();
    return favoriteRecipeIDs.contains(recipeId);
  }

  /// Alterna el estado de favorito de una receta
  /// Si está en favoritos la remueve, si no está la agrega
  Future<void> toggleFavorite(String recipeId) async {
    if (favoriteRecipeIDs.contains(recipeId)) {
      await removeFromFavorites(recipeId);
    } else {
      await addToFavorites(recipeId);
    }
    notifyListeners();
  }

  /// Limpia todas las recetas favoritas
  /// Útil para resetear las preferencias del usuario
  Future<void> clearAllFavorites() async {
    favoriteRecipeIDs.clear();
    await updateFavoritesInFirestore();
    notifyListeners();
  }

  /// Filtra una lista de recetas para obtener solo las favoritas
  /// Útil para mostrar solo las recetas que el usuario ha marcado como favoritas
  List<Receta> favoriteRecipesFrom(List<Receta> allRecipes) {
    return allRecipes.where((r) => favoriteRecipeIDs.contains(r.id)).toList();
  }
} 