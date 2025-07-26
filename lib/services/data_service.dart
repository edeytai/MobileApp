import '../models/models.dart';
import 'package:uuid/uuid.dart';

/// Servicio que centraliza todos los datos de la aplicación
/// Contiene ingredientes, recetas y métodos para acceder a ellos
class DataService {
  static final DataService instance = DataService._();
  DataService._() {
    _initRecetas();
  }

  /// Lista de ingredientes disponibles en la aplicación
  /// Cada ingrediente incluye información nutricional y precio promedio
  List<Ingrediente> ingredientes = [
    Ingrediente(
      nombre: "Pollo",
      categoria: CategoriaIngrediente.proteinas,
      precioPromedio: 80.0,
      unidad: "kg",
      informacionNutricional: InformacionNutricional(
        calorias: 165, proteinas: 31, carbohidratos: 0, grasas: 3.6, fibra: 0, azucares: 0, sodio: 74)),
    Ingrediente(
      nombre: "Huevos",
      categoria: CategoriaIngrediente.proteinas,
      precioPromedio: 45.0,
      unidad: "docena",
      informacionNutricional: InformacionNutricional(
        calorias: 155, proteinas: 13, carbohidratos: 1.1, grasas: 11, fibra: 0, azucares: 1.1, sodio: 124)),
    Ingrediente(
      nombre: "Arroz",
      categoria: CategoriaIngrediente.carbohidratos,
      precioPromedio: 25.0,
      unidad: "kg",
      informacionNutricional: InformacionNutricional(
        calorias: 130, proteinas: 2.7, carbohidratos: 28, grasas: 0.3, fibra: 0.4, azucares: 0.1, sodio: 1)),
    Ingrediente(
      nombre: "Tortillas",
      categoria: CategoriaIngrediente.carbohidratos,
      precioPromedio: 15.0,
      unidad: "paquete",
      informacionNutricional: InformacionNutricional(
        calorias: 104, proteinas: 3, carbohidratos: 20, grasas: 1.5, fibra: 1.2, azucares: 0.3, sodio: 193)),
    Ingrediente(
      nombre: "Tomate",
      categoria: CategoriaIngrediente.verduras,
      precioPromedio: 20.0,
      unidad: "kg",
      informacionNutricional: InformacionNutricional(
        calorias: 18, proteinas: 0.9, carbohidratos: 3.9, grasas: 0.2, fibra: 1.2, azucares: 2.6, sodio: 5)),
    Ingrediente(
      nombre: "Queso",
      categoria: CategoriaIngrediente.lacteos,
      precioPromedio: 120.0,
      unidad: "kg",
      informacionNutricional: InformacionNutricional(
        calorias: 402, proteinas: 25, carbohidratos: 1.3, grasas: 33, fibra: 0, azucares: 0.5, sodio: 621)),
    Ingrediente(
      nombre: "Aceite de oliva",
      categoria: CategoriaIngrediente.condimentos,
      precioPromedio: 80.0,
      unidad: "litro",
      informacionNutricional: InformacionNutricional(
        calorias: 884, proteinas: 0, carbohidratos: 0, grasas: 100, fibra: 0, azucares: 0, sodio: 2)),
    Ingrediente(
      nombre: "Sal",
      categoria: CategoriaIngrediente.condimentos,
      precioPromedio: 10.0,
      unidad: "kg",
      informacionNutricional: InformacionNutricional(
        calorias: 0, proteinas: 0, carbohidratos: 0, grasas: 0, fibra: 0, azucares: 0, sodio: 38758)),
  ];

  /// Lista de recetas disponibles en la aplicación
  late List<Receta> recetas;

  /// Genera un UUID consistente basado en el nombre, tiempo y calorías de la receta
  /// Esto asegura que las recetas tengan el mismo ID en diferentes ejecuciones
  String _generateConsistentUUID(String nombre, int tiempoPreparacion, double calorias) {
    final uniqueString = '${nombre.toLowerCase().replaceAll(' ', '-')}-${tiempoPreparacion}min-${calorias.toInt()}cal';
    int hash = 5381;
    for (int i = 0; i < uniqueString.length; i++) {
      hash = ((hash << 5) + hash) + uniqueString.codeUnitAt(i);
    }
    final uuid = Uuid().v5(Namespace.url.value, uniqueString);
    return uuid;
  }

  /// Inicializa la lista de recetas con datos de ejemplo
  /// Cada receta incluye ingredientes, pasos e información nutricional completa
  void _initRecetas() {
    recetas = [
      // Tacos de Pollo
      Receta(
        id: _generateConsistentUUID("Tacos de Pollo", 25, 350),
        nombre: "Tacos de Pollo",
        descripcion: "Deliciosos tacos de pollo con verduras frescas",
        ingredientes: [
          IngredienteReceta(ingrediente: ingredientes[0], cantidad: 0.5, esOpcional: false),
          IngredienteReceta(ingrediente: ingredientes[3], cantidad: 1, esOpcional: false),
          IngredienteReceta(ingrediente: ingredientes[4], cantidad: 0.2, esOpcional: false),
          IngredienteReceta(ingrediente: ingredientes[6], cantidad: 0.02, esOpcional: false),
          IngredienteReceta(ingrediente: ingredientes[7], cantidad: 0.005, esOpcional: false),
        ],
        pasos: [
          "Corta el pollo en tiras finas",
          "Calienta el aceite en una sartén",
          "Cocina el pollo hasta que esté dorado",
          "Pica las verduras finamente",
          "Calienta las tortillas",
          "Rellena las tortillas con pollo y verduras"
        ],
        tiempoPreparacion: 25,
        dificultad: Dificultad.facil,
        categoria: CategoriaReceta.almuerzo,
        costoEstimado: 45.0,
        informacionNutricional: InformacionNutricional(
          calorias: 350, proteinas: 28, carbohidratos: 25, grasas: 12, fibra: 3, azucares: 2, sodio: 450),
        imagenURL: null,
      ),
      // Ensalada con Arroz
      Receta(
        id: _generateConsistentUUID("Ensalada con Arroz", 20, 280),
        nombre: "Ensalada con Arroz",
        descripcion: "Ensalada nutritiva con arroz integral y verduras",
        ingredientes: [
          IngredienteReceta(ingrediente: ingredientes[2], cantidad: 0.2, esOpcional: false),
          IngredienteReceta(ingrediente: ingredientes[4], cantidad: 0.3, esOpcional: false),
          IngredienteReceta(ingrediente: ingredientes[6], cantidad: 0.01, esOpcional: false),
          IngredienteReceta(ingrediente: ingredientes[7], cantidad: 0.003, esOpcional: false),
        ],
        pasos: [
          "Cocina el arroz según las instrucciones del paquete",
          "Deja enfriar el arroz",
          "Pica todas las verduras",
          "Mezcla el arroz con las verduras",
          "Agrega aceite de oliva y sal al gusto"
        ],
        tiempoPreparacion: 20,
        dificultad: Dificultad.facil,
        categoria: CategoriaReceta.almuerzo,
        costoEstimado: 25.0,
        informacionNutricional: InformacionNutricional(
          calorias: 280, proteinas: 6, carbohidratos: 45, grasas: 8, fibra: 4, azucares: 3, sodio: 200),
        imagenURL: null,
      ),
      // Omelette de Queso
      Receta(
        id: _generateConsistentUUID("Omelette de Queso", 10, 420),
        nombre: "Omelette de Queso",
        descripcion: "Omelette clásico con queso derretido",
        ingredientes: [
          IngredienteReceta(ingrediente: ingredientes[1], cantidad: 3, esOpcional: false),
          IngredienteReceta(ingrediente: ingredientes[5], cantidad: 0.05, esOpcional: false),
          IngredienteReceta(ingrediente: ingredientes[6], cantidad: 0.01, esOpcional: false),
          IngredienteReceta(ingrediente: ingredientes[7], cantidad: 0.002, esOpcional: false),
        ],
        pasos: [
          "Bate los huevos en un tazón",
          "Agrega sal al gusto",
          "Calienta el aceite en una sartén",
          "Vierte los huevos batidos",
          "Cuando esté casi listo, agrega el queso",
          "Dobla el omelette y sirve"
        ],
        tiempoPreparacion: 10,
        dificultad: Dificultad.facil,
        categoria: CategoriaReceta.desayuno,
        costoEstimado: 35.0,
        informacionNutricional: InformacionNutricional(
          calorias: 420, proteinas: 25, carbohidratos: 2, grasas: 35, fibra: 0, azucares: 1, sodio: 650),
        imagenURL: null,
      ),
      // Pasta Carbonara
      Receta(
        id: _generateConsistentUUID("Pasta Carbonara", 30, 580),
        nombre: "Pasta Carbonara",
        descripcion: "Pasta italiana clásica con huevo y queso",
        ingredientes: [
          IngredienteReceta(ingrediente: ingredientes[1], cantidad: 2, esOpcional: false),
          IngredienteReceta(ingrediente: ingredientes[5], cantidad: 0.1, esOpcional: false),
          IngredienteReceta(ingrediente: ingredientes[6], cantidad: 0.02, esOpcional: false),
          IngredienteReceta(ingrediente: ingredientes[7], cantidad: 0.003, esOpcional: false),
        ],
        pasos: [
          "Cocina la pasta según las instrucciones",
          "Bate los huevos con queso rallado",
          "Escurre la pasta reservando un poco de agua",
          "Mezcla la pasta con los huevos y queso",
          "Agrega agua de cocción si es necesario",
          "Sirve inmediatamente"
        ],
        tiempoPreparacion: 30,
        dificultad: Dificultad.medio,
        categoria: CategoriaReceta.cena,
        costoEstimado: 55.0,
        informacionNutricional: InformacionNutricional(
          calorias: 580, proteinas: 22, carbohidratos: 65, grasas: 28, fibra: 3, azucares: 2, sodio: 450),
        imagenURL: null,
      ),
      // Smoothie Verde
      Receta(
        id: _generateConsistentUUID("Smoothie Verde", 5, 180),
        nombre: "Smoothie Verde",
        descripcion: "Smoothie saludable con espinacas y frutas",
        ingredientes: [
          IngredienteReceta(ingrediente: ingredientes[4], cantidad: 0.1, esOpcional: false),
          IngredienteReceta(ingrediente: ingredientes[6], cantidad: 0.01, esOpcional: false),
        ],
        pasos: [
          "Lava las espinacas",
          "Pela y corta las frutas",
          "Coloca todos los ingredientes en la licuadora",
          "Licúa hasta obtener una mezcla suave",
          "Sirve inmediatamente"
        ],
        tiempoPreparacion: 5,
        dificultad: Dificultad.facil,
        categoria: CategoriaReceta.desayuno,
        costoEstimado: 30.0,
        informacionNutricional: InformacionNutricional(
          calorias: 180, proteinas: 8, carbohidratos: 35, grasas: 2, fibra: 6, azucares: 25, sodio: 45),
        imagenURL: null,
      ),
      // Sopa de Pollo
      Receta(
        id: _generateConsistentUUID("Sopa de Pollo", 45, 320),
        nombre: "Sopa de Pollo",
        descripcion: "Sopa reconfortante con pollo y verduras",
        ingredientes: [
          IngredienteReceta(ingrediente: ingredientes[0], cantidad: 0.3, esOpcional: false),
          IngredienteReceta(ingrediente: ingredientes[4], cantidad: 0.2, esOpcional: false),
          IngredienteReceta(ingrediente: ingredientes[6], cantidad: 0.01, esOpcional: false),
          IngredienteReceta(ingrediente: ingredientes[7], cantidad: 0.005, esOpcional: false),
        ],
        pasos: [
          "Corta el pollo en trozos pequeños",
          "Pica todas las verduras",
          "Calienta el aceite en una olla grande",
          "Sofríe el pollo hasta que esté dorado",
          "Agrega las verduras y agua",
          "Cocina a fuego lento por 30 minutos",
          "Sazona con sal y pimienta"
        ],
        tiempoPreparacion: 45,
        dificultad: Dificultad.medio,
        categoria: CategoriaReceta.almuerzo,
        costoEstimado: 40.0,
        informacionNutricional: InformacionNutricional(
          calorias: 320, proteinas: 25, carbohidratos: 15, grasas: 18, fibra: 4, azucares: 3, sodio: 800),
        imagenURL: null,
      ),
    ];
  }

  /// Obtiene todas las recetas disponibles
  List<Receta> getAllRecipes() {
    return recetas;
  }

  /// Busca una receta por su ID único
  /// Retorna null si no se encuentra la receta
  Receta? getRecipeById(String id) {
    try {
      return recetas.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Busca recetas por nombre o descripción
  /// La búsqueda es insensible a mayúsculas/minúsculas
  List<Receta> searchRecipes(String query) {
    return recetas.where((recipe) =>
      recipe.nombre.toLowerCase().contains(query.toLowerCase()) ||
      recipe.descripcion.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  /// Obtiene recetas filtradas por categoría (desayuno, almuerzo, etc.)
  List<Receta> getRecipesByCategory(CategoriaReceta category) {
    return recetas.where((r) => r.categoria == category).toList();
  }

  /// Busca un ingrediente por nombre
  /// Retorna null si no se encuentra el ingrediente
  Ingrediente? buscarIngredientePorNombre(String nombre) {
    try {
      return ingredientes.firstWhere((i) => i.nombre.toLowerCase().contains(nombre.toLowerCase()));
    } catch (_) {
      return null;
    }
  }

  /// Obtiene ingredientes filtrados por categoría nutricional
  List<Ingrediente> obtenerIngredientesPorCategoria(CategoriaIngrediente categoria) {
    return ingredientes.where((i) => i.categoria == categoria).toList();
  }
} 