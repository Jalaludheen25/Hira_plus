import 'package:Hira_Plus/providers/auth_provider.dart';
import 'package:Hira_Plus/screens/user_screens/user_home_screen/provider/canteen_home_page_provider.dart';
import 'package:Hira_Plus/providers/date_provider.dart';
import 'package:Hira_Plus/screens/user_screens/user_home_screen/provider/home_view_mode_provider.dart';
import 'package:Hira_Plus/providers/bottom_nav_provider.dart';
import 'package:Hira_Plus/providers/profile_screen_provider.dart';
import 'package:Hira_Plus/providers/users_provider.dart';
import 'package:Hira_Plus/providers/mess_staff_meal_provider.dart';
import 'package:Hira_Plus/providers/version_check_provider.dart';
import 'package:Hira_Plus/screens/user_screens/user_home_screen/provider/meal_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> getProviders() {
  return [
    ChangeNotifierProvider(create: (context) => AuthProvider()),
    ChangeNotifierProvider(create: (context) => DateProvider()),
    ChangeNotifierProvider(
        create: (context) => CanteenHomePageProvider(context)),
    ChangeNotifierProvider(create: (context) => HomeViewModeProvider()),
    ChangeNotifierProvider(create: (context) => BottomNavProvider()),
    ChangeNotifierProvider(create: (context) => ProfileScreenProvider()),
    ChangeNotifierProvider(create: (context) => UsersProvider()),
    ChangeNotifierProvider(create: (context) => MessStaffMealProvider()),
    ChangeNotifierProvider(create: (context) => VersionCheckProvider()),
    ChangeNotifierProvider(create: (context) => MealProvider()),
  ];
}
