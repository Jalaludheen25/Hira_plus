import 'package:flutter/material.dart';
import 'package:canteen_app/routes/app_routes.dart';
import 'package:canteen_app/routes/app_pages.dart';

class BottomNavigationBarScreen extends StatefulWidget {
  const BottomNavigationBarScreen({super.key});

  @override
  State<BottomNavigationBarScreen> createState() =>
      _BottomNavigationBarScreenState();
}

class _BottomNavigationBarScreenState extends State<BottomNavigationBarScreen> {
  int _selectedIndex = 0; // Track selected tab

  // List of page route names for bottom navigation
  final List<String> _pageRoutes = [
    Routes.home,
    Routes.profile,
  ];

  // Build a nested Navigator using the app routes
  Widget _buildNavigator() {
    final routes = getRoutes();
    final routeName = _pageRoutes[_selectedIndex];
    final builder = routes[routeName]!;
    return Navigator(
      key: ValueKey(_selectedIndex), // forces rebuild when index changes
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          builder: builder,
          settings: settings,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildNavigator(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
