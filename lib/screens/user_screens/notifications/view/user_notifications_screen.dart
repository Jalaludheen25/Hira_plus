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
        backgroundColor: ColorClass.backgroundColor,
        appBar: AppBar(
          title: Text(
            'Notifications',
            style: TextStyleClass.primaryFont500(20, ColorClass.white),
          ),
          backgroundColor: ColorClass.brandDarkGreen,
          elevation: 0,
          iconTheme: const IconThemeData(color: ColorClass.white),
        ),
        body: Consumer<NotificationProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          ColorClass.brandDarkGreen),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading notifications...',
                      style: TextStyleClass.primaryFont400(
                          16, ColorClass.textSub500),
                    ),
                  ],
                ),
              );
            } else if (provider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: ColorClass.redBase,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${provider.error}',
                      style: TextStyleClass.primaryFont400(
                          16, ColorClass.textSub500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            } else if (provider.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      color: ColorClass.neutral400,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No notifications yet',
                      style: TextStyleClass.primaryFont500(
                          18, ColorClass.textSub500),
                    ),
                  ],
                ),
              );
            } else {
              return ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: provider.notifications.length,
                itemBuilder: (context, index) {
                  final notification = provider.notifications[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: ColorClass.strokeSoft200,
                          width: 1,
                        ),
                      ),
                      color: ColorClass.white,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          // Handle notification tap
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: ColorClass.brandDarkGreen
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.notifications_active,
                                      color: ColorClass.brandDarkGreen,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          notification.title,
                                          style: TextStyleClass.primaryFont500(
                                              16, ColorClass.textMain900),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          notification.description,
                                          style: TextStyleClass.primaryFont400(
                                              14, ColorClass.textSub500),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ColorClass.neutral100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${notification.createdAt.year}-${notification.createdAt.month.toString().padLeft(2, '0')}-${notification.createdAt.day.toString().padLeft(2, '0')}',
                                    style: TextStyleClass.primaryFont400(
                                        12, ColorClass.textSub500),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
