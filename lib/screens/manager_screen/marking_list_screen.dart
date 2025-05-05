import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:canteen_app/constants/color_class.dart';
import 'package:canteen_app/constants/textstyle_class.dart';
import 'package:canteen_app/providers/date_provider.dart';

class MarkingListScreen extends StatelessWidget {
  static const String routeName = '/manager/marking_list';

  static void push(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }

  final bool showAppBar;
  MarkingListScreen({Key? key, this.showAppBar = true}) : super(key: key);

  final List<String> userNames = const [
    'Jenny Miller',
    'Lisa Smith',
    'Sara Johnson',
    'Tom Brown',
    'Emily White',
    'John Doe',
    'Alex Green',
    'Priya Patel',
    'Rahul Singh',
    'Sophie Turner',
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DateProvider>(
      create: (_) => DateProvider(),
      child: Scaffold(
        appBar: showAppBar
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
              )
            : null,
        body: Column(
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
              child: ListView.builder(
                itemCount: userNames.length,
                itemBuilder: (context, index) {
                  final userName = userNames[index];
                  final dateKey = userName; // Use user name as key for marking
                  return Container(
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: TextStyleClass.poppinsMedium(
                                  fontSize: 18,
                                  color: ColorClass.textMain900,
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
                                    activeColor: ColorClass.brandLightGreen,
                                    checkColor: ColorClass.brandDarkGreen,
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
                                    activeColor: ColorClass.brandLightGreen,
                                    checkColor: ColorClass.brandDarkGreen,
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
                                    activeColor: ColorClass.brandLightGreen,
                                    checkColor: ColorClass.brandDarkGreen,
                                  );
                                },
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
      ),
    );
  }
} 