import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../utils/app_colors.dart';
import '../services/auth_service.dart';
import 'onboarding_view.dart';
import '../utils/route_transitions.dart';

/// Vista de registro que permite a los usuarios crear una nueva cuenta
/// Incluye validación en tiempo real de email y username, y validación de contraseña
class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  // Controladores para los campos de texto
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  // Variables de estado del formulario
  DateTime? _birthday;
  String? _gender;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isEmailTaken = false;
  bool _isUsernameTaken = false;
  bool _isCheckingEmail = false;
  bool _isCheckingUsername = false;
  
  // Timers para debounce de validación
  Timer? _emailDebounceTimer;
  Timer? _usernameDebounceTimer;

  final List<String> _genders = ['Masculino', 'Femenino', 'Otro'];

  // Validaciones de contraseña
  bool get _isPasswordLengthValid => _passwordController.text.length >= 8 && _passwordController.text.length <= 24;
  bool get _hasUppercase => _passwordController.text.contains(RegExp(r'[A-Z]'));
  bool get _hasDigit => _passwordController.text.contains(RegExp(r'[0-9]'));
  
  // Validaciones de username y email
  bool get _isUsernameValid => RegExp(r'^[a-z0-9._]{3,24}').hasMatch(_usernameController.text);
  bool get _isEmailValid => RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,24}').hasMatch(_emailController.text);
  
  // Validación completa del formulario
  bool get _isFormValid =>
    _nameController.text.isNotEmpty &&
    _usernameController.text.isNotEmpty &&
    _isUsernameValid &&
    _emailController.text.isNotEmpty &&
    _isEmailValid &&
    _gender != null &&
    _birthday != null &&
    _isPasswordLengthValid &&
    _hasUppercase &&
    _hasDigit &&
    _passwordController.text == _confirmPasswordController.text;

  @override
  void initState() {
    super.initState();
    // Agregar listeners para validación en tiempo real
    _emailController.addListener(_onEmailChanged);
    _usernameController.addListener(_onUsernameChanged);
    _passwordController.addListener(_onPasswordChanged);
    _confirmPasswordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    // Limpiar listeners y timers
    _emailController.removeListener(_onEmailChanged);
    _usernameController.removeListener(_onUsernameChanged);
    _passwordController.removeListener(_onPasswordChanged);
    _confirmPasswordController.removeListener(_onPasswordChanged);
    _emailDebounceTimer?.cancel();
    _usernameDebounceTimer?.cancel();
    super.dispose();
  }

  /// Actualiza el estado cuando cambia la contraseña
  void _onPasswordChanged() {
    setState(() {});
  }

  /// Valida el email en tiempo real con debounce
  /// Verifica si el email ya está en uso
  void _onEmailChanged() async {
    final email = _emailController.text.trim();
    
    setState(() {});
    
    _emailDebounceTimer?.cancel();
    
    if (!_isEmailValid || email.isEmpty) {
      setState(() {
        _isEmailTaken = false;
        _isCheckingEmail = false;
      });
      return;
    }
    
    _emailDebounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return;
      
      setState(() {
        _isCheckingEmail = true;
      });
      
      final taken = await AuthService.instance.isEmailTaken(email);
      if (mounted) {
        setState(() {
          _isEmailTaken = taken;
          _isCheckingEmail = false;
        });
      }
    });
  }

  /// Valida el username en tiempo real con debounce
  /// Limpia caracteres no válidos y verifica disponibilidad
  void _onUsernameChanged() async {
    final cleaned = _usernameController.text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9._]'), '');
    if (cleaned != _usernameController.text) {
      _usernameController.value = TextEditingValue(
        text: cleaned,
        selection: TextSelection.collapsed(offset: cleaned.length),
      );
    }
    
    setState(() {});
    
    _usernameDebounceTimer?.cancel();
    
    final username = cleaned;
    if (!_isUsernameValid || username.isEmpty) {
      setState(() {
        _isUsernameTaken = false;
        _isCheckingUsername = false;
      });
      return;
    }
    
    _usernameDebounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return;
      
      setState(() {
        _isCheckingUsername = true;
      });
      
      final taken = await AuthService.instance.isUsernameTaken(username);
      if (mounted) {
        setState(() {
          _isUsernameTaken = taken;
          _isCheckingUsername = false;
        });
      }
    });
  }

  /// Verifica si se puede proceder con el registro
  bool get _canRegister => _isFormValid && !_isEmailTaken && !_isUsernameTaken && !_isCheckingEmail && !_isCheckingUsername;

  /// Procesa el registro del usuario
  /// Crea la cuenta y navega al onboarding
  void _register() async {
    if (!_isFormValid) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await AuthService.instance.register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        birthday: _birthday!,
        gender: _gender!,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        slideFromRightRoute(const OnboardingView()),
        (route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuenta creada exitosamente.')),
      );
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
      appBar: AppBar(
        title: const Text('Crear cuenta'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          // Gesture para navegar hacia atrás con swipe
          onHorizontalDragUpdate: (details) {
            if (details.delta.dx > 15) {
              Navigator.of(context).maybePop();
            }
          },
          child: SizedBox.expand(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 18),
                    const Text(
                      'Completa tus datos para empezar.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Campo de nombre
                    _FormField(
                      icon: Icons.person,
                      hint: 'Nombre',
                      controller: _nameController,
                    ),
                    const SizedBox(height: 14),
                    // Campo de username con validación en tiempo real
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.fieldBackground,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 12.0),
                            child: Icon(Icons.alternate_email),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                hintText: 'Nombre de usuario',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 18),
                              ),
                              autocorrect: false,
                              enableSuggestions: false,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9._]')),
                              ],
                            ),
                          ),
                          // Indicadores de estado del username
                          if (_isCheckingUsername)
                            const Padding(
                              padding: EdgeInsets.only(right: 12.0),
                              child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                            )
                          else if (_usernameController.text.isNotEmpty && _isUsernameValid && !_isUsernameTaken)
                            const Padding(
                              padding: EdgeInsets.only(right: 12.0),
                              child: Icon(Icons.check_circle, color: AppColors.success),
                            )
                          else if (_isUsernameTaken)
                            const Padding(
                              padding: EdgeInsets.only(right: 12.0),
                              child: Icon(Icons.cancel, color: AppColors.error),
                            ),
                        ],
                      ),
                    ),
                    // Mensajes de error para username
                    if (!_isUsernameValid && _usernameController.text.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0, top: 2),
                        child: Text('Solo minúsculas, números, "." y "_", mínimo 3 caracteres.', style: TextStyle(color: AppColors.error, fontSize: 12)),
                      ),
                    if (_isUsernameTaken)
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0, top: 2),
                        child: Text('El nombre de usuario ya está en uso.', style: TextStyle(color: AppColors.error, fontSize: 12)),
                      ),
                    const SizedBox(height: 14),
                    // Selector de fecha de nacimiento
                    Row(
                      children: [
                        const Icon(Icons.cake, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime(2000, 1, 1),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() {
                                  _birthday = picked;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                              decoration: BoxDecoration(
                                color: AppColors.fieldBackground,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _birthday == null ? 'Cumpleaños' : '${_birthday!.day}/${_birthday!.month}/${_birthday!.year}',
                                style: TextStyle(
                                  color: _birthday == null ? Colors.grey : Colors.black,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Selector de género
                    Row(
                      children: [
                        const Icon(Icons.people, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _gender,
                            hint: const Text('Género'),
                            items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                            onChanged: (val) => setState(() => _gender = val),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.fieldBackground,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Campo de email con validación en tiempo real
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.fieldBackground,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 12.0),
                            child: Icon(Icons.email),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                hintText: 'Correo electrónico',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 18),
                              ),
                            ),
                          ),
                          // Indicadores de estado del email
                          if (_isCheckingEmail)
                            const Padding(
                              padding: EdgeInsets.only(right: 12.0),
                              child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                            )
                          else if (_emailController.text.isNotEmpty && _isEmailValid && !_isEmailTaken)
                            const Padding(
                              padding: EdgeInsets.only(right: 12.0),
                              child: Icon(Icons.check_circle, color: AppColors.success),
                            )
                          else if (_isEmailTaken)
                            const Padding(
                              padding: EdgeInsets.only(right: 12.0),
                              child: Icon(Icons.cancel, color: Colors.red),
                            ),
                        ],
                      ),
                    ),
                    // Mensajes de error para email
                    if (!_isEmailValid && _emailController.text.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0, top: 2),
                        child: Text('Formato de correo no válido.', style: TextStyle(color: Colors.red, fontSize: 12)),
                      ),
                    if (_isEmailTaken)
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0, top: 2),
                        child: Text('El correo electrónico ya está en uso.', style: TextStyle(color: Colors.red, fontSize: 12)),
                      ),
                    const SizedBox(height: 14),
                    // Campo de contraseña
                    _PasswordField(
                      controller: _passwordController,
                      hint: 'Contraseña',
                      isVisible: _isPasswordVisible,
                      onVisibilityChanged: (v) => setState(() => _isPasswordVisible = v),
                    ),
                    const SizedBox(height: 8),
                    // Campo de confirmación de contraseña
                    _PasswordField(
                      controller: _confirmPasswordController,
                      hint: 'Confirmar contraseña',
                      isVisible: _isConfirmPasswordVisible,
                      onVisibilityChanged: (v) => setState(() => _isConfirmPasswordVisible = v),
                    ),
                    // Validación de coincidencia de contraseñas
                    if (_passwordController.text != _confirmPasswordController.text && _confirmPasswordController.text.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0, top: 2),
                        child: Text('Las contraseñas no coinciden.', style: TextStyle(color: Colors.red, fontSize: 12)),
                      ),
                    const SizedBox(height: 8),
                    // Requisitos de contraseña
                    _RequirementText(text: 'Entre 8 y 24 caracteres', isMet: _isPasswordLengthValid),
                    _RequirementText(text: 'Al menos una mayúscula', isMet: _hasUppercase),
                    _RequirementText(text: 'Al menos un número', isMet: _hasDigit),
                    const SizedBox(height: 18),
                    // Mensaje de error general
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                      ),
                    // Botón de registro
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading || !_canRegister ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFormValid ? AppColors.appGreen : Colors.grey,
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
                                'Crear cuenta',
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget personalizado para campos de formulario básicos
/// Incluye icono y estilo consistente
class _FormField extends StatelessWidget {
  final IconData icon;
  final String hint;
  final TextEditingController controller;
  const _FormField({required this.icon, required this.hint, required this.controller});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.fieldBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}

/// Widget personalizado para campos de contraseña
/// Incluye toggle de visibilidad
class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool isVisible;
  final ValueChanged<bool> onVisibilityChanged;
  const _PasswordField({required this.controller, required this.hint, required this.isVisible, required this.onVisibilityChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.fieldBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 12.0),
            child: Icon(Icons.lock_outline),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
              ),
              obscureText: !isVisible,
            ),
          ),
          IconButton(
            icon: Icon(isVisible ? Icons.visibility_off : Icons.visibility),
            onPressed: () => onVisibilityChanged(!isVisible),
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}

/// Widget que muestra un requisito de contraseña con estado visual
/// Indica si el requisito se cumple o no
class _RequirementText extends StatelessWidget {
  final String text;
  final bool isMet;
  const _RequirementText({required this.text, required this.isMet});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(isMet ? Icons.check_circle : Icons.cancel, color: isMet ? AppColors.success : AppColors.iconRed, size: 18),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
      ],
    );
  }
} 