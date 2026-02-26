// lib/features/creator/profile/presentation/pages/profile_detail_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import '../../../../auth/presentation/providers/user_profile_provider.dart';

class ProfileDetailScreen extends HookConsumerWidget {
  const ProfileDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(userProfileProvider);
    final profile = profileState.profile;

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: ColorPalette.neutral100,
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, size: 22),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const _ProfileEditScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(SpacePalette.base),
        child: Column(
          children: [
            SizedBox(height: SpacePalette.lg),
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: ColorPalette.neutral400,
              backgroundImage: profile?.avatarUrl != null
                  ? NetworkImage(profile!.avatarUrl!)
                  : null,
              child: profile?.avatarUrl == null
                  ? Text(
                      profile?.displayName.substring(0, 2).toUpperCase() ?? 'CR',
                      style: TextStylePalette.header.copyWith(
                        color: ColorPalette.white,
                      ),
                    )
                  : null,
            ),
            SizedBox(height: SpacePalette.base),
            // Display name
            Text(
              profile?.displayName ?? 'Loading...',
              style: TextStylePalette.smallHeader,
            ),
            SizedBox(height: SpacePalette.xs),
            // Username
            Text(
              '@${profile?.username ?? ''}',
              style: TextStylePalette.subText,
            ),
            SizedBox(height: SpacePalette.xs),
            // Role
            Text(
              'Creator',
              style: TextStylePalette.smSubText,
            ),
            SizedBox(height: 40),
            // Placeholder for future content (posts, liked content)
            Icon(
              Icons.grid_on_outlined,
              size: 48,
              color: ColorPalette.neutral300,
            ),
            SizedBox(height: SpacePalette.sm),
            Text(
              'No posts yet',
              style: TextStylePalette.subText,
            ),
          ],
        ),
      ),
    );
  }
}

/// プロフィール編集画面
class _ProfileEditScreen extends HookConsumerWidget {
  const _ProfileEditScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(userProfileProvider);
    final profile = profileState.profile;

    final nameController = useTextEditingController(
      text: profile?.displayName ?? '',
    );
    final isSaving = useState(false);
    final selectedImageBytes = useState<Uint8List?>(null);
    final selectedImageName = useState<String?>(null);

    final picker = ImagePicker();

    Future<void> pickImage(ImageSource source) async {
      Navigator.pop(context); // close bottom sheet
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
        builder: (ctx) => Container(
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

    Future<void> handleSave() async {
      final newName = nameController.text.trim();
      if (newName.isEmpty) return;

      isSaving.value = true;
      try {
        String? newAvatarUrl;

        // Upload new avatar if selected
        if (selectedImageBytes.value != null && selectedImageName.value != null) {
          final authService = ref.read(authServiceProvider);
          newAvatarUrl = await authService.uploadAvatarBytes(
            selectedImageBytes.value!,
            selectedImageName.value!,
          );
        }

        await ref.read(userProfileProvider.notifier).updateProfile(
          displayName: newName,
          avatarUrl: newAvatarUrl,
        );

        if (context.mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        isSaving.value = false;
      }
    }

    // Determine displayed image
    final hasNewImage = selectedImageBytes.value != null;
    final hasExistingImage = profile?.avatarUrl != null;

    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: ColorPalette.neutral100,
        actions: [
          TextButton(
            onPressed: isSaving.value ? null : handleSave,
            child: isSaving.value
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ColorPalette.smashedPumpkin600,
                    ),
                  )
                : Text(
                    'Save',
                    style: TextStylePalette.smTitle.copyWith(
                      color: ColorPalette.smashedPumpkin600,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(SpacePalette.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: SpacePalette.lg),
            // Avatar with edit overlay
            Center(
              child: GestureDetector(
                onTap: showImagePicker,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: ColorPalette.neutral400,
                      backgroundImage: hasNewImage
                          ? MemoryImage(selectedImageBytes.value!)
                          : (hasExistingImage
                              ? NetworkImage(profile!.avatarUrl!)
                              : null),
                      child: (!hasNewImage && !hasExistingImage)
                          ? Text(
                              profile?.displayName.substring(0, 2).toUpperCase() ?? 'CR',
                              style: TextStylePalette.header.copyWith(
                                color: ColorPalette.white,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: ColorPalette.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: ColorPalette.neutral200,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.camera_alt_outlined,
                          size: 16,
                          color: ColorPalette.neutral800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32),
            // Display Name
            Text('Display Name', style: TextStylePalette.smTitle),
            SizedBox(height: SpacePalette.sm),
            TextField(
              controller: nameController,
              style: TextStylePalette.normalText,
              decoration: InputDecoration(
                hintText: 'Enter your display name',
              ),
            ),
            SizedBox(height: SpacePalette.lg),
          ],
        ),
      ),
    );
  }
}
