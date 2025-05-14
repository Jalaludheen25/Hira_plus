import 'package:hira_plus/constants/textstyle_class.dart';
import 'package:hira_plus/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:hira_plus/routes/app_routes.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:provider/provider.dart';
import 'package:hira_plus/screens/bottom_nav/provider/bottom_nav_provider.dart';

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
        unselectedItemColor: Color.fromARGB(255, 63, 94, 43),
        unselectedFontSize: 14,
        selectedFontSize: 14,
        selectedLabelStyle: TextStyleClass.poppinsSemiBold(
          fontSize: 14,
        ),
        currentIndex: selectedIndex,
        onTap: (int index) {
          bottomNavProvider.setIndex(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 28),
            activeIcon: Icon(Icons.home, size: 34),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 28),
            activeIcon: Icon(Icons.person, size: 34),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
