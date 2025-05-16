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


 static String getVerifyOtp() {
    return '$baseUrl/api/auth/verify-otp';
 }
  static String adminLogin() {
    return '$baseUrl/admin/login';
  }

  static String getRequestOtp() {
    return '$baseUrl/api/auth/request-otp';
  }

  static String getMessStaffLogin() {
    return '$baseUrl/mess-staff/login';
  }

  // ################## MEALS FOR USER ##################

  static String getMealsForUser() {
    return '$baseUrl/meals/my-meals';
  }

  static String addMealForUser() {
    return '$baseUrl/meals/mark';
  }


  // ################## MESS STAFF SCREEN ##################
  static String getMessStaffMeals() {
    return '$baseUrl/api/mess-staff/meals';
  }
}

