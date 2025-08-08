import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';

/// Servicio que maneja el seguimiento nutricional de los usuarios
class NutritionService {
  static final NutritionService instance = NutritionService._();
  NutritionService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Obtiene el resumen nutricional del día actual para el usuario
  Future<UserNutrition?> getUserDailyNutrition() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    try {
      final doc = await _db
          .collection('nutricion_usuarios')
          .where('userId', isEqualTo: user.uid)
          .where('date', isEqualTo: Timestamp.fromDate(startOfDay))
          .get();

      if (doc.docs.isEmpty) {
        // Crear nuevo registro para hoy
        final newNutrition = UserNutrition(
          userId: user.uid,
          date: startOfDay,
        );
        await _db
            .collection('nutricion_usuarios')
            .doc()
            .set(newNutrition.toFirestore());
        return newNutrition;
      }

      return UserNutrition.fromFirestore(doc.docs.first);
    } catch (_) {
      return null;
    }
  }

  /// Actualiza el resumen nutricional del usuario
  Future<void> updateUserNutrition(UserNutrition nutrition) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final startOfDay = DateTime(
        nutrition.date.year,
        nutrition.date.month,
        nutrition.date.day,
      );

      final query = await _db
          .collection('nutricion_usuarios')
          .where('userId', isEqualTo: user.uid)
          .where('date', isEqualTo: Timestamp.fromDate(startOfDay))
          .get();

      if (query.docs.isEmpty) {
        await _db
            .collection('nutricion_usuarios')
            .doc()
            .set(nutrition.toFirestore());
      } else {
        await _db
            .collection('nutricion_usuarios')
            .doc(query.docs.first.id)
            .update(nutrition.toFirestore());
      }
    } catch (_) {
      // Si hay un error al actualizar, simplemente retornamos
    }
  }

  /// Registra el consumo de una receta
  Future<void> logRecipeConsumption(Receta receta) async {
    final nutrition = await getUserDailyNutrition();
    if (nutrition == null) return;

    final updatedNutrition = nutrition.addRecipeNutrition(
      receta.id,
      receta.informacionNutricional,
    );

    await updateUserNutrition(updatedNutrition);
  }

  /// Elimina el registro de consumo de una receta
  Future<void> removeRecipeConsumption(Receta receta) async {
    final nutrition = await getUserDailyNutrition();
    if (nutrition == null) return;

    final updatedNutrition = nutrition.removeRecipeNutrition(
      receta.id,
      receta.informacionNutricional,
    );

    await updateUserNutrition(updatedNutrition);
  }

  /// Registra el consumo de agua
  Future<void> logWaterConsumption(double amount) async {
    final nutrition = await getUserDailyNutrition();
    if (nutrition == null) return;

    final updatedNutrition = nutrition.addWater(amount);
    await updateUserNutrition(updatedNutrition);
  }

  /// Obtiene el historial nutricional del usuario
  Future<List<UserNutrition>> getNutritionHistory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      var query = _db
          .collection('nutricion_usuarios')
          .where('userId', isEqualTo: user.uid)
          .orderBy('date', descending: true);

      if (startDate != null) {
        query = query.where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('date',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => UserNutrition.fromFirestore(doc))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
