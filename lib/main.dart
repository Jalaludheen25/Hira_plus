import 'package:flutter/services.dart';
import 'package:hira_plus/providers/multi_provider.dart';
import 'package:hira_plus/routes/app_pages.dart';
import 'package:hira_plus/routes/app_routes.dart';
import 'package:hira_plus/services/push_notifications.dart';
import 'package:hira_plus/utils/navigation_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shake_flutter/shake_flutter.dart';
import 'dart:io';
import 'package:hira_plus/constants/global_variables.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Shake.start(
      Platform.isAndroid
          ? GlobalVariables.androidShakeKey
          : GlobalVariables.iosShakeKey,
    );
    debugPrint('📱 Shake detection initialized');
  } catch (e, stackTrace) {
    debugPrint('⚠️ Failed to initialize shake detection: $e');
    debugPrint('StackTrace: $stackTrace');
  }

  try {
    await PushNotificationService.initializeOneSignal(
        GlobalVariables.oneSignalKey);
    debugPrint('📱 OneSignal initialized');
  } catch (e, stackTrace) {
    debugPrint('⚠️ Failed to initialize OneSignal: $e');
    debugPrint('StackTrace: $stackTrace');
  }
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: getProviders(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        title: 'Hira Plus',
        theme: ThemeData(
          useMaterial3: true,
        ),
        initialRoute: Routes.splash,
        routes: getRoutes(),
      ),
    );
  }
}
