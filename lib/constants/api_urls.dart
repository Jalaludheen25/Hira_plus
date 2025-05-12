class ApiUrls {
  static const String baseUrl = "https://hiraplusapi.dharmadhara.com";
  static const String directUsUrl = "https://directus.d4dx.co";

  static String getForceUpdate() {
    return '$directUsUrl/items/hira_plus_force_update';
  }

  static String getTestUser() {
    return '$baseUrl/api/auth/test-login';
  }

  // ################## MEALS FOR USER ##################

  static String getMealsForUser() {
    return '$baseUrl/api/meals/my-meals';
  }

  // static String getMealById(String id) {
  //   return '$baseUrl/api/meals/$id';
  // }
}
