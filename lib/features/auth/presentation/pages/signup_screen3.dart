// lib/features/auth/presentation/pages/signup_screen3.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../data/models/user_role.dart';
import '../providers/auth_provider.dart';
import 'signup_success_screen.dart';

class SignUpScreen3 extends HookConsumerWidget {
  final UserRole role;
  final String email;
  final String password;
  final String username;

  const SignUpScreen3({
    Key? key,
    required this.role,
    required this.email,
    required this.password,
    required this.username,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayNameController = useTextEditingController();
    final isLoading = useState(false);
    // Web対応: Uint8Listで画像を保持
    final selectedImageBytes = useState<Uint8List?>(null);
    final selectedImageName = useState<String?>(null);
    final hasDisplayName = useState(false);

    final picker = ImagePicker();

    // 画像選択（Web対応）
    Future<void> pickImage(ImageSource source) async {
      Navigator.pop(context);

      try {
        final XFile? pickedFile = await picker.pickImage(
          source: source,
          maxWidth: 512,
          maxHeight: 512,
          imageQuality: 80,
        );

        if (pickedFile != null) {
          // XFileからbytesを取得（Web/Mobile両対応）
          final bytes = await pickedFile.readAsBytes();
          selectedImageBytes.value = bytes;
          selectedImageName.value = pickedFile.name;
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to pick image: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }

    void showImagePicker() {
      showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(RadiusPalette.lg)),
        ),
        builder: (context) => Container(
          padding: EdgeInsets.all(SpacePalette.base),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ColorPalette.neutral200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: SpacePalette.lg),
              ListTile(
                leading: Icon(Icons.image_outlined, color: ColorPalette.neutral800),
                title: Text('Choose From Library', style: TextStylePalette.normalText),
                onTap: () => pickImage(ImageSource.gallery),
              ),
              Divider(color: ColorPalette.neutral200),
              ListTile(
                leading: Icon(Icons.camera_alt_outlined, color: ColorPalette.neutral800),
                title: Text('Take Photo', style: TextStylePalette.normalText),
                onTap: () => pickImage(ImageSource.camera),
              ),
              SizedBox(height: SpacePalette.base),
            ],
          ),
        ),
      );
    }

    // signup_screen3.dart の handleCreateAccount を修正
Future<void> handleCreateAccount() async {
  if (displayNameController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please enter a display name'), backgroundColor: Colors.red),
    );
    return;
  }

  isLoading.value = true;

  try {
    final authService = ref.read(authServiceProvider);

    // 1. Supabase Authでユーザー作成
    final response = await authService.signUpWithEmail(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Failed to create user');
    }

    // 2. アバター画像をアップロード（選択されていれば）
    String? avatarUrl;
    if (selectedImageBytes.value != null && selectedImageName.value != null) {
      try {
        avatarUrl = await authService.uploadAvatarBytes(
          selectedImageBytes.value!,
          selectedImageName.value!,
        );
      } catch (e) {
        // アバターアップロード失敗は無視（オプションだから）
        print('Avatar upload failed: $e');
      }
    }

    // 3. プロフィールをDBに保存
    try {
      await authService.createProfile(
        username: username,
        displayName: displayNameController.text,
        role: role.name,
        avatarUrl: avatarUrl,
      );
    } catch (e) {
      // プロフィール作成失敗 → Authユーザーも削除してやり直し
      print('Profile creation failed, signing out: $e');
      await authService.signOut();
      rethrow;
    }

    // 4. 成功画面へ
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SignUpSuccessScreen(role: role)),
        (route) => false,
      );
    }
  } on AuthException catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  } finally {
    isLoading.value = false;
  }
}

    // DisplayName監視
    useEffect(() {
      void listener() {
        hasDisplayName.value = displayNameController.text.trim().isNotEmpty;
      }
      displayNameController.addListener(listener);
      return () => displayNameController.removeListener(listener);
    }, [displayNameController]);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: ColorPalette.neutral800, size: 20),
          label: Text('Back', style: TextStylePalette.normalText),
        ),
        leadingWidth: 100,
      ),
      body: SafeArea(
        child: SingleChildScrollView(  // オーバーフロー対策
          child: Padding(
            padding: const EdgeInsets.all(SpacePalette.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Set Up Your Profile', style: TextStylePalette.header),
                SizedBox(height: SpacePalette.sm),
                Text('Choose how you\'ll appear to others', style: TextStylePalette.subText),
                SizedBox(height: SpacePalette.lg),

                // プロフィール画像
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: ColorPalette.neutral100,
                          shape: BoxShape.circle,
                        ),
                        child: selectedImageBytes.value != null
                            ? ClipOval(
                                child: Image.memory(  // Image.file → Image.memory
                                  selectedImageBytes.value!,
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                ),
                              )
                            : Icon(
                                Icons.person_outline,
                                size: 50,
                                color: ColorPalette.neutral400,
                              ),
                      ),
                      SizedBox(height: SpacePalette.base),
                      OutlinedButton.icon(
                        onPressed: showImagePicker,
                        icon: Icon(Icons.upload_outlined, size: 18, color: ColorPalette.neutral800),
                        label: Text('Upload Profile Picture', style: TextStylePalette.smTitle),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: ColorPalette.neutral800),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(RadiusPalette.base),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: SpacePalette.base, vertical: SpacePalette.sm),
                        ),
                      ),
                      SizedBox(height: SpacePalette.xs),
                      Text('(optional)', style: TextStylePalette.smSubText),
                    ],
                  ),
                ),
                SizedBox(height: SpacePalette.lg),

                // Display Name
                Text('Display Name', style: TextStylePalette.smTitle),
                SizedBox(height: SpacePalette.sm),
                SizedBox(
                  height: 48,
                  child: TextField(
                    controller: displayNameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(RadiusPalette.base),
                        borderSide: BorderSide(color: ColorPalette.neutral200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(RadiusPalette.base),
                        borderSide: BorderSide(color: ColorPalette.neutral200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(RadiusPalette.base),
                        borderSide: BorderSide(color: ColorPalette.neutral800, width: 2),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: SpacePalette.base, vertical: SpacePalette.inner),
                    ),
                  ),
                ),
                SizedBox(height: SpacePalette.lg),

                // Create Account Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: hasDisplayName.value && !isLoading.value ? handleCreateAccount : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasDisplayName.value ? ColorPalette.neutral800 : ColorPalette.neutral100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(RadiusPalette.base),
                      ),
                    ),
                    child: isLoading.value
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'Create Account',
                            style: hasDisplayName.value
                                ? TextStylePalette.buttonTextWhite
                                : TextStylePalette.buttonTextBlack.copyWith(color: ColorPalette.neutral400),
                          ),
                  ),
                ),
                SizedBox(height: SpacePalette.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}