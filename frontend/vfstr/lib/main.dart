import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() async{
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
        primaryColor: const Color.fromRGBO(81, 97, 91, 1), 
        scaffoldBackgroundColor: const Color.fromRGBO(245, 241, 230, 1),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromRGBO(81, 97, 91, 1),
          titleTextStyle: TextStyle(
            color: Color.fromRGBO(245, 241, 230, 1),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(
            color: Color.fromRGBO(245, 241, 230, 1), 
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color.fromRGBO(81, 97, 91, 1), 
          size: 50,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: const Color.fromRGBO(245, 241, 230, 1), backgroundColor: const Color.fromRGBO(81, 97, 91, 1), 
            textStyle: const TextStyle(fontSize: 18),
          ),
        ),
      ),
      home: SplashScreen(),
    );
  }
}
