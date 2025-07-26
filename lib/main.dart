import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'views/login_view.dart';
import 'views/onboarding_view.dart';
import 'views/main_tab_view.dart';
import 'utils/app_colors.dart';

/// Punto de entrada principal de la aplicación EETN
/// Inicializa Firebase y ejecuta la aplicación
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const EETNApp());
}

/// Widget principal de la aplicación que configura el tema y las rutas
/// Define el esquema de colores basado en AppColors y configura Material 3
class EETNApp extends StatelessWidget {
  const EETNApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EETN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.appGreen),
        useMaterial3: true,
        splashColor: AppColors.appGreenSplash,
        highlightColor: AppColors.appGreenHighlight,
      ),
      home: const _RootFlow(),
      routes: {
        '/login': (context) => const LoginView(),
      },
    );
  }
}

/// Widget que maneja el flujo de navegación principal de la aplicación
/// Determina qué pantalla mostrar basándose en el estado de autenticación y onboarding
class _RootFlow extends StatefulWidget {
  const _RootFlow();
  @override
  State<_RootFlow> createState() => _RootFlowState();
}

class _RootFlowState extends State<_RootFlow> {
  User? _user;
  bool _loading = true;
  bool? _onboardingCompleted;

  @override
  void initState() {
    super.initState();
    // Escucha cambios en el estado de autenticación de Firebase
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      setState(() { _user = user; _loading = true; });
      if (user == null) {
        // Si no hay usuario autenticado, mostrar pantalla de login
        setState(() { _onboardingCompleted = null; _loading = false; });
      } else {
        try {
          // Verificar si el usuario existe en Firestore
          final doc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
          if (!doc.exists) {
            // Si el usuario no existe en Firestore, cerrar sesión
            await FirebaseAuth.instance.signOut();
            setState(() { 
              _user = null; 
              _onboardingCompleted = null; 
              _loading = false; 
            });
          } else {
            // Verificar si el onboarding está completado
            setState(() {
              _onboardingCompleted = doc.data()?['onboardingCompleted'] == true;
              _loading = false;
            });
          }
        } catch (e) {
          // En caso de error, cerrar sesión
          await FirebaseAuth.instance.signOut();
          setState(() { 
            _user = null; 
            _onboardingCompleted = null; 
            _loading = false; 
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar loading mientras se verifica el estado
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // Si no hay usuario, mostrar pantalla de login
    if (_user == null) {
      return const LoginView();
    }
    // Si el onboarding no está completado, mostrar pantalla de onboarding
    if (_onboardingCompleted == false) {
      return const OnboardingView();
    }
    // Si todo está bien, mostrar la aplicación principal
    return const MainTabView();
  }
}
