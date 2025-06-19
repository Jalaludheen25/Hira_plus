import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';
import 'package:hira_plus/screens/manager_screen/models/users_list_model.dart';
import 'package:hira_plus/routes/app_routes.dart';
import 'package:hira_plus/utils/navigation_helper.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:hira_plus/screens/manager_screen/provider/users_provider.dart';
import 'package:hira_plus/screens/manager_screen/widgets/user_edit_bottom_sheet.dart';
import 'package:hira_plus/screens/manager_screen/widgets/user_action_button.dart';
import 'package:hira_plus/screens/manager_screen/widgets/delete_confirm_dialog.dart';

class UsersListScreen extends StatefulWidget {
  static const String routeName = '/manager/users_list';
  static void push(BuildContext context) {
    navigatePRTo(context: context, route: Routes.usersList);
  }

  const UsersListScreen({Key? key}) : super(key: key);

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    // Fetch users when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UsersProvider>(context, listen: false).fetchUsers();
    });
  }

  void _showEditUserSheet(
      BuildContext context, UsersListModel user, UsersProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return UserEditBottomSheet(
          initialName: user.name ?? '',
          initialPhoneNumber: user.phoneNumber ?? '',
          initialDepartment: user.department ?? '',
          initialDesignation: user.designation ?? '',
          initialIsVerified: user.isVerified == true,
          initialIsDeptHead: user.isDeptHead == true,
          onSave: (name, phoneNumber, department, designation, isVerified,
              isDeptHead) {
            provider.updateUser(user.id!, name, phoneNumber, department,
                designation, isVerified, isDeptHead);
          },
        );
      },
    );
  }

  void _showDeleteUserDialog(
      BuildContext context, String id, UsersProvider provider) {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmDialog(
        title: 'Delete User',
        content: 'Are you sure you want to delete this user?',
        confirmText: 'Delete',
        cancelText: 'Cancel',
        onConfirm: () {
          provider.deleteUser(id);
        },
      ),
    );
  }

  Widget _buildHeaderSection(UsersProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
      decoration: BoxDecoration(
        color: ColorClass.bgWhite0,
        boxShadow: [
          BoxShadow(
            color: ColorClass.neutral200.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Users Count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: ColorClass.brandDarkGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: ColorClass.brandDarkGreen.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.users,
                  color: ColorClass.brandDarkGreen,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Total Users: ${provider.totalUsersCount}',
                  style: TextStyleClass.poppinsMedium(
                    fontSize: 16,
                    color: ColorClass.brandDarkGreen,
                  ),
                ),
                const Spacer(),
                if (provider.selectedDepartment != null &&
                    provider.selectedDepartment != 'All')
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ColorClass.brandDarkGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${provider.filteredUsers.length} filtered',
                      style: TextStyleClass.poppinsRegular(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Department Filter Dropdown
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: ColorClass.neutral100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ColorClass.neutral300),
            ),
            child: DropdownButtonFormField<String>(
              value: provider.selectedDepartment,
              decoration: InputDecoration(
                hintText: 'Filter by Department',
                hintStyle: TextStyleClass.poppinsRegular(
                  fontSize: 14,
                  color: ColorClass.neutral400,
                ),
                prefixIcon: Icon(
                  LucideIcons.filter,
                  color: ColorClass.brandDarkGreen,
                  size: 18,
                ),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                DropdownMenuItem<String>(
                  value: 'All',
                  child: Text(
                    'All Departments',
                    style: TextStyleClass.poppinsRegular(
                      fontSize: 14,
                      color: ColorClass.textMain900,
                    ),
                  ),
                ),
                ...provider.availableDepartments.map((String department) {
                  return DropdownMenuItem<String>(
                    value: department,
                    child: Text(
                      department,
                      style: TextStyleClass.poppinsRegular(
                        fontSize: 14,
                        color: ColorClass.textMain900,
                      ),
                    ),
                  );
                }),
              ],
              onChanged: (String? newValue) {
                provider.setSelectedDepartment(newValue);
              },
            ),
          ),

          const SizedBox(height: 16),

          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: ColorClass.neutral100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchText = value),
              decoration: InputDecoration(
                hintText: 'Search users',
                hintStyle: TextStyleClass.poppinsRegular(
                    fontSize: 16, color: ColorClass.neutral400),
                border: InputBorder.none,
                prefixIcon:
                    const Icon(Icons.search, color: ColorClass.neutral400),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UsersProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading || provider.error != null) {
          return const Scaffold(
            body: Center(
              child: CupertinoActivityIndicator(),
            ),
          );
        }

        final filteredUsers = _searchText.isEmpty
            ? provider.filteredUsers
            : provider.searchUsers(_searchText);

        return Scaffold(
          backgroundColor: ColorClass.bgWhite0,
          body: Column(
            children: [
              _buildHeaderSection(provider),
              Expanded(
                child: ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredUsers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: ColorClass.bgWhite0,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: ColorClass.neutral200.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        title: Text(
                          user.name ?? 'No Name',
                          style: TextStyleClass.poppinsMedium(
                              fontSize: 16, color: ColorClass.textMain900),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.designation ?? 'No Designation',
                              style: TextStyleClass.poppinsRegular(
                                  fontSize: 14, color: ColorClass.neutral400),
                            ),
                            Text(
                              user.department ?? 'No Department',
                              style: TextStyleClass.poppinsRegular(
                                  fontSize: 14, color: ColorClass.neutral400),
                            ),
                            if (user.isDeptHead == true)
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: Row(
                                  children: [
                                    Icon(Icons.verified,
                                        color: ColorClass.brandDarkGreen,
                                        size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      'Head',
                                      style: TextStyleClass.poppinsBold(
                                          fontSize: 12,
                                          color: ColorClass.brandDarkGreen),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            UserActionButton(
                              icon: LucideIcons.edit,
                              iconColor: ColorClass.textMain900,
                              backgroundColor: ColorClass.neutral100,
                              onTap: () =>
                                  _showEditUserSheet(context, user, provider),
                            ),
                            const SizedBox(width: 8),
                            UserActionButton(
                              icon: LucideIcons.trash,
                              iconColor: ColorClass.redDark,
                              backgroundColor: ColorClass.redLight,
                              onTap: () => _showDeleteUserDialog(
                                  context, user.id!, provider),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 54,
              )
            ],
          ),
          floatingActionButton: MediaQuery.of(context).viewInsets.bottom == 0
              ? FloatingActionButton(
                  onPressed: () {
                    context.read<UsersProvider>().setTempIsVerified(false);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) => UserEditBottomSheet(
                        title: 'Add User',
                        initialName: '',
                        initialPhoneNumber: '',
                        initialDepartment: '',
                        initialDesignation: '',
                        initialIsVerified:
                            context.read<UsersProvider>().tempIsVerified,
                        initialIsDeptHead: false,
                        onSave: (name, phoneNumber, department, designation,
                            isVerified, isDeptHead) {
                          provider.addUser(name, phoneNumber, department,
                              designation, isVerified, isDeptHead);
                          context
                              .read<UsersProvider>()
                              .setTempIsVerified(false);
                        },
                      ),
                    );
                  },
                  backgroundColor: ColorClass.brandDarkGreen,
                  child: const Icon(Icons.add, color: Colors.white),
                )
              : null,
        );
      },
    );
  }
}
