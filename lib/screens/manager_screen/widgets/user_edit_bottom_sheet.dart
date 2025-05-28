import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';
import 'package:hira_plus/screens/manager_screen/provider/users_provider.dart';
import 'package:provider/provider.dart';

class UserEditBottomSheet extends StatefulWidget {
  final String title;
  final String initialName;
  final String initialPhoneNumber;
  final String initialDepartment;
  final String initialDesignation;
  final bool initialIsVerified;
  final bool initialIsDeptHead;
  final Function(String name, String phoneNumber, String department, String designation, bool isVerified, bool isDeptHead) onSave;

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
  late TextEditingController _departmentController;
  late TextEditingController _designationController;
  bool _isSaving = false;
  bool _isDeptHead = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _phoneNumberController = TextEditingController(text: widget.initialPhoneNumber);
    _departmentController = TextEditingController(text: widget.initialDepartment);
    _designationController = TextEditingController(text: widget.initialDesignation);
    _isDeptHead = widget.initialIsDeptHead;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    _departmentController.dispose();
    _designationController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    try {
      final result = widget.onSave(
        _nameController.text,
        _phoneNumberController.text,
        _departmentController.text,
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
            style: TextStyleClass.poppinsSemiBold(fontSize: 20, color: ColorClass.textMain900),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              labelStyle: TextStyleClass.poppinsRegular(fontSize: 14, color: ColorClass.neutral400),
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
              labelStyle: TextStyleClass.poppinsRegular(fontSize: 14, color: ColorClass.neutral400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _departmentController,
            decoration: InputDecoration(
              labelText: 'Department',
              labelStyle: TextStyleClass.poppinsRegular(fontSize: 14, color: ColorClass.neutral400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _designationController,
            decoration: InputDecoration(
              labelText: 'Designation',
              labelStyle: TextStyleClass.poppinsRegular(fontSize: 14, color: ColorClass.neutral400),
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
            title: Text('Department Head', style: TextStyleClass.poppinsRegular(fontSize: 16)),
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
                    style: TextStyleClass.poppinsMedium(fontSize: 16, color: Colors.white),
                  ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
