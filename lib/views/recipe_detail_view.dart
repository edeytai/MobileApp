import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/app_colors.dart';
import '../services/favorite_recipes_manager.dart';

/// Vista que muestra los detalles completos de una receta
/// Incluye información nutricional, ingredientes, pasos y funcionalidad de favoritos
class RecipeDetailView extends StatefulWidget {
  final Receta receta;
  const RecipeDetailView({super.key, required this.receta});

  @override
  State<RecipeDetailView> createState() => _RecipeDetailViewState();
}

class _RecipeDetailViewState extends State<RecipeDetailView> {
  final FavoriteRecipesManager _favoriteManager = FavoriteRecipesManager.instance;
  bool _isFavorite = false;
  bool _loadingFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavorite();
  }

  /// Carga el estado de favorito de la receta desde Firestore
  Future<void> _loadFavorite() async {
    setState(() => _loadingFavorite = true);
    final isFav = await _favoriteManager.isFavorite(widget.receta.id);
    setState(() {
      _isFavorite = isFav;
      _loadingFavorite = false;
    });
  }

  /// Alterna el estado de favorito de la receta
  Future<void> _toggleFavorite() async {
    setState(() => _loadingFavorite = true);
    await _favoriteManager.toggleFavorite(widget.receta.id);
    final isFav = await _favoriteManager.isFavorite(widget.receta.id);
    setState(() {
      _isFavorite = isFav;
      _loadingFavorite = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final receta = widget.receta;
    return Scaffold(
      appBar: AppBar(
        title: Text(receta.nombre),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        actions: [
          // Botón de favorito en el AppBar
          _loadingFavorite
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : IconButton(
                  icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border, color: _isFavorite ? AppColors.appGreen : null),
                  onPressed: _toggleFavorite,
                ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título y descripción de la receta
                Text(
                  receta.nombre,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (receta.descripcion.isNotEmpty)
                  Text(
                    receta.descripcion,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                const SizedBox(height: 16),
                // Chips con estadísticas básicas
                Row(
                  children: [
                    _StatChip(icon: Icons.schedule, label: '${receta.tiempoPreparacion} min'),
                    const SizedBox(width: 10),
                    _StatChip(icon: Icons.attach_money, label: '\$${receta.costoEstimado.toStringAsFixed(0)}'),
                    const SizedBox(width: 10),
                    _StatChip(icon: Icons.bar_chart, label: receta.dificultad.toString().split('.').last),
                  ],
                ),
                const SizedBox(height: 24),
                // Sección de información nutricional
                const Text('Información Nutricional', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 16,
                  runSpacing: 10,
                  children: [
                    _NutritionInfo(title: 'Calorías', value: '${receta.informacionNutricional.calorias.toStringAsFixed(0)} kcal', icon: Icons.local_fire_department),
                    _NutritionInfo(title: 'Proteínas', value: '${receta.informacionNutricional.proteinas.toStringAsFixed(1)} g', icon: Icons.bolt),
                    _NutritionInfo(title: 'Carbohidratos', value: '${receta.informacionNutricional.carbohidratos.toStringAsFixed(1)} g', icon: Icons.eco),
                    _NutritionInfo(title: 'Grasas', value: '${receta.informacionNutricional.grasas.toStringAsFixed(1)} g', icon: Icons.opacity),
                    _NutritionInfo(title: 'Fibra', value: '${receta.informacionNutricional.fibra.toStringAsFixed(1)} g', icon: Icons.grass),
                    _NutritionInfo(title: 'Azúcar', value: '${receta.informacionNutricional.azucares.toStringAsFixed(1)} g', icon: Icons.star),
                    _NutritionInfo(title: 'Sodio', value: '${receta.informacionNutricional.sodio.toStringAsFixed(1)} mg', icon: Icons.spa),
                  ],
                ),
                const SizedBox(height: 24),
                // Sección de ingredientes
                const Text('Ingredientes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ...receta.ingredientes.map((ing) => _IngredientRow(ing: ing)),
                const SizedBox(height: 24),
                // Sección de instrucciones
                const Text('Instrucciones', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ...receta.pasos.asMap().entries.map((e) => _StepRow(index: e.key, paso: e.value)),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget que muestra una estadística de la receta en formato chip
/// Utilizado para mostrar tiempo, costo y dificultad
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18, color: AppColors.appGreen),
      label: Text(label, style: const TextStyle(fontSize: 14)),
      backgroundColor: AppColors.appGreen.withAlpha(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

/// Widget que muestra información nutricional individual
/// Incluye icono, título y valor
class _NutritionInfo extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const _NutritionInfo({required this.title, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.appGreen.withAlpha(18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.appGreen, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget que muestra un ingrediente individual de la receta
/// Incluye cantidad, unidad, nombre y si es opcional
class _IngredientRow extends StatelessWidget {
  final IngredienteReceta ing;
  const _IngredientRow({required this.ing});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Text('•', style: TextStyle(fontSize: 18, color: AppColors.appGreen)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${ing.cantidad} ${ing.ingrediente.unidad} ${ing.ingrediente.nombre}${ing.esOpcional ? ' (opcional)' : ''}',
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget que muestra un paso individual de las instrucciones
/// Incluye número de paso y descripción
class _StepRow extends StatelessWidget {
  final int index;
  final String paso;
  const _StepRow({required this.index, required this.paso});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: AppColors.appGreen,
            child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(paso, style: const TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }
} 