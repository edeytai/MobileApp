import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../services/data_service.dart';
import '../services/favorite_recipes_manager.dart';
import '../models/models.dart';
import 'recipe_detail_view.dart';
import 'recipe_list_full_screen_view.dart';

/// Vista principal de la aplicación que muestra el dashboard del usuario
/// Incluye resumen nutricional, recetas favoritas y comidas recientes
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: FavoriteRecipesManager.instance,
      child: const _HomeViewBody(),
    );
  }
}

/// Cuerpo principal de la vista de inicio
/// Maneja el estado y la lógica de la pantalla
class _HomeViewBody extends StatefulWidget {
  const _HomeViewBody();
  @override
  State<_HomeViewBody> createState() => _HomeViewBodyState();
}

class _HomeViewBodyState extends State<_HomeViewBody> {
  final DataService _dataService = DataService.instance;
  late List<Receta> recetas;
  late List<Receta> plannedMeals;
  late List<Receta> previousMeals;

  @override
  void initState() {
    super.initState();
    // Inicializar datos de recetas
    recetas = _dataService.recetas;
    plannedMeals = [];
    previousMeals = recetas.length > 3 ? recetas.sublist(2, 6) : recetas;
    // Cargar favoritos desde Firestore
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FavoriteRecipesManager.instance.loadFavoritesFromFirestore();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EETN'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Sección de resumen nutricional
                _NutritionSummarySection(),
                const SizedBox(height: 24),
                // Sección de comidas planeadas
                _SectionTitle(
                  title: 'Comidas Planeadas',
                  onViewAll: null,
                ),
                _EmptyCard(
                  icon: Icons.calendar_today,
                  text: 'Hoy no hay nada en el menú. ¡Planea algo rico!',
                ),
                const SizedBox(height: 24),
                // Sección de recetas favoritas
                Consumer<FavoriteRecipesManager>(
                  builder: (context, favManager, _) {
                    final favoritos = favManager.favoriteRecipesFrom(recetas);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Mis Favoritos',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            if (favoritos.length > 3)
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RecipeListFullScreenView(
                                        title: 'Mis Favoritos',
                                        recipes: favoritos,
                                        emptyMessage: 'Aún no tienes recetas favoritas',
                                        emptyIcon: Icons.favorite_border,
                                      ),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(foregroundColor: AppColors.appGreen),
                                child: const Text('Ver más'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (favoritos.isEmpty)
                          _EmptyCard(
                            icon: Icons.favorite_border,
                            text: 'Aún no tienes recetas favoritas.',
                          )
                        else
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: favoritos
                                .take(3)
                                .map((receta) => _RecipeCard(receta: receta))
                                .toList(),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Sección de comidas recientes
                _SectionTitle(
                  title: 'Comidas Recientes',
                  onViewAll: previousMeals.length > 3 ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeListFullScreenView(
                          title: 'Comidas Recientes',
                          recipes: previousMeals,
                          emptyMessage: 'No hay comidas recientes',
                          emptyIcon: Icons.history,
                        ),
                      ),
                    );
                  } : null,
                ),
                previousMeals.isEmpty
                    ? _EmptyCard(
                        icon: Icons.history,
                        text: 'No hay comidas recientes.',
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: previousMeals
                            .take(3)
                            .map((receta) => _RecipeCard(receta: receta))
                            .toList(),
                      ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget que muestra el resumen nutricional del día
/// Incluye calorías, proteínas, carbohidratos, grasas, etc.
class _NutritionSummarySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      _NutritionCard(
        icon: Icons.local_fire_department,
        title: 'Calorías',
        value: '832',
        unit: 'kCal',
      ),
      _NutritionCard(
        icon: Icons.bolt,
        title: 'Proteína',
        value: '200',
        unit: 'g',
      ),
      _NutritionCard(
        icon: Icons.eco,
        title: 'Carbohidratos',
        value: '180',
        unit: 'g',
      ),
      _NutritionCard(
        icon: Icons.opacity,
        title: 'Grasas',
        value: '70',
        unit: 'g',
      ),
      _NutritionCard(icon: Icons.grass, title: 'Fibra', value: '25', unit: 'g'),
      _NutritionCard(
        icon: Icons.water_drop,
        title: 'Agua',
        value: '1000',
        unit: 'ml',
      ),
      _NutritionCard(icon: Icons.star, title: 'Azúcar', value: '30', unit: 'g'),
      _NutritionCard(
        icon: Icons.spa,
        title: 'Sodio',
        value: '1500',
        unit: 'mg',
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen Nutricional',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: constraints.maxWidth,
              height: 130,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, i) => items[i],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Tarjeta individual que muestra un valor nutricional
/// Incluye icono, valor, unidad y título
class _NutritionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String unit;
  const _NutritionCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.appGreen.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.appGreen.withAlpha(38)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.appGreen, size: 28),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(unit, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Widget que muestra el título de una sección con botón "Ver más" opcional
class _SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;
  const _SectionTitle({required this.title, this.onViewAll});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            style: TextButton.styleFrom(foregroundColor: AppColors.appGreen),
            child: const Text('Ver más'),
          ),
      ],
    );
  }
}

/// Widget que muestra un estado vacío con icono y mensaje
/// Utilizado cuando no hay contenido para mostrar
class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String text;
  const _EmptyCard({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.fieldBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.grey[400]),
          const SizedBox(height: 10),
          Text(text, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

/// Tarjeta que muestra una receta individual
/// Incluye información básica y botón de favorito
class _RecipeCard extends StatelessWidget {
  final Receta receta;
  const _RecipeCard({required this.receta});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.appGreen.withAlpha(30),
          child: Icon(Icons.restaurant_menu, color: AppColors.appGreen),
        ),
        title: Text(
          receta.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${receta.tiempoPreparacion} min | ${receta.categoria.toString().split('.').last}',
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
                const SizedBox(width: 4),
                Text('${receta.informacionNutricional.calorias.toInt()} cal'),
                const SizedBox(width: 16),
                Icon(Icons.attach_money, size: 16, color: AppColors.iconGreen),
                const SizedBox(width: 4),
                Text('\$${receta.costoEstimado.toInt()}'),
              ],
            ),
          ],
        ),
        trailing: Consumer<FavoriteRecipesManager>(
          builder: (context, favManager, _) {
            return FutureBuilder<bool>(
              future: favManager.isFavorite(receta.id),
              builder: (context, snapshot) {
                final isFavorite = snapshot.data ?? false;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                      ),
                      onPressed: () {
                        favManager.toggleFavorite(receta.id);
                      },
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                );
              },
            );
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailView(receta: receta),
            ),
          );
        },
      ),
    );
  }
}
