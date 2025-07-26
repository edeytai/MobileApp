# EETN - Flutter App

Una aplicación móvil desarrollada en Flutter que proporciona funcionalidades de autenticación, gestión de recetas y perfil de usuario.

## 🚀 Características

- **Autenticación**: Sistema de login y registro con Firebase Auth
- **Onboarding**: Flujo de introducción para nuevos usuarios
- **Gestión de Recetas**: Visualización y gestión de recetas
- **Perfil de Usuario**: Edición y gestión del perfil personal
- **Diseño Moderno**: Interfaz de usuario moderna con Material Design 3
- **Multiplataforma**: Soporte para iOS, Android, Web, macOS, Linux y Windows

## 🛠️ Tecnologías Utilizadas

- **Flutter**: Framework de desarrollo multiplataforma
- **Firebase**: 
  - Firebase Auth para autenticación
  - Cloud Firestore para base de datos
  - Firebase Storage para almacenamiento de archivos
- **Provider**: Gestión de estado
- **Google Sign-In**: Autenticación con Google
- **Shared Preferences**: Almacenamiento local
- **Image Picker**: Selección de imágenes

## 📱 Plataformas Soportadas

- ✅ iOS
- ✅ Android
- ✅ Web
- ✅ macOS
- ✅ Linux
- ✅ Windows

## 🚀 Instalación y Configuración

### Prerrequisitos

- Flutter SDK (versión 3.8.1 o superior)
- Dart SDK
- Android Studio / Xcode (para desarrollo móvil)
- Cuenta de Firebase

### Pasos de Instalación

1. **Clonar el repositorio**
   ```bash
   git clone <url-del-repositorio>
   cd eetn
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Configurar Firebase**
   - Crear un proyecto en [Firebase Console](https://console.firebase.google.com/)
   - Descargar los archivos de configuración:
     - `google-services.json` para Android (colocar en `android/app/`)
     - `GoogleService-Info.plist` para iOS (colocar en `ios/Runner/`)

4. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── models/                   # Modelos de datos
├── services/                 # Servicios (auth, data, etc.)
├── utils/                    # Utilidades (colores, rutas, etc.)
└── views/                    # Pantallas de la aplicación
    ├── login_view.dart
    ├── sign_up_view.dart
    ├── onboarding_view.dart
    ├── home_view.dart
    ├── profile_view.dart
    └── ...
```

## 🎨 Esquema de Colores

La aplicación utiliza un esquema de colores personalizado definido en `lib/utils/app_colors.dart`:

- **App Green**: `#93c47d` - Color principal de la aplicación
- **App Green Splash**: Color de splash personalizado
- **App Green Highlight**: Color de resaltado

## 🔧 Configuración de Desarrollo

### Análisis de Código

El proyecto incluye configuración de linting con `flutter_lints` para mantener la calidad del código:

```bash
flutter analyze
```

### Testing

Para ejecutar las pruebas:

```bash
flutter test
```

## 📦 Build y Deploy

### Android

```bash
flutter build apk --release
```

### iOS

```bash
flutter build ios --release
```

### Web

```bash
flutter build web --release
```

## 🤝 Contribución

1. Fork el proyecto
2. Crear una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 📞 Contacto

Para preguntas o soporte, por favor contacta al equipo de desarrollo.

---

Desarrollado con ❤️ usando Flutter 