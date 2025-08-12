import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hira_plus/screens/manager_screen/models/user/user_marking_model.dart';
import 'package:hira_plus/screens/manager_screen/provider/user_marking_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hira_plus/constants/color_class.dart';
import 'package:hira_plus/constants/textstyle_class.dart';

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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _provider = UserMarkingProvider();
    _selectedDate = DateFormat('yyyy-MM-dd').format(_currentDate);
    _provider.fetchMarkings(_selectedDate, _selectedDate);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateDate(DateTime date) {
    setState(() {
      _currentDate = date;
      _selectedDate = DateFormat('yyyy-MM-dd').format(date);
    });
    _provider.fetchMarkings(_selectedDate, _selectedDate);
  }

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

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  List<UsersMarkingModel> _getFilteredUsers(List<UsersMarkingModel> users) {
    if (_searchQuery.isEmpty) {
      return users;
    }

    return users.where((user) {
      final name = user.name?.toLowerCase() ?? '';
      final department = user.department?.toLowerCase() ?? '';
      final designation = user.designation?.toLowerCase() ?? '';

      return name.contains(_searchQuery) ||
          department.contains(_searchQuery) ||
          designation.contains(_searchQuery);
    }).toList();
  }

  Widget _buildSearchField() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search by name, department, or designation...',
          hintStyle: TextStyleClass.poppinsRegular(
            fontSize: 14,
            color: ColorClass.neutral400,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: ColorClass.brandDarkGreen,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: ColorClass.neutral400,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: ColorClass.neutral300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: ColorClass.brandDarkGreen),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: ColorClass.neutral300),
          ),
          filled: true,
          fillColor: ColorClass.brandWhite,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        style: TextStyleClass.poppinsRegular(
          fontSize: 14,
          color: ColorClass.textMain900,
        ),
      ),
    );
  }

  Widget _buildDateSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
    );
  }

  Widget _buildHeaderRow() {
    return Container(
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
    );
  }

  Widget _buildUserTile(UsersMarkingModel user) {
    // Find meal for the selected date
    final todayMeal = user.meals?.firstWhere(
      (meal) =>
          meal.date != null &&
          DateFormat('yyyy-MM-dd').format(meal.date!) == _selectedDate,
      orElse: () => Meal(breakfast: false, lunch: false, dinner: false),
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
                      _provider.editMarking(
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
                      _provider.editMarking(
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
                      _provider.editMarking(
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
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isNotEmpty ? Icons.search_off : Icons.no_meals,
            size: 64,
            color: ColorClass.neutral400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyleClass.poppinsRegular(
              fontSize: 16,
              color: ColorClass.neutral400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<UserMarkingProvider>(
        builder: (context, provider, _) {
          final filteredUsers = _getFilteredUsers(provider.markings);

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
                          _buildDateSection(),
                          _buildSearchField(),
                          _buildHeaderRow(),
                          Expanded(
                            child: filteredUsers.isEmpty
                                ? _buildEmptyState(_searchQuery.isNotEmpty
                                    ? 'No users found matching "$_searchQuery"'
                                    : 'No marking data available')
                                : ListView.builder(
                                    itemCount: filteredUsers.length,
                                    itemBuilder: (context, index) {
                                      return _buildUserTile(
                                          filteredUsers[index]);
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
