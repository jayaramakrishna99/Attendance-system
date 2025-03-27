import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'welcome_screen.dart';

class HomeScreen extends StatefulWidget {
  final String facultyId; // Add facultyId

  const HomeScreen({Key? key, required this.facultyId}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; 
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      WelcomeScreen(facultyId: widget.facultyId), // Pass facultyId
      LoginScreen(),
      RegisterScreen(),
    ];
  }
  // final List<Widget> _screens = [
  //   WelcomeScreen(),
  //   LoginScreen(),
  //   RegisterScreen(),
  // ];
  
  static get employeeId => null;

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
