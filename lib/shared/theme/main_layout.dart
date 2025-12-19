// lib/screens/main_layout.dart
import 'package:flutter/material.dart';
import '../../features/auth/data/models/user_role.dart';
import 'creator_main_layout.dart';
import 'organizer_main_layout.dart';

class MainLayout extends StatelessWidget {
  final UserRole userRole;

  const MainLayout({
    Key? key,
    required this.userRole,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ロールに応じて適切なレイアウトを返す
    switch (userRole) {
      case UserRole.creator:
        return CreatorMainLayout();
      case UserRole.organizer:
        return OrganizerMainLayout();
    }
  }
}