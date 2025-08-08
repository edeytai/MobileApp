import 'package:cloud_firestore/cloud_firestore.dart';

/// Servicio que provee acceso al catálogo de ingredientes desde Firestore.
class IngredientService {
  /// Singleton del servicio
  IngredientService._();
  static final IngredientService instance = IngredientService._();

  static const String _collectionName = 'ingredientes_catalogo';
  CollectionReference<Map<String, dynamic>> get _collection =>
      FirebaseFirestore.instance.collection(_collectionName);

  /// Devuelve un stream reactivo con la lista de ingredientes
  /// ordenados por nombre.
  Stream<List<SelectableIngredient>> watchIngredients() {
    return _collection.orderBy('nombre').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return SelectableIngredient(
          id: doc.id,
          name: (data['nombre'] ?? '') as String,
          imageUrl: (data['imageUrl'] ?? '') as String,
        );
      }).toList();
    });
  }

  /// Obtiene en una sola consulta (no reactiva) la lista de ingredientes.
  Future<List<SelectableIngredient>> fetchIngredients() async {
    final snapshot = await _collection.orderBy('nombre').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return SelectableIngredient(
        id: doc.id,
        name: (data['nombre'] ?? '') as String,
        imageUrl: (data['imageUrl'] ?? '') as String,
      );
    }).toList();
  }
}

/// DTO simple para representar un ingrediente seleccionable en la UI.
class SelectableIngredient {
  final String id;
  final String name;
  final String imageUrl;

  const SelectableIngredient({required this.id, required this.name, required this.imageUrl});
}


