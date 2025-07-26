# 📁 Carpeta `views/`

Esta carpeta contiene todas las pantallas y widgets de la interfaz de usuario de la aplicación EETN.

## 📄 Archivos

### 🔐 Autenticación

#### `login_view.dart`
- **Propósito**: Pantalla de inicio de sesión
- **Funcionalidades**:
  - Login con email/password
  - Autenticación con Google
  - Navegación a registro y restablecimiento de contraseña
  - Validación de campos en tiempo real
- **Características**: Diseño moderno con validación y manejo de errores

#### `sign_up_view.dart`
- **Propósito**: Pantalla de registro de nuevos usuarios
- **Funcionalidades**:
  - Registro completo con validación en tiempo real
  - Verificación de disponibilidad de email y username
  - Validación de contraseña con requisitos visuales
  - Selección de fecha de nacimiento y género
- **Características**: Formulario extenso con validación robusta

#### `password_reset_view.dart`
- **Propósito**: Restablecimiento de contraseña
- **Funcionalidades**:
  - Envío de email de restablecimiento
  - Validación de formato de email
  - Diálogo de confirmación
- **Características**: Interfaz simple y directa

#### `complete_registration_view.dart`
- **Propósito**: Completar registro para usuarios de Google
- **Funcionalidades**:
  - Completar perfil después de autenticación con Google
  - Validación de username en tiempo real
  - Opción de cancelar y eliminar cuenta
- **Características**: Formulario específico para usuarios de Google

### 🎯 Onboarding

#### `onboarding_view.dart`
- **Propósito**: Proceso de personalización inicial
- **Funcionalidades**:
  - Preguntas de preferencias culinarias
  - Selección múltiple y única
  - Barra de progreso
  - Guardado en Firestore
- **Características**: Interfaz interactiva con animaciones

### 🏠 Navegación Principal

#### `main_tab_view.dart`
- **Propósito**: Navegación principal con tabs
- **Funcionalidades**:
  - Bottom navigation bar
  - Tabs para diferentes secciones
  - Placeholders para funcionalidades futuras
- **Características**: Estructura base de navegación

#### `home_view.dart`
- **Propósito**: Dashboard principal de la aplicación
- **Funcionalidades**:
  - Resumen nutricional
  - Comidas planeadas
  - Recetas favoritas
  - Comidas recientes
  - Navegación a listas completas
- **Características**: Vista principal con múltiples secciones

### 🍳 Recetas

#### `recipe_detail_view.dart`
- **Propósito**: Vista detallada de una receta
- **Funcionalidades**:
  - Información completa de la receta
  - Lista de ingredientes con cantidades
  - Pasos de preparación
  - Información nutricional
  - Toggle de favoritos
- **Características**: Vista rica en información con navegación

#### `recipe_list_full_screen_view.dart`
- **Propósito**: Lista completa de recetas en pantalla completa
- **Funcionalidades**:
  - Lista de recetas con búsqueda
  - Filtros (placeholder)
  - Estado vacío personalizable
  - Navegación a detalles
- **Características**: Vista reutilizable para diferentes listas

### 👤 Perfil de Usuario

#### `profile_view.dart`
- **Propósito**: Vista del perfil del usuario
- **Funcionalidades**:
  - Mostrar información del usuario
  - Cambio de foto de perfil
  - Navegación al menú
  - Pull to refresh
- **Características**: Vista de perfil con gestión de imagen

#### `profile_edit_view.dart`
- **Propósito**: Edición del perfil del usuario
- **Funcionalidades**:
  - Edición de nombre, username y biografía
  - Validación de username en tiempo real
  - Cambio de foto de perfil
  - Guardado en Firestore
- **Características**: Formulario de edición con validaciones

#### `menu_view.dart`
- **Propósito**: Menú lateral con opciones del perfil
- **Funcionalidades**:
  - Opciones de configuración (placeholders)
  - Navegación a edición de perfil
  - Cerrar sesión
  - Animación de modal
- **Características**: Menú modal con animaciones

## 🏗️ Arquitectura de Vistas

### Patrones Utilizados

#### StatefulWidget
- Para vistas que necesitan estado local
- Gestión de formularios y validaciones
- Animaciones y timers

#### StatelessWidget
- Para vistas simples sin estado
- Widgets reutilizables
- Componentes de UI

#### Provider
- Para gestión de estado global
- Sincronización de favoritos
- Estado de autenticación

### Navegación

#### Rutas Nombradas
```dart
// Definición en main.dart
'/login': (context) => const LoginView(),
'/signup': (context) => const SignUpView(),
```

#### Navegación Programática
```dart
// Navegación con transiciones personalizadas
Navigator.push(
  context,
  slideFromRightRoute(NextScreen()),
);
```

### Validaciones

#### Tiempo Real
- Validación de email y username
- Verificación de disponibilidad
- Debounce para optimización

#### Formularios
- Validación de campos requeridos
- Formato de datos
- Confirmación de contraseñas

## 🎨 Diseño y UX

### Consistencia Visual
- Uso de `AppColors` en todas las vistas
- Transiciones consistentes
- Espaciado y tipografía uniformes

### Responsividad
- Adaptación a diferentes tamaños de pantalla
- Manejo de teclado en formularios
- Scroll en contenido extenso

### Accesibilidad
- Contraste de colores adecuado
- Tamaños de texto legibles
- Navegación por teclado

## 🔄 Flujo de Usuario

### Nuevo Usuario
1. `login_view.dart` → Login o registro
2. `sign_up_view.dart` → Registro completo
3. `onboarding_view.dart` → Personalización
4. `main_tab_view.dart` → Aplicación principal

### Usuario Existente
1. `login_view.dart` → Login
2. `main_tab_view.dart` → Aplicación principal
3. `home_view.dart` → Dashboard

### Navegación en App
1. `main_tab_view.dart` → Navegación principal
2. `home_view.dart` → Dashboard
3. `recipe_list_full_screen_view.dart` → Listas de recetas
4. `recipe_detail_view.dart` → Detalles de receta
5. `profile_view.dart` → Perfil del usuario

## 📱 Características Especiales

### Gestos
- Swipe para navegar hacia atrás
- Pull to refresh en listas
- Tap para interacciones

### Animaciones
- Transiciones de página
- Animaciones de modal
- Indicadores de carga

### Estados
- Loading states
- Error states
- Empty states
- Success states

## 🔧 Configuración

### Dependencias
- `flutter/material.dart`: UI básica
- `provider`: Gestión de estado
- `firebase_auth`: Autenticación
- `cloud_firestore`: Base de datos
- `image_picker`: Selección de imágenes

### Importaciones
```dart
import '../models/models.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import '../utils/route_transitions.dart';
``` 