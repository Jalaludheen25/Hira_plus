class ApiUrls {
  static const String baseUrl = "https://hiraplusapi.dharmadhara.com";
  static const String directUsUrl = "https://directus.d4dx.co";

  static String getForceUpdate() {
    return '$directUsUrl/items/hira_plus_force_update';
  }

  static String getVerifyOtp() {
    return '$baseUrl/api/auth/verify-otp';
  }

  static String getRequestOtp() {
    return '$baseUrl/api/auth/request-otp';
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


  // ################## MESS STAFF SCREEN ##################
  static String getMessStaffMeals() {
    return '$baseUrl/api/mess-staff/meals';
  }
}