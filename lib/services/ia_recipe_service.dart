import '../models/models.dart';

/// Servicio que maneja la generación de recetas mediante inteligencia artificial
/// Actualmente es un placeholder para futuras implementaciones de IA
class IARecipeService {
  static final IARecipeService instance = IARecipeService._();
  IARecipeService._();

  /// Genera recetas basadas en un prompt o criterios específicos
  /// Por ahora retorna una lista vacía, pendiente de implementación
  Future<List<Receta>> getAIRecipes({String? prompt}) async {
    return [];
  }
} 