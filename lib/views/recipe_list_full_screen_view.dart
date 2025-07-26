import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/favorite_recipes_manager.dart';
import '../utils/app_colors.dart';
import 'recipe_detail_view.dart';

/// Vista que muestra una lista completa de recetas en pantalla completa
/// Incluye funcionalidad de búsqueda y filtros (placeholder)
class RecipeListFullScreenView extends StatefulWidget {
  final String title;
  final List<Receta> recipes;
  final String? emptyMessage;
  final IconData? emptyIcon;

  const RecipeListFullScreenView({
    super.key,
    required this.title,
    required this.recipes,
    this.emptyMessage,
    this.emptyIcon,
  });

  @override
  State<RecipeListFullScreenView> createState() => _RecipeListFullScreenViewState();
}

class _RecipeListFullScreenViewState extends State<RecipeListFullScreenView> {
  List<Receta> _filteredRecipes = [];

  @override
  void initState() {
    super.initState();
    _filteredRecipes = widget.recipes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        actions: [
          // Botones de filtro y búsqueda (solo si hay recetas)
          if (widget.recipes.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Filtros próximamente'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: _RecipeSearchDelegate(widget.recipes),
                );
              },
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: ChangeNotifierProvider.value(
          value: FavoriteRecipesManager.instance,
          child: _filteredRecipes.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _filteredRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = _filteredRecipes[index];
                    return _RecipeCard(receta: recipe);
                  },
                ),
        ),
      ),
    );
  }

  /// Construye el estado vacío cuando no hay recetas
  /// Muestra un icono y mensaje personalizable
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.emptyIcon ?? Icons.restaurant_menu,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            widget.emptyMessage ?? 'No hay recetas disponibles',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Delegate para la funcionalidad de búsqueda de recetas
/// Permite buscar por nombre y descripción de las recetas
class _RecipeSearchDelegate extends SearchDelegate<String> {
  final List<Receta> recipes;

  _RecipeSearchDelegate(this.recipes);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  /// Construye los resultados de búsqueda
  /// Filtra las recetas por nombre y descripción
  Widget _buildSearchResults() {
    final filteredRecipes = recipes.where((recipe) {
      return recipe.nombre.toLowerCase().contains(query.toLowerCase()) ||
             recipe.descripcion.toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (filteredRecipes.isEmpty) {
      return const Center(
        child: Text(
          'No se encontraron recetas',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: filteredRecipes.length,
      itemBuilder: (context, index) {
        final recipe = filteredRecipes[index];
        return _RecipeCard(receta: recipe);
      },
    );
  }
}

/// Widget que representa una receta individual en la lista
/// Incluye información básica y funcionalidad de favoritos
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