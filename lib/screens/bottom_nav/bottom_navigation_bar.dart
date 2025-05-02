import 'package:flutter/material.dart';
import 'package:canteen_app/routes/app_routes.dart';
import 'package:canteen_app/routes/app_pages.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:canteen_app/constants/color_class.dart';
import 'package:provider/provider.dart';
import 'package:canteen_app/providers/bottom_nav_provider.dart';

class BottomNavigationBarScreen extends StatelessWidget {
  const BottomNavigationBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomNavProvider = Provider.of<BottomNavProvider>(context);
    final int selectedIndex = bottomNavProvider.selectedIndex;
    final List<String> pageRoutes = [
      Routes.home,
      Routes.profile,
    ];
    final routes = getRoutes();
    final routeName = pageRoutes[selectedIndex];
    final builder = routes[routeName]!;
    return Scaffold(
      body: Navigator(
        key: ValueKey(selectedIndex),
        onGenerateRoute: (RouteSettings settings) {
          return MaterialPageRoute(
            builder: builder,
            settings: settings,
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: ColorClass.brandWhite,
        selectedItemColor: ColorClass.brandDarkGreen,
        unselectedItemColor: ColorClass.brandLightGreen,
        currentIndex: selectedIndex,
        onTap: (int index) {
          bottomNavProvider.setIndex(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 34),
            activeIcon: Icon(Icons.home, size: 34),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 34),
            activeIcon: Icon(Icons.person, size: 34),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
