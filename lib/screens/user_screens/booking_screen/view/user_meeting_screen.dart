import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';
import 'package:hira_plus/screens/user_screens/booking_screen/provider/user_meeting_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:developer' as developer;
import 'package:logger/logger.dart';
import 'package:hira_plus/screens/user_screens/user_home_screen/models/user_meeting_model.dart';

class UserMeetingScreen extends StatefulWidget {
  final MeetingModel? meeting;
  final bool isEdit;
  const UserMeetingScreen({Key? key, this.meeting, this.isEdit = false})
      : super(key: key);

  @override
  State<UserMeetingScreen> createState() => _UserMeetingScreenState();
}

class _UserMeetingScreenState extends State<UserMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _noOfPersonsController = TextEditingController();
  final Logger _logger = Logger();

  // Food controllers
  final _breakfastController = TextEditingController(text: '0');
  final _morningSnacksCountController = TextEditingController(text: '0');
  final _morningTeaCountController = TextEditingController(text: '0');
  final _lunchController = TextEditingController(text: '0');
  final _eveningSnacksCountController = TextEditingController(text: '0');
  final _eveningTeaCountController = TextEditingController(text: '0');
  final _dinnerController = TextEditingController(text: '0');

  DateTime _startDatetime = DateTime.now().add(const Duration(hours: 1));
  DateTime _endDatetime = DateTime.now().add(const Duration(hours: 3));
  bool _foodRequired = false;

  // Dropdown selections
  String? _selectedHall;

  // Predefined halls - match backend enum
  final List<String> _halls = [
    'Conference Hall [3rd Floor]',
    'Auditorium [2nd Floor]',
    'Meeting Space [1st Floor]',
  ];

  @override
  void initState() {
    super.initState();
    _logger.i('🏗️ [INIT] Initializing Create User Meeting Screen');
    developer.log('🏗️ Initializing Create User Meeting Screen',
        name: 'CreateUserMeetingScreen');
    if (widget.isEdit && widget.meeting != null) {
      final m = widget.meeting!;
      _titleController.text = m.title;
      _descriptionController.text = m.description;
      _noOfPersonsController.text = m.noOfPersons.toString();
      _breakfastController.text = m.breakfast.toString();
      _morningSnacksCountController.text = m.morningSnacksCount.toString();
      _morningTeaCountController.text = m.morningTeaCount.toString();
      _lunchController.text = m.lunch.toString();
      _eveningSnacksCountController.text = m.eveningSnacksCount.toString();
      _eveningTeaCountController.text = m.eveningTeaCount.toString();
      _dinnerController.text = m.dinner.toString();
      _startDatetime = m.startDatetime;
      _endDatetime = m.endDatetime;
      _foodRequired = m.foodRequired;
      _selectedHall = m.hall;
    }
  }

  @override
  void dispose() {
    _logger.i('🧹 [DISPOSE] Disposing Create User Meeting Screen');
    developer.log('🧹 Disposing Create User Meeting Screen',
        name: 'CreateUserMeetingScreen');
    _titleController.dispose();
    _descriptionController.dispose();
    _noOfPersonsController.dispose();
    _breakfastController.dispose();
    _morningSnacksCountController.dispose();
    _morningTeaCountController.dispose();
    _lunchController.dispose();
    _eveningSnacksCountController.dispose();
    _eveningTeaCountController.dispose();
    _dinnerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserMeetingProvider(),
      child: Scaffold(
        backgroundColor: ColorClass.brandWhite,
        appBar: AppBar(
          title: Text(
            widget.isEdit ? 'Edit Meeting' : 'Create Meeting',
            style: TextStyleClass.poppinsSemiBold(
              fontSize: 20,
              color: ColorClass.white,
            ),
          ),
          backgroundColor: ColorClass.brandDarkGreen,
          elevation: 0,
          iconTheme: const IconThemeData(color: ColorClass.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _logger.i('🔙 [NAVIGATION] Navigating back from create meeting');
              developer.log('🔙 Navigating back from create meeting',
                  name: 'CreateUserMeetingScreen');
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Field
                _buildTextField(
                  controller: _titleController,
                  label: 'Meeting Title',
                  icon: LucideIcons.fileText,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter meeting title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description Field
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  icon: LucideIcons.alignLeft,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter meeting description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Date and Time Section
                Text(
                  'Date & Time',
                  style: TextStyleClass.poppinsSemiBold(fontSize: 16),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildDateTimeField(
                        label: 'Start Date & Time',
                        dateTime: _startDatetime,
                        onTap: () => _selectDateTime(true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDateTimeField(
                        label: 'End Date & Time',
                        dateTime: _endDatetime,
                        onTap: () => _selectDateTime(false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Hall Dropdown
                _buildHallDropdown(),
                const SizedBox(height: 16),

                // Number of Persons Field
                _buildTextField(
                  controller: _noOfPersonsController,
                  label: 'Number of Attendees',
                  icon: LucideIcons.users,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter number of attendees';
                    }
                    final number = int.tryParse(value);
                    if (number == null || number <= 0) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Food Required Section
                Row(
                  children: [
                    Switch(
                      value: _foodRequired,
                      onChanged: (value) {
                        if (mounted) {
                          setState(() {
                            _foodRequired = value;
                          });
                        }
                      },
                      activeColor: ColorClass.brandDarkGreen,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Food Required',
                      style: TextStyleClass.poppinsMedium(fontSize: 16),
                    ),
                  ],
                ),

                if (_foodRequired) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Food Requirements',
                    style: TextStyleClass.poppinsSemiBold(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  // Food options grid - Morning
                  Row(
                    children: [
                      Expanded(
                        child: _buildFoodCountField(
                          controller: _breakfastController,
                          label: 'Breakfast',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFoodCountField(
                          controller: _morningSnacksCountController,
                          label: 'Morning Snacks',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFoodCountField(
                          controller: _morningTeaCountController,
                          label: 'Morning Tea',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFoodCountField(
                          controller: _lunchController,
                          label: 'Lunch',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFoodCountField(
                          controller: _eveningSnacksCountController,
                          label: 'Evening Snacks',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFoodCountField(
                          controller: _eveningTeaCountController,
                          label: 'Evening Tea',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildFoodCountField(
                    controller: _dinnerController,
                    label: 'Dinner',
                  ),
                ],

                const SizedBox(height: 32),

                // Create Button
                SizedBox(
                  width: double.infinity,
                  child: Consumer<UserMeetingProvider>(
                    builder: (context, provider, _) {
                      return ElevatedButton(
                        onPressed: provider.isLoading ? null : _saveMeeting,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorClass.brandDarkGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: provider.isLoading
                            ? const CupertinoActivityIndicator(
                                color: Colors.white)
                            : Text(
                                widget.isEdit
                                    ? 'Update Meeting'
                                    : 'Create Meeting',
                                style: TextStyleClass.poppinsSemiBold(
                                    fontSize: 16),
                              ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: ColorClass.brandDarkGreen),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ColorClass.neutral300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ColorClass.neutral300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ColorClass.brandDarkGreen, width: 2),
        ),
        filled: true,
        fillColor: ColorClass.neutral100,
      ),
    );
  }

  Widget _buildDateTimeField({
    required String label,
    required DateTime dateTime,
    required VoidCallback onTap,
  }) {
    final formatter = DateFormat('MMM dd, yyyy\nhh:mm a');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: ColorClass.neutral300),
          borderRadius: BorderRadius.circular(12),
          color: ColorClass.neutral100,
        ),
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
            const SizedBox(height: 4),
            Text(
              formatter.format(dateTime),
              style: TextStyleClass.poppinsMedium(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHallDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       
        DropdownButtonFormField<String>(
          value: _selectedHall,
          decoration: InputDecoration(
            labelText: 'Select Hall/Venue',
            prefixIcon:
                Icon(LucideIcons.mapPin, color: ColorClass.brandDarkGreen),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ColorClass.neutral300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: ColorClass.neutral300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: ColorClass.brandDarkGreen, width: 2),
            ),
            filled: true,
            fillColor: ColorClass.neutral100,
          ),
          items: _halls.map((String hall) {
            return DropdownMenuItem<String>(
              value: hall,
              child: Text(hall),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (mounted) {
              setState(() {
                _selectedHall = newValue;
              });
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a hall/venue';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFoodCountField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: ColorClass.neutral100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      validator: (value) {
        final number = int.tryParse(value ?? '0');
        if (number == null || number < 0) {
          return 'Invalid number';
        }
        return null;
      },
    );
  }

  Future<void> _selectDateTime(bool isStartTime) async {
    final currentDateTime = isStartTime ? _startDatetime : _endDatetime;

    final date = await showDatePicker(
      context: context,
      initialDate: currentDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(currentDateTime),
      );

      if (time != null && mounted) {
        final newDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        if (mounted) {
          if (isStartTime) {
            _startDatetime = newDateTime;
            // Ensure end time is after start time
            if (_endDatetime.isBefore(_startDatetime)) {
              _endDatetime = _startDatetime.add(const Duration(hours: 2));
            }
          } else {
            if (newDateTime.isAfter(_startDatetime)) {
              _endDatetime = newDateTime;
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('End time must be after start time'),
                  backgroundColor: ColorClass.redBase,
                ),
              );
              return; // Don't call setState if invalid
            }
          }
          setState(() {}); // Update UI
        }
      }
    }
  }

  void _saveMeeting() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = Provider.of<UserMeetingProvider>(context, listen: false);
    final isEditing = widget.isEdit && widget.meeting != null;

    if (isEditing) {
      // Prepare meeting data for update
      final meetingData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'startDatetime': _startDatetime.toIso8601String(),
        'endDatetime': _endDatetime.toIso8601String(),
        'hall': _selectedHall ?? 'Conference Hall [3rd Floor]',
        'noOfPersons': int.parse(_noOfPersonsController.text),
        'foodRequired': _foodRequired,
        'breakfast': int.parse(_breakfastController.text),
        'morningSnacksCount': int.parse(_morningSnacksCountController.text),
        'morningTeaCount': int.parse(_morningTeaCountController.text),
        'lunch': int.parse(_lunchController.text),
        'eveningSnacksCount': int.parse(_eveningSnacksCountController.text),
        'eveningTeaCount': int.parse(_eveningTeaCountController.text),
        'dinner': int.parse(_dinnerController.text),
        'department': widget.meeting?.department ?? '',
      };
      final updatedMeeting = await provider.updateMeeting(
        context,
        widget.meeting!.id,
        meetingData,
      );
      if (updatedMeeting != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Meeting "${updatedMeeting.title}" updated successfully'),
            backgroundColor: ColorClass.greenBase,
          ),
        );
        Navigator.pop(context, true);
      }
      return;
    }

    // Create new meeting (not editing)
    final meeting = await provider.createMeeting(
      context,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      startDatetime: _startDatetime,
      endDatetime: _endDatetime,
      hall: _selectedHall ?? 'Conference Hall [3rd Floor]',
      noOfPersons: int.parse(_noOfPersonsController.text),
      foodRequired: _foodRequired,
      breakfast: int.parse(_breakfastController.text),
      morningSnacksCount: int.parse(_morningSnacksCountController.text),
      morningTeaCount: int.parse(_morningTeaCountController.text),
      lunch: int.parse(_lunchController.text),
      eveningSnacksCount: int.parse(_eveningSnacksCountController.text),
      eveningTeaCount: int.parse(_eveningTeaCountController.text),
      dinner: int.parse(_dinnerController.text),
    );

    if (meeting != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Meeting "${meeting.title}" created successfully'),
          backgroundColor: ColorClass.greenBase,
        ),
      );
      Navigator.pop(context, true);
    }
  }
}
