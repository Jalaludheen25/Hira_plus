import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Hira_Plus/constants/color_class.dart';  
import 'package:Hira_Plus/constants/textstyle_class.dart';
import 'package:Hira_Plus/providers/user_marking_provider.dart';
import 'package:Hira_Plus/models/user_marking_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

class MarkingListScreen extends StatefulWidget {
  static const String routeName = '/manager/marking_list';

  static void push(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(routeName);
  }

  final bool showAppBar;
  const MarkingListScreen({Key? key, this.showAppBar = true}) : super(key: key);

  @override
  State<MarkingListScreen> createState() => _MarkingListScreenState();
}

class _MarkingListScreenState extends State<MarkingListScreen> {
  late UserMarkingProvider _provider;
  String _selectedDate = '';
  DateTime _currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _provider = UserMarkingProvider();
    _selectedDate = DateFormat('yyyy-MM-dd').format(_currentDate);
    _provider.fetchMarkings(_selectedDate, _selectedDate);
  }
  
  void _updateDate(DateTime date) {
    setState(() {
      _currentDate = date;
      _selectedDate = DateFormat('yyyy-MM-dd').format(date);
    });
    _provider.fetchMarkings(_selectedDate, _selectedDate);
  }

  // Show date picker
  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _currentDate,
      firstDate: DateTime(2022),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _currentDate) {
      _updateDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<UserMarkingProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: ColorClass.brandWhite,
            appBar: widget.showAppBar
                ? AppBar(
                    backgroundColor: ColorClass.brandDarkGreen,
                    iconTheme: const IconThemeData(color: Colors.white),
                    title: Text(
                      'Marking List',
                      style: TextStyleClass.poppinsSemiBold(
                        fontSize: 20,
                        color: ColorClass.white,
                      ),
                    ),
                    actions: [
                      IconButton(
                        onPressed: _selectDate,
                        icon: const Icon(Icons.calendar_month),
                      )
                    ],
                  )
                : null,
            body: provider.isLoading
                ? const Center(child: CupertinoActivityIndicator())
                : provider.error != null
                    ? Center(child: Text('Error: ${provider.error}'))
                    : Column(
                        children: [
                          // Date display
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat('dd MMMM yyyy').format(_currentDate),
                                  style: TextStyleClass.poppinsSemiBold(
                                    fontSize: 18,
                                    color: ColorClass.textMain900,
                                  ),
                                ),
                                IconButton(
                                  onPressed: _selectDate,
                                  icon: const Icon(Icons.calendar_today, size: 20),
                                  color: ColorClass.brandDarkGreen,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: ColorClass.greenBase.withOpacity(0.1),
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Expanded(flex: 2, child: SizedBox()),
                                Expanded(
                                  flex: 3,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: ['B', 'L', 'D']
                                        .map((label) => Text(
                                              label,
                                              style: TextStyleClass.poppinsMedium(
                                                fontSize: 14,
                                                color: ColorClass.brandDarkGreen,
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: provider.markings.isEmpty
                                ? const Center(child: Text('No marking data available'))
                                : ListView.builder(
                                    itemCount: provider.markings.length,
                                    itemBuilder: (context, index) {
                                      final user = provider.markings[index];
                                      // Find meal for the selected date
                                      final todayMeal = user.meals?.firstWhere(
                                        (meal) => meal.date != null && 
                                            DateFormat('yyyy-MM-dd').format(meal.date!) == _selectedDate,
                                        orElse: () => Meal(
                                          breakfast: false,
                                          lunch: false, 
                                          dinner: false
                                        ),
                                      );
                                      
                                      // Default values if no meal found
                                      final hasBreakfast = todayMeal?.breakfast ?? false;
                                      final hasLunch = todayMeal?.lunch ?? false;
                                      final hasDinner = todayMeal?.dinner ?? false;
                                      
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: ColorClass.greenBase.withOpacity(0.1),
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    user.name ?? '',
                                                    style: TextStyleClass.poppinsMedium(
                                                      fontSize: 18,
                                                      color: ColorClass.textMain900,
                                                    ),
                                                  ),
                                                  Text(
                                                    user.department ?? '',
                                                    style: TextStyleClass.poppinsRegular(
                                                      fontSize: 12,
                                                      color: ColorClass.neutral400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  Checkbox(
                                                    value: hasBreakfast,
                                                    onChanged: (value) {
                                                      if (user.id != null) {
                                                        provider.editMarking(
                                                          user.id!,
                                                          _selectedDate,
                                                          breakfast: value ?? false,
                                                          lunch: hasLunch,
                                                          dinner: hasDinner,
                                                        );
                                                      }
                                                    },
                                                    activeColor: ColorClass.brandLightGreen,
                                                    checkColor: ColorClass.brandDarkGreen,
                                                  ),
                                                  Checkbox(
                                                    value: hasLunch,
                                                    onChanged: (value) {
                                                      if (user.id != null) {
                                                        provider.editMarking(
                                                          user.id!,
                                                          _selectedDate,
                                                          breakfast: hasBreakfast,
                                                          lunch: value ?? false,
                                                          dinner: hasDinner,
                                                        );
                                                      }
                                                    },
                                                    activeColor: ColorClass.brandLightGreen,
                                                    checkColor: ColorClass.brandDarkGreen,
                                                  ),
                                                  Checkbox(
                                                    value: hasDinner,
                                                    onChanged: (value) {
                                                      if (user.id != null) {
                                                        provider.editMarking(
                                                          user.id!,
                                                          _selectedDate,
                                                          breakfast: hasBreakfast,
                                                          lunch: hasLunch,
                                                          dinner: value ?? false,
                                                        );
                                                      }
                                                    },
                                                    activeColor: ColorClass.brandLightGreen,
                                                    checkColor: ColorClass.brandDarkGreen,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
          );
        },
      ),
    );
  }
} 