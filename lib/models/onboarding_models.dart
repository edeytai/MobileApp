import 'package:flutter/material.dart';

/// Modelo que representa una opción de respuesta en el proceso de onboarding
/// Contiene el texto, icono y color de cada opción disponible
class OnboardingOptionData {
  final String text;
  final String icon;
  final String colorHex;

  const OnboardingOptionData({
    required this.text,
    required this.icon,
    required this.colorHex,
  });

  /// Convierte el color hexadecimal a un objeto Color de Flutter
  Color get color => _hexToColor(colorHex);

  /// Método auxiliar para convertir strings hexadecimales a objetos Color
  static Color _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

/// Modelo que representa una pregunta del proceso de onboarding
/// Define la estructura de cada pregunta con sus opciones y configuración
class OnboardingQuestionData {
  final String id;
  final String icon;
  final String title;
  final String subtitle;
  final List<OnboardingOptionData> options;
  final bool allowMultiple;

  const OnboardingQuestionData({
    required this.id,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.options,
    required this.allowMultiple,
  });
}

/// Lista completa de preguntas del proceso de onboarding
/// Cada pregunta está diseñada para personalizar las recomendaciones de recetas
const List<OnboardingQuestionData> onboardingQuestions = [
  // Pregunta sobre experiencia culinaria
  OnboardingQuestionData(
    id: 'cooking_experience',
    icon: '👨‍🍳',
    title: '¿Cuál es tu experiencia en la cocina?',
    subtitle: 'Esto nos ayudará a sugerir recetas del nivel adecuado para ti',
    options: [
      OnboardingOptionData(text: 'Principiante - Apenas estoy aprendiendo', icon: '🌱', colorHex: '#4CAF50'),
      OnboardingOptionData(text: 'Intermedio - Puedo seguir recetas básicas', icon: '📚', colorHex: '#2196F3'),
      OnboardingOptionData(text: 'Avanzado - Me siento cómodo experimentando', icon: '🚀', colorHex: '#FF9800'),
      OnboardingOptionData(text: 'Experto - Puedo crear mis propias recetas', icon: '👑', colorHex: '#9C27B0'),
    ],
    allowMultiple: false,
  ),
  // Pregunta sobre tiempo disponible para cocinar
  OnboardingQuestionData(
    id: 'cooking_time',
    icon: '⏰',
    title: '¿Cuánto tiempo sueles tener para cocinar?',
    subtitle: 'Para recomendarte recetas que se ajusten perfectamente a tu rutina diaria',
    options: [
      OnboardingOptionData(text: '15 minutos o menos', icon: '⚡', colorHex: '#F44336'),
      OnboardingOptionData(text: '15-30 minutos', icon: '⏱️', colorHex: '#FF9800'),
      OnboardingOptionData(text: '30-60 minutos', icon: '🕐', colorHex: '#2196F3'),
      OnboardingOptionData(text: 'Más de 1 hora', icon: '🕙', colorHex: '#9C27B0'),
    ],
    allowMultiple: false,
  ),
  // Pregunta sobre presupuesto disponible
  OnboardingQuestionData(
    id: 'budget_preference',
    icon: '💰',
    title: '¿Estás dispuesto a gastar en ingredientes adicionales?',
    subtitle: 'Para sugerirte recetas que se ajusten a tu situación',
    options: [
      OnboardingOptionData(text: 'Quiero trabajar solo con lo que tengo en casa', icon: '🏠', colorHex: '#4CAF50'),
      OnboardingOptionData(text: 'Puedo gastar hasta \$50 en ingredientes', icon: '💵', colorHex: '#2196F3'),
      OnboardingOptionData(text: 'Puedo gastar hasta \$100 en ingredientes', icon: '💳', colorHex: '#FF9800'),
      OnboardingOptionData(text: 'Puedo gastar más de \$100 en ingredientes', icon: '💎', colorHex: '#9C27B0'),
    ],
    allowMultiple: false,
  ),
  // Pregunta sobre restricciones alimentarias
  OnboardingQuestionData(
    id: 'dietary_restrictions',
    icon: '🥗',
    title: '¿Tienes alguna restricción alimentaria?',
    subtitle: 'Selecciona todas las que apliquen para recomendarte recetas perfectas',
    options: [
      OnboardingOptionData(text: 'Ninguna', icon: '✅', colorHex: '#4CAF50'),
      OnboardingOptionData(text: 'Vegetariano', icon: '🥬', colorHex: '#4CAF50'),
      OnboardingOptionData(text: 'Vegano', icon: '🌱', colorHex: '#4CAF50'),
      OnboardingOptionData(text: 'Sin gluten', icon: '🌾', colorHex: '#FF9800'),
      OnboardingOptionData(text: 'Sin lactosa', icon: '🥛', colorHex: '#2196F3'),
      OnboardingOptionData(text: 'Bajo en carbohidratos', icon: '🍞', colorHex: '#F44336'),
      OnboardingOptionData(text: 'Bajo en sodio', icon: '🧂', colorHex: '#9C27B0'),
    ],
    allowMultiple: true,
  ),
  // Pregunta sobre objetivos de salud
  OnboardingQuestionData(
    id: 'health_goals',
    icon: '💪',
    title: '¿Tienes algún objetivo de salud específico?',
    subtitle: 'Para sugerirte recetas que se alineen con tus metas',
    options: [
      OnboardingOptionData(text: 'No tengo objetivos específicos', icon: '😊', colorHex: '#9E9E9E'),
      OnboardingOptionData(text: 'Quiero comer más saludable', icon: '🥗', colorHex: '#4CAF50'),
      OnboardingOptionData(text: 'Quiero perder peso', icon: '⚖️', colorHex: '#2196F3'),
      OnboardingOptionData(text: 'Quiero ganar músculo', icon: '💪', colorHex: '#FF9800'),
      OnboardingOptionData(text: 'Tengo una condición médica', icon: '🩺', colorHex: '#F44336'),
    ],
    allowMultiple: false,
  ),
]; 