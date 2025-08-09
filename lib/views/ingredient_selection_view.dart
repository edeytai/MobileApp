import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/ingredient_service.dart';

/// Pantalla que permite seleccionar ingredientes desde un catálogo en Firestore.
/// Incluye búsqueda, selección múltiple y un panel inferior con los
/// ingredientes elegidos para continuar al siguiente paso del flujo.
class IngredientSelectionView extends StatefulWidget {
  const IngredientSelectionView({super.key});

  @override
  State<IngredientSelectionView> createState() => _IngredientSelectionViewState();
}

class _IngredientSelectionViewState extends State<IngredientSelectionView> {
  final TextEditingController _searchController = TextEditingController();

  String _query = '';
  final Set<String> _selectedIngredientNames = <String>{};

  List<SelectableIngredient> _applyFilter(List<SelectableIngredient> items) {
    if (_query.isEmpty) return items;
    final lower = _query.toLowerCase();
    return items.where((i) => i.name.toLowerCase().contains(lower)).toList();
  }

  void _toggleSelection(SelectableIngredient item) {
    setState(() {
      if (_selectedIngredientNames.contains(item.name)) {
        _selectedIngredientNames.remove(item.name);
      } else {
        _selectedIngredientNames.add(item.name);
      }
    });
  }

  void _removeSelection(SelectableIngredient item) {
    setState(() {
      _selectedIngredientNames.remove(item.name);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSelection = _selectedIngredientNames.isNotEmpty;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  // Título
                  Text(
                    'Selecciona ingredientes',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AppColors.appGreen,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Barra de búsqueda
                  TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Buscar ingrediente',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFF93C47D), width: 1.2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Grid expandible
                  Expanded(
                    child: StreamBuilder<List<SelectableIngredient>>(
                      stream: IngredientService.instance.watchIngredients(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final items = _applyFilter(snapshot.data!);
                        if (items.isEmpty) {
                          return const Center(child: Text('No se encontraron ingredientes'));
                        }
                        return GridView.builder(
                          padding: EdgeInsets.only(bottom: hasSelection ? 140 : 20),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.9,
                          ),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final bool isSelected = _selectedIngredientNames.contains(item.name);
                            return _IngredientTile(
                              name: item.name,
                              imageUrl: item.imageUrl,
                              isSelected: isSelected,
                              onTap: () => _toggleSelection(item),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Panel inferior de seleccionados
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  height: hasSelection ? 110 : 0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, -4),
                      ),
                    ],
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200, width: 1),
                    ),
                  ),
                  child: hasSelection
                      ? Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _selectedIngredientNames.length,
                                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                                  itemBuilder: (context, index) {
                                    // Este chip se renderiza a partir del stream superior; por simplicidad,
                                    // mostramos sólo el nombre y la imagen si se dispone mediante una búsqueda simple.
                                    // Para consistencia, se recomienda mantener un cache local de seleccionados si fuese necesario.
                                    return StreamBuilder<List<SelectableIngredient>>(
                                      stream: IngredientService.instance.watchIngredients(),
                                      builder: (context, snap) {
                                        final list = snap.data ?? [];
                                        final name = _selectedIngredientNames.elementAt(index);
                                        final found = list.firstWhere(
                                          (e) => e.name == name,
                                          orElse: () => SelectableIngredient(id: name, name: name, imageUrl: ''),
                                        );
                                        return _SelectedIngredientChip(
                                          name: found.name,
                                          imageUrl: found.imageUrl,
                                          onRemove: () => _removeSelection(found),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              _ProceedButton(onPressed: _goToNextStep),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToNextStep() {
    if (_selectedIngredientNames.isEmpty) return;
    Navigator.of(context).pushNamed(
      '/create-loading',
      arguments: _selectedIngredientNames.toList(growable: false),
    );
  }
}

class _IngredientTile extends StatelessWidget {
  final String name;
  final String imageUrl;
  final bool isSelected;
  final VoidCallback onTap;
  const _IngredientTile({required this.name, required this.imageUrl, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.appGreen : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: ClipOval(
              child: Image.network(
                imageUrl,
                width: 76,
                height: 76,
                fit: BoxFit.cover,
                errorBuilder: (_, error, stackTrace) => const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Modelo local eliminado: ahora usamos SelectableIngredient desde IngredientService

class _SelectedIngredientChip extends StatelessWidget {
  final String name;
  final String imageUrl;
  final VoidCallback onRemove;

  const _SelectedIngredientChip({required this.name, required this.imageUrl, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: ClipOval(
                child: Image.network(
                  imageUrl,
                  width: 54,
                  height: 54,
                  fit: BoxFit.cover,
                  errorBuilder: (_, error, stackTrace) => const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: -6,
          right: -6,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onRemove,
              customBorder: const CircleBorder(),
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade400, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.grey),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProceedButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _ProceedButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.appGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }
}


