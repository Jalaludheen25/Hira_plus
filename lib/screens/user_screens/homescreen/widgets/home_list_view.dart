import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:canteen_app/constants/color_class.dart';
import 'package:canteen_app/constants/textstyle_class.dart';
import 'package:canteen_app/providers/canteen_home_page_provider.dart';
import 'package:canteen_app/providers/date_provider.dart';

class HomeListView extends StatelessWidget {
  final ScrollController scrollController;
  final String Function(int) getMonthName;
  final String Function(int) getDayName;
  const HomeListView({required this.scrollController, required this.getMonthName, required this.getDayName, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final canteenProvider = Provider.of<CanteenHomePageProvider>(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: ColorClass.primaryBase.withOpacity(0.1),
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
                              color: ColorClass.primaryBase,
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            itemCount: canteenProvider.allDays.length,
            itemBuilder: (context, index) {
              final date = canteenProvider.allDays[index];
              final dateKey = '${date.year}-${date.month}-${date.day}';
              final isToday = date.day == DateTime.now().day &&
                  date.month == DateTime.now().month &&
                  date.year == DateTime.now().year;
              final bool isFirstDayOfMonth = date.day == 1;
              return Column(
                children: [
                  if (isFirstDayOfMonth)
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: ColorClass.primaryBase.withOpacity(0.05),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Text(
                              '${getMonthName(date.month)} ${date.year}',
                              style: TextStyleClass.poppinsMedium(
                                fontSize: 16,
                                color: ColorClass.primaryBase,
                              ),
                            ),
                          ),
                          if (isToday)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: ColorClass.primaryBase,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Today',
                                style: TextStyleClass.poppinsMedium(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: ColorClass.primaryBase.withOpacity(0.1),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              if (isToday)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ColorClass.primaryBase,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    date.day.toString().padLeft(2, '0'),
                                    style: TextStyleClass.poppinsMedium(
                                      fontSize: 26,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              else
                                Text(
                                  date.day.toString().padLeft(2, '0'),
                                  style: TextStyleClass.poppinsMedium(
                                    fontSize: 26,
                                    color: ColorClass.textMain900,
                                  ),
                                ),
                              Text(
                                ' ${getDayName(date.weekday)}',
                                style: TextStyleClass.poppinsMedium(
                                  fontSize: 14,
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
                              Consumer<DateProvider>(
                                builder: (context, dateProvider, child) {
                                  return Checkbox(
                                    value: dateProvider.isMealSelected(dateKey, 'Breakfast'),
                                    onChanged: (value) {
                                      dateProvider.toggleMeal(dateKey, 'Breakfast');
                                    },
                                    activeColor: ColorClass.primaryBase,
                                  );
                                },
                              ),
                              Consumer<DateProvider>(
                                builder: (context, dateProvider, child) {
                                  return Checkbox(
                                    value: dateProvider.isMealSelected(dateKey, 'Lunch'),
                                    onChanged: (value) {
                                      dateProvider.toggleMeal(dateKey, 'Lunch');
                                    },
                                    activeColor: ColorClass.primaryBase,
                                  );
                                },
                              ),
                              Consumer<DateProvider>(
                                builder: (context, dateProvider, child) {
                                  return Checkbox(
                                    value: dateProvider.isMealSelected(dateKey, 'Dinner'),
                                    onChanged: (value) {
                                      dateProvider.toggleMeal(dateKey, 'Dinner');
                                    },
                                    activeColor: ColorClass.primaryBase,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
} 