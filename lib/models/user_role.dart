// lib/models/user_role.dart
enum UserRole {
  organizer,
  creator,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.organizer:
        return 'Organizer';
      case UserRole.creator:
        return 'Creator';
    }
  }
}