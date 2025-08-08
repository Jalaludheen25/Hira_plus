import 'package:flutter/material.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:hira_plus/screens/driver_screen/provider/driver_provider.dart';
import 'package:hira_plus/screens/driver_screen/vehicles/provider/vehicle_provider.dart';
import 'package:hira_plus/screens/driver_screen/vehicles/model/vehicle_model.dart'
    as VehicleModel;
import 'package:hira_plus/screens/driver_screen/model/driver_route_model.dart';
import 'package:intl/intl.dart';
import 'package:hira_plus/utils/shared_utils.dart';

class DriverRideReport extends StatefulWidget {
  const DriverRideReport({super.key});

  @override
  State<DriverRideReport> createState() => _DriverRideReportState();
}

class _DriverRideReportState extends State<DriverRideReport>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showAddRideForm = false;

  // Form controllers
  final TextEditingController _startKmController = TextEditingController();
  final TextEditingController _endKmController = TextEditingController();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  VehicleModel.Vehicle? _selectedVehicle;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Fetch trips and vehicles when the widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final driverProvider =
          Provider.of<DriverProvider>(context, listen: false);
      final vehicleProvider =
          Provider.of<VehicleProvider>(context, listen: false);

      driverProvider.fetchTrips();
      vehicleProvider.loadVehicles();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _startKmController.dispose();
    _endKmController.dispose();
    _fromController.dispose();
    _toController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: ColorClass.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Driver Ride Report',
                          style: TextStyleClass.poppinsBold(
                            fontSize: 20,
                            color: ColorClass.brandDarkGreen,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 28),
                          onPressed: () => Navigator.pop(context),
                          color: ColorClass.brandDarkGreen,
                        ),
                      ],
                    ),
                  ),

                  // TabBar
                  Container(
                    color: ColorClass.brandDarkGreen,
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: ColorClass.white,
                      indicatorWeight: 3,
                      labelColor: ColorClass.white,
                      unselectedLabelColor: ColorClass.white.withOpacity(0.7),
                      labelStyle: TextStyleClass.poppinsSemiBold(fontSize: 16),
                      unselectedLabelStyle:
                          TextStyleClass.poppinsMedium(fontSize: 16),
                      tabs: const [
                        Tab(text: 'Upcoming'),
                        Tab(text: 'Recent'),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: _showAddRideForm
                        ? _buildAddRideForm()
                        : TabBarView(
                            controller: _tabController,
                            children: [
                              _buildUpcomingRides(),
                              _buildRecentRides(),
                            ],
                          ),
                  ),
                ],
              ),

              // Floating Action Button (only show when not in form mode)
              if (!_showAddRideForm)
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        _showAddRideForm = true;
                        _clearForm();
                      });
                    },
                    backgroundColor: ColorClass.brandDarkGreen,
                    child: const Icon(
                      Icons.add,
                      color: ColorClass.white,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUpcomingRides() {
    return Consumer<DriverProvider>(
      builder: (context, provider, child) {
        debugPrint(
            'Building upcoming rides. Loading: ${provider.isLoading}, Trips: ${provider.trips.length}');

        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final now = DateTime.now();
        debugPrint('Current time: $now');

        final upcomingTrips = provider.trips.where((trip) {
          final tripStartDateTime = _parseTimeString(trip.startTime, trip.date);

          if (tripStartDateTime == null) {
            debugPrint('Could not parse start time: ${trip.startTime}');
            return false;
          }

          // If trip has end time, check if current time is before end time
          if (trip.endTime.isNotEmpty) {
            final tripEndDateTime = _parseTimeString(trip.endTime, trip.date);
            if (tripEndDateTime != null) {
              // Show in upcoming if current time is before end time
              return tripEndDateTime.isAfter(now);
            }
          }

          // If no end time, show if it's today and start time hasn't passed
          return trip.date.year == now.year &&
              trip.date.month == now.month &&
              trip.date.day == now.day &&
              tripStartDateTime.isAfter(now);
        }).toList();

        debugPrint('Upcoming trips found: ${upcomingTrips.length}');

        // Sort by date and time (earliest first)
        upcomingTrips.sort((a, b) {
          final aDateTime = _parseTimeString(a.startTime, a.date);
          final bDateTime = _parseTimeString(b.startTime, b.date);

          if (aDateTime == null || bDateTime == null) {
            return a.date.compareTo(b.date);
          }

          return aDateTime.compareTo(bDateTime);
        });

        if (upcomingTrips.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.calendar,
                  size: 48,
                  color: ColorClass.neutral400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No upcoming or live rides',
                  style: TextStyleClass.poppinsMedium(
                    fontSize: 16,
                    color: ColorClass.neutral500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: upcomingTrips.length,
          itemBuilder: (context, index) {
            final trip = upcomingTrips[index];
            return _buildRideCard(trip, isUpcoming: true);
          },
        );
      },
    );
  }

  Widget _buildRecentRides() {
    return Consumer<DriverProvider>(
      builder: (context, provider, child) {
        debugPrint(
            'Building recent rides. Loading: ${provider.isLoading}, Trips: ${provider.trips.length}');

        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final now = DateTime.now();
        final recentTrips = provider.trips.where((trip) {
          final tripStartDateTime = _parseTimeString(trip.startTime, trip.date);

          if (tripStartDateTime == null) {
            debugPrint('Could not parse start time: ${trip.startTime}');
            return false;
          }

          // If trip has end time, check if current time is after end time
          if (trip.endTime.isNotEmpty) {
            final tripEndDateTime = _parseTimeString(trip.endTime, trip.date);
            if (tripEndDateTime != null) {
              // Show in recent if current time is after end time
              return tripEndDateTime.isBefore(now);
            }
          }

          // If no end time, check if start time has passed
          return tripStartDateTime.isBefore(now);
        }).toList();

        debugPrint('Recent trips found: ${recentTrips.length}');

        // Sort by date and time (latest first)
        recentTrips.sort((a, b) {
          final aDateTime = _parseTimeString(a.startTime, a.date);
          final bDateTime = _parseTimeString(b.startTime, b.date);

          if (aDateTime == null || bDateTime == null) {
            return b.date.compareTo(a.date);
          }

          return bDateTime.compareTo(aDateTime);
        });

        if (recentTrips.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.history,
                  size: 48,
                  color: ColorClass.neutral400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No completed rides',
                  style: TextStyleClass.poppinsMedium(
                    fontSize: 16,
                    color: ColorClass.neutral500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: recentTrips.length,
          itemBuilder: (context, index) {
            final trip = recentTrips[index];
            return _buildRideCard(trip, isUpcoming: false);
          },
        );
      },
    );
  }

  Widget _buildAddRideForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _showAddRideForm = false;
                    _clearForm();
                  });
                },
                icon: const Icon(Icons.arrow_back),
                color: ColorClass.brandDarkGreen,
              ),
              Text(
                'Add New Ride',
                style: TextStyleClass.poppinsBold(
                  fontSize: 18,
                  color: ColorClass.brandDarkGreen,
                ),
              ),
              SizedBox(width: 50),
            ],
          ),
          const SizedBox(height: 20),

          // Vehicle Dropdown
          _buildVehicleDropdown(),
          const SizedBox(height: 16),

          // Start KM
          _buildTextField(
            label: 'Starting KM',
            controller: _startKmController,
            icon: LucideIcons.gauge,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),

          // Date and Time
          Row(
            children: [
              Expanded(
                child: _buildDateField(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimeField(label: 'Start Time', isStartTime: true),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // End Time
          _buildTimeField(label: 'End Time', isStartTime: false),
          const SizedBox(height: 16),

          // From Location
          _buildTextField(
            label: 'From',
            controller: _fromController,
            icon: LucideIcons.mapPin,
          ),
          const SizedBox(height: 16),

          // To Location
          _buildTextField(
            label: 'To',
            controller: _toController,
            icon: LucideIcons.mapPin,
          ),
          const SizedBox(height: 16),

          // Description
          _buildTextField(
            label: 'Description',
            controller: _descriptionController,
            icon: LucideIcons.fileText,
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          // End KM
          _buildTextField(
            label: 'Ending KM',
            controller: _endKmController,
            icon: LucideIcons.gauge,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _showAddRideForm = false;
                      _clearForm();
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: ColorClass.brandDarkGreen),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyleClass.poppinsSemiBold(
                      fontSize: 16,
                      color: ColorClass.brandDarkGreen,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveRide,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorClass.brandDarkGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Save Ride',
                    style: TextStyleClass.poppinsSemiBold(
                      fontSize: 16,
                      color: ColorClass.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleDropdown() {
    return Consumer<VehicleProvider>(
      builder: (context, vehicleProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  LucideIcons.car,
                  color: ColorClass.brandDarkGreen,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Vehicle',
                  style: TextStyleClass.poppinsSemiBold(
                    fontSize: 16,
                    color: ColorClass.brandDarkGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: ColorClass.brandLightGreen,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: vehicleProvider.isLoading
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                ColorClass.brandDarkGreen,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Loading vehicles...',
                            style: TextStyleClass.poppinsRegular(
                              fontSize: 14,
                              color: ColorClass.neutral500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : DropdownButtonFormField<VehicleModel.Vehicle>(
                      value: _selectedVehicle,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      hint: Text(
                        vehicleProvider.vehicles.isEmpty
                            ? 'No vehicles available'
                            : 'Select Vehicle',
                        style: TextStyleClass.poppinsRegular(
                          fontSize: 14,
                          color: ColorClass.neutral500,
                        ),
                      ),
                      items: vehicleProvider.vehicles
                          .map((VehicleModel.Vehicle vehicle) {
                        return DropdownMenuItem<VehicleModel.Vehicle>(
                          value: vehicle,
                          child: Text(
                            vehicle.displayName,
                            style: TextStyleClass.poppinsRegular(
                              fontSize: 14,
                              color: ColorClass.brandDarkGreen,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: vehicleProvider.vehicles.isEmpty
                          ? null
                          : (VehicleModel.Vehicle? value) {
                              setState(() {
                                _selectedVehicle = value;
                              });
                            },
                      icon: Icon(
                        LucideIcons.chevronDown,
                        color: ColorClass.brandDarkGreen,
                      ),
                      dropdownColor: ColorClass.white,
                    ),
            ),
            if (vehicleProvider.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  vehicleProvider.errorMessage!,
                  style: TextStyleClass.poppinsRegular(
                    fontSize: 12,
                    color: ColorClass.orangeDark,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: ColorClass.brandDarkGreen,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyleClass.poppinsSemiBold(
                fontSize: 16,
                color: ColorClass.brandDarkGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: ColorClass.brandLightGreen,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            style: TextStyleClass.poppinsRegular(
              fontSize: 14,
              color: ColorClass.brandDarkGreen,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              LucideIcons.calendar,
              color: ColorClass.brandDarkGreen,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Date',
              style: TextStyleClass.poppinsSemiBold(
                fontSize: 16,
                color: ColorClass.brandDarkGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: ColorClass.brandLightGreen,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(
              _selectedDate != null
                  ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                  : 'Select Date',
              style: TextStyleClass.poppinsRegular(
                fontSize: 14,
                color: _selectedDate != null
                    ? ColorClass.brandDarkGreen
                    : ColorClass.neutral500,
              ),
            ),
            trailing: const Icon(
              LucideIcons.calendar,
              color: ColorClass.brandDarkGreen,
            ),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() {
                  _selectedDate = date;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField({required String label, required bool isStartTime}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              LucideIcons.clock,
              color: ColorClass.brandDarkGreen,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyleClass.poppinsSemiBold(
                fontSize: 16,
                color: ColorClass.brandDarkGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: ColorClass.brandLightGreen,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(
              isStartTime
                  ? _selectedStartTime != null
                      ? _selectedStartTime!.format(context)
                      : 'Select Time'
                  : _selectedEndTime != null
                      ? _selectedEndTime!.format(context)
                      : 'Select Time',
              style: TextStyleClass.poppinsRegular(
                fontSize: 14,
                color: isStartTime
                    ? _selectedStartTime != null
                        ? ColorClass.brandDarkGreen
                        : ColorClass.neutral500
                    : _selectedEndTime != null
                        ? ColorClass.brandDarkGreen
                        : ColorClass.neutral500,
              ),
            ),
            trailing: const Icon(
              LucideIcons.clock,
              color: ColorClass.brandDarkGreen,
            ),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: isStartTime
                    ? _selectedStartTime ?? TimeOfDay.now()
                    : _selectedEndTime ?? TimeOfDay.now(),
              );
              if (time != null) {
                setState(() {
                  if (isStartTime) {
                    _selectedStartTime = time;
                  } else {
                    _selectedEndTime = time;
                  }
                });
              }
            },
          ),
        ),
      ],
    );
  }

  bool _validateForm() {
    return _selectedVehicle != null &&
        _startKmController.text.isNotEmpty &&
        _endKmController.text.isNotEmpty &&
        _selectedDate != null &&
        _selectedStartTime != null &&
        _selectedEndTime != null &&
        _fromController.text.isNotEmpty &&
        _toController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty;
  }

  void _clearForm() {
    _selectedVehicle = null;
    _startKmController.clear();
    _endKmController.clear();
    _fromController.clear();
    _toController.clear();
    _descriptionController.clear();
    _selectedDate = null;
    _selectedStartTime = null;
    _selectedEndTime = null;
  }

  void _saveRide() async {
    debugPrint('=== SAVE RIDE STARTED ===');

    if (!_validateForm()) {
      debugPrint('Form validation failed');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill all required fields'),
          backgroundColor: ColorClass.orangeDark,
        ),
      );
      return;
    }

    debugPrint('Form validation passed');

    try {
      final provider = Provider.of<DriverProvider>(context, listen: false);

      // Debug: Print form data
      debugPrint('=== FORM DATA ===');
      debugPrint('Vehicle: ${_selectedVehicle?.displayName}');
      debugPrint('Start KM: ${_startKmController.text}');
      debugPrint('End KM: ${_endKmController.text}');
      debugPrint('Date: $_selectedDate');
      debugPrint('Start Time: $_selectedStartTime');
      debugPrint('End Time: $_selectedEndTime');
      debugPrint('From: $_fromController.text');
      debugPrint('To: $_toController.text');
      debugPrint('Description: ${_descriptionController.text}');

      // Create TripModel
      final trip = TripModel(
        id: '', // Will be assigned by backend
        user: '', // Will be set by provider from SharedPreferences
        vehicle: Vehicle(
          id: _selectedVehicle!.id,
          vehicleName: _selectedVehicle!.vehicleName,
          vehicleNumber: _selectedVehicle!.vehicleNumber,
        ),
        fromLocation: _fromController.text,
        toLocation: _toController.text,
        startKm: int.parse(_startKmController.text),
        endKm: int.parse(_endKmController.text),
        startTime:
            '${_selectedStartTime!.hour.toString().padLeft(2, '0')}:${_selectedStartTime!.minute.toString().padLeft(2, '0')}',
        endTime:
            '${_selectedEndTime!.hour.toString().padLeft(2, '0')}:${_selectedEndTime!.minute.toString().padLeft(2, '0')}',
        date: _selectedDate!,
        description: _descriptionController.text,
      );

      debugPrint('=== CREATED TRIP MODEL ===');
      debugPrint('User: ${trip.user}');
      debugPrint('Vehicle ID: ${trip.vehicle.id}');
      debugPrint('Vehicle Name: ${trip.vehicle.vehicleName}');
      debugPrint('From: ${trip.fromLocation}');
      debugPrint('To: ${trip.toLocation}');
      debugPrint('Start KM: ${trip.startKm}');
      debugPrint('End KM: ${trip.endKm}');
      debugPrint('Start Time: ${trip.startTime}');
      debugPrint('End Time: ${trip.endTime}');
      debugPrint('Date: ${trip.date}');
      debugPrint('Description: ${trip.description}');

      // Get token from SharedPreferences
      final token = await SharedUtils.getString('auth_token');
      debugPrint('Token: $token');

      debugPrint('=== CALLING POST TRIP ===');
      final success = await provider.postTrip(trip, token);
      debugPrint('Post trip result: $success');

      if (success) {
        debugPrint('Ride saved successfully!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Ride saved successfully!'),
            backgroundColor: ColorClass.greenDark,
          ),
        );

        setState(() {
          _showAddRideForm = false;
          _clearForm();
        });
      } else {
        debugPrint('Failed to save ride');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to save ride. Please try again.'),
            backgroundColor: ColorClass.orangeDark,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving ride: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: ColorClass.orangeDark,
        ),
      );
    }
  }

  Widget _buildRideCard(TripModel trip, {required bool isUpcoming}) {
    final formattedDate = DateFormat('dd/MM/yyyy').format(trip.date);
    final hasEndData = trip.endKm > 0 && trip.endTime.isNotEmpty;
    final distance = hasEndData ? trip.endKm - trip.startKm : 0;

    // Determine trip status
    final now = DateTime.now();
    String status;
    Color statusColor;
    Color statusBgColor;

    final tripStartDateTime = _parseTimeString(trip.startTime, trip.date);

    if (tripStartDateTime == null) {
      // If we can't parse the start time, use fallback logic
      status = isUpcoming ? 'Live' : 'Completed';
      statusColor = isUpcoming ? ColorClass.orangeDark : ColorClass.greenDark;
      statusBgColor = isUpcoming
          ? ColorClass.orangeDark.withOpacity(0.1)
          : ColorClass.greenDark.withOpacity(0.1);
    } else {
      // Parse end time if available
      final tripEndDateTime = _parseTimeString(trip.endTime, trip.date);

      // Determine status based on current time
      if (tripEndDateTime != null) {
        if (now.isBefore(tripStartDateTime)) {
          // Current time is before start time
          status = 'Upcoming';
          statusColor = ColorClass.blueBase;
          statusBgColor = ColorClass.blueBase.withOpacity(0.1);
        } else if (now.isAfter(tripEndDateTime)) {
          // Current time is after end time
          status = 'Completed';
          statusColor = ColorClass.greenDark;
          statusBgColor = ColorClass.greenDark.withOpacity(0.1);
        } else {
          // Current time is between start and end time
          status = 'Live';
          statusColor = ColorClass.orangeDark;
          statusBgColor = ColorClass.orangeDark.withOpacity(0.1);
        }
      } else {
        // No end time - only compare with start time
        if (now.isBefore(tripStartDateTime)) {
          status = 'Upcoming';
          statusColor = ColorClass.blueBase;
          statusBgColor = ColorClass.blueBase.withOpacity(0.1);
        } else {
          status = 'Live';
          statusColor = ColorClass.orangeDark;
          statusBgColor = ColorClass.orangeDark.withOpacity(0.1);
        }
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorClass.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: ColorClass.brandDarkGreen.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with From → To and Status
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${trip.fromLocation} → ${trip.toLocation}',
                      style: TextStyleClass.poppinsSemiBold(
                        fontSize: 16,
                        color: ColorClass.brandDarkGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: TextStyleClass.poppinsRegular(
                        fontSize: 14,
                        color: ColorClass.neutral500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyleClass.poppinsSemiBold(
                    fontSize: 12,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Vehicle and Distance details
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  icon: LucideIcons.car,
                  label: 'Vehicle',
                  value: trip.vehicle.vehicleName,
                ),
              ),
              if (hasEndData)
                Expanded(
                  child: _buildDetailItem(
                    icon: LucideIcons.mapPin,
                    label: 'Distance',
                    value: '$distance km',
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Time details
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  icon: LucideIcons.clock,
                  label: 'Start Time',
                  value: trip.startTime,
                ),
              ),
              if (trip.endTime.isNotEmpty)
                Expanded(
                  child: _buildDetailItem(
                    icon: LucideIcons.clock,
                    label: 'End Time',
                    value: trip.endTime,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // KM details
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  icon: LucideIcons.gauge,
                  label: 'Start KM',
                  value: '${trip.startKm} km',
                ),
              ),
              if (hasEndData)
                Expanded(
                  child: _buildDetailItem(
                    icon: LucideIcons.gauge,
                    label: 'End KM',
                    value: '${trip.endKm} km',
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Description
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                LucideIcons.fileText,
                color: ColorClass.brandDarkGreen,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  trip.description,
                  style: TextStyleClass.poppinsRegular(
                    fontSize: 14,
                    color: ColorClass.neutral600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: ColorClass.neutral400,
          size: 14,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyleClass.poppinsRegular(
                  fontSize: 12,
                  color: ColorClass.neutral500,
                ),
              ),
              Text(
                value,
                style: TextStyleClass.poppinsSemiBold(
                  fontSize: 14,
                  color: ColorClass.brandDarkGreen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper function to parse time string in "09:00 AM" format
  DateTime? _parseTimeString(String timeString, DateTime date) {
    try {
      if (timeString.isEmpty) return null;

      // Handle "09:00 AM" format
      if (timeString.contains('AM') || timeString.contains('PM')) {
        final parts = timeString.split(' ');
        if (parts.length >= 2) {
          final timePart = parts[0]; // "09:00"
          final period = parts[1]; // "AM" or "PM"

          final timeComponents = timePart.split(':');
          if (timeComponents.length >= 2) {
            int hours = int.parse(timeComponents[0]);
            int minutes = int.parse(timeComponents[1]);

            // Convert to 24-hour format
            if (period == 'PM' && hours != 12) {
              hours += 12;
            } else if (period == 'AM' && hours == 12) {
              hours = 0;
            }

            return DateTime(date.year, date.month, date.day, hours, minutes);
          }
        }
      }

      // Handle "HH:MM" format
      if (timeString.contains(':')) {
        final parts = timeString.split(':');
        if (parts.length >= 2) {
          final hours = int.parse(parts[0]);
          final minutes = int.parse(parts[1]);
          return DateTime(date.year, date.month, date.day, hours, minutes);
        }
      }

      // If it's just a number, assume it's hours
      final hours = int.parse(timeString);
      return DateTime(date.year, date.month, date.day, hours, 0);
    } catch (e) {
      debugPrint('Error parsing time string: $timeString - $e');
      return null;
    }
  }
}
