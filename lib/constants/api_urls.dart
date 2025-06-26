class ApiUrls {
  // Base URLs for the application
  static const String baseUrl = "https://hiraplusapi.dharmadhara.com/api";
  static const String directUsUrl = "https://directus.d4dx.co";

  // ################## FORCE UPDATE API ##################
  static String getForceUpdate() {
    return '$directUsUrl/items/hira_plus_force_update';
  }

  // ################## ADMIN USER MANAGEMENT APIs ##################
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

  // ################## AUTHENTICATION APIs ##################
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

  // ################## DEPARTMENT API ##################
  static String getDepartments() {
    return '$baseUrl/admin/departments';
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

  // ################## USER PROFILE ##################
  static String getProfileMe() {
    return '$baseUrl/auth/me';
  }

  // ################## BANNER MANAGEMENT ##################
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

  // ################## ADMIN GUEST MEALS (BULK BOOKING) ##################
  static String adminGuestMeals() {
    return '$baseUrl/admin/guest-meals';
  }

  static String adminEditGuestMeals(String id) {
    return '$baseUrl/admin/guest-meals/$id';
  }

  // ################## MEETINGS API ##################

  /// Get all meetings
  static String getMeetings() {
    return '$baseUrl/admin/meetings';
  }

  /// Create a new meeting
  static String createMeeting() {
    return '$baseUrl/admin/meetings';
  }

  /// Edit a meeting (admin)
  static String adminEditMeeting(String meetingId) {
    return '$baseUrl/admin/meetings/$meetingId';
  }

  /// Delete a meeting (admin)
  static String adminDeleteMeeting(String meetingId) {
    return '$baseUrl/admin/meetings/$meetingId';
  }

  /// Update meeting status (admin)
  static String adminUpdateMeetingStatus(String meetingId) {
    return '$baseUrl/admin/meetings/$meetingId';
  }

  // ################## GUEST MEALS FOR MESS STAFF ##################

  static String getBulkMealsForMessStaff() {
    return '$baseUrl/mess-staff/guest-meals';
  }

  // ################## RECEPTION APIs ##################

  static String getReceptionLogin() {
    return '$baseUrl/reception/login';
  }

  static String getAllReceptionUsers() {
    return '$baseUrl/reception/users/all';
  }

  static String checkInUser(String userId) {
    return '$baseUrl/reception/check-in/$userId';
  }

  static String checkOutUser(String userId) {
    return '$baseUrl/reception/checkout/$userId';
  }

  // Get today's check-ins
  static String getTodayCheckIns() {
    return '$baseUrl/reception/check-ins/today';
  }

  // ################## USER CHECK IN STATUS ##################
  static String getUserCheckInStatus() {
    return '$baseUrl/auth/today-checked-in';
  }

  // Get today's check-outs
  static String getTodayCheckOuts() {
    return '$baseUrl/reception/checkouts/today';
  }

  static String getAttendanceByDate(String date) {
    return '$baseUrl/reception/attendance/by-date?date=$date';
  }

  static String editChecks(String userId) {
    return '$baseUrl/reception/edit-check-in/$userId';
  }

  // ################## USER MEETINGS ##################
  static String getUserMeetings() {
    return '$baseUrl/auth/meetings'; // GET - show meetings
  }

  static String createUserMeeting() {
    return '$baseUrl/auth/dept-meetings'; // POST - create meeting (deptHead only)
  }

  static String editMeeting(String meetingId) {
    return '$baseUrl/auth/dept-meetings/$meetingId'; // PUT - edit meeting
  }

  // Delete meeting endpoint
  static String deleteMeeting(String meetingId) {
    return '$baseUrl/auth/dept-meetings/$meetingId'; // DELETE - delete meeting
  }

  // ################## MEETING FOOD REQUIREMENTS ##################

  static String getMeetingFoodRequirements({
    required String startDate,
    required String endDate,
  }) {
    return '$baseUrl/mess-staff/meeting-food-requirements?startDate=$startDate&endDate=$endDate';
  }

  // ################## DEPARTMENTS ##################
  static String departmentsApi() {
    return '$baseUrl/admin/departments';
  }
}
