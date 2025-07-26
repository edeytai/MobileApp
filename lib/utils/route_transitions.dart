import 'package:flutter/material.dart';

/// Crea una transición de página que se desliza desde la derecha
/// Utilizada para navegación entre pantallas con efecto de deslizamiento
PageRouteBuilder<dynamic> slideFromRightRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.ease;
      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
  );
}

/// Widget que proporciona animación de deslizamiento desde abajo para menús
/// Combina animación de deslizamiento y fade para una transición suave
class MenuSlideAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback? onClose;

  const MenuSlideAnimation({
    super.key,
    required this.child,
    this.onClose,
  });

  @override
  State<MenuSlideAnimation> createState() => _MenuSlideAnimationState();
}

class _MenuSlideAnimationState extends State<MenuSlideAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Configurar el controlador de animación
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Animación de deslizamiento desde abajo hacia arriba
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    // Animación de fade para suavizar la aparición
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    // Iniciar la animación automáticamente
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Cierra el menú con animación y ejecuta el callback onClose
  Future<void> closeWithAnimation() async {
    await _animationController.reverse();
    widget.onClose?.call();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Muestra un modal bottom sheet con contenido de menú
/// Permite cerrar tocando fuera del contenido y es arrastrable
void showMenuModal(BuildContext context, Widget menuContent) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        color: Colors.transparent,
        child: DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) => menuContent,
        ),
      ),
    ),
  );
} 