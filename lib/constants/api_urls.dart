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
    return '$baseUrl/auth/verify-otp';
  }

  static String adminLogin() {
    return '$baseUrl/admin/login';
  }

  static String testLogin() {
    return '$baseUrl/auth/test-login';
  }

  static String getRequestOtp() {
    return '$baseUrl/auth/request-otp';
  }

  static String getMessStaffLogin() {
    return '$baseUrl/mess-staff/login';
  }

  // ################## CONTACTS ##################
  static String getContacts() {
    return '$baseUrl/auth/users';
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
    return '$baseUrl/mess-staff/meals';
  }

  // ################## ADMIN MESSAGES ##################
  static String getMessages() {
    return '$baseUrl/admin/messages';
  }

  static String createMessage() {
    return '$baseUrl/admin/messages';
  }

  static String sendMessage(String id) {
    return '$baseUrl/admin/messages/$id/send';
  }

  static String getProfileMe() {
    return '$baseUrl/auth/me';
  }

  static String getBanner() {
    return '$baseUrl/banner';
  }

  static String postBanner() {
    return '$baseUrl/banner';
  }

  static String editBanner(String id) {
    return '$baseUrl/banner/$id';
  }

  static String deleteBanner(String id) {
    return '$baseUrl/banner/$id';
  }

  // ################## GUEST MEALS (BULK BOOKING) ##################
  static String getGuestMeals() {
    return '$baseUrl/auth/guest-meals';
  }
  
  static String editGuestMeals(String id) {
    return '$baseUrl/auth/guest-meals/$id';
  }
}