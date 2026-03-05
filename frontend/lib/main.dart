import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HerLunaApp());
}

class HerLunaApp extends StatelessWidget {
  const HerLunaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HerLuna AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F6F2),
      ),
      home: const SplashScreen(),
    );
  }
}
