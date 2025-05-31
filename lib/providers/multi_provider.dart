import 'package:hira_plus/screens/login_screen/provider/auth_provider.dart';
import 'package:hira_plus/screens/manager_screen/provider/meeting_provider.dart';
import 'package:hira_plus/screens/mess_staff_screen/provider/mess_bulk_meal_provider.dart';
import 'package:hira_plus/screens/reception_screen/provider/reception_provider.dart';
import 'package:hira_plus/screens/user_screens/booking_screen/provider/bulk_food_provider.dart';
import 'package:hira_plus/screens/user_screens/booking_screen/provider/user_meeting_provider.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/provider/canteen_home_page_provider.dart';
import 'package:hira_plus/providers/date_provider.dart';
import 'package:hira_plus/screens/bottom_nav/provider/bottom_nav_provider.dart';
import 'package:hira_plus/screens/profile_screen/provider/profile_screen_provider.dart';
import 'package:hira_plus/screens/manager_screen/provider/users_provider.dart';
import 'package:hira_plus/screens/mess_staff_screen/provider/mess_staff_meal_provider.dart';
import 'package:hira_plus/screens/forced_update_screen/provider/version_check_provider.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/provider/user_meeting_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> getProviders() {
  return [
    ChangeNotifierProvider(create: (context) => AuthProvider()),
    ChangeNotifierProvider(create: (context) => DateProvider()),
    ChangeNotifierProvider(create: (context) => CanteenHomeProvider(context)),
    ChangeNotifierProvider(create: (context) => BottomNavProvider()),
    ChangeNotifierProvider(create: (context) => ProfileScreenProvider()),
    ChangeNotifierProvider(create: (context) => UsersProvider()),
    ChangeNotifierProvider(create: (context) => MessStaffMealProvider()),
    ChangeNotifierProvider(create: (context) => VersionCheckProvider()),
    ChangeNotifierProvider(create: (context) => BulkFoodProvider()),
    ChangeNotifierProvider(create: (context) => MessBulkMealProvider()),
    ChangeNotifierProvider(create: (context) => ReceptionProvider()),
    ChangeNotifierProvider(create: (context) => MeetingProvider()),
    ChangeNotifierProvider(create: (context) => UserMeetingProvider()),
    ChangeNotifierProvider(create: (context) => MeetingListProvider()),
  ];
}