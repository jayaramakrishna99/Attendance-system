import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attendance Recognition',
      theme: ThemeData(
        primaryColor: const Color.fromRGBO(81, 97, 91, 1), // Dark Green
        scaffoldBackgroundColor: const Color.fromRGBO(245, 241, 230, 1), // Cream Background
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromRGBO(81, 97, 91, 1), // Dark Green AppBar
          titleTextStyle: TextStyle(
            color: Color.fromRGBO(245, 241, 230, 1), // Cream text
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(
            color: Color.fromRGBO(245, 241, 230, 1), // Cream icons in AppBar
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color.fromRGBO(81, 97, 91, 1), // Dark Green for icons
          size: 50,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: const Color.fromRGBO(245, 241, 230, 1), backgroundColor: const Color.fromRGBO(81, 97, 91, 1), // Cream Text
            textStyle: const TextStyle(fontSize: 18),
          ),
        ),
      ),
      home: SplashScreen(),
    );
  }
}
