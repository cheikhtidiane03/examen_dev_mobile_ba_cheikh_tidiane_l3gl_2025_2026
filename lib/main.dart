import 'package:flutter/material.dart';
import 'package:sunuTask/core/theme/app_theme.dart';
import 'package:sunuTask/screens/splash/splash_screen.dart';
import 'package:sunuTask/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await StorageService.instance.init();

  runApp(const SunuTask());
}

class SunuTask extends StatelessWidget {
  const SunuTask({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: SplashScreen(),
    );
  }
}
