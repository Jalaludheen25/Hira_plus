import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';
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
  final Function(String name, String phoneNumber, String department,
      String designation, bool isVerified, bool isDeptHead) onSave;

  const UserEditBottomSheet({
    Key? key,
    this.title = 'Edit User',
    required this.initialName,
    required this.initialPhoneNumber,
    required this.initialDepartment,
    required this.initialDesignation,
    required this.initialIsVerified,
    required this.initialIsDeptHead,
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.title,
            style: TextStyleClass.poppinsSemiBold(
                fontSize: 20, color: ColorClass.textMain900),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              labelStyle: TextStyleClass.poppinsRegular(
                  fontSize: 14, color: ColorClass.neutral400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneNumberController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              labelStyle: TextStyleClass.poppinsRegular(
                  fontSize: 14, color: ColorClass.neutral400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
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
                  child: const Center(child: CupertinoActivityIndicator()),
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
                    (departments.isNotEmpty ? departments.first : null),
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
          const SizedBox(height: 16),
          TextField(
            controller: _designationController,
            decoration: InputDecoration(
              labelText: 'Designation',
              labelStyle: TextStyleClass.poppinsRegular(
                  fontSize: 14, color: ColorClass.neutral400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 24),
          CheckboxListTile(
            value: _isDeptHead,
            onChanged: (val) {
              setState(() {
                _isDeptHead = val ?? false;
              });
            },
            title: Text('Department Head',
                style: TextStyleClass.poppinsRegular(fontSize: 16)),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          ElevatedButton(
            onPressed: _isSaving ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorClass.brandDarkGreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isSaving
                ? const CupertinoActivityIndicator(color: Colors.white)
                : Text(
                    'Save',
                    style: TextStyleClass.poppinsMedium(
                        fontSize: 16, color: Colors.white),
                  ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
