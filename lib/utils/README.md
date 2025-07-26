# 📁 Carpeta `utils/`

Esta carpeta contiene utilidades y helpers reutilizables para la aplicación EETN.

## 📄 Archivos

### `app_colors.dart`
- **Propósito**: Define la paleta de colores centralizada de la aplicación
- **Contenido**:
  - **Colores principales**: Verde de marca (`appGreen: #93c47d`)
  - **Colores de fondo**: Fondos de campos y contenedores
  - **Colores de estado**: Éxito, error, advertencia
  - **Colores de iconos**: Para diferentes tipos de iconos
  - **Colores utilitarios**: Grises y colores de texto

#### Uso
```dart
// En cualquier widget
Container(
  color: AppColors.appGreen,
  child: Text('Texto', style: TextStyle(color: AppColors.textPrimary)),
)
```

### `route_transitions.dart`
- **Propósito**: Proporciona transiciones personalizadas para navegación
- **Funcionalidades**:
  - `slideFromRightRoute`: Transición deslizante desde la derecha
  - `MenuSlideAnimation`: Animación para menús modales
  - `showMenuModal`: Función para mostrar modales con animación
  - `closeWithAnimation`: Cierre animado de modales

#### Uso
```dart
// Navegación con transición personalizada
Navigator.push(
  context,
  slideFromRightRoute(NextScreen()),
);

// Mostrar menú modal
showMenuModal(
  context,
  MenuWidget(),
);
```

## 🎨 Sistema de Colores

### Paleta Principal
- `appGreen`: #93c47d - Color principal de la marca
- `appGreenLight`: Versión más clara del verde principal
- `appGreenDark`: Versión más oscura del verde principal

### Estados
- `success`: Verde para indicar éxito
- `error`: Rojo para errores
- `warning`: Amarillo para advertencias
- `info`: Azul para información

### Fondos
- `fieldBackground`: Fondo para campos de entrada
- `cardBackground`: Fondo para tarjetas
- `screenBackground`: Fondo principal de pantallas

### Texto
- `textPrimary`: Color principal de texto
- `textSecondary`: Color secundario de texto
- `textMuted`: Color de texto atenuado

## 🎭 Animaciones

### Transiciones de Página
```dart
// Transición deslizante
PageRouteBuilder(
  pageBuilder: (context, animation, secondaryAnimation) => NextScreen(),
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  },
)
```

### Animaciones de Modal
```dart
// Animación de menú
class MenuSlideAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback onClose;
  
  // Implementación con AnimationController
}
```

## 🔧 Configuración

### Importación
```dart
import '../utils/app_colors.dart';
import '../utils/route_transitions.dart';
```

### Uso en MaterialApp
```dart
MaterialApp(
  theme: ThemeData(
    primaryColor: AppColors.appGreen,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.appGreen,
    ),
  ),
  // ...
)
```

## 📱 Consistencia Visual

### Beneficios
- **Consistencia**: Todos los colores están centralizados
- **Mantenibilidad**: Cambios de color en un solo lugar
- **Reutilización**: Animaciones y transiciones reutilizables
- **Escalabilidad**: Fácil agregar nuevos colores o animaciones

### Mejores Prácticas
1. **Siempre usar AppColors**: No usar colores hardcodeados
2. **Transiciones consistentes**: Usar las transiciones definidas
3. **Animaciones suaves**: Mantener consistencia en las animaciones
4. **Accesibilidad**: Considerar contraste de colores

## 🔄 Flujo de Desarrollo

### Agregar Nuevos Colores
1. Definir en `app_colors.dart`
2. Documentar el propósito
3. Usar en los widgets correspondientes

### Agregar Nuevas Animaciones
1. Crear función en `route_transitions.dart`
2. Documentar parámetros y uso
3. Probar en diferentes contextos 