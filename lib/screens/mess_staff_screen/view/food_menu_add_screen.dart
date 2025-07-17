import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../constants/color_class.dart';
import '../../../constants/textstyle_class.dart';
import '../../../utils/navigation_helper.dart';
import '../provider/menu_provider.dart';
import '../models/menu_model.dart';

class FoodMenuAddScreen extends StatefulWidget {
  final MenuModel? editingMenu;
  const FoodMenuAddScreen({Key? key, this.editingMenu}) : super(key: key);

  @override
  State<FoodMenuAddScreen> createState() => _FoodMenuAddScreenState();
}

class _FoodMenuAddScreenState extends State<FoodMenuAddScreen> {
  final TextEditingController _breakfastController = TextEditingController();
  final TextEditingController _lunchController = TextEditingController();
  final TextEditingController _dinnerController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isEditing = false;
  String? _editingId;

  @override
  void initState() {
    super.initState();
    if (widget.editingMenu != null) {
      final menu = widget.editingMenu!;
      _isEditing = true;
      _editingId = menu.id;
      _selectedDate = menu.date;
      _breakfastController.text = menu.breakfast;
      _lunchController.text = menu.lunch;
      _dinnerController.text = menu.dinner;
    }
  }

  @override
  void dispose() {
    _breakfastController.dispose();
    _lunchController.dispose();
    _dinnerController.dispose();
    super.dispose();
  }


  void _submitMenu(BuildContext context, MenuProvider provider) async {
    final breakfast = _breakfastController.text.trim();
    final lunch = _lunchController.text.trim();
    final dinner = _dinnerController.text.trim();
    if (breakfast.isEmpty && lunch.isEmpty && dinner.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least one meal.')),
      );
      return;
    }
    final menuData = {
      'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
      'breakfast': breakfast,
      'lunch': lunch,
      'dinner': dinner,
      'addedBy': 'Mess Staff',
    };
    bool success = false;
    if (_isEditing && _editingId != null) {
      menuData['id'] = _editingId!;
      success = await provider.updateMenuByDate(menuData);
    } else {
      success = await provider.addMenuByDate(menuData);
    }
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Menu updated!' : 'Menu added!'), backgroundColor: ColorClass.brandDarkGreen),
      );
      _breakfastController.clear();
      _lunchController.clear();
      _dinnerController.clear();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) Navigator.pop(context, true);
      });
    } else if (provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error!), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MenuProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: ColorClass.brandWhite,
          appBar: AppBar(
            title: Text(_isEditing ? 'Edit Food Menu' : 'Add Food Menu', style: TextStyleClass.poppinsSemiBold(fontSize: 20, color: ColorClass.white)),
            backgroundColor: ColorClass.brandDarkGreen,
            elevation: 0,
            iconTheme: const IconThemeData(color: ColorClass.white),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => navigateBack(context),
            ),
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Select Date', style: TextStyleClass.poppinsSemiBold(fontSize: 18, color: ColorClass.brandDarkGreen)),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2022),
                            lastDate: DateTime(2030),
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
                            _selectedDate = pickedDate;
                            setState(() {}); // Only for date field update
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: ColorClass.brandWhite,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: ColorClass.brandLightGreen, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Icon(LucideIcons.calendar, color: ColorClass.brandDarkGreen, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate), style: TextStyleClass.poppinsMedium(fontSize: 16, color: ColorClass.brandDarkGreen)),
                              ),
                              Icon(LucideIcons.chevronDown, color: ColorClass.brandDarkGreen, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('Meal Details', style: TextStyleClass.poppinsSemiBold(fontSize: 18, color: ColorClass.brandDarkGreen)),
                      const SizedBox(height: 16),
                      _buildMealField(_breakfastController, 'Breakfast', LucideIcons.sunMedium, 'Enter breakfast menu'),
                      const SizedBox(height: 16),
                      _buildMealField(_lunchController, 'Lunch', LucideIcons.sun, 'Enter lunch menu'),
                      const SizedBox(height: 16),
                      _buildMealField(_dinnerController, 'Dinner', LucideIcons.moon, 'Enter dinner menu'),
                      const SizedBox(height: 32),
                      if (provider.error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(provider.error!, style: TextStyleClass.poppinsRegular(fontSize: 14, color: Colors.red)),
                        ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: provider.isLoading ? null : () => _submitMenu(context, provider),
                          icon: Icon(_isEditing ? LucideIcons.save : LucideIcons.plus),
                          label: Text(_isEditing ? 'Update Menu' : 'Add Menu'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorClass.brandDarkGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildMealField(TextEditingController controller, String label, IconData icon, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyleClass.poppinsMedium(fontSize: 14, color: ColorClass.brandDarkGreen)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: ColorClass.brandWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ColorClass.brandLightGreen, width: 1.5),
          ),
          child: TextFormField(
            controller: controller,
            style: TextStyleClass.poppinsMedium(fontSize: 16, color: ColorClass.brandDarkGreen),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyleClass.poppinsRegular(fontSize: 16, color: ColorClass.neutral400),
              prefixIcon: Icon(icon, color: ColorClass.brandDarkGreen, size: 24),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
} 