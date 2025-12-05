// lib/screens/creator/profile/widgets/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_theme.dart';

class EditProfileScreen extends HookWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final nameController = useTextEditingController(text: 'Creator Name');
    final bioController = useTextEditingController(text: 'man of culture');
    final dateOfBirthController = useTextEditingController();

    void _showImagePickerSheet() {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          decoration: BoxDecoration(
            color: ColorPalette().neutral0,
            borderRadius: BorderRadius.vertical(top: Radius.circular(RadiusPalette.lg)),
          ),
          padding: EdgeInsets.all(SpacePalette.base),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ImagePickerOption(
                  icon: Icons.photo_library_outlined,
                  label: 'Choose From Library',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Choose from library...')),
                    );
                  },
                ),
                SizedBox(height: SpacePalette.sm),
                _ImagePickerOption(
                  icon: Icons.camera_alt_outlined,
                  label: 'Take Photo',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Take photo...')),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    void _selectDateOfBirth() async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: ColorPalette().neutral900,
              ),
            ),
            child: child!,
          );
        },
      );
      if (picked != null) {
        dateOfBirthController.text = '${picked.year}/${picked.month}/${picked.day}';
      }
    }

    return Scaffold(
      backgroundColor: ColorPalette().neutral0,
      appBar: AppBar(
        backgroundColor: ColorPalette().neutral0,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorPalette().neutral900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.inter(
            fontSize: FontSizePalette.md,
            fontWeight: FontWeight.w600,
            color: ColorPalette().neutral900,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(SpacePalette.base),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // プロフィール画像
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: ColorPalette().neutral300,
                            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=1'),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _showImagePickerSheet,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: ColorPalette().neutral900,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: ColorPalette().neutral0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: SpacePalette.xl),
                    
                    // Name
                    Text(
                      'Name',
                      style: GoogleFonts.inter(
                        fontSize: FontSizePalette.sm,
                        fontWeight: FontWeight.w600,
                        color: ColorPalette().neutral900,
                      ),
                    ),
                    SizedBox(height: SpacePalette.sm),
                    TextField(
                      controller: nameController,
                      style: GoogleFonts.inter(
                        fontSize: FontSizePalette.base,
                        color: ColorPalette().neutral900,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter your name',
                        hintStyle: GoogleFonts.inter(
                          fontSize: FontSizePalette.base,
                          color: ColorPalette().neutral400,
                        ),
                        filled: true,
                        fillColor: ColorPalette().neutral100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(RadiusPalette.sm),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.all(SpacePalette.base),
                      ),
                    ),
                    SizedBox(height: SpacePalette.base),
                    
                    // Bio
                    Text(
                      'Bio',
                      style: GoogleFonts.inter(
                        fontSize: FontSizePalette.sm,
                        fontWeight: FontWeight.w600,
                        color: ColorPalette().neutral900,
                      ),
                    ),
                    SizedBox(height: SpacePalette.sm),
                    TextField(
                      controller: bioController,
                      style: GoogleFonts.inter(
                        fontSize: FontSizePalette.base,
                        color: ColorPalette().neutral900,
                      ),
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Tell us about yourself',
                        hintStyle: GoogleFonts.inter(
                          fontSize: FontSizePalette.base,
                          color: ColorPalette().neutral400,
                        ),
                        filled: true,
                        fillColor: ColorPalette().neutral100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(RadiusPalette.sm),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.all(SpacePalette.base),
                      ),
                    ),
                    SizedBox(height: SpacePalette.base),
                    
                    // Date of Birth
                    Text(
                      'Date of Birth',
                      style: GoogleFonts.inter(
                        fontSize: FontSizePalette.sm,
                        fontWeight: FontWeight.w600,
                        color: ColorPalette().neutral900,
                      ),
                    ),
                    SizedBox(height: SpacePalette.sm),
                    GestureDetector(
                      onTap: _selectDateOfBirth,
                      child: Container(
                        padding: EdgeInsets.all(SpacePalette.base),
                        decoration: BoxDecoration(
                          color: ColorPalette().neutral100,
                          borderRadius: BorderRadius.circular(RadiusPalette.sm),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dateOfBirthController.text.isEmpty
                                  ? 'Select date'
                                  : dateOfBirthController.text,
                              style: GoogleFonts.inter(
                                fontSize: FontSizePalette.base,
                                color: dateOfBirthController.text.isEmpty
                                    ? ColorPalette().neutral400
                                    : ColorPalette().neutral900,
                              ),
                            ),
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: ColorPalette().neutral400,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Save Button
            Container(
              padding: EdgeInsets.all(SpacePalette.base),
              decoration: BoxDecoration(
                color: ColorPalette().neutral0,
                border: Border(
                  top: BorderSide(
                    color: ColorPalette().neutral200,
                    width: 1,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: ButtonSizePalette.heightMd,
                child: ElevatedButton(
                  onPressed: () {
                    // 保存処理（後で実装）
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Profile updated!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette().neutral900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(RadiusPalette.sm),
                    ),
                  ),
                  child: Text(
                    'Save',
                    style: GoogleFonts.inter(
                      fontSize: FontSizePalette.md,
                      fontWeight: FontWeight.w600,
                      color: ColorPalette().neutral0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 画像選択オプション
class _ImagePickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImagePickerOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(SpacePalette.base),
        decoration: BoxDecoration(
          color: ColorPalette().neutral100,
          borderRadius: BorderRadius.circular(RadiusPalette.base),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: ColorPalette().neutral800,
            ),
            SizedBox(width: SpacePalette.base),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: FontSizePalette.base,
                fontWeight: FontWeight.w600,
                color: ColorPalette().neutral900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}