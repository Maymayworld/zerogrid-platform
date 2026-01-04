// lib/features/auth/data/models/user_role.dart
// 確認済み
enum UserRole {
  organizer,
  creator,
}

// UserRoleの拡張メソッド
extension UserRoleExtension on UserRole {
  // getter。thisにより変数的なのでこの形式
  // user = UserRole.organizer;など定義されていれば
  // thisはUserRole.organizerを指す
  String get displayName {
    switch (this) {
      case UserRole.organizer:
        return 'Organizer';
      case UserRole.creator:
        return 'Creator';
    }
  }
}