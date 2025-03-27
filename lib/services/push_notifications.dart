import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'dart:developer' as dev;

class PushNotificationService {
  static Future<void> initializeOneSignal(String appId) async {
    try {
      // Initialize OneSignal
      OneSignal.initialize(appId);

      // Request notification permission
      await OneSignal.Notifications.requestPermission(true);

      // Set notification handlers
      OneSignal.Notifications.clearAll();

      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        // Show notification when app is open
        event.notification.display();
      });

      // Handle when user taps notification
      OneSignal.Notifications.addClickListener((event) {
        dev.log('Notification opened: ${event.notification.title}');
      });

      dev.log('OneSignal initialized successfully');
    } catch (e) {
      dev.log('Error initializing OneSignal: $e');
    }
  }
}

  // Remove this method to stop OneSignal Debugging
//   OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

//   OneSignal.initialize("47055440-3068-4d27-8d90-5b289debeba3");

// // The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
//   OneSignal.Notifications.requestPermission(true);
