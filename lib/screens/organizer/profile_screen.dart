// lib/screens/organizer/profile_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: FontSizePalette.size24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 80, color: Colors.grey[300]),
            SizedBox(height: SpacePalette.base),
            Text(
              'Profile Page',
              style: TextStyle(
                fontSize: FontSizePalette.size24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: SpacePalette.sm),
            Text(
              'Coming soon...',
            ),
          ],
        ),
      ),
    );
  }
}