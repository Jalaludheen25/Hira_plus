enum UserRole {
  driver('driver', 'Driver');

  const UserRole(this.value, this.displayName);

  final String value;
  final String displayName;

  static UserRole? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    switch (value.toLowerCase()) {
      case 'driver':
        return UserRole.driver;
      default:
        return null; // Return null for unknown values
    }
  }

  static List<UserRole> get allRoles => UserRole.values;

  // Helper method to check if this role maps to isDriver
  bool get isDriverRole => this == UserRole.driver;
}
