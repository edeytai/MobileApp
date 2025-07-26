# 📁 Carpeta `models/`

Esta carpeta contiene todos los modelos de datos y estructuras utilizadas en la aplicación EETN.

## 📄 Archivos

### `models.dart`
- **Propósito**: Contiene los modelos principales de la aplicación
- **Contenido**:
  - **Enums**: `CategoriaIngrediente`, `Dificultad`, `CategoriaReceta`
  - **Clases de datos**:
    - `InformacionNutricional`: Información nutricional de recetas
    - `Ingrediente`: Modelo de ingrediente individual
    - `IngredienteReceta`: Ingrediente con cantidad para una receta
    - `Receta`: Modelo principal de receta con todos sus datos
    - `SugerenciaReceta`: Sugerencias de recetas
    - `FiltrosBusqueda`: Filtros para búsqueda de recetas
  - **Modelos de base de datos**:
    - `DatabaseRecipe`: Estructura para almacenar recetas en Firestore
    - `DatabaseFavorite`: Estructura para favoritos
    - `DatabaseIngredient`: Estructura para ingredientes
    - `DatabaseRecipeIngredient`: Relación receta-ingrediente
    - `DatabaseRecipeStep`: Pasos de una receta

### `onboarding_models.dart`
- **Propósito**: Modelos específicos para el proceso de onboarding
- **Contenido**:
  - `OnboardingOptionData`: Opciones de respuesta para preguntas de onboarding
  - `OnboardingQuestionData`: Preguntas del proceso de onboarding
  - `onboardingQuestions`: Lista completa de preguntas de onboarding

## 🏗️ Estructura de Datos

### Modelos Principales

#### `Receta`
```dart
class Receta {
  final String id;
  final String nombre;
  final String descripcion;
  final List<IngredienteReceta> ingredientes;
  final List<String> pasos;
  final InformacionNutricional informacionNutricional;
  final Dificultad dificultad;
  final CategoriaReceta categoria;
  final int tiempoPreparacion;
  final double costoEstimado;
  final String imagenURL;
}
```

#### `Ingrediente`
```dart
class Ingrediente {
  final String id;
  final String nombre;
  final CategoriaIngrediente categoria;
  final String descripcion;
  final String imagenURL;
}
```

#### `InformacionNutricional`
```dart
class InformacionNutricional {
  final double calorias;
  final double proteinas;
  final double carbohidratos;
  final double grasas;
  final double fibra;
  final double sodio;
}
```

## 🔄 Relaciones

- **Receta** ↔ **IngredienteReceta** ↔ **Ingrediente**: Una receta tiene múltiples ingredientes con cantidades específicas
- **Receta** ↔ **InformacionNutricional**: Cada receta tiene información nutricional
- **Usuario** ↔ **Favoritos**: Los usuarios pueden marcar recetas como favoritas

## 📊 Uso en la Aplicación

- **Vistas**: Los modelos se utilizan para mostrar datos en las pantallas
- **Servicios**: Los servicios utilizan estos modelos para operaciones de datos
- **Firestore**: Los modelos se serializan/deserializan para almacenamiento en la base de datos
- **Búsqueda**: Los filtros utilizan estos modelos para búsquedas avanzadas 