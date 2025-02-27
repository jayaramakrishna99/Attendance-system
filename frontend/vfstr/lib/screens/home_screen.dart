import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'welcome_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; 
  final List<Widget> _screens = [
    WelcomeScreen(),
    LoginScreen(),
    RegisterScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex], 
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.login),
            label: 'Mark Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.app_registration),
            label: 'Register/Update',
          ),
        ],
        backgroundColor: Color.fromRGBO(81, 97, 91, 1), 
        selectedItemColor: Color.fromRGBO(245, 241, 230, 1), 
        unselectedItemColor: Colors.grey, 
        selectedLabelStyle: TextStyle(
          color: Color.fromRGBO(245, 241, 230, 1), 
        ),
        unselectedLabelStyle: TextStyle(
          color: Colors.grey, 
        ),
      ),
    );
  }
}
