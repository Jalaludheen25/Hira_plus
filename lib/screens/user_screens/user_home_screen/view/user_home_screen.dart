import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/provider/canteen_home_page_provider.dart';
import '../widgets/month_calendar_view.dart';
import '../widgets/home_list_view.dart';
import '../widgets/today_fab.dart';
import 'package:hira_plus/screens/profile_screen/provider/profile_screen_provider.dart';
import 'package:hira_plus/screens/login_screen/provider/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import 'dart:async';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  CanteenHomeProvider? _viewModeProvider;
  VoidCallback? _viewModeListener;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final canteenProvider =
          Provider.of<CanteenHomeProvider>(context, listen: false);
      // Fetch meals data when screen loads
      canteenProvider.fetchUserMeals(context);
      _scrollToToday(canteenProvider);
      _setupViewModeListener();
    });
  }

  void _setupViewModeListener() {
    _viewModeProvider =
        Provider.of<CanteenHomeProvider>(context, listen: false);
    _viewModeListener = () {
      if (_viewModeProvider!.mode == HomeViewMode.list) {
        final canteenProvider =
            Provider.of<CanteenHomeProvider>(context, listen: false);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToToday(canteenProvider);
        });
      }
    };
    _viewModeProvider?.addListener(_viewModeListener!);
  }

  @override
  void dispose() {
    _viewModeProvider?.removeListener(_viewModeListener!);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final canteenProvider =
          Provider.of<CanteenHomeProvider>(context, listen: false);
      _scrollToToday(canteenProvider);
      // Set user info for profile card
      final profileProvider = Provider.of<ProfileScreenProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      profileProvider.setUserInfo(
        userType: authProvider.userType.toLowerCase().replaceAll(' ', '_'),
        userName: authProvider.username,
        phone: authProvider.phone,
        department: authProvider.department,
        designation: authProvider.designation,
      );
    });
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  void _scrollToToday(CanteenHomeProvider canteenProvider) {
    final todayIndex = canteenProvider.getTodayIndex();
    if (todayIndex != -1) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          todayIndex * 56.0, // Use compact item height
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        Future.delayed(const Duration(milliseconds: 100), () {
          _scrollToToday(canteenProvider);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canteenProvider = Provider.of<CanteenHomeProvider>(context);
    final mealCounts = canteenProvider.getCurrentMonthMealCounts();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorClass.brandDarkGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Hira +',
          style: TextStyleClass.poppinsSemiBold(
            fontSize: 20,
            color: ColorClass.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Banner
            _buildBanner(),
            const SizedBox(height: 10),
            // 2. Meal Count Card
            _buildMealCountCard(mealCounts),
            const SizedBox(height: 16),
            // 3. Mark Meal Widget
            _buildMarkMealWidget(context, canteenProvider),
            const SizedBox(height: 16),
            // 4. All Users Widget
            _buildAllUsersWidget(context, canteenProvider),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner() {
    final banner = Provider.of<CanteenHomeProvider>(context).banner;
    if (banner == null || banner.bannerImage.isEmpty) {
      // Placeholder if no banner
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: 120,
        decoration: BoxDecoration(
          color: ColorClass.brandDarkGreen,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Text(
          'No banner available',
          style: TextStyleClass.poppinsSemiBold(
            fontSize: 16,
            color: ColorClass.white,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return FutureBuilder<Size>(
          future: _getImageSize(banner.bannerImage),
          builder: (context, snapshot) {
            double aspectRatio = 16 / 9; // Default to landscape
            if (snapshot.hasData) {
              final size = snapshot.data!;
              aspectRatio = size.width / size.height;
            }
            // If portrait, make it taller
            final isPortrait = aspectRatio < 1.0;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: isPortrait ? 3 / 4 : aspectRatio,
                      child: Image.network(
                        banner.bannerImage,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: ColorClass.brandDarkGreen,
                          alignment: Alignment.center,
                          child: Icon(Icons.broken_image, color: ColorClass.white, size: 48),
                        ),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: ColorClass.brandDarkGreen,
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(color: ColorClass.white),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        color: Colors.black.withOpacity(0.4),
                        child: Text(
                          banner.title,
                          style: TextStyleClass.poppinsSemiBold(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<Size> _getImageSize(String url) async {
    final Completer<Size> completer = Completer();
    final Image image = Image.network(url);
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        final myImage = info.image;
        completer.complete(Size(myImage.width.toDouble(), myImage.height.toDouble()));
      }, onError: (dynamic _, __) {
        completer.complete(const Size(16, 9)); // fallback
      }),
    );
    return completer.future;
  }

  Widget _buildMealCountCard(Map<String, int> mealCounts) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorClass.brandLightGreen,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ColorClass.brandDarkGreen.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Month\'s Meal Count',
            style: TextStyleClass.poppinsSemiBold(fontSize: 18, color: ColorClass.brandDarkGreen),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMealCountItem('Breakfast', mealCounts['breakfast'] ?? 0, Icons.free_breakfast, ColorClass.yellowBase),
              _buildMealCountItem('Lunch', mealCounts['lunch'] ?? 0, Icons.lunch_dining, ColorClass.orangeBase),
              _buildMealCountItem('Dinner', mealCounts['dinner'] ?? 0, Icons.dinner_dining, ColorClass.blueBase),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealCountItem(String label, int count, IconData icon, Color color) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 6),
        Text('$count', style: TextStyleClass.poppinsSemiBold(fontSize: 18, color: color)),
        Text(label, style: TextStyleClass.poppinsRegular(fontSize: 14, color: ColorClass.brandDarkGreen)),
      ],
    );
  }

  Widget _buildMarkMealWidget(BuildContext context, CanteenHomeProvider canteenProvider) {
    return GestureDetector(
      onTap: () => _showMealMarkBottomSheet(context, canteenProvider),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: ColorClass.brandDarkGreen,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.edit_calendar, color: ColorClass.white, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Mark Your Meals',
                style: TextStyleClass.poppinsSemiBold(fontSize: 16, color: ColorClass.white),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: ColorClass.white, size: 20),
          ],
        ),
      ),
    );
  }

  void _showMealMarkBottomSheet(BuildContext context, CanteenHomeProvider canteenProvider) {
    // Always show today's date and list view when opening
    canteenProvider.setMode(HomeViewMode.list);
    canteenProvider.setSelectedDate(DateTime.now(), context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final canteenProvider = Provider.of<CanteenHomeProvider>(context);
        print('Current HomeViewMode: ' + canteenProvider.mode.toString());

        // Ensure scroll to today when in list mode
        if (canteenProvider.mode == HomeViewMode.list) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToToday(canteenProvider);
          });
        }

        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.7,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Toggle between list and calendar view
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: canteenProvider.mode == HomeViewMode.list
                              ? null
                              : () => canteenProvider.setMode(HomeViewMode.list),
                          icon: Icon(Icons.list, color: canteenProvider.mode == HomeViewMode.list ? ColorClass.brandDarkGreen : Colors.grey),
                          label: Text('List', style: TextStyleClass.poppinsRegular(fontSize: 15, color: canteenProvider.mode == HomeViewMode.list ? ColorClass.brandDarkGreen : Colors.grey)),
                        ),
                        TextButton.icon(
                          onPressed: canteenProvider.mode == HomeViewMode.month
                              ? null
                              : () => canteenProvider.setMode(HomeViewMode.month),
                          icon: Icon(Icons.calendar_month, color: canteenProvider.mode == HomeViewMode.month ? ColorClass.brandDarkGreen : Colors.grey),
                          label: Text('Calendar', style: TextStyleClass.poppinsRegular(fontSize: 15, color: canteenProvider.mode == HomeViewMode.month ? ColorClass.brandDarkGreen : Colors.grey)),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: canteenProvider.mode == HomeViewMode.list
                        ? Stack(
                            children: [
                              HomeListView(
                                scrollController: _scrollController,
                                getMonthName: _getMonthName,
                                getDayName: _getDayName,
                                itemHeight: 56.0,
                              ),
                              Positioned(
                                bottom: 16,
                                right: 16,
                                child: TodayFAB(
                                  onPressed: () {
                                    canteenProvider.setSelectedDate(DateTime.now(), context);
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      _scrollToToday(canteenProvider);
                                    });
                                  },
                                ),
                              ),
                            ],
                          )
                        : MonthCalendarView(
                            selectedDate: canteenProvider.selectedDate,
                            getMonthName: _getMonthName,
                            onMonthChanged: (int delta) {
                              final currentYear = DateTime.now().year;
                              final currentMonth = canteenProvider.selectedDate.month;
                              final newMonth = currentMonth + delta;
                              final newYear = canteenProvider.selectedDate.year + ((newMonth - 1) ~/ 12);
                              final normalizedMonth = ((newMonth - 1) % 12) + 1;
                              if (newYear == currentYear && normalizedMonth >= 1 && normalizedMonth <= 12) {
                                final newDate = DateTime(newYear, normalizedMonth, 1);
                                canteenProvider.setSelectedDate(newDate, context);
                              }
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAllUsersWidget(BuildContext context, CanteenHomeProvider canteenProvider) {
    return GestureDetector(
      onTap: () => _showAllUsersBottomSheet(context, canteenProvider),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: ColorClass.brandDarkGreen,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.people, color: ColorClass.white, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'All Users',
                style: TextStyleClass.poppinsSemiBold(fontSize: 16, color: ColorClass.white),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: ColorClass.white, size: 20),
          ],
        ),
      ),
    );
  }

  void _showAllUsersBottomSheet(BuildContext context, CanteenHomeProvider canteenProvider) {
    // Fetch contacts when opening the bottom sheet
    canteenProvider.fetchContacts(context);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Header with refresh button
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'All Users',
                          style: TextStyleClass.poppinsSemiBold(fontSize: 18, color: ColorClass.brandDarkGreen),
                        ),
                        IconButton(
                          onPressed: () => canteenProvider.fetchContacts(context),
                          icon: const Icon(Icons.refresh, color: ColorClass.brandDarkGreen),
                        ),
                      ],
                    ),
                  ),
                  // Content based on state
                  Expanded(
                    child: Consumer<CanteenHomeProvider>(
                      builder: (context, provider, child) {
                        if (provider.isLoadingContacts) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text("Loading contacts..."),
                              ],
                            ),
                          );
                        }

                        if (provider.contactsError.isNotEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  provider.contactsError.contains('Authentication')
                                      ? Icons.lock_outline
                                      : Icons.error_outline,
                                  size: 48,
                                  color: provider.contactsError.contains('Authentication')
                                      ? Colors.orange
                                      : Colors.red,
                                ),
                                const SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                                  child: Text(
                                    provider.contactsError,
                                    textAlign: TextAlign.center,
                                    style: TextStyleClass.poppinsMedium(
                                      fontSize: 16,
                                      color: provider.contactsError.contains('Authentication')
                                          ? Colors.orange
                                          : Colors.red,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Retry'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ColorClass.brandDarkGreen,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () => provider.fetchContacts(context),
                                ),
                              ],
                            ),
                          );
                        }

                        if (provider.contacts.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No contacts available',
                                  style: TextStyleClass.poppinsMedium(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          controller: scrollController,
                          itemCount: provider.contacts.length,
                          separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[200]),
                          itemBuilder: (context, index) {
                            final contact = provider.contacts[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: ColorClass.brandLightGreen,
                                child: Text(
                                  contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                                  style: TextStyleClass.poppinsBold(
                                    fontSize: 16,
                                    color: ColorClass.brandDarkGreen,
                                  ),
                                ),
                              ),
                              title: Text(
                                contact.name,
                                style: TextStyleClass.poppinsSemiBold(fontSize: 16),
                              ),
                              subtitle: Text(
                                '${contact.phoneNumber}\n${contact.designation} • ${contact.department}',
                                style: TextStyleClass.poppinsRegular(fontSize: 13, color: Colors.grey[700]),
                              ),
                              isThreeLine: true,
                              trailing: IconButton(
                                icon: Icon(Icons.call, color: ColorClass.brandDarkGreen),
                                onPressed: () async {
                                  if (contact.phoneNumber.isNotEmpty) {
                                    final uri = Uri(scheme: 'tel', path: contact.phoneNumber);
                                    try {
                                      if (await canLaunchUrl(uri)) {
                                        await launchUrl(uri);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Cannot make call to ${contact.phoneNumber}'),
                                            backgroundColor: ColorClass.redBase,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Error making call: $e'),
                                          backgroundColor: ColorClass.redBase,
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}