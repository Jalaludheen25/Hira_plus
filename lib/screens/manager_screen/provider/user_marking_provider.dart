import 'package:flutter/material.dart';
import 'package:hira_plus/screens/manager_screen/models/user/user_marking_model.dart';
import 'package:hira_plus/utils/service_utils.dart';
import 'package:hira_plus/constants/api_urls.dart';

class UserMarkingProvider extends ChangeNotifier {
  List<UsersMarkingModel> _markings = [];
  bool _isLoading = false;
  String? _error;

  List<UsersMarkingModel> get markings => _markings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMarkings(String startDate, String endDate) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await HttpServiceUtils.fetchData(
          ApiUrls.getUsersMarkings(startDate, endDate), true);
      _markings =
          (response as List).map((e) => UsersMarkingModel.fromJson(e)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching markings: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> editMarking(String userId, String date,
      {required bool breakfast,
      required bool lunch,
      required bool dinner}) async {
    try {
      final data = {
        "date": date,
        "breakfast": breakfast,
        "lunch": lunch,
        "dinner": dinner
      };
      debugPrint('Editing marking for user $userId on $date: $data');
      await HttpServiceUtils.putData(
          ApiUrls.editUsersMarkings(userId), data, null);

      // Update local data
      final userIndex = _markings.indexWhere((user) => user.id == userId);
      if (userIndex >= 0) {
        final mealIndex = _markings[userIndex].meals?.indexWhere(
                (meal) => meal.date.toString().substring(0, 10) == date) ??
            -1;

        if (mealIndex >= 0 && _markings[userIndex].meals != null) {
          // Update existing meal
          _markings[userIndex].meals![mealIndex].breakfast = breakfast;
          _markings[userIndex].meals![mealIndex].lunch = lunch;
          _markings[userIndex].meals![mealIndex].dinner = dinner;
        } else {
          // Create new meal entry if doesn't exist
          final newMeal = Meal(
              date: DateTime.parse(date),
              breakfast: breakfast,
              lunch: lunch,
              dinner: dinner,
              userId: userId);
          _markings[userIndex].meals ??= [];
          _markings[userIndex].meals!.add(newMeal);
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error editing marking: $e');
      // Don't throw, just log error
    }
  }
}
