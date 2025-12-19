// // lib/features/organizer/chat/presentation/chat_screen.dart
// import 'package:flutter/material.dart';
// import '../../../../shared/theme/app_theme.dart';

// class ChatScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       appBar: AppBar(
//         backgroundColor: backgroundColor,
//         elevation: 0,
//         title: Text(
//           'Chat',
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: FontSizePalette.size24,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.chat_bubble, size: 80, color: Colors.grey[300]),
//             SizedBox(height: SpacePalette.base),
//             Text(
//               'Chat Page',
//               style: TextStyle(
//                 fontSize: FontSizePalette.size24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey[400],
//               ),
//             ),
//             SizedBox(height: SpacePalette.sm),
//             Text(
//               'Coming soon...',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }