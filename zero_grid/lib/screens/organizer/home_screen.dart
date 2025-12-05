// lib/screens/organizer/home_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'Home',
          style: TextStyle(
            color: Colors.black,
            fontSize: FontSizePalette.lg,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home, size: 80, color: Colors.grey[300]),
            SizedBox(height: SpacePalette.base),
            Text(
              'Home Page',
              style: TextStyle(
                fontSize: FontSizePalette.lg,
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