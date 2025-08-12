import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';
import 'package:hira_plus/screens/manager_screen/provider/transportation_provider.dart';
import 'package:toastification/toastification.dart';

class DriverSelectionScreen extends StatefulWidget {
  const DriverSelectionScreen({Key? key}) : super(key: key);

  @override
  State<DriverSelectionScreen> createState() => _DriverSelectionScreenState();
}

class _DriverSelectionScreenState extends State<DriverSelectionScreen> {
  String _searchQuery = '';
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransportationProvider>(context, listen: false)
          .fetchDrivers();
    });
  }

  Future<void> _updateUserRole(String userId, String currentRole) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final provider =
          Provider.of<TransportationProvider>(context, listen: false);
      final newRole = currentRole == 'driver' ? 'user' : 'driver';
      final success = await provider.updateUserRole(userId, newRole);

      if (success) {
        toastification.show(
          context: context,
          title: Text('User role updated to $newRole'),
          type: ToastificationType.success,
          autoCloseDuration: Duration(seconds: 3),
        );
      } else {
        toastification.show(
          context: context,
          title: Text('Failed to update user role'),
          type: ToastificationType.error,
          autoCloseDuration: Duration(seconds: 3),
        );
      }
    } catch (e) {
      toastification.show(
        context: context,
        title: Text('Error: $e'),
        type: ToastificationType.error,
        autoCloseDuration: Duration(seconds: 3),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorClass.bgWhite0,
      appBar: AppBar(
        backgroundColor: ColorClass.brandDarkGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          'Manage Drivers',
          style: TextStyleClass.poppinsSemiBold(
            fontSize: 20,
            color: ColorClass.white,
          ),
        ),
      ),
      body: Consumer<TransportationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CupertinoActivityIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.alertCircle,
                    size: 48,
                    color: ColorClass.neutral400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${provider.error}',
                    style: TextStyleClass.poppinsRegular(
                      fontSize: 16,
                      color: ColorClass.neutral400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchDrivers(),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final filteredUsers = provider.drivers.where((user) {
            final name = user.name?.toLowerCase() ?? '';
            final department = user.department?.toLowerCase() ?? '';
            final role = user.role?.toLowerCase() ?? '';
            final query = _searchQuery.toLowerCase();

            return name.contains(query) ||
                department.contains(query) ||
                role.contains(query);
          }).toList();

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search users...',
                      hintStyle: TextStyleClass.poppinsRegular(fontSize: 14),
                      prefixIcon: Icon(LucideIcons.search,
                          color: ColorClass.neutral400, size: 18),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: ColorClass.neutral300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: ColorClass.brandDarkGreen),
                      ),
                    ),
                  ),
                ),
              ),

              // Users List
              Expanded(
                child: filteredUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.users,
                              size: 48,
                              color: ColorClass.neutral300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No users found'
                                  : 'No users match your search',
                              style: TextStyleClass.poppinsRegular(
                                fontSize: 16,
                                color: ColorClass.neutral400,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          final isDriver = user.role == 'driver';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDriver
                                    ? ColorClass.brandLightGreen
                                    : ColorClass.neutral200,
                                width: isDriver ? 1.5 : 1,
                              ),
                            ),
                            child: ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              leading: CircleAvatar(
                                radius: 18,
                                backgroundColor: isDriver
                                    ? ColorClass.brandLightGreen
                                    : ColorClass.neutral200,
                                child: Icon(
                                  isDriver ? LucideIcons.car : LucideIcons.user,
                                  color: isDriver
                                      ? ColorClass.brandDarkGreen
                                      : ColorClass.neutral500,
                                  size: 16,
                                ),
                              ),
                              title: Text(
                                user.name ?? 'Unknown User',
                                style:
                                    TextStyleClass.poppinsMedium(fontSize: 14),
                              ),
                              subtitle: user.department?.isNotEmpty == true
                                  ? Text(
                                      user.department!,
                                      style: TextStyleClass.poppinsRegular(
                                        fontSize: 12,
                                        color: ColorClass.neutral500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : null,
                              trailing: _isUpdating
                                  ? SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                ColorClass.brandDarkGreen),
                                      ),
                                    )
                                  : SizedBox(
                                      height: 28,
                                      child: ElevatedButton(
                                        onPressed: () => _updateUserRole(
                                            user.id!, user.role ?? 'user'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isDriver
                                              ? Colors.orange
                                              : ColorClass.brandDarkGreen,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 4),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          minimumSize: Size(0, 28),
                                        ),
                                        child: Text(
                                          isDriver ? 'Remove' : 'Make Driver',
                                          style: TextStyleClass.poppinsRegular(
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
