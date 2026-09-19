enum UserRole { patient, doctor, admin }

extension UserRoleLabel on UserRole {
  String get label {
    switch (this) {
      case UserRole.patient:
        return 'Patient';
      case UserRole.doctor:
        return 'Doctor';
      case UserRole.admin:
        return 'Administrator';
    }
  }

  String get greeting {
    switch (this) {
      case UserRole.patient:
        return 'Find the right care for you';
      case UserRole.doctor:
        return 'Good morning, Dr. Wilson';
      case UserRole.admin:
        return 'Good morning, Sarah';
    }
  }
}
