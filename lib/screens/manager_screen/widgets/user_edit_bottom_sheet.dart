import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';
import 'package:hira_plus/constants/user_role_enum.dart';
import 'package:hira_plus/screens/manager_screen/provider/users_provider.dart';
import 'package:hira_plus/screens/manager_screen/provider/department_provider.dart';
import 'package:provider/provider.dart';

class UserEditBottomSheet extends StatefulWidget {
  final String title;
  final String initialName;
  final String initialPhoneNumber;
  final String initialDepartment;
  final String initialDesignation;
  final bool initialIsVerified;
  final bool initialIsDeptHead;
  final UserRole? initialRole;
  final String? initialStatus;
  final bool initialIsFreeFood;
  final bool initialIsIntern;
  final Function(
      String name,
      String phoneNumber,
      String department,
      String designation,
      bool isVerified,
      bool isDeptHead,
      UserRole? role,
      String status,
      bool isFreeFood,
      bool isIntern) onSave;

  const UserEditBottomSheet({
    Key? key,
    this.title = 'Edit User',
    required this.initialName,
    required this.initialPhoneNumber,
    required this.initialDepartment,
    required this.initialDesignation,
    required this.initialIsVerified,
    required this.initialIsDeptHead,
    required this.initialRole,
    this.initialStatus,
    required this.initialIsFreeFood,
    required this.initialIsIntern,
    required this.onSave,
  }) : super(key: key);

  @override
  State<UserEditBottomSheet> createState() => _UserEditBottomSheetState();
}

class _UserEditBottomSheetState extends State<UserEditBottomSheet> {
  late TextEditingController _nameController;
  late TextEditingController _phoneNumberController;
  String? _selectedDepartment;
  late TextEditingController _designationController;
  bool _isSaving = false;
  bool _isDeptHead = false;
  UserRole? _selectedRole;
  String _selectedStatus = 'active';
  bool _isFreeFood = false;
  bool _isIntern = false;

  final List<String> _statusOptions = ['active', 'inactive'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _phoneNumberController =
        TextEditingController(text: widget.initialPhoneNumber);
    _selectedDepartment =
        widget.initialDepartment.isNotEmpty ? widget.initialDepartment : null;
    _designationController =
        TextEditingController(text: widget.initialDesignation);
    _isDeptHead = widget.initialIsDeptHead;
    _selectedRole = widget.initialRole;
    _selectedStatus = widget.initialStatus ?? 'active';
    _isFreeFood = widget.initialIsFreeFood;
    _isIntern = widget.initialIsIntern;

    // Load departments after the first frame to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final deptProvider = context.read<DepartmentProvider>();
      if (deptProvider.departments.isEmpty && !deptProvider.isLoading) {
        deptProvider.fetchDepartments(context);
      }
      // If no initial department provided, default to provider's first item
      if (_selectedDepartment == null && deptProvider.departments.isNotEmpty) {
        if (mounted) {
          setState(() {
            _selectedDepartment = deptProvider.departments.first;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    _designationController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    try {
      final result = widget.onSave(
        _nameController.text,
        _phoneNumberController.text,
        _selectedDepartment ?? '',
        _designationController.text,
        context.read<UsersProvider>().tempIsVerified,
        _isDeptHead,
        _selectedRole,
        _selectedStatus,
        _isFreeFood,
        _isIntern,
      );
      if (result is Future) {
        await result;
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      // Optionally handle error
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ColorClass.neutral100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorClass.neutral200),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: ColorClass.brandDarkGreen, size: 20),
          labelStyle: TextStyleClass.poppinsMedium(
            fontSize: 14,
            color: ColorClass.textSub500,
          ),
          hintStyle: TextStyleClass.poppinsRegular(
            fontSize: 14,
            color: ColorClass.neutral400,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
    required String label,
    required IconData icon,
    String? hint,
    double? maxHeight,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ColorClass.neutral100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorClass.neutral200),
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: ColorClass.brandDarkGreen, size: 20),
          labelStyle: TextStyleClass.poppinsMedium(
            fontSize: 14,
            color: ColorClass.textSub500,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
        menuMaxHeight: maxHeight,
        items: items,
        onChanged: onChanged,
        dropdownColor: ColorClass.bgWhite0,
        borderRadius: BorderRadius.circular(12),
        style: TextStyleClass.poppinsRegular(
          fontSize: 14,
          color: ColorClass.textMain900,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height *
            0.85, // Limit to 85% of screen height
      ),
      decoration: const BoxDecoration(
        color: ColorClass.bgWhite0,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: ColorClass.boxShadow,
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Fixed header with handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ColorClass.neutral300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorClass.brandDarkGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.edit,
                    color: ColorClass.brandDarkGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.title,
                  style: TextStyleClass.poppinsSemiBold(
                      fontSize: 22, color: ColorClass.textMain900),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                      hint: 'Enter full name',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _phoneNumberController,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      hint: 'Enter phone number',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    Consumer<DepartmentProvider>(
                      builder: (context, deptProvider, _) {
                        if (deptProvider.isLoading) {
                          return Container(
                            height: 56,
                            decoration: BoxDecoration(
                              border: Border.all(color: ColorClass.neutral300),
                              borderRadius: BorderRadius.circular(8),
                              color: ColorClass.neutral100,
                            ),
                            child: const Center(
                                child: CupertinoActivityIndicator()),
                          );
                        }

                        if (deptProvider.error != null) {
                          return Text(
                            deptProvider.error!,
                            style: TextStyleClass.poppinsRegular(
                                fontSize: 14, color: ColorClass.redBase),
                          );
                        }

                        final departments = deptProvider.departments;

                        return DropdownButtonFormField<String>(
                          value: _selectedDepartment ??
                              (departments.isNotEmpty
                                  ? departments.first
                                  : null),
                          decoration: InputDecoration(
                            labelText: 'Select Department',
                            labelStyle: TextStyleClass.poppinsRegular(
                                fontSize: 14, color: ColorClass.neutral400),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: ColorClass.neutral100,
                          ),
                          menuMaxHeight: 200, // Limit dropdown height
                          items: departments
                              .map((dept) => DropdownMenuItem<String>(
                                    value: dept,
                                    child: Text(dept),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedDepartment = val;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a department';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<UserRole?>(
                      value: _selectedRole,
                      decoration: InputDecoration(
                        labelText: 'User Role (Optional)',
                        labelStyle: TextStyleClass.poppinsRegular(
                            fontSize: 14, color: ColorClass.neutral400),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: ColorClass.neutral100,
                      ),
                      items: [
                        ...UserRole.allRoles
                            .map((role) => DropdownMenuItem<UserRole?>(
                                  value: role,
                                  child: Text(
                                    role.displayName,
                                    style: TextStyleClass.poppinsRegular(
                                      fontSize: 14,
                                      color: ColorClass.textMain900,
                                    ),
                                  ),
                                )),
                      ],
                      onChanged: (UserRole? newRole) {
                        setState(() {
                          _selectedRole = newRole;
                        });
                        debugPrint(
                            '[UserEditBottomSheet] Role changed to: ${newRole?.displayName ?? 'No Role'}');
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _designationController,
                      label: 'Designation',
                      icon: Icons.work_outline,
                      hint: 'Enter designation',
                    ),
                    const SizedBox(height: 12),

                    // Status Dropdown
                    _buildDropdown<String>(
                      value: _selectedStatus,
                      label: 'User Status',
                      icon: Icons.check_circle_outline,
                      hint: 'Select status',
                      items: _statusOptions.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyleClass.poppinsMedium(
                              fontSize: 14,
                              color: ColorClass.textMain900,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Additional Options Section
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 3,
                            height: 20,
                            decoration: BoxDecoration(
                              color: ColorClass.brandDarkGreen,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Additional Options',
                            style: TextStyleClass.poppinsSemiBold(
                              fontSize: 16,
                              color: ColorClass.brandDarkGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Department Head Switch
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ColorClass.bgWhite0,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: ColorClass.neutral200),
                        boxShadow: [
                          BoxShadow(
                            color: ColorClass.neutral200.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Department Head',
                                style:
                                    TextStyleClass.poppinsMedium(fontSize: 14),
                              ),
                              Text(
                                'Is this user a department head?',
                                style: TextStyleClass.poppinsRegular(
                                  fontSize: 12,
                                  color: ColorClass.neutral500,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: _isDeptHead,
                            onChanged: (value) {
                              setState(() {
                                _isDeptHead = value;
                              });
                            },
                            activeColor: ColorClass.brandDarkGreen,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Free Food Switch
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ColorClass.bgWhite0,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: ColorClass.neutral200),
                        boxShadow: [
                          BoxShadow(
                            color: ColorClass.neutral200.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Free Food',
                                style:
                                    TextStyleClass.poppinsMedium(fontSize: 14),
                              ),
                              Text(
                                'Does this user get free food?',
                                style: TextStyleClass.poppinsRegular(
                                  fontSize: 12,
                                  color: ColorClass.neutral500,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: _isFreeFood,
                            onChanged: (value) {
                              setState(() {
                                _isFreeFood = value;
                              });
                            },
                            activeColor: ColorClass.brandDarkGreen,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Intern Switch
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ColorClass.bgWhite0,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: ColorClass.neutral200),
                        boxShadow: [
                          BoxShadow(
                            color: ColorClass.neutral200.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Intern',
                                style:
                                    TextStyleClass.poppinsMedium(fontSize: 14),
                              ),
                              Text(
                                'Is this user an intern?',
                                style: TextStyleClass.poppinsRegular(
                                  fontSize: 12,
                                  color: ColorClass.neutral500,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: _isIntern,
                            onChanged: (value) {
                              setState(() {
                                _isIntern = value;
                              });
                            },
                            activeColor: ColorClass.brandDarkGreen,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Fixed save button at bottom
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ColorClass.brandDarkGreen,
                    ColorClass.brandGreen,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: ColorClass.brandDarkGreen.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isSaving ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSaving
                    ? const CupertinoActivityIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.save_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Save Changes',
                            style: TextStyleClass.poppinsSemiBold(
                                fontSize: 16, color: Colors.white),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
