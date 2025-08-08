import 'package:uuid/uuid.dart';
export 'user_nutrition.dart';

/// Enum que define las categorías de ingredientes disponibles
/// Utilizado para clasificar ingredientes por tipo nutricional
enum CategoriaIngrediente {
  proteinas('Proteínas'),
  carbohidratos('Carbohidratos'),
  verduras('Verduras'),
  frutas('Frutas'),
  lacteos('Lácteos'),
  condimentos('Condimentos'),
  otros('Otros');

  final String value;
  const CategoriaIngrediente(this.value);

  factory CategoriaIngrediente.fromJson(String value) =>
      CategoriaIngrediente.values.firstWhere((e) => e.value == value);

  String toJson() => value;
}

/// Modelo que representa la información nutricional de un ingrediente o receta
/// Contiene todos los valores nutricionales principales
class InformacionNutricional {
  final double calorias;
  final double proteinas;
  final double carbohidratos;
  final double grasas;
  final double fibra;
  final double azucares;
  final double sodio;

  InformacionNutricional({
    required this.calorias,
    required this.proteinas,
    required this.carbohidratos,
    required this.grasas,
    required this.fibra,
    required this.azucares,
    required this.sodio,
  });

  factory InformacionNutricional.fromJson(Map<String, dynamic> json) => InformacionNutricional(
        calorias: (json['calorias'] as num).toDouble(),
        proteinas: (json['proteinas'] as num).toDouble(),
        carbohidratos: (json['carbohidratos'] as num).toDouble(),
        grasas: (json['grasas'] as num).toDouble(),
        fibra: (json['fibra'] as num).toDouble(),
        azucares: (json['azucares'] as num).toDouble(),
        sodio: (json['sodio'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'calorias': calorias,
        'proteinas': proteinas,
        'carbohidratos': carbohidratos,
        'grasas': grasas,
        'fibra': fibra,
        'azucares': azucares,
        'sodio': sodio,
      };
}

/// Modelo que representa un ingrediente individual
/// Contiene información nutricional, precio y categoría
class Ingrediente {
  final String id;
  final String nombre;
  final CategoriaIngrediente categoria;
  final double precioPromedio;
  final String unidad;
  final InformacionNutricional informacionNutricional;

  Ingrediente({
    String? id,
    required this.nombre,
    required this.categoria,
    required this.precioPromedio,
    required this.unidad,
    required this.informacionNutricional,
  }) : id = id ?? const Uuid().v4();

  factory Ingrediente.fromJson(Map<String, dynamic> json) => Ingrediente(
        id: json['id'],
        nombre: json['nombre'],
        categoria: CategoriaIngrediente.fromJson(json['categoria']),
        precioPromedio: (json['precioPromedio'] as num).toDouble(),
        unidad: json['unidad'],
        informacionNutricional: InformacionNutricional.fromJson(json['informacionNutricional']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'categoria': categoria.toJson(),
        'precioPromedio': precioPromedio,
        'unidad': unidad,
        'informacionNutricional': informacionNutricional.toJson(),
      };
}

/// Modelo que representa un ingrediente dentro de una receta
/// Incluye la cantidad necesaria y si es opcional
class IngredienteReceta {
  final Ingrediente ingrediente;
  final double cantidad;
  final bool esOpcional;

  IngredienteReceta({
    required this.ingrediente,
    required this.cantidad,
    required this.esOpcional,
  });

  factory IngredienteReceta.fromJson(Map<String, dynamic> json) => IngredienteReceta(
        ingrediente: Ingrediente.fromJson(json['ingrediente']),
        cantidad: (json['cantidad'] as num).toDouble(),
        esOpcional: json['esOpcional'],
      );

  Map<String, dynamic> toJson() => {
        'ingrediente': ingrediente.toJson(),
        'cantidad': cantidad,
        'esOpcional': esOpcional,
      };
}

/// Enum que define los niveles de dificultad para las recetas
enum Dificultad {
  facil('Fácil'),
  medio('Medio'),
  dificil('Difícil');

  final String value;
  const Dificultad(this.value);

  factory Dificultad.fromJson(String value) =>
      Dificultad.values.firstWhere((e) => e.value == value);
  String toJson() => value;
}

/// Enum que define las categorías de recetas por momento del día
enum CategoriaReceta {
  desayuno('Desayuno'),
  colacionMatutina('Colación matutina'),
  almuerzo('Comida'),
  colacionVespertina('Colación vespertina'),
  cena('Cena'),
  snack('Snack'),
  postre('Postre');

  final String value;
  const CategoriaReceta(this.value);

  factory CategoriaReceta.fromJson(String value) =>
      CategoriaReceta.values.firstWhere((e) => e.value == value);
  String toJson() => value;
}

/// Modelo principal que representa una receta completa
/// Contiene todos los datos necesarios para mostrar y preparar una receta
class Receta {
  final String id;
  final String nombre;
  final String descripcion;
  final List<IngredienteReceta> ingredientes;
  final List<String> pasos;
  final int tiempoPreparacion;
  final Dificultad dificultad;
  final CategoriaReceta categoria;
  final double costoEstimado;
  final InformacionNutricional informacionNutricional;
  final String? imagenURL;

  Receta({
    String? id,
    required this.nombre,
    required this.descripcion,
    required this.ingredientes,
    required this.pasos,
    required this.tiempoPreparacion,
    required this.dificultad,
    required this.categoria,
    required this.costoEstimado,
    required this.informacionNutricional,
    this.imagenURL,
  }) : id = id ?? const Uuid().v4();

  factory Receta.fromJson(Map<String, dynamic> json) => Receta(
        id: json['id'],
        nombre: json['nombre'],
        descripcion: json['descripcion'],
        ingredientes: (json['ingredientes'] as List)
            .map((e) => IngredienteReceta.fromJson(e))
            .toList(),
        pasos: List<String>.from(json['pasos'] ?? []),
        tiempoPreparacion: json['tiempoPreparacion'],
        dificultad: Dificultad.fromJson(json['dificultad']),
        categoria: CategoriaReceta.fromJson(json['categoria']),
        costoEstimado: (json['costoEstimado'] as num).toDouble(),
        informacionNutricional: InformacionNutricional.fromJson(json['informacionNutricional']),
        imagenURL: json['imagenURL'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'descripcion': descripcion,
        'ingredientes': ingredientes.map((e) => e.toJson()).toList(),
        'pasos': pasos,
        'tiempoPreparacion': tiempoPreparacion,
        'dificultad': dificultad.toJson(),
        'categoria': categoria.toJson(),
        'costoEstimado': costoEstimado,
        'informacionNutricional': informacionNutricional.toJson(),
        'imagenURL': imagenURL,
      };
}

/// Modelo que representa una sugerencia de receta generada por IA
/// Incluye información sobre ingredientes disponibles y faltantes
class SugerenciaReceta {
  final String id;
  final Receta receta;
  final List<Ingrediente> ingredientesDisponibles;
  final List<Ingrediente> ingredientesFaltantes;
  final double costoIngredientesFaltantes;
  final double puntuacion;
  final List<String> razones;

  SugerenciaReceta({
    String? id,
    required this.receta,
    required this.ingredientesDisponibles,
    required this.ingredientesFaltantes,
    required this.costoIngredientesFaltantes,
    required this.puntuacion,
    required this.razones,
  }) : id = id ?? const Uuid().v4();

  factory SugerenciaReceta.fromJson(Map<String, dynamic> json) => SugerenciaReceta(
        id: json['id'],
        receta: Receta.fromJson(json['receta']),
        ingredientesDisponibles: (json['ingredientesDisponibles'] as List)
            .map((e) => Ingrediente.fromJson(e))
            .toList(),
        ingredientesFaltantes: (json['ingredientesFaltantes'] as List)
            .map((e) => Ingrediente.fromJson(e))
            .toList(),
        costoIngredientesFaltantes: (json['costoIngredientesFaltantes'] as num).toDouble(),
        puntuacion: (json['puntuacion'] as num).toDouble(),
        razones: List<String>.from(json['razones'] ?? []),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'receta': receta.toJson(),
        'ingredientesDisponibles': ingredientesDisponibles.map((e) => e.toJson()).toList(),
        'ingredientesFaltantes': ingredientesFaltantes.map((e) => e.toJson()).toList(),
        'costoIngredientesFaltantes': costoIngredientesFaltantes,
        'puntuacion': puntuacion,
        'razones': razones,
      };
}

/// Modelo que representa los filtros de búsqueda para recetas
/// Permite filtrar por ingredientes, presupuesto, tiempo, etc.
class FiltrosBusqueda {
  List<Ingrediente> ingredientesDisponibles;
  double? presupuestoMaximo;
  int? tiempoMaximo;
  CategoriaReceta? categoriaPreferida;
  Dificultad? dificultadMaxima;
  double? caloriasMaximas;
  bool incluirIngredientesFaltantes;

  FiltrosBusqueda({
    this.ingredientesDisponibles = const [],
    this.presupuestoMaximo,
    this.tiempoMaximo,
    this.categoriaPreferida,
    this.dificultadMaxima,
    this.caloriasMaximas,
    this.incluirIngredientesFaltantes = true,
  });

  factory FiltrosBusqueda.fromJson(Map<String, dynamic> json) => FiltrosBusqueda(
        ingredientesDisponibles: (json['ingredientesDisponibles'] as List?)?.map((e) => Ingrediente.fromJson(e)).toList() ?? [],
        presupuestoMaximo: (json['presupuestoMaximo'] as num?)?.toDouble(),
        tiempoMaximo: json['tiempoMaximo'],
        categoriaPreferida: json['categoriaPreferida'] != null ? CategoriaReceta.fromJson(json['categoriaPreferida']) : null,
        dificultadMaxima: json['dificultadMaxima'] != null ? Dificultad.fromJson(json['dificultadMaxima']) : null,
        caloriasMaximas: (json['caloriasMaximas'] as num?)?.toDouble(),
        incluirIngredientesFaltantes: json['incluirIngredientesFaltantes'] ?? true,
      );

  Map<String, dynamic> toJson() => {
        'ingredientesDisponibles': ingredientesDisponibles.map((e) => e.toJson()).toList(),
        'presupuestoMaximo': presupuestoMaximo,
        'tiempoMaximo': tiempoMaximo,
        'categoriaPreferida': categoriaPreferida?.toJson(),
        'dificultadMaxima': dificultadMaxima?.toJson(),
        'caloriasMaximas': caloriasMaximas,
        'incluirIngredientesFaltantes': incluirIngredientesFaltantes,
      };
}

/// Modelo para ingredientes de plantilla (templates)
/// Utilizado para mostrar ingredientes predefinidos en la interfaz
class TemplateIngredient {
  final String id;
  final String name;
  final String portionSize;
  final String description;
  final String icon;

  TemplateIngredient({
    String? id,
    required this.name,
    required this.portionSize,
    required this.description,
    required this.icon,
  }) : id = id ?? const Uuid().v4();

  factory TemplateIngredient.fromJson(Map<String, dynamic> json) => TemplateIngredient(
        id: json['id'],
        name: json['name'],
        portionSize: json['portionSize'],
        description: json['description'],
        icon: json['icon'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'portionSize': portionSize,
        'description': description,
        'icon': icon,
      };
}

/// Modelo que representa una receta en la base de datos
/// Estructura optimizada para almacenamiento en base de datos relacional
class DatabaseRecipe {
  final int id;
  final String name;
  final String description;
  final int prepTime;
  final String difficulty;
  final String category;
  final double estimatedCost;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final double fiber;
  final double sugar;
  final double sodium;
  final String? imageURL;
  final DateTime createdAt;
  final DateTime updatedAt;

  DatabaseRecipe({
    required this.id,
    required this.name,
    required this.description,
    required this.prepTime,
    required this.difficulty,
    required this.category,
    required this.estimatedCost,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.fiber,
    required this.sugar,
    required this.sodium,
    this.imageURL,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DatabaseRecipe.fromJson(Map<String, dynamic> json) => DatabaseRecipe(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        prepTime: json['prepTime'],
        difficulty: json['difficulty'],
        category: json['category'],
        estimatedCost: (json['estimatedCost'] as num).toDouble(),
        calories: (json['calories'] as num).toDouble(),
        protein: (json['protein'] as num).toDouble(),
        carbs: (json['carbs'] as num).toDouble(),
        fats: (json['fats'] as num).toDouble(),
        fiber: (json['fiber'] as num).toDouble(),
        sugar: (json['sugar'] as num).toDouble(),
        sodium: (json['sodium'] as num).toDouble(),
        imageURL: json['imageURL'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'prepTime': prepTime,
        'difficulty': difficulty,
        'category': category,
        'estimatedCost': estimatedCost,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fats': fats,
        'fiber': fiber,
        'sugar': sugar,
        'sodium': sodium,
        'imageURL': imageURL,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

/// Modelo que representa un favorito en la base de datos
/// Relaciona usuarios con recetas favoritas
class DatabaseFavorite {
  final int id;
  final int userId;
  final int recipeId;
  final DateTime addedAt;

  DatabaseFavorite({
    required this.id,
    required this.userId,
    required this.recipeId,
    required this.addedAt,
  });

  factory DatabaseFavorite.fromJson(Map<String, dynamic> json) => DatabaseFavorite(
        id: json['id'],
        userId: json['userId'],
        recipeId: json['recipeId'],
        addedAt: DateTime.parse(json['addedAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'recipeId': recipeId,
        'addedAt': addedAt.toIso8601String(),
      };
}

/// Modelo que representa un ingrediente en la base de datos
/// Estructura optimizada para almacenamiento en base de datos relacional
class DatabaseIngredient {
  final int id;
  final String name;
  final String category;
  final double averagePrice;
  final String unit;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final double fiber;
  final double sugar;
  final double sodium;

  DatabaseIngredient({
    required this.id,
    required this.name,
    required this.category,
    required this.averagePrice,
    required this.unit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.fiber,
    required this.sugar,
    required this.sodium,
  });

  factory DatabaseIngredient.fromJson(Map<String, dynamic> json) => DatabaseIngredient(
        id: json['id'],
        name: json['name'],
        category: json['category'],
        averagePrice: (json['averagePrice'] as num).toDouble(),
        unit: json['unit'],
        calories: (json['calories'] as num).toDouble(),
        protein: (json['protein'] as num).toDouble(),
        carbs: (json['carbs'] as num).toDouble(),
        fats: (json['fats'] as num).toDouble(),
        fiber: (json['fiber'] as num).toDouble(),
        sugar: (json['sugar'] as num).toDouble(),
        sodium: (json['sodium'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'averagePrice': averagePrice,
        'unit': unit,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fats': fats,
        'fiber': fiber,
        'sugar': sugar,
        'sodium': sodium,
      };
}

/// Modelo que representa la relación entre recetas e ingredientes en la base de datos
/// Tabla de relación muchos a muchos con cantidad y opcionalidad
class DatabaseRecipeIngredient {
  final int id;
  final int recipeId;
  final int ingredientId;
  final double quantity;
  final bool isOptional;

  DatabaseRecipeIngredient({
    required this.id,
    required this.recipeId,
    required this.ingredientId,
    required this.quantity,
    required this.isOptional,
  });

  factory DatabaseRecipeIngredient.fromJson(Map<String, dynamic> json) => DatabaseRecipeIngredient(
        id: json['id'],
        recipeId: json['recipeId'],
        ingredientId: json['ingredientId'],
        quantity: (json['quantity'] as num).toDouble(),
        isOptional: json['isOptional'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'recipeId': recipeId,
        'ingredientId': ingredientId,
        'quantity': quantity,
        'isOptional': isOptional,
      };
}

/// Modelo que representa un paso de receta en la base de datos
/// Almacena las instrucciones paso a paso de cada receta
class DatabaseRecipeStep {
  final int id;
  final int recipeId;
  final int stepNumber;
  final String instruction;

  DatabaseRecipeStep({
    required this.id,
    required this.recipeId,
    required this.stepNumber,
    required this.instruction,
  });

  factory DatabaseRecipeStep.fromJson(Map<String, dynamic> json) => DatabaseRecipeStep(
        id: json['id'],
        recipeId: json['recipeId'],
        stepNumber: json['stepNumber'],
        instruction: json['instruction'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'recipeId': recipeId,
        'stepNumber': stepNumber,
        'instruction': instruction,
      };
} 