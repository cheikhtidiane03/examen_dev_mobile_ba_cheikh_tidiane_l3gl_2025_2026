// lib/main.dart

import 'package:flutter/material.dart';
import 'providers/app_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/project_provider.dart';
import 'providers/task_provider.dart';
import 'services/storage_service.dart';
import 'screens/splash/splash_screen.dart';

void main() async {
  // Obligatoire avant tout appel asynchrone dans main()
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser SharedPreferences UNE SEULE FOIS au démarrage
  await StorageService.instance.init();

  runApp(const SunuTaskApp());
}

class SunuTaskApp extends StatefulWidget {
  const SunuTaskApp({super.key});

  @override
  State<SunuTaskApp> createState() => _SunuTaskAppState();
}

class _SunuTaskAppState extends State<SunuTaskApp> {
  // Créer les providers UNE SEULE FOIS
  final AppProvider _appProvider = AppProvider();
  final AuthProvider _authProvider = AuthProvider();
  final ProjectProvider _projectProvider = ProjectProvider();
  final TaskProvider _taskProvider = TaskProvider();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SunuTask',
      debugShowCheckedModeBanner: false,
      // Passer les providers au SplashScreen qui gérera la navigation
      home: SplashScreen(
        appProvider: _appProvider,
        authProvider: _authProvider,
        projectProvider: _projectProvider,
        taskProvider: _taskProvider,
      ),
    );
  }
}