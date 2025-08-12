import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';
import 'package:hira_plus/screens/manager_screen/provider/transportation_provider.dart';
import 'package:toastification/toastification.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({Key? key}) : super(key: key);

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleNameController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _vehicleNameController.dispose();
    _vehicleNumberController.dispose();
    super.dispose();
  }

  Future<void> _addVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final vehicleData = {
      'vehicleName': _vehicleNameController.text.trim(),
      'vehicleNumber': _vehicleNumberController.text.trim(),
    };

    try {
      final provider =
          Provider.of<TransportationProvider>(context, listen: false);
      final success = await provider.addVehicle(vehicleData);

      if (success) {
        toastification.show(
          context: context,
          title: Text('Vehicle added successfully'),
          type: ToastificationType.success,
          autoCloseDuration: Duration(seconds: 3),
        );
        Navigator.pop(context);
      } else {
        toastification.show(
          context: context,
          title: Text('Failed to add vehicle'),
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
          'Add Vehicle',
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
              // Vehicle Name Field
              Text(
                'Vehicle Name',
                style: TextStyleClass.poppinsMedium(
                  fontSize: 16,
                  color: ColorClass.brandDarkGreen,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _vehicleNameController,
                decoration: InputDecoration(
                  hintText: 'Enter vehicle name',
                  prefixIcon:
                      Icon(LucideIcons.car, color: ColorClass.neutral400),
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
                    return 'Please enter vehicle name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Vehicle Number Field
              Text(
                'Vehicle Number',
                style: TextStyleClass.poppinsMedium(
                  fontSize: 16,
                  color: ColorClass.brandDarkGreen,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _vehicleNumberController,
                decoration: InputDecoration(
                  hintText: 'Enter vehicle number',
                  prefixIcon:
                      Icon(LucideIcons.hash, color: ColorClass.neutral400),
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
                    return 'Please enter vehicle number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 40),

              // Add Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addVehicle,
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
                          'Add Vehicle',
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
