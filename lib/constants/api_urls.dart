class ApiUrls {
  static const String baseUrl = "https://hiraplusapi.dharmadhara.com";
  static const String directUsUrl = "https://directus.d4dx.co";

  static String getForceUpdate() {
    return '$directUsUrl/items/hira_plus_force_update';
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