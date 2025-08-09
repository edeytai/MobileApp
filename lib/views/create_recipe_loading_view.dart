import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/ia_recipe_service.dart';
import '../utils/app_colors.dart';
import 'main_tab_view.dart';
import 'recipe_list_full_screen_view.dart';

/// Pantalla de carga que, al ser mostrada, obtiene las preferencias del usuario
/// (onboarding) y llama a la IA con los ingredientes seleccionados para generar
/// recetas sugeridas. Al finalizar, navega a la lista de resultados.
class CreateRecipeLoadingView extends StatefulWidget {
  final List<String> ingredientNames;
  const CreateRecipeLoadingView({super.key, required this.ingredientNames});

  @override
  State<CreateRecipeLoadingView> createState() => _CreateRecipeLoadingViewState();
}

class _CreateRecipeLoadingViewState extends State<CreateRecipeLoadingView> {
  String? _error;
  bool _isRunning = true;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    setState(() {
      _error = null;
      _isRunning = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      final userDoc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
      final Map<String, dynamic> data = (userDoc.data() ?? <String, dynamic>{});
      final Map<String, List<String>> onboardingAnswers = {};
      if (data['onboardingAnswers'] is Map<String, dynamic>) {
        final raw = data['onboardingAnswers'] as Map<String, dynamic>;
        for (final entry in raw.entries) {
          final key = entry.key;
          final val = entry.value;
          onboardingAnswers[key] = (val is List)
              ? val.map((e) => e.toString()).toList()
              : <String>[];
        }
      }

      final List<Receta> suggestions = await IARecipeService.instance.generateRecipesWithOpenAI(
        ingredientNames: widget.ingredientNames,
        onboardingAnswers: onboardingAnswers,
      );

      if (!mounted) return;
      // Dejar pila como: Home -> Lista IA
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainTabView()),
        (_) => false,
      );
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RecipeListFullScreenView(
            title: 'Sugerencias de IA',
            recipes: suggestions,
            emptyMessage: 'La IA no generó recetas con los criterios dados.',
            emptyIcon: Icons.psychology_alt_outlined,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Generando recetas...'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (_isRunning) ...[
                  const SizedBox(height: 12),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Conectando con IA para crear recetas con tus ingredientes...',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ] else if (_error != null) ...[
                  Icon(Icons.error_outline, color: Colors.red[400], size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Ocurrió un error al generar recetas:\n${/* Avoid long error */ ''}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Volver'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _run,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.appGreen, foregroundColor: Colors.white),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}


