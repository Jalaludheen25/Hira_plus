import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';
import 'package:hira_plus/screens/manager_screen/provider/transportation_provider.dart';
import 'package:toastification/toastification.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({Key? key}) : super(key: key);

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _departmentController = TextEditingController();
  final _designationController = TextEditingController();

  String _selectedRole = 'user';
  String _selectedStatus = 'active';
  bool _isDeptHead = false;
  bool _isFreeFood = false;
  bool _isIntern = false;
  bool _isLoading = false;

  final List<String> _roles = ['user', 'driver'];
  final List<String> _statusOptions = ['active', 'inactive'];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _designationController.dispose();
    super.dispose();
  }

  Future<void> _addUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider =
          Provider.of<TransportationProvider>(context, listen: false);
      final newUser = await provider.addUser(
        phoneNumber: _phoneController.text.trim(),
        name: _nameController.text.trim(),
        department: _departmentController.text.trim(),
        designation: _designationController.text.trim(),
        isDeptHead: _isDeptHead,
        status: _selectedStatus,
        isFreeFood: _isFreeFood,
        isIntern: _isIntern,
        role: _selectedRole,
      );

      if (newUser != null) {
        toastification.show(
          context: context,
          title: Text('User added successfully'),
          description:
              Text('${newUser.name} has been added as ${newUser.role}'),
          type: ToastificationType.success,
          autoCloseDuration: Duration(seconds: 3),
        );
        Navigator.pop(context);
      } else {
        toastification.show(
          context: context,
          title: Text('Failed to add user'),
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
        _isLoading = false;
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
          'Add New User',
          style: TextStyleClass.poppinsSemiBold(
            fontSize: 20,
            color: ColorClass.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name Field
              Text(
                'Full Name',
                style: TextStyleClass.poppinsMedium(
                  fontSize: 16,
                  color: ColorClass.brandDarkGreen,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter full name',
                  prefixIcon:
                      Icon(LucideIcons.user, color: ColorClass.neutral400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ColorClass.neutral300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ColorClass.brandDarkGreen),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter full name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Phone Number Field
              Text(
                'Phone Number',
                style: TextStyleClass.poppinsMedium(
                  fontSize: 16,
                  color: ColorClass.brandDarkGreen,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Enter phone number',
                  prefixIcon:
                      Icon(LucideIcons.phone, color: ColorClass.neutral400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ColorClass.neutral300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ColorClass.brandDarkGreen),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter phone number';
                  }
                  if (value.trim().length < 10) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Department Field
              Text(
                'Department',
                style: TextStyleClass.poppinsMedium(
                  fontSize: 16,
                  color: ColorClass.brandDarkGreen,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _departmentController,
                decoration: InputDecoration(
                  hintText: 'Enter department',
                  prefixIcon:
                      Icon(LucideIcons.building, color: ColorClass.neutral400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ColorClass.neutral300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ColorClass.brandDarkGreen),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter department';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Designation Field
              Text(
                'Designation',
                style: TextStyleClass.poppinsMedium(
                  fontSize: 16,
                  color: ColorClass.brandDarkGreen,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _designationController,
                decoration: InputDecoration(
                  hintText: 'Enter designation',
                  prefixIcon:
                      Icon(LucideIcons.briefcase, color: ColorClass.neutral400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ColorClass.neutral300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ColorClass.brandDarkGreen),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter designation';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Role Dropdown
              Text(
                'Role',
                style: TextStyleClass.poppinsMedium(
                  fontSize: 16,
                  color: ColorClass.brandDarkGreen,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(
                  prefixIcon:
                      Icon(LucideIcons.userCheck, color: ColorClass.neutral400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ColorClass.neutral300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ColorClass.brandDarkGreen),
                  ),
                ),
                items: _roles.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Status Dropdown
              Text(
                'Status',
                style: TextStyleClass.poppinsMedium(
                  fontSize: 16,
                  color: ColorClass.brandDarkGreen,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  prefixIcon: Icon(LucideIcons.checkCircle,
                      color: ColorClass.neutral400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ColorClass.neutral300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ColorClass.brandDarkGreen),
                  ),
                ),
                items: _statusOptions.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Additional Options
              Text(
                'Additional Options',
                style: TextStyleClass.poppinsMedium(
                  fontSize: 16,
                  color: ColorClass.brandDarkGreen,
                ),
              ),
              const SizedBox(height: 12),

              // Department Head Switch
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColorClass.neutral200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Department Head',
                          style: TextStyleClass.poppinsMedium(fontSize: 14),
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

              const SizedBox(height: 12),

              // Free Food Switch
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColorClass.neutral200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Free Food',
                          style: TextStyleClass.poppinsMedium(fontSize: 14),
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

              const SizedBox(height: 12),

              // Intern Switch
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColorClass.neutral200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Intern',
                          style: TextStyleClass.poppinsMedium(fontSize: 14),
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

              const SizedBox(height: 40),

              // Add Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorClass.brandDarkGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Add User',
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
      ),
    );
  }
}
