import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/onboarding_models.dart';
import '../utils/app_colors.dart';

/// Vista que maneja el proceso de onboarding para nuevos usuarios
/// Permite personalizar la experiencia basándose en preferencias del usuario
class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  int _currentIndex = 0;
  final Map<String, Set<String>> _answers = {};
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Inicializar las respuestas para todas las preguntas
    for (final q in onboardingQuestions) {
      _answers[q.id] = {};
    }
  }

  /// Alterna la selección de una opción para la pregunta actual
  /// Maneja selección múltiple y única según la configuración de la pregunta
  void _toggleOption(String questionId, String option, bool allowMultiple) {
    setState(() {
      final selected = _answers[questionId] ?? <String>{};
      if (allowMultiple) {
        // Para preguntas de selección múltiple, toggle la opción
        if (selected.contains(option)) {
          selected.remove(option);
        } else {
          selected.add(option);
        }
      } else {
        // Para preguntas de selección única, reemplaza la selección
        selected.clear();
        selected.add(option);
      }
      _answers[questionId] = selected;
    });
  }

  /// Verifica si se puede proceder a la siguiente pregunta
  /// Valida que se haya seleccionado al menos una opción
  bool _canProceed() {
    final q = onboardingQuestions[_currentIndex];
    final selected = _answers[q.id] ?? <String>{};
    if (q.allowMultiple) {
      return selected.isNotEmpty;
    } else {
      return selected.length == 1;
    }
  }

  /// Guarda las respuestas en Firestore y finaliza el onboarding
  /// Marca el onboarding como completado y navega a la aplicación principal
  Future<void> _saveAnswersAndFinish() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user logged in');
      
      // Convertir las respuestas a formato compatible con Firestore
      final answersMap = <String, List<String>>{};
      _answers.forEach((key, value) {
        answersMap[key] = value.toList();
      });
      
      // Actualizar el documento del usuario en Firestore
      await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).update({
        'onboardingCompleted': true,
        'onboardingAnswers': answersMap,
      });
      
      if (!mounted) return;
      // No necesitamos navegar manualmente, el _RootFlow en main.dart se encargará
      // de detectar el cambio de estado y navegar correctamente
    } catch (e) {
      setState(() { _errorMessage = e.toString(); });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = onboardingQuestions[_currentIndex];
    final selected = _answers[q.id] ?? <String>{};
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personaliza tu experiencia'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Barra de progreso que muestra el avance en el onboarding
            LinearProgressIndicator(
              value: (_currentIndex + 1) / onboardingQuestions.length,
              backgroundColor: AppColors.fieldBackground,
              color: AppColors.appGreen,
              minHeight: 6,
            ),
            const SizedBox(height: 18),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header de la pregunta con icono, título y subtítulo
                    Row(
                      children: [
                        Text(q.icon, style: const TextStyle(fontSize: 36)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(q.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(q.subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Lista de opciones para la pregunta actual
                    ...q.options.map((opt) => _OptionCard(
                      option: opt,
                      isSelected: selected.contains(opt.text),
                      allowMultiple: q.allowMultiple,
                      onTap: () => _toggleOption(q.id, opt.text, q.allowMultiple),
                    )),
                    const SizedBox(height: 24),
                    // Mensaje de error si existe
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Barra de navegación con botones anterior/siguiente
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
              child: Row(
                children: [
                  // Botón anterior (solo visible si no es la primera pregunta)
                  if (_currentIndex > 0)
                    TextButton(
                      onPressed: _isLoading ? null : () {
                        setState(() { _currentIndex--; });
                      },
                      style: TextButton.styleFrom(foregroundColor: AppColors.appGreen),
                      child: const Text('Anterior'),
                    ),
                  const Spacer(),
                  // Botón siguiente/finalizar
                  ElevatedButton(
                    onPressed: !_canProceed() || _isLoading ? null : () async {
                      if (_currentIndex == onboardingQuestions.length - 1) {
                        // Si es la última pregunta, finalizar el onboarding
                        await _saveAnswersAndFinish();
                      } else {
                        // Si no es la última, ir a la siguiente pregunta
                        setState(() { _currentIndex++; });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _canProceed() ? AppColors.appGreen : Colors.grey,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(_currentIndex == onboardingQuestions.length - 1 ? 'Finalizar' : 'Siguiente',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget que representa una opción individual en el onboarding
/// Muestra el icono, texto y estado de selección
class _OptionCard extends StatelessWidget {
  final OnboardingOptionData option;
  final bool isSelected;
  final bool allowMultiple;
  final VoidCallback onTap;
  const _OptionCard({required this.option, required this.isSelected, required this.allowMultiple, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? option.color.withAlpha(204) : AppColors.fieldBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? option.color : Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            Text(option.icon, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(option.text, style: TextStyle(fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.white : Colors.black)),
            ),
            // Icono de verificación según el tipo de selección
            if (isSelected)
              Icon(allowMultiple ? Icons.check_box : Icons.check_circle, color: Colors.white),
          ],
        ),
      ),
    );
  }
} 