# 📁 Carpeta `lib/`

Esta es la carpeta principal del proyecto Flutter que contiene todo el código Dart de la aplicación EETN.

## 📂 Estructura de Carpetas

### `main.dart`
- **Propósito**: Punto de entrada principal de la aplicación
- **Funcionalidad**: Inicializa Firebase, configura el tema de la app y maneja el flujo de navegación inicial basado en el estado de autenticación y onboarding del usuario

### `models/`
- Contiene todos los modelos de datos y estructuras utilizadas en la aplicación
- Define las clases para ingredientes, recetas, información nutricional, etc.

### `services/`
- Contiene la lógica de negocio y servicios de la aplicación
- Maneja autenticación, datos, gestión de favoritos y servicios de IA

### `utils/`
- Contiene utilidades y helpers reutilizables
- Incluye colores de la app, transiciones de rutas y otras utilidades

### `views/`
- Contiene todas las pantallas y widgets de la interfaz de usuario
- Organiza las vistas por funcionalidad (autenticación, perfil, recetas, etc.)

## 🏗️ Arquitectura del Proyecto

La aplicación sigue una arquitectura modular donde:

- **Models**: Definen la estructura de datos
- **Services**: Contienen la lógica de negocio y comunicación con APIs
- **Views**: Manejan la presentación e interacción del usuario
- **Utils**: Proporcionan utilidades compartidas

## 🔧 Tecnologías Principales

- **Flutter**: Framework de UI
- **Firebase**: Autenticación y base de datos
- **Provider**: Gestión de estado
- **Cloud Firestore**: Base de datos en tiempo real
- **Firebase Storage**: Almacenamiento de archivos

## 📱 Funcionalidades Principales

1. **Autenticación**: Login, registro, Google Sign-In
2. **Onboarding**: Personalización inicial del usuario
3. **Gestión de Recetas**: Ver, buscar, favoritos
4. **Perfil de Usuario**: Edición y gestión de datos personales
5. **Navegación**: Sistema de tabs y navegación entre pantallas 