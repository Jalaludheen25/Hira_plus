enum UserRole {
  driver('driver', 'Driver'),
  accountant('accountant', 'Accountant'),
  member('member', 'Member');

  const UserRole(this.value, this.displayName);

  final String value;
  final String displayName;

  static UserRole? fromString(String? value) {
    if (value == null || value.isEmpty) return null;
    switch (value.toLowerCase()) {
      case 'driver':
        return UserRole.driver;
      case 'accountant':
        return UserRole.accountant;
      case 'member':
        return UserRole.member;
      default:
        return null; // Return null for unknown values
    }
  }

  static List<UserRole> get allRoles => UserRole.values;

  // Helper method to check if this role maps to isDriver
  bool get isDriverRole => this == UserRole.driver;

  // Helper to convert enum to API string
  String toApiString() => value;
}
