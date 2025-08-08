import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';

/// Modelo que representa el resumen nutricional diario de un usuario
class UserNutrition {
  final String userId;
  final DateTime date;
  final double calorias;
  final double proteinas;
  final double carbohidratos;
  final double grasas;
  final double fibra;
  final double azucares;
  final double sodio;
  final double agua;
  final List<String> recetasConsumidas;
  final DateTime updatedAt;

  UserNutrition({
    required this.userId,
    required this.date,
    this.calorias = 0,
    this.proteinas = 0,
    this.carbohidratos = 0,
    this.grasas = 0,
    this.fibra = 0,
    this.azucares = 0,
    this.sodio = 0,
    this.agua = 0,
    this.recetasConsumidas = const [],
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  /// Crea una instancia desde un documento de Firestore
  factory UserNutrition.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserNutrition(
      userId: data['userId'],
      date: (data['date'] as Timestamp).toDate(),
      calorias: (data['calorias'] as num).toDouble(),
      proteinas: (data['proteinas'] as num).toDouble(),
      carbohidratos: (data['carbohidratos'] as num).toDouble(),
      grasas: (data['grasas'] as num).toDouble(),
      fibra: (data['fibra'] as num).toDouble(),
      azucares: (data['azucares'] as num).toDouble(),
      sodio: (data['sodio'] as num).toDouble(),
      agua: (data['agua'] as num).toDouble(),
      recetasConsumidas: List<String>.from(data['recetasConsumidas'] ?? []),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Convierte la instancia a un mapa para Firestore
  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'date': Timestamp.fromDate(date),
    'calorias': calorias,
    'proteinas': proteinas,
    'carbohidratos': carbohidratos,
    'grasas': grasas,
    'fibra': fibra,
    'azucares': azucares,
    'sodio': sodio,
    'agua': agua,
    'recetasConsumidas': recetasConsumidas,
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  /// Crea una nueva instancia con valores actualizados
  UserNutrition copyWith({
    String? userId,
    DateTime? date,
    double? calorias,
    double? proteinas,
    double? carbohidratos,
    double? grasas,
    double? fibra,
    double? azucares,
    double? sodio,
    double? agua,
    List<String>? recetasConsumidas,
  }) {
    return UserNutrition(
      userId: userId ?? this.userId,
      date: date ?? this.date,
      calorias: calorias ?? this.calorias,
      proteinas: proteinas ?? this.proteinas,
      carbohidratos: carbohidratos ?? this.carbohidratos,
      grasas: grasas ?? this.grasas,
      fibra: fibra ?? this.fibra,
      azucares: azucares ?? this.azucares,
      sodio: sodio ?? this.sodio,
      agua: agua ?? this.agua,
      recetasConsumidas: recetasConsumidas ?? this.recetasConsumidas,
    );
  }

  /// Agrega los valores nutricionales de una receta al resumen diario
  UserNutrition addRecipeNutrition(String recipeId, InformacionNutricional info) {
    if (recetasConsumidas.contains(recipeId)) return this;
    
    return copyWith(
      calorias: calorias + info.calorias,
      proteinas: proteinas + info.proteinas,
      carbohidratos: carbohidratos + info.carbohidratos,
      grasas: grasas + info.grasas,
      fibra: fibra + info.fibra,
      azucares: azucares + info.azucares,
      sodio: sodio + info.sodio,
      recetasConsumidas: [...recetasConsumidas, recipeId],
    );
  }

  /// Remueve los valores nutricionales de una receta del resumen diario
  UserNutrition removeRecipeNutrition(String recipeId, InformacionNutricional info) {
    if (!recetasConsumidas.contains(recipeId)) return this;
    
    return copyWith(
      calorias: calorias - info.calorias,
      proteinas: proteinas - info.proteinas,
      carbohidratos: carbohidratos - info.carbohidratos,
      grasas: grasas - info.grasas,
      fibra: fibra - info.fibra,
      azucares: azucares - info.azucares,
      sodio: sodio - info.sodio,
      recetasConsumidas: recetasConsumidas.where((id) => id != recipeId).toList(),
    );
  }

  /// Registra consumo de agua
  UserNutrition addWater(double amount) {
    return copyWith(agua: agua + amount);
  }
}
