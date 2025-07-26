import 'package:flutter/material.dart';
import 'profile_edit_view.dart';
import '../utils/route_transitions.dart';
import '../services/auth_service.dart';

/// Vista que muestra el menú lateral con opciones del perfil
/// Se muestra como un modal bottom sheet con animación
class MenuView extends StatelessWidget {
  final VoidCallback onClose;
  final Map<String, dynamic>? userData;

  const MenuView({
    super.key,
    required this.onClose,
    this.userData,
  });

  @override
  Widget build(BuildContext context) {
    return MenuSlideAnimation(
      onClose: onClose,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header del menú con botón de cerrar
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                bottom: 16,
                left: 24,
                right: 24,
              ),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: onClose,
                    child: const Text(
                      'Listo',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Lista de opciones del menú
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // Opción de notificaciones (placeholder)
                    _MenuOption(
                      icon: Icons.notifications,
                      text: 'Notificaciones',
                      onTap: () {
                        onClose();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Configuración de notificaciones próximamente.')),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Opción de recetas guardadas (placeholder)
                    _MenuOption(
                      icon: Icons.bookmark,
                      text: 'Guardados',
                      onTap: () {
                        onClose();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Recetas guardadas próximamente.')),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Opción para editar perfil
                    _MenuOption(
                      icon: Icons.edit,
                      text: 'Editar perfil',
                      onTap: () async {
                        onClose();
                        if (userData != null) {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileEditView(userData: userData!),
                            ),
                          );
                        }
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Opción de ajustes (placeholder)
                    _MenuOption(
                      icon: Icons.settings,
                      text: 'Ajustes',
                      onTap: () {
                        onClose();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Configuración de ajustes próximamente.')),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Opción de privacidad (placeholder)
                    _MenuOption(
                      icon: Icons.security,
                      text: 'Privacidad',
                      onTap: () {
                        onClose();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Configuración de privacidad próximamente.')),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Opción de ayuda (placeholder)
                    _MenuOption(
                      icon: Icons.help,
                      text: 'Ayuda',
                      onTap: () {
                        onClose();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Centro de ayuda próximamente.')),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Opción de acerca de (placeholder)
                    _MenuOption(
                      icon: Icons.info,
                      text: 'Acerca de',
                      onTap: () {
                        onClose();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Acerca de EETN próximamente.')),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            
            // Botón de cerrar sesión en la parte inferior
            Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).padding.bottom + 24,
              ),
              child: _MenuOption(
                icon: Icons.logout,
                text: 'Cerrar Sesión',
                isDestructive: true,
                onTap: () async {
                  onClose();
                  try {
                    await AuthService.instance.logout();
                    // No necesitamos navegar manualmente, el _RootFlow en main.dart
                    // se encargará de detectar el cambio de estado de autenticación
                    // y navegar correctamente a la pantalla de login
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al cerrar sesión: $e')),
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget que representa una opción individual del menú
/// Incluye icono, texto y manejo de tap
class _MenuOption extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuOption({
    required this.icon,
    required this.text,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isDestructive ? Colors.red : Colors.grey[700],
            ),
            const SizedBox(width: 20),
            Text(
              text,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isDestructive ? Colors.red : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 