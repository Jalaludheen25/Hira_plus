import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';
import 'package:hira_plus/screens/manager_screen/provider/transportation_provider.dart';
import 'package:toastification/toastification.dart';

class AddRouteScreen extends StatefulWidget {
  const AddRouteScreen({Key? key}) : super(key: key);

  @override
  State<AddRouteScreen> createState() => _AddRouteScreenState();
}

class _AddRouteScreenState extends State<AddRouteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _routeNameController = TextEditingController();
  final _startLocationController = TextEditingController();
  final _endLocationController = TextEditingController();
  final _startKmController = TextEditingController();
  final _endKmController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedVehicleId;
  String? _selectedDriverId;
  String _selectedStatus = 'active';
  bool _isLoading = false;

  final List<String> _statusOptions = ['active', 'inactive', 'completed'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransportationProvider>(context, listen: false)
          .fetchAllData();
    });
  }

  @override
  void dispose() {
    _routeNameController.dispose();
    _startLocationController.dispose();
    _endLocationController.dispose();
    _startKmController.dispose();
    _endKmController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _addRoute() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedVehicleId == null) {
      toastification.show(
        context: context,
        title: Text('Please select a vehicle'),
        type: ToastificationType.error,
        autoCloseDuration: Duration(seconds: 3),
      );
      return;
    }

    if (_selectedDriverId == null) {
      toastification.show(
        context: context,
        title: Text('Please select a driver'),
        type: ToastificationType.error,
        autoCloseDuration: Duration(seconds: 3),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final routeData = {
      'user': _selectedDriverId,
      'vehicle': _selectedVehicleId,
      'fromLocation': _startLocationController.text.trim(),
      'toLocation': _endLocationController.text.trim(),
      'startKm': int.tryParse(_startKmController.text.trim()) ?? 0,
      'endKm': int.tryParse(_endKmController.text.trim()) ?? 0,
      'startTime': '08:00', // Default value, can be made configurable
      'endTime': '17:00', // Default value, can be made configurable
      'date': DateTime.now().toIso8601String().split('T')[0], // Today's date
      'description': _descriptionController.text.trim(),
    };

    try {
      final provider =
          Provider.of<TransportationProvider>(context, listen: false);
      final success = await provider.addRoute(routeData);

      if (success) {
        toastification.show(
          context: context,
          title: Text('Route added successfully'),
          type: ToastificationType.success,
          autoCloseDuration: Duration(seconds: 3),
        );
        Navigator.pop(context);
      } else {
        toastification.show(
          context: context,
          title: Text('Failed to add route'),
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
          'Add New Route',
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Route Name Field
                  Text(
                    'Route Name',
                    style: TextStyleClass.poppinsMedium(
                      fontSize: 16,
                      color: ColorClass.brandDarkGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _routeNameController,
                    decoration: InputDecoration(
                      hintText: 'Enter route name',
                      prefixIcon: Icon(LucideIcons.navigation,
                          color: ColorClass.neutral400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: ColorClass.neutral300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: ColorClass.brandDarkGreen),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter route name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Start Location Field
                  Text(
                    'Start Location',
                    style: TextStyleClass.poppinsMedium(
                      fontSize: 16,
                      color: ColorClass.brandDarkGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _startLocationController,
                    decoration: InputDecoration(
                      hintText: 'Enter start location',
                      prefixIcon: Icon(LucideIcons.mapPin,
                          color: ColorClass.neutral400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: ColorClass.neutral300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: ColorClass.brandDarkGreen),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter start location';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // End Location Field
                  Text(
                    'End Location',
                    style: TextStyleClass.poppinsMedium(
                      fontSize: 16,
                      color: ColorClass.brandDarkGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _endLocationController,
                    decoration: InputDecoration(
                      hintText: 'Enter end location',
                      prefixIcon:
                          Icon(LucideIcons.flag, color: ColorClass.neutral400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: ColorClass.neutral300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: ColorClass.brandDarkGreen),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter end location';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Start KM Field
                  Text(
                    'Start KM',
                    style: TextStyleClass.poppinsMedium(
                      fontSize: 16,
                      color: ColorClass.brandDarkGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _startKmController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter starting kilometer reading',
                      prefixIcon:
                          Icon(LucideIcons.gauge, color: ColorClass.neutral400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: ColorClass.neutral300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: ColorClass.brandDarkGreen),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter start KM';
                      }
                      if (int.tryParse(value.trim()) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // End KM Field
                  Text(
                    'End KM',
                    style: TextStyleClass.poppinsMedium(
                      fontSize: 16,
                      color: ColorClass.brandDarkGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _endKmController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter ending kilometer reading',
                      prefixIcon:
                          Icon(LucideIcons.gauge, color: ColorClass.neutral400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: ColorClass.neutral300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: ColorClass.brandDarkGreen),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter end KM';
                      }
                      if (int.tryParse(value.trim()) == null) {
                        return 'Please enter a valid number';
                      }
                      final startKm =
                          int.tryParse(_startKmController.text.trim()) ?? 0;
                      final endKm = int.tryParse(value.trim()) ?? 0;
                      if (endKm <= startKm) {
                        return 'End KM must be greater than Start KM';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Vehicle Selection
                  Text(
                    'Select Vehicle',
                    style: TextStyleClass.poppinsMedium(
                      fontSize: 16,
                      color: ColorClass.brandDarkGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value:
                        provider.vehicles.any((v) => v.id == _selectedVehicleId)
                            ? _selectedVehicleId
                            : null,
                    decoration: InputDecoration(
                      hintText: 'Choose a vehicle',
                      prefixIcon:
                          Icon(LucideIcons.car, color: ColorClass.neutral400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: ColorClass.neutral300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: ColorClass.brandDarkGreen),
                      ),
                    ),
                    items: provider.vehicles.map((vehicle) {
                      return DropdownMenuItem(
                        value: vehicle.id,
                        child: Text(
                            '${vehicle.vehicleName ?? 'Unknown'} (${vehicle.vehicleNumber ?? 'No Number'})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedVehicleId = value;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  // Driver Selection
                  Text(
                    'Select Driver',
                    style: TextStyleClass.poppinsMedium(
                      fontSize: 16,
                      color: ColorClass.brandDarkGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: provider.availableDrivers
                            .any((d) => d.id == _selectedDriverId)
                        ? _selectedDriverId
                        : null,
                    decoration: InputDecoration(
                      hintText: 'Choose a driver',
                      prefixIcon:
                          Icon(LucideIcons.user, color: ColorClass.neutral400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: ColorClass.neutral300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: ColorClass.brandDarkGreen),
                      ),
                    ),
                    items: provider.availableDrivers.map((driver) {
                      return DropdownMenuItem(
                        value: driver.id,
                        child: Text(
                            '${driver.name ?? 'Unknown'} (${driver.department ?? 'No Dept'})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDriverId = value;
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
                        borderSide:
                            BorderSide(color: ColorClass.brandDarkGreen),
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

                  const SizedBox(height: 20),

                  // Description Field
                  Text(
                    'Description (Optional)',
                    style: TextStyleClass.poppinsMedium(
                      fontSize: 16,
                      color: ColorClass.brandDarkGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Enter route description',
                      prefixIcon: Icon(LucideIcons.fileText,
                          color: ColorClass.neutral400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: ColorClass.neutral300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: ColorClass.brandDarkGreen),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Add Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _addRoute,
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
                              'Add Route',
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
      ),
    );
  }
}
