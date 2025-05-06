import 'package:flutter/material.dart';
import 'package:Hira_Plus/constants/color_class.dart';  
import 'package:Hira_Plus/constants/textstyle_class.dart';
import 'package:Hira_Plus/routes/app_routes.dart';
import 'package:Hira_Plus/utils/navigation_helper.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:Hira_Plus/providers/users_provider.dart';
import 'package:Hira_Plus/screens/manager_screen/widgets/user_edit_bottom_sheet.dart';
import 'package:Hira_Plus/screens/manager_screen/widgets/user_action_button.dart';
import 'package:Hira_Plus/screens/manager_screen/widgets/delete_confirm_dialog.dart';

class UsersListScreen extends StatelessWidget {
  static const String routeName = '/manager/users_list';
  static void push(BuildContext context) {
    navigatePRTo(context: context, route: Routes.usersList);
  }

  UsersListScreen({Key? key}) : super(key: key);

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return _UsersListView(searchController: _searchController);
  }
}

class _UsersListView extends StatefulWidget {
  final TextEditingController searchController;
  const _UsersListView({required this.searchController, Key? key}) : super(key: key);

  @override
  State<_UsersListView> createState() => _UsersListViewState();
}

class _UsersListViewState extends State<_UsersListView> {
  String _searchText = '';

  void _showEditUserSheet(BuildContext context, int index, UsersProvider provider, Map<String, String> user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return UserEditBottomSheet(
          initialName: user['name']!,
          initialUsername: user['username']!,
          onSave: (name, username) {
            provider.updateUser(index, name, username);
          },
        );
      },
    );
  }

  void _showDeleteUserDialog(BuildContext context, int index, UsersProvider provider) {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmDialog(
        title: 'Delete User',
        content: 'Are you sure you want to delete this user?',
        confirmText: 'Delete',
        cancelText: 'Cancel',
        onConfirm: () {
          provider.deleteUser(index);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UsersProvider>(
      builder: (context, provider, _) {
        final filteredUsers = _searchText.isEmpty
            ? provider.users
            : provider.searchUsers(_searchText);
        return Scaffold(
          backgroundColor: ColorClass.bgWhite0,
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 28, 16, 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: ColorClass.neutral100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: widget.searchController,
                    onChanged: (value) => setState(() => _searchText = value),
                    decoration: InputDecoration(
                      hintText: 'Search users',
                      hintStyle: TextStyleClass.poppinsRegular(fontSize: 16, color: ColorClass.neutral400),
                      border: InputBorder.none,
                      prefixIcon: const Icon(Icons.search, color: ColorClass.neutral400),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredUsers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    final realIndex = provider.users.indexOf(user);
                    return Container(
                      decoration: BoxDecoration(
                        color: ColorClass.bgWhite0,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                        title: Text(
                          user['name']!,
                          style: TextStyleClass.poppinsMedium(fontSize: 16, color: ColorClass.textMain900),
                        ),
                        subtitle: Text(
                          user['username']!,
                          style: TextStyleClass.poppinsRegular(fontSize: 14, color: ColorClass.neutral400),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            UserActionButton(
                              icon: LucideIcons.edit,
                              iconColor: ColorClass.textMain900,
                              backgroundColor: ColorClass.neutral100,
                              onTap: () => _showEditUserSheet(context, realIndex, provider, user),
                            ),
                            const SizedBox(width: 8),
                            UserActionButton(
                              icon: LucideIcons.trash,
                              iconColor: ColorClass.redDark,
                              backgroundColor: ColorClass.redLight,
                              onTap: () => _showDeleteUserDialog(context, realIndex, provider),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: MediaQuery.of(context).viewInsets.bottom == 0
              ? FloatingActionButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) => UserEditBottomSheet(
                        title: 'Add User',
                        initialName: '',
                        initialUsername: '',
                        onSave: (name, username) {
                          Provider.of<UsersProvider>(context, listen: false).addUser(name, username);
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