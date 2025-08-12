import 'package:hira_plus/routes/app_routes.dart';
import 'package:hira_plus/screens/bottom_nav/view/bottom_navigation_bar.dart';
import 'package:hira_plus/screens/login_screen/view/login_screen.dart';
import 'package:hira_plus/screens/profile_screen/view/profile_screen.dart';
import 'package:hira_plus/screens/splash_screen/splash_screen.dart';
import 'package:hira_plus/screens/user_screens/booking_screen/view/booking_screen.dart';
import 'package:hira_plus/screens/user_screens/booking_screen/view/bulk_food_booking_screen.dart';
import 'package:hira_plus/screens/user_screens/contact_us/contact_us_screen.dart';
import 'package:hira_plus/screens/mess_staff_screen/view/mess_staff_screen.dart';
import 'package:hira_plus/screens/manager_screen/views/dashboard/manager_screen.dart';
import 'package:hira_plus/screens/manager_screen/views/user/marking_list_screen.dart';
import 'package:hira_plus/screens/manager_screen/views/user/users_list_screen.dart';
import 'package:hira_plus/screens/forced_update_screen/view/force_update_screen.dart';
import 'package:flutter/material.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/view/user_home_screen.dart';
import 'package:hira_plus/screens/manager_screen/views/shared/messages_screen.dart';
import 'package:hira_plus/screens/user_screens/notifications/view/user_notifications_screen.dart';
import 'package:hira_plus/screens/reception_screen/view/reception_screen.dart';
import 'package:hira_plus/screens/manager_screen/views/transportation/transportation_screen.dart';
import 'package:hira_plus/screens/manager_screen/views/user/add_user_screen.dart';
import 'package:hira_plus/screens/manager_screen/provider/transportation_provider.dart';
import 'package:provider/provider.dart';

Map<String, WidgetBuilder> getRoutes() {
  return {
    Routes.splash: (context) => const SplashScreen(),
    Routes.login: (context) => const LoginScreen(),
    Routes.bottomNav: (context) => const BottomNavigationBarScreen(),
    Routes.profile: (context) => ProfileScreen(),
    Routes.home: (context) => const UserHomeScreen(),
    Routes.contactUs: (context) => const ContactUsScreen(),
    Routes.messStaff: (context) => const MessStaffScreen(),
    Routes.manager: (context) => const ManagerScreen(),
    Routes.markingList: (context) => MarkingListScreen(),
    Routes.usersList: (context) => UsersListScreen(),
    Routes.forceUpdate: (context) => const ForceUpdatePage(),
    Routes.messages: (context) => const ManagerMessagesScreen(),
    Routes.notifications: (context) => const UserNotificationsScreen(),
    Routes.bookings: (context) => const BookingScreen(),
    Routes.bulkFoodBooking: (context) => const BulkFoodBookingScreen(),
    Routes.reception: (context) => const ReceptionScreen(),
    Routes.transportation: (context) => ChangeNotifierProvider(
          create: (_) => TransportationProvider(),
          child: const TransportationScreen(),
        ),
    Routes.addUser: (context) => ChangeNotifierProvider(
          create: (_) => TransportationProvider(),
          child: const AddUserScreen(),
        ),
  };
}
