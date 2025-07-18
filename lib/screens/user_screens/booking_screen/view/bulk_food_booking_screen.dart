import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hira_plus/constants/app_utils.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';
import 'package:hira_plus/screens/user_screens/booking_screen/model/guest_meal_model.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:hira_plus/screens/user_screens/booking_screen/provider/bulk_food_provider.dart';
import 'dart:developer' as developer;
import 'package:logger/logger.dart';

class BulkFoodBookingScreen extends StatefulWidget {
  final GuestMealModel? editingMeal;
  
  const BulkFoodBookingScreen({Key? key, this.editingMeal}) : super(key: key);

  @override
  State<BulkFoodBookingScreen> createState() => _BulkFoodBookingScreenState();
}

class _BulkFoodBookingScreenState extends State<BulkFoodBookingScreen> {
  final Logger _logger = Logger();
  final TextEditingController _breakfastController = TextEditingController();
  final TextEditingController _lunchController = TextEditingController();
  final TextEditingController _dinnerController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isEditing = false;

  // Restriction: After 6:00 AM today, cannot book bulk food for today
  bool _isBookingRestricted() {
    final now = DateTime.now();
    final isToday = _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
    final restrictionTime = DateTime(now.year, now.month, now.day, 6, 0, 0);
    return isToday && now.isAfter(restrictionTime);
  }

  @override
  void initState() {
    super.initState();
    _isEditing = widget.editingMeal != null;
    
    if (_isEditing) {
      // Pre-populate fields when editing
      final meal = widget.editingMeal!;
      _selectedDate = meal.date;
      _breakfastController.text = meal.breakfastCount.toString();
      _lunchController.text = meal.lunchCount.toString();
      _dinnerController.text = meal.dinnerCount.toString();
      
      _logger.i('✏️ [BULK_BOOKING] Initializing for editing meal: ${meal.id}');
      developer.log('✏️ Initializing for editing meal: ${meal.id}', name: 'BulkFoodBooking');
    } else {
      _logger.i('🍽️ [BULK_BOOKING] Initializing for new booking');
      developer.log('🍽️ Initializing for new booking', name: 'BulkFoodBooking');
    }
  }

  @override
  void dispose() {
    _breakfastController.dispose();
    _lunchController.dispose();
    _dinnerController.dispose();
    _logger.i('🧹 [BULK_BOOKING] Disposing controllers and resources');
    developer.log('🧹 Disposing controllers and resources', name: 'BulkFoodBooking');
    super.dispose();
  }

  Future<void> _selectDate() async {
    _logger.d('📅 [DATE_PICKER] Opening date picker');
    developer.log('📅 Opening date picker', name: 'BulkFoodBooking');
    
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
      _logger.i('📅 [DATE_PICKER] Date selected: ${DateFormat('yyyy-MM-dd').format(pickedDate)}');
      developer.log('📅 Date selected: ${DateFormat('yyyy-MM-dd').format(pickedDate)}', 
          name: 'BulkFoodBooking');
    }
  }

  void _submitBooking() async {
    final actionType = _isEditing ? 'update' : 'submission';
    _logger.i('📝 [SUBMIT] Starting bulk food booking $actionType');
    developer.log('📝 Starting bulk food booking $actionType', name: 'BulkFoodBooking');

    final breakfastCount = int.tryParse(_breakfastController.text.trim()) ?? 0;
    final lunchCount = int.tryParse(_lunchController.text.trim()) ?? 0;
    final dinnerCount = int.tryParse(_dinnerController.text.trim()) ?? 0;

    // Validation
    if (breakfastCount == 0 && lunchCount == 0 && dinnerCount == 0) {
      _logger.w('⚠️ [VALIDATION] No meal counts provided');
      developer.log('⚠️ Validation failed: No meal counts provided', 
          name: 'BulkFoodBooking');
      
      AppUtils.showInSnackBarNormal(
        'Please enter at least one meal count',
        context,
      );
      return;
    }

    _logger.d('📊 [VALIDATION] Meal counts - Breakfast: $breakfastCount, Lunch: $lunchCount, Dinner: $dinnerCount');
    developer.log('📊 Meal counts - Breakfast: $breakfastCount, Lunch: $lunchCount, Dinner: $dinnerCount', 
        name: 'BulkFoodBooking');

    try {
      final provider = Provider.of<BulkFoodProvider>(context, listen: false);
      
      _logger.i('🚀 [API] Calling bulk food booking API');
      developer.log('🚀 Calling bulk food booking API', name: 'BulkFoodBooking');

      bool success;
      
      if (_isEditing) {
        success = await provider.updateGuestMealBooking(
          context: context,
          id: widget.editingMeal!.id,
          date: _selectedDate,
          breakfastCount: breakfastCount,
          lunchCount: lunchCount,
          dinnerCount: dinnerCount,
        );
      } else {
        success = await provider.submitBulkFoodBooking(
          context: context,
          date: _selectedDate,
          breakfastCount: breakfastCount,
          lunchCount: lunchCount,
          dinnerCount: dinnerCount,
        );
      }

      if (success) {
        final successMessage = _isEditing ? 'Booking updated successfully!' : 'Booking submitted successfully!';
        
        _logger.i('✅ [SUCCESS] Bulk food booking $actionType successful');
        developer.log('✅ Bulk food booking $actionType successful', 
            name: 'BulkFoodBooking');
        
        if (!_isEditing) {
          // Clear form only for new bookings
          _breakfastController.clear();
          _lunchController.clear();
          _dinnerController.clear();
          setState(() {
            _selectedDate = DateTime.now();
          });
        }

        AppUtils.showInSnackBarNormal(successMessage, context);
        
        // Navigate back to list screen
        Navigator.of(context).pop();
        
      } else {
        _logger.e('❌ [ERROR] Failed to $actionType bulk food booking');
        developer.log('❌ Failed to $actionType bulk food booking', 
            name: 'BulkFoodBooking');
      }
    } catch (e) {
      _logger.e('💥 [EXCEPTION] Error in bulk food booking: $e');
      developer.log('💥 Error in bulk food booking: $e', 
          name: 'BulkFoodBooking', error: e);
      
      AppUtils.showInSnackBarNormal(
        'Failed to ${_isEditing ? 'update' : 'submit'} booking. Please try again.',
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BulkFoodProvider(),
      child: Consumer<BulkFoodProvider>(
        builder: (context, provider, _) {
          final bookingRestricted = _isBookingRestricted();
          return Scaffold(
            backgroundColor: ColorClass.brandWhite,
            appBar: AppBar(
              title: Text(
                _isEditing ? 'Edit Bulk Booking' : 'Bulk Food Booking',
                style: TextStyleClass.poppinsSemiBold(
                  fontSize: 20,
                  color: ColorClass.white,
                ),
              ),
              backgroundColor: ColorClass.brandDarkGreen,
              elevation: 0,
              iconTheme: const IconThemeData(color: ColorClass.white),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Selection Section
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
                          color: ColorClass.brandLightGreen,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.calendar,
                            color: ColorClass.brandDarkGreen,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                              style: TextStyleClass.poppinsMedium(
                                fontSize: 16,
                                color: ColorClass.brandDarkGreen,
                              ),
                            ),
                          ),
                          Icon(
                            LucideIcons.chevronDown,
                            color: ColorClass.brandDarkGreen,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Meal Counts Section
                  _buildSectionTitle('Meal Counts'),
                  const SizedBox(height: 16),

                  // Breakfast Count
                  _buildMealCountField(
                    controller: _breakfastController,
                    label: 'Breakfast',
                    icon: LucideIcons.sunMedium,
                    hint: 'Enter breakfast count',
                  ),
                  const SizedBox(height: 16),

                  // Lunch Count
                  _buildMealCountField(
                    controller: _lunchController,
                    label: 'Lunch',
                    icon: LucideIcons.sun,
                    hint: 'Enter lunch count',
                  ),
                  const SizedBox(height: 16),

                  // Dinner Count
                  _buildMealCountField(
                    controller: _dinnerController,
                    label: 'Dinner',
                    icon: LucideIcons.moon,
                    hint: 'Enter dinner count',
                  ),

                  const SizedBox(height: 32),

                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ColorClass.brandLightGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ColorClass.brandLightGreen.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.info,
                          color: ColorClass.brandDarkGreen,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Enter the number of meals needed for each type. Leave blank or 0 for meals not required.',
                            style: TextStyleClass.poppinsRegular(
                              fontSize: 14,
                              color: ColorClass.brandDarkGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Restriction message
                  if (bookingRestricted)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Can't book bulk food for today after 6:00 AM.",
                              style: TextStyleClass.poppinsRegular(
                                fontSize: 14,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: bookingRestricted || provider.isLoading ? null : _submitBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorClass.brandDarkGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: provider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              _isEditing ? 'Update Booking' : 'Submit Booking',
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyleClass.poppinsSemiBold(
        fontSize: 18,
        color: ColorClass.brandDarkGreen,
      ),
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
              LengthLimitingTextInputFormatter(3), // Max 999 meals
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
            onChanged: (value) {
              _logger.d('📝 [INPUT] $label count changed to: $value');
              developer.log('📝 $label count changed to: $value', 
                  name: 'BulkFoodBooking');
            },
          ),
        ),
      ],
    );
  }
}