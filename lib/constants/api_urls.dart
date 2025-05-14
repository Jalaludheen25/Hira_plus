class ApiUrls {
 static const String baseUrl = "https://hiraplusapi.dharmadhara.com/api";
 static const String directUsUrl = "https://directus.d4dx.co";

  static String getForceUpdate() {
    return '$directUsUrl/items/hira_plus_force_update';
  }
 static String getUsers() {
    return '$baseUrl/admin/users';
  }
 static String getUsersMarkings(String startDate, String endDate) {
    return '$baseUrl/admin/users/meals?startDate=$startDate&endDate=$endDate';
  }
 static String editUsersMarkings(String id) {
    return '$baseUrl/admin/users/$id/meals';
  }
 static String usersByMeal(String date, String mealType) {
    return '$baseUrl/admin/meals/$mealType?date=$date';
  }

  static String getTestUser() {
    return '$baseUrl/api/auth/test-login';
  }
  
 
  static String getMessStaffLogin() {
    return '$baseUrl/api/mess-staff/login';
  }

  // ################## MEALS FOR USER ##################

  static String getMealsForUser() {
    return '$baseUrl/api/meals/my-meals';
  }

  static String addMealForUser() {
    return '$baseUrl/api/meals/mark';
  }
}
