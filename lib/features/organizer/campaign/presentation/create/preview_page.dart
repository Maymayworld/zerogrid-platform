// // lib/features/organizer/create/presentation/pages/preview_page.dart
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:zero_grid/features/auth/presentation/providers/user_profile_provider.dart';
// import 'package:zero_grid/features/organizer/campaign/presentation/providers/campaign_service_provider.dart';
// import 'package:zero_grid/features/organizer/campaign/presentation/providers/project_provider.dart';
// import 'package:zero_grid/shared/theme/app_theme.dart';

// class PreviewPage extends HookConsumerWidget {
//   const PreviewPage({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final project = ref.watch(projectProvider);
//     final profileState = ref.watch(userProfileProvider);
//     final profile = profileState.profile;
//     final width = MediaQuery.of(context).size.width;

//     final isLoading = useState(false);
//     final selectedImageBytes = useState<Uint8List?>(null);
//     final selectedImageName = useState<String?>(null);

//     final picker = ImagePicker();

//     // サムネイル選択
//     Future<void> pickThumbnail() async {
//       try {
//         final XFile? pickedFile = await picker.pickImage(
//           source: ImageSource.gallery,
//           maxWidth: 1280,
//           maxHeight: 720,
//           imageQuality: 85,
//         );

//         if (pickedFile != null) {
//           final bytes = await pickedFile.readAsBytes();
//           selectedImageBytes.value = bytes;
//           selectedImageName.value = pickedFile.name;
//         }
//       } catch (e) {
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to pick image: $e'), backgroundColor: Colors.red),
//           );
//         }
//       }
//     }

//     // 投稿処理
//     Future<void> handlePost() async {
//       isLoading.value = true;

//       try {
//         final campaignService = ref.read(campaignServiceProvider);
//         String? thumbnailUrl;

//         // サムネイルがあればアップロード
//         if (selectedImageBytes.value != null && selectedImageName.value != null) {
//           thumbnailUrl = await campaignService.uploadThumbnail(
//             selectedImageBytes.value!,
//             selectedImageName.value!,
//           );
//         }

//         // 案件登録
//         await campaignService.createCampaign(
//           project: project,
//           thumbnailUrl: thumbnailUrl,
//         );

//         // プロジェクト状態リセット
//         ref.read(projectProvider.notifier).reset();

//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Campaign posted successfully!'),
//               backgroundColor: ColorPalette.systemGreen,
//             ),
//           );
//           // ホーム画面に戻る（全てpop）
//           Navigator.of(context).popUntil((route) => route.isFirst);
//         }
//       } catch (e) {
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to post: $e'), backgroundColor: Colors.red),
//           );
//         }
//       } finally {
//         isLoading.value = false;
//       }
//     }

//     // 投稿可能かチェック
//     final canPost = project.projectName.isNotEmpty &&
//         project.description.isNotEmpty &&
//         project.category.isNotEmpty &&
//         project.platforms.isNotEmpty &&
//         project.targetViews > 0 &&
//         project.budget > 0 &&
//         project.endDate.isNotEmpty;

//     return Scaffold(
//       backgroundColor: ColorPalette.neutral0,
//       appBar: AppBar(
//         backgroundColor: ColorPalette.neutral0,
//         elevation: 0,
//         title: Text('Preview', style: TextStylePalette.title),
//         centerTitle: true,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: ColorPalette.neutral800),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.all(SpacePalette.base),
//           child: Column(
//             children: [
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       // サムネイル
//                       InkWell(
//                         onTap: pickThumbnail,
//                         child: Container(
//                           width: double.infinity,
//                           height: (width - SpacePalette.base * 2) * 9 / 16,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(RadiusPalette.base),
//                             color: ColorPalette.neutral100,
//                           ),
//                           child: selectedImageBytes.value != null
//                               ? ClipRRect(
//                                   borderRadius: BorderRadius.circular(RadiusPalette.base),
//                                   child: Image.memory(
//                                     selectedImageBytes.value!,
//                                     fit: BoxFit.cover,
//                                     width: double.infinity,
//                                     height: double.infinity,
//                                   ),
//                                 )
//                               : Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Icon(Icons.upload, size: 40, color: ColorPalette.neutral500),
//                                     SizedBox(height: SpacePalette.sm),
//                                     Text(
//                                       'Upload Image',
//                                       style: TextStylePalette.smallHeader.copyWith(
//                                         color: ColorPalette.neutral500,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                         ),
//                       ),
//                       SizedBox(height: SpacePalette.base),

//                       // プラットフォームチップ
//                       Row(
//                         children: [
//                           ...project.platforms.map((name) => Padding(
//                                 padding: EdgeInsets.only(right: SpacePalette.sm),
//                                 child: PlatformChip(platformName: name),
//                               )),
//                         ],
//                       ),
//                       SizedBox(height: SpacePalette.base),

//                       // プロジェクト名
//                       Align(
//                         alignment: Alignment.centerLeft,
//                         child: Text(
//                           project.projectName.isEmpty ? 'Project Name' : project.projectName,
//                           style: TextStylePalette.smallHeader,
//                         ),
//                       ),
//                       SizedBox(height: SpacePalette.base),

//                       // 単価
//                       Align(
//                         alignment: Alignment.centerLeft,
//                         child: Text(
//                           '￥${project.pricePerThousand.toStringAsFixed(0)} / 1000 Views',
//                           style: TextStylePalette.header,
//                         ),
//                       ),
//                       SizedBox(height: SpacePalette.base),

//                       Divider(color: ColorPalette.neutral200, height: 1),

//                       // 会社情報
//                       Padding(
//                         padding: EdgeInsets.symmetric(vertical: SpacePalette.base),
//                         child: Row(
//                           children: [
//                             CircleAvatar(
//                               radius: 20,
//                               backgroundColor: ColorPalette.neutral800,
//                               backgroundImage: profile?.avatarUrl != null
//                                   ? NetworkImage(profile!.avatarUrl!)
//                                   : null,
//                               child: profile?.avatarUrl == null
//                                   ? Text(
//                                       profile?.displayName.substring(0, 1).toUpperCase() ?? 'C',
//                                       style: TextStylePalette.smTitle.copyWith(
//                                         color: ColorPalette.neutral0,
//                                       ),
//                                     )
//                                   : null,
//                             ),
//                             SizedBox(width: SpacePalette.sm),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   profile?.displayName ?? 'Company Name',
//                                   style: TextStylePalette.smTitle,
//                                 ),
//                                 SizedBox(height: SpacePalette.xs),
//                                 Row(
//                                   children: [
//                                     Icon(Icons.star, size: 14, color: Color(0xFFFBBF24)),
//                                     SizedBox(width: SpacePalette.xs),
//                                     Text(
//                                       '4.9 (131 reviews)',
//                                       style: TextStylePalette.smSubText,
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),

//                       Divider(color: ColorPalette.neutral200, height: 1),
//                       SizedBox(height: SpacePalette.base),

//                       // Description
//                       Align(
//                         alignment: Alignment.centerLeft,
//                         child: Text('Description', style: TextStylePalette.smTitle),
//                       ),
//                       SizedBox(height: SpacePalette.sm),
//                       Align(
//                         alignment: Alignment.centerLeft,
//                         child: Text(
//                           project.description.isEmpty ? 'No description' : project.description,
//                           style: TextStylePalette.normalText,
//                         ),
//                       ),
//                       SizedBox(height: SpacePalette.base),

//                       Divider(color: ColorPalette.neutral200, height: 1),
//                       SizedBox(height: SpacePalette.base),

//                       // Resources
//                       if (project.links.isNotEmpty) ...[
//                         Align(
//                           alignment: Alignment.centerLeft,
//                           child: Text('Resources', style: TextStylePalette.smTitle),
//                         ),
//                         SizedBox(height: SpacePalette.sm),
//                         ...project.links.where((link) => link.isNotEmpty).map((link) => Padding(
//                               padding: EdgeInsets.only(bottom: SpacePalette.xs),
//                               child: Row(
//                                 children: [
//                                   Icon(Icons.link, size: 16, color: ColorPalette.neutral500),
//                                   SizedBox(width: SpacePalette.xs),
//                                   Expanded(
//                                     child: Text(
//                                       link,
//                                       style: TextStylePalette.smSubText,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             )),
//                         SizedBox(height: SpacePalette.base),
//                       ],
//                     ],
//                   ),
//                 ),
//               ),

//               // Postボタン
//               SizedBox(height: SpacePalette.base),
//               SizedBox(
//                 width: double.infinity,
//                 height: 48,
//                 child: ElevatedButton(
//                   onPressed: canPost && !isLoading.value ? handlePost : null,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: canPost ? ColorPalette.neutral800 : ColorPalette.neutral100,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(RadiusPalette.base),
//                     ),
//                   ),
//                   child: isLoading.value
//                       ? SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
//                         )
//                       : Text(
//                           'Post',
//                           style: canPost
//                               ? TextStylePalette.buttonTextWhite
//                               : TextStylePalette.buttonTextBlack.copyWith(
//                                   color: ColorPalette.neutral400,
//                                 ),
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class PlatformChip extends StatelessWidget {
//   final String platformName;

//   const PlatformChip({super.key, required this.platformName});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: ButtonSizePalette.tag,
//       padding: EdgeInsets.symmetric(horizontal: SpacePalette.sm),
//       decoration: BoxDecoration(
//         color: ColorPalette.neutral100,
//         border: Border.all(color: ColorPalette.neutral200, width: 1),
//         borderRadius: BorderRadius.circular(RadiusPalette.base),
//       ),
//       child: Center(
//         child: Text(platformName, style: TextStylePalette.smText),
//       ),
//     );
//   }
// }