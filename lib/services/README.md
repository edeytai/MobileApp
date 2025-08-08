# 📁 Carpeta `services/`

Esta carpeta contiene todos los servicios y la lógica de negocio de la aplicación EETN.

## 📄 Archivos

### `auth_service.dart`
- **Propósito**: Maneja toda la autenticación de usuarios
- **Funcionalidades**:
  - Registro de usuarios con email/password
  - Login con email/password
  - Autenticación con Google
  - Verificación de disponibilidad de email y username
  - Restablecimiento de contraseñas
  - Cierre de sesión
- **Integración**: Firebase Auth + Firestore para perfiles de usuario

### `data_service.dart`
- **Propósito**: Centraliza el acceso a datos de la aplicación
- **Funcionalidades**:
  - Proporciona datos de ingredientes predefinidos
  - Gestiona recetas de ejemplo
  - Búsqueda de recetas por categoría
  - Búsqueda de ingredientes
  - Generación de UUIDs consistentes
- **Datos**: Contiene listas de ingredientes y recetas de ejemplo

### `favorite_recipes_manager.dart`
- **Propósito**: Gestiona las recetas favoritas del usuario
- **Funcionalidades**:
  - Agregar/quitar recetas de favoritos
  - Sincronización con Firestore
  - Notificación de cambios de estado
  - Verificación de estado de favorito
- **Patrón**: Utiliza `ChangeNotifier` para notificar cambios a la UI

### `ia_recipe_service.dart`
- **Propósito**: Servicio placeholder para futuras funcionalidades de IA
- **Estado**: Actualmente es un placeholder para generación de recetas con IA
- **Funcionalidades**: Preparado para integración con servicios de IA

### `nutrition_service.dart`
- **Propósito**: Gestiona el seguimiento nutricional de los usuarios
- **Funcionalidades**:
  - Obtención y actualización de datos nutricionales diarios
  - Almacenamiento en Firestore
  - Historial nutricional
  - Registro de consumo de agua
- **Integración**: Firestore para almacenamiento de datos nutricionales

## 🏗️ Arquitectura de Servicios

### Patrón Singleton
Los servicios utilizan el patrón singleton para garantizar una única instancia:
```dart
class AuthService {
  static final AuthService instance = AuthService._internal();
  AuthService._internal();
}
```

### Gestión de Estado
- **Provider**: Utilizado para `FavoriteRecipesManager`
- **ChangeNotifier**: Para notificar cambios de estado
- **FutureBuilder**: Para operaciones asíncronas

### Integración con Firebase

#### Firestore Collections
- `usuarios`: Perfiles de usuarios
- `favoritos`: Recetas favoritas por usuario
- `recetas`: Catálogo de recetas (futuro)
- `nutricion_usuarios`: Datos nutricionales diarios de usuarios

#### Firebase Auth
- Autenticación con email/password
- Autenticación con Google
- Gestión de sesiones

## 🔄 Flujo de Datos

### Autenticación
1. Usuario se registra/login → `AuthService`
2. Creación/verificación de perfil → Firestore
3. Navegación a onboarding o app principal

### Favoritos
1. Usuario marca favorito → `FavoriteRecipesManager`
2. Actualización en Firestore
3. Notificación a UI para actualizar estado

### Datos
1. Vistas solicitan datos → `DataService`
2. Procesamiento de datos
3. Retorno de modelos estructurados

## 📱 Uso en Vistas

### AuthService
```dart
// Login
await AuthService.instance.login(email, password);

// Registro
await AuthService.instance.register(email, password, userData);

// Verificar email
bool taken = await AuthService.instance.isEmailTaken(email);
```

### DataService
```dart
// Obtener todas las recetas
List<Receta> recipes = DataService.instance.getAllRecipes();

// Buscar recetas
List<Receta> results = DataService.instance.searchRecipes(query);
```

### FavoriteRecipesManager
```dart
// Agregar a favoritos
await FavoriteRecipesManager.instance.addToFavorites(recipeId);

// Verificar si es favorito
bool isFavorite = await FavoriteRecipesManager.instance.isFavorite(recipeId);
```

### NutritionService
```dart
// Obtener datos nutricionales del día
UserNutrition? nutrition = await NutritionService.instance.getUserDailyNutrition();

// Registrar consumo de agua
await NutritionService.instance.logWaterConsumption(250.0); // 250ml

// Obtener historial nutricional
List<UserNutrition> history = await NutritionService.instance.getNutritionHistory();
```

## 🔧 Configuración

### Firebase
- Configuración en `main.dart`
- Archivos de configuración en `android/` e `ios/`
- Reglas de seguridad en Firestore

### Dependencias
- `firebase_auth`: Autenticación
- `cloud_firestore`: Base de datos
- `provider`: Gestión de estado
- `google_sign_in`: Autenticación con Google 