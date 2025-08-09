import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

/// Servicio que maneja la generación de recetas mediante inteligencia artificial
/// Integra la API de OpenAI usando `dart-define` para inyectar la API key en tiempo de build.
class IARecipeService {
  static final IARecipeService instance = IARecipeService._();
  IARecipeService._();

  /// Lee la API key desde variables de entorno en tiempo de ejecución.
  /// En Flutter, define `--dart-define=OPENAI_API_KEY=...` al ejecutar la app.
  String? get _apiKey => const String.fromEnvironment('OPENAI_API_KEY');

  /// Modelo de OpenAI a usar. Puedes cambiarlo si lo deseas.
  static const String _defaultModel = 'gpt-4.1-nano';

  /// Endpoint Chat Completions compatible (v1) para simplicidad de integración.
  static const String _chatCompletionsUrl = 'https://api.openai.com/v1/chat/completions';

  /// Convierte la respuesta de la IA (JSON) a una lista de `Receta` usando un formato JSON acordado en el prompt.
  List<Receta> _parseRecipesFromModelJson(Map<String, dynamic> json) {
    final List<dynamic> items = (json['recipes'] as List<dynamic>? ?? []);
    final List<Receta> result = [];
    for (final item in items) {
      try {
        // Se esperan campos mínimos: nombre, descripcion, pasos (List<String>), tiempo, dificultad, categoria, costo, infoNutricional
        final String nombre = item['name'] ?? 'Receta sin nombre';
        final String descripcion = item['description'] ?? '';
        final List<String> pasos = (item['steps'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
        final int tiempo = (item['timeMinutes'] as num?)?.toInt() ?? 20;
        final String dificultadStr = (item['difficulty'] ?? 'Fácil').toString();
        final String categoriaStr = (item['category'] ?? 'Comida').toString();
        final double costo = (item['estimatedCost'] as num?)?.toDouble() ?? 0;
        final Map<String, dynamic> info = (item['nutrition'] as Map<String, dynamic>? ?? {});

        final InformacionNutricional infoNutricional = InformacionNutricional(
          calorias: (info['calories'] as num?)?.toDouble() ?? 0,
          proteinas: (info['protein'] as num?)?.toDouble() ?? 0,
          carbohidratos: (info['carbs'] as num?)?.toDouble() ?? 0,
          grasas: (info['fats'] as num?)?.toDouble() ?? 0,
          fibra: (info['fiber'] as num?)?.toDouble() ?? 0,
          azucares: (info['sugar'] as num?)?.toDouble() ?? 0,
          sodio: (info['sodium'] as num?)?.toDouble() ?? 0,
        );

        // Ingredientes opcionales devueltos por la IA
        final List<dynamic> ingredientsJson = (item['ingredients'] as List<dynamic>? ?? []);
        final List<IngredienteReceta> ingredientes = ingredientsJson.map((ing) {
          final String ingName = (ing['name'] ?? '').toString();
          final double cantidad = (ing['quantity'] as num?)?.toDouble() ?? 0;
          final String unit = (ing['unit'] ?? '').toString();
          final bool optional = (ing['optional'] == true);
          final Ingrediente ingrediente = Ingrediente(
            nombre: ingName.isEmpty ? 'Ingrediente' : ingName,
            categoria: CategoriaIngrediente.otros,
            precioPromedio: 0,
            unidad: unit.isEmpty ? 'ud' : unit,
            informacionNutricional: InformacionNutricional(
              calorias: 0,
              proteinas: 0,
              carbohidratos: 0,
              grasas: 0,
              fibra: 0,
              azucares: 0,
              sodio: 0,
            ),
          );
          return IngredienteReceta(ingrediente: ingrediente, cantidad: cantidad, esOpcional: optional);
        }).toList();

        final Receta receta = Receta(
          nombre: nombre,
          descripcion: descripcion,
          ingredientes: ingredientes,
          pasos: pasos,
          tiempoPreparacion: tiempo,
          dificultad: _mapDificultad(dificultadStr),
          categoria: _mapCategoria(categoriaStr),
          costoEstimado: costo,
          informacionNutricional: infoNutricional,
          imagenURL: item['imageUrl']?.toString(),
        );
        result.add(receta);
      } catch (_) {
        // Ignorar items mal formados sin romper toda la respuesta
        continue;
      }
    }
    return result;
  }

  Dificultad _mapDificultad(String value) {
    final lower = value.toLowerCase();
    if (lower.contains('dif') || lower.contains('hard')) return Dificultad.dificil;
    if (lower.contains('med')) return Dificultad.medio;
    return Dificultad.facil;
  }

  CategoriaReceta _mapCategoria(String value) {
    final lower = value.toLowerCase();
    if (lower.contains('desayuno') || lower.contains('breakfast')) return CategoriaReceta.desayuno;
    if (lower.contains('almuerzo') || lower.contains('comida') || lower.contains('lunch')) return CategoriaReceta.almuerzo;
    if (lower.contains('cena') || lower.contains('dinner')) return CategoriaReceta.cena;
    if (lower.contains('postre') || lower.contains('dessert')) return CategoriaReceta.postre;
    if (lower.contains('snack')) return CategoriaReceta.snack;
    return CategoriaReceta.almuerzo;
  }

  /// Construye un prompt estructurado para pedir a la IA recetas en JSON.
  String _buildSystemPrompt() {
    return 'Eres un asistente experto en nutrición y cocina. Devuelves únicamente JSON válido y conciso. '
        'No incluyas texto fuera de JSON.';
  }

  String _buildUserPrompt({required List<String> ingredientNames, required Map<String, List<String>> onboardingAnswers}) {
    final buf = StringBuffer();
    buf.writeln('Genera entre 3 y 6 recetas en formato JSON con la siguiente estructura:');
    buf.writeln('{"recipes": [');
    buf.writeln('{');
    buf.writeln('  "name": "...",');
    buf.writeln('  "description": "...",');
    buf.writeln('  "ingredients": [');
    buf.writeln('    {"name": "...", "quantity": 1.0, "unit": "g|ml|ud", "optional": false}');
    buf.writeln('  ],');
    buf.writeln('  "steps": ["...", "..."],');
    buf.writeln('  "timeMinutes": 20,');
    buf.writeln('  "difficulty": "Fácil|Medio|Difícil",');
    buf.writeln('  "category": "Desayuno|Comida|Cena|Snack|Postre",');
    buf.writeln('  "estimatedCost": 0,');
    buf.writeln('  "nutrition": {"calories": 0, "protein": 0, "carbs": 0, "fats": 0, "fiber": 0, "sugar": 0, "sodium": 0}');
    buf.writeln('}');
    buf.writeln('] }');
    buf.writeln('Usa únicamente estos ingredientes disponibles (puede faltar alguno extra básico):');
    buf.writeln(ingredientNames.join(', '));
    buf.writeln('Preferencias del usuario (onboarding):');
    onboardingAnswers.forEach((key, value) {
      buf.writeln('- $key: ${value.join('; ')}');
    });
    buf.writeln('Respeta restricciones y objetivos. Responde solo con JSON válido.');
    return buf.toString();
  }

  /// Llama a OpenAI y devuelve una lista de `Receta`.
  Future<List<Receta>> generateRecipesWithOpenAI({
    required List<String> ingredientNames,
    required Map<String, List<String>> onboardingAnswers,
  }) async {
    final apiKey = _apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OPENAI_API_KEY no configurada. Ejecuta con --dart-define=OPENAI_API_KEY=tu_api_key');
    }

    final headers = <String, String>{
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'model': _defaultModel,
      'temperature': 0.7,
      'messages': [
        {'role': 'system', 'content': _buildSystemPrompt()},
        {'role': 'user', 'content': _buildUserPrompt(ingredientNames: ingredientNames, onboardingAnswers: onboardingAnswers)},
      ],
      'response_format': {'type': 'json_object'},
    });

    final response = await http.post(Uri.parse(_chatCompletionsUrl), headers: headers, body: body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Error OpenAI (${response.statusCode}): ${response.body}');
    }

    final Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;
    final List<dynamic> choices = (json['choices'] as List<dynamic>? ?? []);
    if (choices.isEmpty) return [];
    final String content = choices.first['message']?['content']?.toString() ?? '{}';

    // El contenido es JSON por response_format json_object
    Map<String, dynamic> modelJson;
    try {
      modelJson = jsonDecode(content) as Map<String, dynamic>;
    } catch (_) {
      // Si falló, intenta extraer JSON rudimentario
      final start = content.indexOf('{');
      final end = content.lastIndexOf('}');
      if (start >= 0 && end > start) {
        modelJson = jsonDecode(content.substring(start, end + 1)) as Map<String, dynamic>;
      } else {
    return [];
      }
    }
    return _parseRecipesFromModelJson(modelJson);
  }
} 