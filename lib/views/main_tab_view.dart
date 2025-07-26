import 'package:flutter/material.dart';
import 'home_view.dart';
import 'package:eetn/views/profile_view.dart';
import '../utils/app_colors.dart';

/// Vista principal que contiene la navegación por tabs
/// Maneja la transición entre las diferentes secciones de la aplicación
class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  bool _isAnimating = false;

  /// Lista de páginas que se muestran en cada tab
  final List<Widget> _pages = [
    const HomeView(),
    const CreateRecipePlaceholder(),
    const ProfileView(),
  ];

  /// Maneja el cambio de tab con animación suave
  /// Previene cambios múltiples durante la animación
  void _onTabTapped(int index) async {
    if (_selectedIndex == index || _isAnimating) return;
    setState(() {
      _isAnimating = true;
    });
    await _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    setState(() {
      _selectedIndex = index;
      _isAnimating = false;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _selectedIndex = index);
        },
        physics: const BouncingScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: InkRipple.splashFactory,
          splashColor: AppColors.appGreenHighlight,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onTabTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
            BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Crear'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          ],
          backgroundColor: AppColors.backgroundColor,
          selectedItemColor: AppColors.appGreen,
          unselectedItemColor: Colors.grey,
          elevation: 8,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          enableFeedback: true,
        ),
      ),
    );
  }
}

/// Widget placeholder para la funcionalidad de crear receta
/// Se mostrará hasta que se implemente la funcionalidad completa
class CreateRecipePlaceholder extends StatelessWidget {
  const CreateRecipePlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Crear Receta (próximamente)',
        style: TextStyle(fontSize: 22),
      ),
    );
  }
}

/// Widget placeholder para la funcionalidad de perfil
/// Se mostrará hasta que se implemente la funcionalidad completa
class ProfilePlaceholder extends StatelessWidget {
  const ProfilePlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Perfil (próximamente)', style: TextStyle(fontSize: 22)),
    );
  }
}
