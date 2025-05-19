import 'package:flutter/material.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';
import 'package:provider/provider.dart';
import '../provider/notification_provider.dart';

class UserNotificationsScreen extends StatelessWidget {
  const UserNotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationProvider()..fetchNotifications(),
      child: Scaffold(
        appBar: AppBar(
        title: Text('Notifications',
            style: TextStyleClass.primaryFont500(20, ColorClass.white)),
        backgroundColor: ColorClass.brandDarkGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
        body: Consumer<NotificationProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (provider.error != null) {
              return Center(child: Text('Error: \\${provider.error}'));
            } else if (provider.notifications.isEmpty) {
              return const Center(
                child: Text(
                  'No notifications yet.',
                  style: TextStyle(fontSize: 18),
                ),
              );
            } else {
              final notifications = provider.notifications;
              return ListView.separated(
                itemCount: notifications.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return ListTile(
                    title: Text(notification.title),
                    subtitle: Text(notification.description),
                    trailing: Text(
                      '${notification.createdAt.year}-${notification.createdAt.month.toString().padLeft(2, '0')}-${notification.createdAt.day.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
} 