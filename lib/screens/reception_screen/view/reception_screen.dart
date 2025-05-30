import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/screens/reception_screen/provider/reception_provider.dart';
import 'package:hira_plus/screens/reception_screen/models/reception_user_model.dart';
import 'package:hira_plus/screens/profile_screen/widgets/profile_card.dart';
import 'package:hira_plus/screens/profile_screen/widgets/logout_confirmation_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:hira_plus/screens/profile_screen/provider/profile_screen_provider.dart';
import 'package:hira_plus/screens/login_screen/provider/auth_provider.dart';
import 'package:hira_plus/screens/profile_screen/widgets/powered_by_section.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/widgets/custom_drawer.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shake_flutter/shake_flutter.dart';
import 'package:shake_flutter/enums/shake_screen.dart';
import 'package:hira_plus/routes/app_routes.dart';
import 'package:hira_plus/utils/navigation_helper.dart';
import 'package:toastification/toastification.dart';
import 'package:intl/intl.dart';

class ReceptionScreen extends StatefulWidget {
  const ReceptionScreen({Key? key}) : super(key: key);

  @override
  State<ReceptionScreen> createState() => _ReceptionScreenState();
}

class _ReceptionScreenState extends State<ReceptionScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<ReceptionProvider>(context, listen: false);
      // Initialize provider first (loads saved states and today's attendance)
      await provider.initialize(context);
      // Then fetch users
      provider.fetchUsers(context);
    });
  }

  // Handle back button press
  Future<bool> _onWillPop() async {
    final receptionProvider = Provider.of<ReceptionProvider>(context, listen: false);
    
    if (receptionProvider.shouldExitOnBack(context)) {
      // User pressed back twice within 2 seconds, exit the app
      SystemNavigator.pop();
      return true;
    }
    
    // Don't exit the app on first back press
    return false;
  }

  // Method to show date picker
  Future<void> _selectDate(BuildContext context, ReceptionProvider provider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ColorClass.brandDarkGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != provider.selectedDate) {
      provider.setSelectedDate(picked);
      // Optionally fetch attendance data for the selected date
      // provider.fetchAttendanceForDate(provider.selectedDateString);
    }
  }

  Widget _buildUsersTab() {
    return Consumer<ReceptionProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Reception'),
            backgroundColor: ColorClass.brandDarkGreen,
            foregroundColor: ColorClass.white,
            elevation: 0,
            actions: [
              // Calendar icon to select date
              
            ],
          ),
          backgroundColor: ColorClass.white,
          body: Column(
            children: [
              // Date display section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: ColorClass.brandLightGreen.withOpacity(0.1),
                  border: Border(
                    bottom: BorderSide(
                      color: ColorClass.brandLightGreen.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Date',
                          style: TextStyle(
                            fontSize: 12,
                            color: ColorClass.neutral400,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('EEEE, MMMM dd, yyyy').format(provider.selectedDate),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ColorClass.brandDarkGreen,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => _selectDate(context, provider),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: ColorClass.brandDarkGreen,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Change',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Header for the checkboxes
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: ColorClass.neutral100,
                  border: Border(
                    bottom: BorderSide(
                      color: ColorClass.neutral200,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Users',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ColorClass.brandDarkGreen,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: Center(
                        child: Text(
                          'Check In',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 60,
                      child: Center(
                        child: Text(
                          'Check Out',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Loading or error states
              if (provider.isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (provider.error.isNotEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          provider.error,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => provider.fetchUsers(context),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorClass.brandDarkGreen,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (provider.users.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text('No users found'),
                  ),
                )
              else
                // Users list
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => provider.fetchUsers(context),
                    color: ColorClass.brandDarkGreen,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: provider.users.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        color: ColorClass.neutral200,
                      ),
                      itemBuilder: (context, index) {
                        final ReceptionUser user = provider.users[index];
                        final checkedIn = provider.isCheckedIn(user.id);
                        final checkedOut = provider.isCheckedOut(user.id);
                        
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              // User info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: ColorClass.textMain900,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${user.designation} • ${user.department}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: ColorClass.neutral500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Check In checkbox - GREEN when checked, stays checked
                              SizedBox(
                                width: 60,
                                child: Center(
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      checkboxTheme: CheckboxThemeData(
                                        fillColor: MaterialStateProperty.resolveWith<Color?>(
                                          (Set<MaterialState> states) {
                                            if (states.contains(MaterialState.selected)) {
                                              return Colors.green.shade600; // GREEN for check-in
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ),
                                    child: Checkbox(
                                      value: checkedIn,
                                      checkColor: Colors.white,
                                      onChanged: checkedIn 
                                          ? null // Don't allow unchecking once checked in
                                          : (val) {
                                              if (val == true) {
                                                provider.checkIn(context, user.id);
                                              }
                                            },
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(width: 12),
                              
                              // Check Out checkbox - RED when checked, stays checked
                              SizedBox(
                                width: 60,
                                child: Center(
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      checkboxTheme: CheckboxThemeData(
                                        fillColor: MaterialStateProperty.resolveWith<Color?>(
                                          (Set<MaterialState> states) {
                                            if (states.contains(MaterialState.selected)) {
                                              return Colors.red.shade600; // RED for check-out
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ),
                                    child: Checkbox(
                                      value: checkedOut,
                                      checkColor: Colors.white,
                                      onChanged: checkedOut 
                                          ? null // Don't allow unchecking once checked out
                                          : (val) {
                                              if (val == true) {
                                                // Only allow check out if user is checked in
                                                if (checkedIn) {
                                                  provider.checkOut(context, user.id);
                                                } else {
                                                  // Show error message
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('Please check in ${user.name} first'),
                                                      backgroundColor: Colors.orange,
                                                      duration: const Duration(seconds: 2),
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCheckInOutTab() {
    return Consumer<ReceptionProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Reports'),
            backgroundColor: ColorClass.brandDarkGreen,
            foregroundColor: ColorClass.white,
            elevation: 0,
            // actions: [
            //   // IconButton(
            //   //   icon: const Icon(Icons.calendar_month),
            //   //   onPressed: () async {
            //   //     final DateTime? picked = await showDatePicker(
            //   //       context: context,
            //   //       initialDate: provider.attendanceSelectedDate,
            //   //       firstDate: DateTime(2020),
            //   //       lastDate: DateTime.now().add(const Duration(days: 365)),
            //   //       builder: (context, child) {
            //   //         return Theme(
            //   //           data: Theme.of(context).copyWith(
            //   //             colorScheme: ColorScheme.light(
            //   //               primary: ColorClass.brandDarkGreen,
            //   //               onPrimary: Colors.white,
            //   //               surface: Colors.white,
            //   //               onSurface: Colors.black,
            //   //             ),
            //   //           ),
            //   //           child: child!,
            //   //         );
            //   //       },
            //   //     );
            //   //     if (picked != null && picked != provider.attendanceSelectedDate) {
            //   //       provider.setAttendanceSelectedDate(picked, context);
            //   //     }
            //   //   },
            //   // ),
            // ],
          ),
          backgroundColor: ColorClass.white,
          body: Column(
            children: [
              // Date display section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: ColorClass.brandLightGreen.withOpacity(0.1),
                  border: Border(
                    bottom: BorderSide(
                      color: ColorClass.brandLightGreen.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Date',
                          style: TextStyle(
                            fontSize: 12,
                            color: ColorClass.neutral400,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('EEEE, MMMM dd, yyyy').format(provider.attendanceSelectedDate),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ColorClass.brandDarkGreen,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: provider.attendanceSelectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: ColorClass.brandDarkGreen,
                                  onPrimary: Colors.white,
                                  surface: Colors.white,
                                  onSurface: Colors.black,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null && picked != provider.attendanceSelectedDate) {
                          provider.setAttendanceSelectedDate(picked, context);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: ColorClass.brandDarkGreen,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Change',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: ColorClass.neutral100,
                  border: Border(
                    bottom: BorderSide(
                      color: ColorClass.neutral200,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'User',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ColorClass.brandDarkGreen,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Center(
                        child: Text(
                          'Check In',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 80,
                      child: Center(
                        child: Text(
                          'Check Out',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Attendance list or states
              if (provider.isAttendanceLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (provider.attendanceError.isNotEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          provider.attendanceError,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => provider.fetchAttendanceByDate(context),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorClass.brandDarkGreen,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (provider.attendanceByDate.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text('No attendance records found'),
                  ),
                )
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => provider.fetchAttendanceByDate(context),
                    color: ColorClass.brandDarkGreen,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: provider.attendanceByDate.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        color: ColorClass.neutral200,
                      ),
                      itemBuilder: (context, index) {
                        final record = provider.attendanceByDate[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              // User info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      record.user.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: ColorClass.textMain900,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${record.user.designation} • ${record.user.department}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: ColorClass.neutral500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              // Check In time
                              SizedBox(
                                width: 80,
                                child: Center(
                                  child: Text(
                                    DateFormat('hh:mm a').format(record.checkedInTime.toLocal()),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Check Out time
                              SizedBox(
                                width: 80,
                                child: Center(
                                  child: record.checkoutTime != null
                                      ? Text(
                                          DateFormat('hh:mm a').format(record.checkoutTime!.toLocal()),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.red.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        )
                                      : Text(
                                          'Not checked out',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.orange,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileTab() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: ColorClass.brandDarkGreen,
        foregroundColor: ColorClass.white,
        elevation: 0,
      ),
      backgroundColor: ColorClass.white,
      body: Consumer2<ProfileScreenProvider, AuthProvider>(
        builder: (context, profileProvider, authProvider, _) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    ProfileCard(
                      userName: profileProvider.userName.isNotEmpty 
                          ? profileProvider.userName 
                          : 'Reception Staff',
                      phone: profileProvider.phone,
                      department: profileProvider.department.isNotEmpty 
                          ? profileProvider.department 
                          : 'Reception',
                      designation: 'Reception Staff',
                    ),
                    const SizedBox(height: 32),
                    CustomDrawerItem(
                      title: 'Feedback',
                      icon: LucideIcons.messageCircle,
                      onTap: () async {
                        final Uri emailLaunchUri = Uri(
                          scheme: 'mailto',
                          path: 'mail@d4dx.co',
                        );
                        await launchUrl(emailLaunchUri);
                      },
                    ),
                    CustomDrawerItem(
                      title: 'Privacy Policy',
                      icon: LucideIcons.shieldCheck,
                      onTap: () async {
                        final Uri url = Uri.parse(
                            'https://www.termsfeed.com/live/4e2e2e2e-privacy-policy');
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      },
                    ),
                    CustomDrawerItem(
                      title: 'Contact Us',
                      icon: LucideIcons.phone,
                      onTap: () {
                        navigateTo(
                          context: context,
                          route: Routes.contactUs,
                        );
                      },
                    ),
                    CustomDrawerItem(
                      title: 'About Us',
                      icon: LucideIcons.info,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('About Us'),
                            content: const Text('This is dummy content for About Us.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    CustomDrawerItem(
                      title: 'Raise a bug',
                      icon: LucideIcons.bug,
                      onTap: () {
                        Shake.show(ShakeScreen.home);
                      },
                    ),
                    const Divider(),
                    CustomDrawerItem(
                      title: 'Logout',
                      icon: LucideIcons.logOut,
                      isDestructive: true,
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          builder: (context) => LogoutConfirmationBottomSheet(
                            onLogout: () async {
                              await authProvider.logout();
                              if (context.mounted) {
                                toastification.show(
                                  context: context,
                                  title: const Text('Logged out successfully'),
                                  type: ToastificationType.success,
                                  autoCloseDuration: const Duration(seconds: 2),
                                );
                                
                                Future.delayed(const Duration(milliseconds: 500), () {
                                  navigatePRToGlobal(route: Routes.login);
                                });
                              }
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const PoweredBySection(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _tabViews = <Widget>[
      _buildUsersTab(),
      _buildCheckInOutTab(),
      _buildProfileTab(),
    ];
    
    // WillPopScope to handle back button
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: ColorClass.white,
        body: _tabViews[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: ColorClass.brandWhite,
          selectedItemColor: ColorClass.brandDarkGreen,
          unselectedItemColor: const Color.fromARGB(255, 63, 94, 43),
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.how_to_reg),
              activeIcon: Icon(Icons.how_to_reg,size: 30,),
              label: 'Attendance',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assessment),
              activeIcon: Icon(Icons.assessment,size: 30,),
              label: 'Reports',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              activeIcon: Icon(Icons.person,size: 30,),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}