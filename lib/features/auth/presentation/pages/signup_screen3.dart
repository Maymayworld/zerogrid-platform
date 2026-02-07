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
import 'login_screen.dart';
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
          print('Profile creation failed, signing out: $e');
          await authService.signOut();
          rethrow;
        }

        // 4. 成功画面へ
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => SignUpSuccessScreen(
                role: role,
                username: username,
                avatarBytes: selectedImageBytes.value,
              ),
            ),
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
      backgroundColor: ColorPalette.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorPalette.neutral800),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SpacePalette.base),
          child: Column(
            children: [
              // プログレスバー（ステップ 2/3）
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 2 / 3,
                  minHeight: 4,
                  backgroundColor: ColorPalette.neutral200,
                  valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.neutral800),
                ),
              ),
              SizedBox(height: SpacePalette.lg),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 上部スペース
                      SizedBox(height: 40),

                      // プロフィール画像
                      GestureDetector(
                        onTap: showImagePicker,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: ColorPalette.neutral100,
                            shape: BoxShape.circle,
                            border: Border.all(color: ColorPalette.neutral200),
                          ),
                          child: selectedImageBytes.value != null
                              ? ClipOval(
                                  child: Image.memory(
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
                      ),
                      SizedBox(height: SpacePalette.base),

                      // Upload Profile Picture ボタン（Duolingoアウトラインスタイル）
                      DuolingoOutlineButton(
                        onPressed: showImagePicker,
                        text: 'Upload Profile Picture',
                        icon: Icons.upload_outlined,
                      ),
                      SizedBox(height: SpacePalette.xs),
                      Text('(optional)', style: TextStylePalette.smSubText),
                      SizedBox(height: SpacePalette.lg),

                      // Display Name
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Display Name', style: TextStylePalette.smTitle),
                      ),
                      SizedBox(height: SpacePalette.sm),
                      SizedBox(
                        height: ButtonSizePalette.button,
                        child: TextField(
                          controller: displayNameController,
                          decoration: InputDecoration(
                            hintText: 'Enter Display Name',
                            hintStyle: TextStylePalette.hintText,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: SpacePalette.base,
                              vertical: SpacePalette.inner,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: SpacePalette.lg),
                    ],
                  ),
                ),
              ),

              // Create Account Button（Duolingoスタイル）
              DuolingoButton(
                onPressed: handleCreateAccount,
                isEnabled: hasDisplayName.value,
                isLoading: isLoading.value,
                text: 'Create Account',
              ),
              SizedBox(height: SpacePalette.base),
            ],
          ),
        ),
      ),
    );
  }
}
