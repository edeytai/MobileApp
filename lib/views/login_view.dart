import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/auth_service.dart';
import 'sign_up_view.dart';
import 'password_reset_view.dart';
import 'complete_registration_view.dart';
import '../utils/route_transitions.dart';

/// Vista de inicio de sesión que permite a los usuarios autenticarse
/// Incluye login con email/contraseña, Google y Apple
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isPasswordVisible = false;

  /// Maneja el proceso de login con email y contraseña
  /// Valida los campos y muestra errores si es necesario
  void _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await AuthService.instance.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (!mounted) return;
      // No necesitamos navegar manualmente, el _RootFlow en main.dart se encargará
      // de detectar el cambio de estado de autenticación y navegar correctamente
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Maneja el proceso de login con Google
  /// Verifica si el usuario tiene perfil completo o necesita completar registro
  void _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await AuthService.instance.loginWithGoogleAndCheckProfile();
      final user = result['user'];
      final hasProfile = result['hasProfile'] as bool;
      if (!mounted) return;
      if (hasProfile) {
        // Si tiene perfil completo, no necesitamos navegar manualmente
        // el _RootFlow en main.dart se encargará de detectar el cambio
        // de estado de autenticación y navegar correctamente
      } else {
        // Si no tiene perfil completo, navega a completar registro
        Navigator.push(
          context,
          slideFromRightRoute(CompleteRegistrationView(user: user)),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                // Header con logo y mensaje de bienvenida
                Column(
                  children: [
                    Text(
                      'EETN',
                      style: TextStyle(
                        fontSize: 54,
                        fontWeight: FontWeight.bold,
                        color: AppColors.appGreen,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Bienvenido de vuelta',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Inicia sesión para descubrir nuevas recetas.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // Campo de email
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.fieldBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person_outline),
                      hintText: 'Correo',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 18),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                const SizedBox(height: 16),
                // Campo de contraseña con toggle de visibilidad
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.fieldBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 12.0),
                        child: Icon(Icons.lock_outline),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            hintText: 'Contraseña',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 18),
                          ),
                          obscureText: !_isPasswordVisible,
                        ),
                      ),
                      IconButton(
                        icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Enlace para restablecer contraseña
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isLoading ? null : () {
                      Navigator.push(
                        context,
                        slideFromRightRoute(const PasswordResetView()),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.appGreen,
                      textStyle: const TextStyle(fontSize: 13),
                    ),
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                ),
                // Mensaje de error si existe
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                const SizedBox(height: 8),
                // Botón de login principal
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.appGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Iniciar Sesión',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 18),
                // Separador visual
                Row(
                  children: [
                    const Expanded(child: Divider(thickness: 1, color: AppColors.divider)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text('O', style: TextStyle(color: Colors.grey[600])),
                    ),
                    const Expanded(child: Divider(thickness: 1, color: AppColors.divider)),
                  ],
                ),
                const SizedBox(height: 18),
                // Botón de login con Google
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _loginWithGoogle,
                    icon: const Icon(Icons.g_mobiledata, color: Colors.red, size: 28),
                    label: const Text(
                      'Iniciar sesión con Google',
                      style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: AppColors.divider),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Botón de login con Apple (placeholder)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : () {},
                    icon: const Icon(Icons.apple, color: Colors.black, size: 24),
                    label: const Text(
                      'Iniciar sesión con Apple',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: AppColors.divider),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Enlace para registrarse
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿No tienes una cuenta?', style: TextStyle(fontSize: 14)),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          slideFromRightRoute(const SignUpView()),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.appGreen,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      child: const Text('Regístrate'),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 