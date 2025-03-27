import 'package:flutter/material.dart';
import 'package:canteen_app/routes/app_routes.dart';
import 'package:canteen_app/routes/app_pages.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:canteen_app/constants/color_class.dart';
import 'package:canteen_app/constants/ui_styles.dart';

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
        backgroundColor: ColorClass.white,
        selectedItemColor: ColorClass.primaryBase,
        unselectedItemColor: ColorClass.neutral400,
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.user),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
