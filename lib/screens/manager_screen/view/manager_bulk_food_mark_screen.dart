import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hira_plus/constants/app_utils.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';
import 'package:hira_plus/utils/navigation_helper.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:hira_plus/screens/manager_screen/provider/manager_bulk_food_provider.dart';
import 'dart:developer' as developer;
import 'package:logger/logger.dart';
import 'package:hira_plus/screens/manager_screen/models/manager_guest_meal_model.dart';

class ManagerBulkFoodMarkScreen extends StatefulWidget {
  final String? department;
  final ManagerGuestMealModel? editingMeal;
  const ManagerBulkFoodMarkScreen({Key? key, this.department, this.editingMeal}) : super(key: key);

  @override
  State<ManagerBulkFoodMarkScreen> createState() => _ManagerBulkFoodMarkScreenState();
}

class _ManagerBulkFoodMarkScreenState extends State<ManagerBulkFoodMarkScreen> {
  final TextEditingController _breakfastController = TextEditingController();
  final TextEditingController _lunchController = TextEditingController();
  final TextEditingController _dinnerController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final Logger _logger = Logger();
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;
  bool _showDuplicateWarning = false;
  bool _isEditing = false;
  String? _editingId;

  @override
  void initState() {
    super.initState();
    _logger.i('🏗️ [INIT] Initializing Manager Bulk Food Mark Screen');
    developer.log('🏗️ Initializing Manager Bulk Food Mark Screen', name: 'ManagerBulkFoodMarkScreen');
    
    // If editing, pre-fill all fields
    if (widget.editingMeal != null) {
      final meal = widget.editingMeal!;
      _isEditing = true;
      _editingId = meal.id;
      _selectedDate = meal.date;
      _departmentController.text = meal.department;
      _breakfastController.text = meal.breakfastCount.toString();
      _lunchController.text = meal.lunchCount.toString();
      _dinnerController.text = meal.dinnerCount.toString();
      
      _logger.i('✏️ [EDIT] Pre-filling form for editing meal: ${meal.id}');
      developer.log('✏️ Pre-filling form for editing meal: ${meal.id}', name: 'ManagerBulkFoodMarkScreen');
    } else if (widget.department != null && widget.department!.isNotEmpty) {
      _departmentController.text = widget.department!;
      _logger.d('📝 [INIT] Pre-filled department: ${widget.department}');
      developer.log('📝 Pre-filled department: ${widget.department}', name: 'ManagerBulkFoodMarkScreen');
    }
    
    // Check for duplicates when date or department changes
    _departmentController.addListener(_checkForDuplicates);
  }

  @override
  void dispose() {
    _logger.i('🧹 [DISPOSE] Disposing Manager Bulk Food Mark Screen');
    developer.log('🧹 Disposing Manager Bulk Food Mark Screen', name: 'ManagerBulkFoodMarkScreen');
    
    _breakfastController.dispose();
    _lunchController.dispose();
    _dinnerController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  void _checkForDuplicates() {
    final provider = Provider.of<ManagerBulkFoodProvider>(context, listen: false);
    final hasExisting = provider.hasExistingBooking(_selectedDate, _departmentController.text.trim());
    
    if (hasExisting != _showDuplicateWarning) {
      setState(() {
        _showDuplicateWarning = hasExisting;
      });
      
      _logger.d('⚠️ [DUPLICATE] Duplicate warning state changed to: $hasExisting');
      developer.log('⚠️ Duplicate warning state changed to: $hasExisting', name: 'ManagerBulkFoodMarkScreen');
    }
  }

  Future<void> _selectDate() async {
    _logger.d('📅 [ACTION] Date picker opened');
    developer.log('📅 Date picker opened', name: 'ManagerBulkFoodMarkScreen');
    
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ColorClass.brandDarkGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: ColorClass.brandDarkGreen,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
      
      _logger.i('📅 [ACTION] Date selected: ${DateFormat('yyyy-MM-dd').format(pickedDate)}');
      developer.log('📅 Date selected: ${DateFormat('yyyy-MM-dd').format(pickedDate)}', name: 'ManagerBulkFoodMarkScreen');
      
      _checkForDuplicates(); // Check for duplicates when date changes
    }
  }

  void _showDuplicateBookingDialog() {
    final provider = Provider.of<ManagerBulkFoodProvider>(context, listen: false);
    final existingBooking = provider.getExistingBooking(_selectedDate, _departmentController.text.trim());
    
    if (existingBooking == null) {
      _logger.w('⚠️ [WARNING] Duplicate dialog called but no existing booking found');
      developer.log('⚠️ Duplicate dialog called but no existing booking found', name: 'ManagerBulkFoodMarkScreen');
      return;
    }

    _logger.i('📋 [ACTION] Showing duplicate booking dialog');
    developer.log('📋 Showing duplicate booking dialog', name: 'ManagerBulkFoodMarkScreen');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Booking Already Exists',
            style: TextStyleClass.poppinsSemiBold(
              fontSize: 18,
              color: ColorClass.brandDarkGreen,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'A booking already exists for ${_departmentController.text} on ${DateFormat('MMMM d, yyyy').format(_selectedDate)}:',
                style: TextStyleClass.poppinsRegular(
                  fontSize: 16,
                  color: ColorClass.neutral600,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColorClass.brandLightGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildMealInfoRow('Breakfast', existingBooking.breakfastCount),
                    _buildMealInfoRow('Lunch', existingBooking.lunchCount),
                    _buildMealInfoRow('Dinner', existingBooking.dinnerCount),
                    const Divider(),
                    _buildMealInfoRow('Total', existingBooking.totalMealCount, isTotal: true),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'You can update the existing booking or choose a different date.',
                style: TextStyleClass.poppinsRegular(
                  fontSize: 14,
                  color: ColorClass.neutral500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _logger.d('❌ [ACTION] Duplicate dialog cancelled');
                developer.log('❌ Duplicate dialog cancelled', name: 'ManagerBulkFoodMarkScreen');
                navigateBack(context);
              },
              child: Text(
                'Cancel',
                style: TextStyleClass.poppinsMedium(
                  fontSize: 14,
                  color: ColorClass.neutral500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                navigateBack(context);
                _logger.d('📅 [ACTION] User chose different date option');
                developer.log('📅 User chose different date option', name: 'ManagerBulkFoodMarkScreen');
                _selectDate(); // Allow user to pick a different date
              },
              child: Text(
                'Choose Different Date',
                style: TextStyleClass.poppinsMedium(
                  fontSize: 14,
                  color: ColorClass.brandDarkGreen,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                navigateBack(context);
                _logger.d('🔄 [ACTION] User chose to update existing booking');
                developer.log('🔄 User chose to update existing booking', name: 'ManagerBulkFoodMarkScreen');
                _showUpdateBookingDialog(existingBooking);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorClass.brandDarkGreen,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Update Existing',
                style: TextStyleClass.poppinsMedium(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMealInfoRow(String label, int count, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyleClass.poppinsRegular(
              fontSize: isTotal ? 14 : 13,
              color: isTotal ? ColorClass.brandDarkGreen : ColorClass.neutral600,
            ),
          ),
          Text(
            count.toString(),
            style: TextStyleClass.poppinsSemiBold(
              fontSize: isTotal ? 14 : 13,
              color: isTotal ? ColorClass.brandDarkGreen : ColorClass.neutral600,
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdateBookingDialog(existingBooking) {
    // Pre-fill form with existing data for update
    _breakfastController.text = existingBooking.breakfastCount.toString();
    _lunchController.text = existingBooking.lunchCount.toString();
    _dinnerController.text = existingBooking.dinnerCount.toString();

    _logger.i('🔄 [ACTION] Form updated with existing booking data');
    developer.log('🔄 Form updated with existing booking data', name: 'ManagerBulkFoodMarkScreen');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Form updated with existing booking data. Modify the values and submit to update.',
          style: TextStyleClass.poppinsRegular(fontSize: 14, color: Colors.white),
        ),
        backgroundColor: ColorClass.brandDarkGreen,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _submitBooking() async {
    // Prevent multiple submissions
    if (_isSubmitting) {
      _logger.w('⚠️ [WARNING] Submission already in progress, ignoring');
      developer.log('⚠️ Submission already in progress, ignoring', name: 'ManagerBulkFoodMarkScreen');
      return;
    }

    final breakfastCount = int.tryParse(_breakfastController.text.trim()) ?? 0;
    final lunchCount = int.tryParse(_lunchController.text.trim()) ?? 0;
    final dinnerCount = int.tryParse(_dinnerController.text.trim()) ?? 0;
    final department = _departmentController.text.trim();

    _logger.i('🍽️ [SUBMIT] Submitting booking with values:');
    _logger.i('📅 Date: $_selectedDate');
    _logger.i('🍽️ Meals - Breakfast: $breakfastCount, Lunch: $lunchCount, Dinner: $dinnerCount');
    _logger.i('🏢 Department: $department');
    
    developer.log('🍽️ Submitting booking with values:', name: 'ManagerBulkFoodMarkScreen');
    developer.log('📅 Date: $_selectedDate', name: 'ManagerBulkFoodMarkScreen');
    developer.log('🍽️ Meals - Breakfast: $breakfastCount, Lunch: $lunchCount, Dinner: $dinnerCount', name: 'ManagerBulkFoodMarkScreen');
    developer.log('🏢 Department: $department', name: 'ManagerBulkFoodMarkScreen');

    // Validation
    if (breakfastCount == 0 && lunchCount == 0 && dinnerCount == 0) {
      _logger.w('⚠️ [VALIDATION] No meal counts provided');
      developer.log('⚠️ No meal counts provided', name: 'ManagerBulkFoodMarkScreen');
      AppUtils.showInSnackBarNormal('Please enter at least one meal count', context);
      return;
    }

    if (department.isEmpty) {
      _logger.w('⚠️ [VALIDATION] Department name is empty');
      developer.log('⚠️ Department name is empty', name: 'ManagerBulkFoodMarkScreen');
      AppUtils.showInSnackBarNormal('Please enter department name', context);
      return;
    }

    final provider = Provider.of<ManagerBulkFoodProvider>(context, listen: false);

    setState(() {
      _isSubmitting = true;
    });

    try {
      bool success = false;
      if (_isEditing && _editingId != null) {
        // Update existing booking
        _logger.i('🔄 [API] Calling updateGuestMealBooking for id: $_editingId');
        developer.log('🔄 Calling updateGuestMealBooking for id: $_editingId', name: 'ManagerBulkFoodMarkScreen');
        
        success = await provider.updateGuestMealBooking(
          context: context,
          id: _editingId!,
          date: _selectedDate,
          breakfastCount: breakfastCount,
          lunchCount: lunchCount,
          dinnerCount: dinnerCount,
          department: department,
          addedBy: 'Manager', // Default value since we removed the field
        );
      } else {
        // Check for duplicate booking and show dialog if exists
        if (provider.hasExistingBooking(_selectedDate, department)) {
          _logger.w('⚠️ [DUPLICATE] Duplicate booking detected, showing dialog');
          developer.log('⚠️ Duplicate booking detected, showing dialog', name: 'ManagerBulkFoodMarkScreen');
          _showDuplicateBookingDialog();
          setState(() {
            _isSubmitting = false;
          });
          return;
        }
        
        // Create new booking
        _logger.i('📤 [API] Calling submitBulkFoodBooking');
        developer.log('📤 Calling submitBulkFoodBooking', name: 'ManagerBulkFoodMarkScreen');
        
        success = await provider.submitBulkFoodBooking(
          context: context,
          date: _selectedDate,
          breakfastCount: breakfastCount,
          lunchCount: lunchCount,
          dinnerCount: dinnerCount,
          department: department,
          addedBy: 'Manager', // Default value since we removed the field
        );
      }

      _logger.i('📥 [API] Submit/Update result: $success');
      developer.log('📥 Submit/Update result: $success', name: 'ManagerBulkFoodMarkScreen');

      if (success) {
        _logger.i('✅ [SUCCESS] Booking ${_isEditing ? "updated" : "submitted"} successfully');
        developer.log('✅ Booking ${_isEditing ? "updated" : "submitted"} successfully', name: 'ManagerBulkFoodMarkScreen');
        
        AppUtils.showInSnackBarNormal(_isEditing ? 'Booking updated successfully!' : 'Booking submitted successfully!', context);
        
        // Wait a moment before navigating back
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          navigateBack(context);
        }
      } else {
        _logger.e('❌ [ERROR] Failed to ${_isEditing ? "update" : "submit"} booking');
        developer.log('❌ Failed to ${_isEditing ? "update" : "submit"} booking', name: 'ManagerBulkFoodMarkScreen');
        
        // Show the error message from provider
        final errorMessage = provider.errorMessage.isNotEmpty 
            ? provider.errorMessage 
            : 'Failed to ${_isEditing ? "update" : "submit"} booking. Please try again.';
        AppUtils.showInSnackBarNormal(errorMessage, context);
      }
    } catch (e, stackTrace) {
      _logger.e('❌ [EXCEPTION] Exception during submission: $e');
      _logger.e('📚 [STACKTRACE] Stack trace: $stackTrace');
      developer.log('❌ Exception during submission: $e', name: 'ManagerBulkFoodMarkScreen');
      developer.log('📚 Stack trace: $stackTrace', name: 'ManagerBulkFoodMarkScreen');
      
      AppUtils.showInSnackBarNormal('An error occurred. Please try again.', context);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ManagerBulkFoodProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: ColorClass.brandWhite,
          appBar: AppBar(
            title: Text(
              _isEditing ? 'Edit Bulk Food Booking' : 'Bulk Food Booking',
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
                _logger.i('🔙 [NAVIGATION] Navigating back from bulk food mark screen');
                developer.log('🔙 Navigating back from bulk food mark screen', name: 'ManagerBulkFoodMarkScreen');
                navigateBack(context);
              },
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Select Date'),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ColorClass.brandWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _showDuplicateWarning ? ColorClass.redBase : ColorClass.brandLightGreen,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.calendar,
                          color: _showDuplicateWarning ? ColorClass.redBase : ColorClass.brandDarkGreen,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                            style: TextStyleClass.poppinsMedium(
                              fontSize: 16,
                              color: _showDuplicateWarning ? ColorClass.redBase : ColorClass.brandDarkGreen,
                            ),
                          ),
                        ),
                        Icon(
                          LucideIcons.chevronDown,
                          color: _showDuplicateWarning ? ColorClass.redBase : ColorClass.brandDarkGreen,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Show duplicate warning
                if (_showDuplicateWarning)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ColorClass.redLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ColorClass.redBase.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.alertTriangle,
                          color: ColorClass.redBase,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'A booking already exists for this date and department',
                            style: TextStyleClass.poppinsRegular(
                              fontSize: 14,
                              color: ColorClass.redDark,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _showDuplicateBookingDialog,
                          child: Text(
                            'View',
                            style: TextStyleClass.poppinsMedium(
                              fontSize: 14,
                              color: ColorClass.redBase,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 32),
                
                _buildSectionTitle('Department Information'),
                const SizedBox(height: 16),
                _buildTextFieldWithIcon(
                  controller: _departmentController,
                  label: 'Department Name',
                  icon: LucideIcons.building,
                  hint: 'Enter department name',
                  showWarning: _showDuplicateWarning,
                ),
                
                const SizedBox(height: 32),
                
                _buildSectionTitle('Meal Counts'),
                const SizedBox(height: 16),
                _buildMealCountField(
                  controller: _breakfastController,
                  label: 'Breakfast',
                  icon: LucideIcons.sunMedium,
                  hint: 'Enter breakfast count',
                ),
                const SizedBox(height: 16),
                _buildMealCountField(
                  controller: _lunchController,
                  label: 'Lunch',
                  icon: LucideIcons.sun,
                  hint: 'Enter lunch count',
                ),
                const SizedBox(height: 16),
                _buildMealCountField(
                  controller: _dinnerController,
                  label: 'Dinner',
                  icon: LucideIcons.moon,
                  hint: 'Enter dinner count',
                ),
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  child: AppUtils.agreeButton(
                    onTap: _submitBooking,
                    title: _isEditing ? 'Update Booking' : (_showDuplicateWarning ? 'Update Existing Booking' : 'Submit Booking'),
                    width: double.infinity,
                    isLoading: _isSubmitting || provider.isLoading,
                    isDisabled: _isSubmitting || provider.isLoading,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyleClass.poppinsSemiBold(
        fontSize: 18,
        color: ColorClass.brandDarkGreen,
      ),
    );
  }

  Widget _buildTextFieldWithIcon({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    bool showWarning = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyleClass.poppinsMedium(
            fontSize: 14,
            color: showWarning ? ColorClass.redBase : ColorClass.brandDarkGreen,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: ColorClass.brandWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: showWarning ? ColorClass.redBase : ColorClass.brandLightGreen,
              width: 1.5,
            ),
          ),
          child: TextFormField(
            controller: controller,
            style: TextStyleClass.poppinsMedium(
              fontSize: 16,
              color: showWarning ? ColorClass.redBase : ColorClass.brandDarkGreen,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyleClass.poppinsRegular(
                fontSize: 16,
                color: ColorClass.neutral400,
              ),
              prefixIcon: Icon(
                icon,
                color: showWarning ? ColorClass.redBase : ColorClass.brandDarkGreen,
                size: 24,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMealCountField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyleClass.poppinsMedium(
            fontSize: 14,
            color: ColorClass.brandDarkGreen,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: ColorClass.brandWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ColorClass.brandLightGreen,
              width: 1.5,
            ),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            style: TextStyleClass.poppinsMedium(
              fontSize: 16,
              color: ColorClass.brandDarkGreen,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyleClass.poppinsRegular(
                fontSize: 16,
                color: ColorClass.neutral400,
              ),
              prefixIcon: Icon(
                icon,
                color: ColorClass.brandDarkGreen,
                size: 24,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}