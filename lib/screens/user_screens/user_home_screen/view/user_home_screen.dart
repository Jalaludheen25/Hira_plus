import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/provider/canteen_home_page_provider.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/provider/user_meeting_provider.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/models/user_meeting_model.dart' as UserMeeting;
import '../widgets/month_calendar_view.dart';
import '../widgets/home_list_view.dart';
import '../widgets/today_fab.dart';
import 'package:hira_plus/screens/profile_screen/provider/profile_screen_provider.dart';
import 'package:hira_plus/screens/login_screen/provider/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'dart:async';
import 'package:lucide_icons/lucide_icons.dart';

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
      final meetingProvider =
          Provider.of<MeetingListProvider>(context, listen: false);
      
      // Fetch meals data when screen loads
      canteenProvider.fetchUserMeals(context);
      _scrollToToday(canteenProvider);
      _setupViewModeListener();
      canteenProvider.fetchBanner();
      
      // Fetch meetings for all users
      meetingProvider.fetchMeetings(context);
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
      final profileProvider =
          Provider.of<ProfileScreenProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      profileProvider.setUserInfo(
        userType: authProvider.userType.toLowerCase().replaceAll(' ', '_'),
        userName: authProvider.username,
        phone: authProvider.phone,
        department: authProvider.department,
        designation: authProvider.designation,
        isDeptHead: authProvider.isDeptHead,
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
          todayIndex * 85.0, // Increased from 56.0 to 80.0 for taller items
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

  // Helper method to build detailed food text
  String _buildFoodDetailsText(UserMeeting.MeetingModel meeting) {
    List<String> foodItems = [];
    
    if (meeting.breakfast > 0) {
      foodItems.add('Breakfast (${meeting.breakfast})');
    }
    if (meeting.midmorningSnacks > 0) {
      foodItems.add('Morning Snacks (${meeting.midmorningSnacks})');
    }
    if (meeting.lunch > 0) {
      foodItems.add('Lunch (${meeting.lunch})');
    }
    if (meeting.eveningsnacks > 0) {
      foodItems.add('Evening Snacks (${meeting.eveningsnacks})');
    }
    if (meeting.dinner > 0) {
      foodItems.add('Dinner (${meeting.dinner})');
    }
    
    if (foodItems.isEmpty) {
      return 'No food specified';
    }
    
    return foodItems.join(', ');
  }

  // Helper method to get status color and text
  Map<String, dynamic> _getStatusDetails(UserMeeting.MeetingModel meeting) {
    if (meeting.isPending) {
      return {
        'text': 'Pending',
        'color': ColorClass.orangeDark,
        'backgroundColor': ColorClass.orangeLighter,
        'icon': LucideIcons.clock,
      };
    } else if (meeting.isApproved) {
      return {
        'text': 'Approved',
        'color': ColorClass.greenDark,
        'backgroundColor': ColorClass.greenLighter,
        'icon': LucideIcons.checkCircle,
      };
    } else {
      return {
        'text': 'Rejected',
        'color': ColorClass.redDark,
        'backgroundColor': ColorClass.redLighter,
        'icon': LucideIcons.xCircle,
      };
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
            // 4. Meetings Widget (NEW)
            _buildMeetingsWidget(context),
            const SizedBox(height: 16),
            // 5. All Users Widget
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
                          child: Icon(Icons.broken_image,
                              color: ColorClass.white, size: 48),
                        ),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: ColorClass.brandDarkGreen,
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(
                                color: ColorClass.white),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
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
            completer.complete(
                Size(myImage.width.toDouble(), myImage.height.toDouble()));
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
            style: TextStyleClass.poppinsSemiBold(
                fontSize: 18, color: ColorClass.brandDarkGreen),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMealCountItem('Breakfast', mealCounts['breakfast'] ?? 0,
                  Icons.free_breakfast, ColorClass.yellowBase),
              _buildMealCountItem('Lunch', mealCounts['lunch'] ?? 0,
                  Icons.lunch_dining, ColorClass.orangeBase),
              _buildMealCountItem('Dinner', mealCounts['dinner'] ?? 0,
                  Icons.dinner_dining, ColorClass.blueBase),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealCountItem(
      String label, int count, IconData icon, Color color) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 6),
        Text('$count',
            style: TextStyleClass.poppinsSemiBold(fontSize: 18, color: color)),
        Text(label,
            style: TextStyleClass.poppinsRegular(
                fontSize: 14, color: ColorClass.brandDarkGreen)),
      ],
    );
  }

  Widget _buildMarkMealWidget(
      BuildContext context, CanteenHomeProvider canteenProvider) {
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
                style: TextStyleClass.poppinsSemiBold(
                    fontSize: 16, color: ColorClass.white),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: ColorClass.white, size: 20),
          ],
        ),
      ),
    );
  }

  // NEW: Meetings Widget
  Widget _buildMeetingsWidget(BuildContext context) {
    return GestureDetector(
      onTap: () => _showMeetingsBottomSheet(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: ColorClass.brandDarkGreen,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.event, color: ColorClass.white, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'View All Meetings',
                style: TextStyleClass.poppinsSemiBold(
                    fontSize: 16, color: ColorClass.white),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: ColorClass.white, size: 20),
          ],
        ),
      ),
    );
  }

  // NEW: Show Meetings Bottom Sheet
  void _showMeetingsBottomSheet(BuildContext context) {
    // Refresh meetings when opening
    final meetingProvider = Provider.of<MeetingListProvider>(context, listen: false);
    meetingProvider.fetchMeetings(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Consumer<MeetingListProvider>(
                builder: (context, provider, _) {
                  return Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'All Meetings',
                              style: TextStyleClass.poppinsSemiBold(
                                  fontSize: 18, color: ColorClass.brandDarkGreen),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => provider.fetchMeetings(context),
                                  icon: const Icon(Icons.refresh,
                                      size: 30, color: ColorClass.brandDarkGreen),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 30),
                                  onPressed: () => Navigator.pop(context),
                                  color: ColorClass.brandDarkGreen,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Content
                      Expanded(
                        child: _buildMeetingsContent(provider, scrollController),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMeetingsContent(MeetingListProvider provider, ScrollController scrollController) {
    if (provider.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Loading meetings..."),
          ],
        ),
      );
    }

    if (provider.errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                provider.errorMessage,
                textAlign: TextAlign.center,
                style: TextStyleClass.poppinsMedium(
                  fontSize: 16,
                  color: Colors.red,
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
              onPressed: () => provider.fetchMeetings(context),
            ),
          ],
        ),
      );
    }

    if (provider.meetings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No meetings available',
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: provider.meetings.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final meeting = provider.meetings[index];
        return _buildMeetingCard(meeting);
      },
    );
  }

  Widget _buildMeetingCard(UserMeeting.MeetingModel meeting) {
    final formattedStartDate = DateFormat('EEEE, MMMM d, yyyy').format(meeting.startDatetime);
    final formattedStartTime = DateFormat('h:mm a').format(meeting.startDatetime);
    final formattedEndTime = DateFormat('h:mm a').format(meeting.endDatetime);
    final statusDetails = _getStatusDetails(meeting);
    
    return Container(
      decoration: BoxDecoration(
        color: ColorClass.brandWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusDetails['backgroundColor'].withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: statusDetails['backgroundColor'].withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meeting.title,
                        style: TextStyleClass.poppinsSemiBold(
                          fontSize: 16,
                          color: ColorClass.brandDarkGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        meeting.description,
                        style: TextStyleClass.poppinsRegular(
                          fontSize: 14,
                          color: ColorClass.neutral500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusDetails['backgroundColor'],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusDetails['icon'],
                        size: 12,
                        color: statusDetails['color'],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusDetails['text'],
                        style: TextStyleClass.poppinsSemiBold(
                          fontSize: 10,
                          color: statusDetails['color'],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Meeting Details
            _buildDetailRow(LucideIcons.calendar, formattedStartDate),
            const SizedBox(height: 4),
            _buildDetailRow(LucideIcons.clock, '$formattedStartTime - $formattedEndTime'),
            const SizedBox(height: 4),
            _buildDetailRow(LucideIcons.mapPin, meeting.hall),
            const SizedBox(height: 4),
            _buildDetailRow(LucideIcons.users, '${meeting.noOfPersons} attendees'),
            const SizedBox(height: 4),
            _buildDetailRow(LucideIcons.building, meeting.department),
            
            if (meeting.foodRequired) ...[
              const SizedBox(height: 4),
              _buildDetailRow(LucideIcons.utensils, _buildFoodDetailsText(meeting)),
            ],
            
            const SizedBox(height: 8),
            Text(
              'Created: ${DateFormat('MMM d, h:mm a').format(meeting.createdAt)}',
              style: TextStyleClass.poppinsRegular(
                fontSize: 11,
                color: ColorClass.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 12,
          color: ColorClass.neutral400,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyleClass.poppinsRegular(
              fontSize: 12,
              color: ColorClass.neutral500,
            ),
          ),
        ),
      ],
    );
  }

  void _showMealMarkBottomSheet(
      BuildContext context, CanteenHomeProvider canteenProvider) {
    // Always show today's date and list view when opening
    canteenProvider.setMode(HomeViewMode.list);
    canteenProvider.setSelectedDate(DateTime.now(), context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final canteenProvider = Provider.of<CanteenHomeProvider>(context);
        debugPrint('Current HomeViewMode: ${canteenProvider.mode}');

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
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Close button and view toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(),
                      Text("Mark Your Meals",
                          style: TextStyleClass.poppinsSemiBold(
                              fontSize: 18, color: ColorClass.brandDarkGreen)),
                      Container(
                        padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: Icon(Icons.close, size: 30),
                          onPressed: () => Navigator.pop(context),
                          color: ColorClass.brandDarkGreen,
                        ),
                      ),
                    ],
                  ),
                  // Toggle between list and calendar view
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: canteenProvider.mode == HomeViewMode.list
                              ? null
                              : () =>
                                  canteenProvider.setMode(HomeViewMode.list),
                          icon: Icon(Icons.list,
                              color: canteenProvider.mode == HomeViewMode.list
                                  ? ColorClass.brandDarkGreen
                                  : Colors.grey),
                          label: Text('List',
                              style: TextStyleClass.poppinsRegular(
                                  fontSize: 15,
                                  color:
                                      canteenProvider.mode == HomeViewMode.list
                                          ? ColorClass.brandDarkGreen
                                          : Colors.grey)),
                        ),
                        TextButton.icon(
                          onPressed: canteenProvider.mode == HomeViewMode.month
                              ? null
                              : () =>
                                  canteenProvider.setMode(HomeViewMode.month),
                          icon: Icon(Icons.calendar_month,
                              color: canteenProvider.mode == HomeViewMode.month
                                  ? ColorClass.brandDarkGreen
                                  : Colors.grey),
                          label: Text('Calendar',
                              style: TextStyleClass.poppinsRegular(
                                  fontSize: 15,
                                  color:
                                      canteenProvider.mode == HomeViewMode.month
                                          ? ColorClass.brandDarkGreen
                                          : Colors.grey)),
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
                                itemHeight: 90.0, // Increased from 56.0 to 80.0
                              ),
                              Positioned(
                                bottom: 16,
                                right: 16,
                                child: TodayFAB(
                                  onPressed: () {
                                    canteenProvider.setSelectedDate(
                                        DateTime.now(), context);
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
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
                              final currentMonth =
                                  canteenProvider.selectedDate.month;
                              final newMonth = currentMonth + delta;
                              final newYear =
                                  canteenProvider.selectedDate.year +
                                      ((newMonth - 1) ~/ 12);
                              final normalizedMonth = ((newMonth - 1) % 12) + 1;
                              if (newYear == currentYear &&
                                  normalizedMonth >= 1 &&
                                  normalizedMonth <= 12) {
                                final newDate =
                                    DateTime(newYear, normalizedMonth, 1);
                                canteenProvider.setSelectedDate(
                                    newDate, context);
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

  Widget _buildAllUsersWidget(
      BuildContext context, CanteenHomeProvider canteenProvider) {
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
                style: TextStyleClass.poppinsSemiBold(
                    fontSize: 16, color: ColorClass.white),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: ColorClass.white, size: 20),
          ],
        ),
      ),
    );
  }

  void _showAllUsersBottomSheet(
      BuildContext context, CanteenHomeProvider canteenProvider) {
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
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Close button and header
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'All Users',
                          style: TextStyleClass.poppinsSemiBold(
                              fontSize: 18, color: ColorClass.brandDarkGreen),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () =>
                                  canteenProvider.fetchContacts(context),
                              icon: const Icon(Icons.refresh,
                                  size: 30, color: ColorClass.brandDarkGreen),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 30),
                              onPressed: () => Navigator.pop(context),
                              color: ColorClass.brandDarkGreen,
                            ),
                          ],
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
                                  provider.contactsError
                                          .contains('Authentication')
                                      ? Icons.lock_outline
                                      : Icons.error_outline,
                                  size: 48,
                                  color: provider.contactsError
                                          .contains('Authentication')
                                      ? Colors.orange
                                      : Colors.red,
                                ),
                                const SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32.0),
                                  child: Text(
                                    provider.contactsError,
                                    textAlign: TextAlign.center,
                                    style: TextStyleClass.poppinsMedium(
                                      fontSize: 16,
                                      color: provider.contactsError
                                              .contains('Authentication')
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
                                  onPressed: () =>
                                      provider.fetchContacts(context),
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
                          separatorBuilder: (_, __) =>
                              Divider(height: 1, color: Colors.grey[200]),
                          itemBuilder: (context, index) {
                            final contact = provider.contacts[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: ColorClass.brandLightGreen,
                                child: Text(
                                  contact.name.isNotEmpty
                                      ? contact.name[0].toUpperCase()
                                      : '?',
                                  style: TextStyleClass.poppinsBold(
                                    fontSize: 16,
                                    color: ColorClass.brandDarkGreen,
                                  ),
                                ),
                              ),
                              title: Text(
                                contact.name,
                                style: TextStyleClass.poppinsSemiBold(
                                    fontSize: 16),
                              ),
                              subtitle: Text(
                                '${contact.phoneNumber}\n${contact.designation} • ${contact.department}',
                                style: TextStyleClass.poppinsRegular(
                                    fontSize: 13, color: Colors.grey[700]),
                              ),
                              isThreeLine: true,
                              trailing: IconButton(
                                icon: Icon(Icons.call,
                                    color: ColorClass.brandDarkGreen),
                                onPressed: () async {
                                  if (contact.phoneNumber.isNotEmpty) {
                                    final uri = Uri(
                                        scheme: 'tel',
                                        path: contact.phoneNumber);
                                    try {
                                      if (await canLaunchUrl(uri)) {
                                        await launchUrl(uri);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Cannot make call to ${contact.phoneNumber}'),
                                            backgroundColor: ColorClass.redBase,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text('Error making call: $e'),
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