// lib/features/organizer/project/presentation/edit_project_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../../shared/theme/app_theme.dart';

class EditProjectScreen extends HookWidget {
  final String? projectName;
  final int? budget;
  final int? targetViews;

  const EditProjectScreen({
    Key? key,
    this.projectName,
    this.budget,
    this.targetViews,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final projectNameController = useTextEditingController(text: projectName ?? '');
    final targetViewsController = useTextEditingController(
      text: targetViews?.toString() ?? '',
    );
    final budgetController = useTextEditingController(
      text: budget?.toString() ?? '',
    );
    final categoryController = useTextEditingController();
    
    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      appBar: AppBar(
        backgroundColor: ColorPalette.neutral100,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorPalette.neutral800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Project',
          style: TextStylePalette.title,
        ),
        centerTitle: true,
        actions: [
          if (budget != null)
            Padding(
              padding: EdgeInsets.only(right: SpacePalette.base),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: SpacePalette.sm,
                    vertical: SpacePalette.xs,
                  ),
                  decoration: BoxDecoration(
                    color: ColorPalette.neutral0,
                    borderRadius: BorderRadius.circular(RadiusPalette.mini),
                  ),
                  child: Text(
                    '¥${budget!.toString().replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},',
                    )}',
                    style: TextStylePalette.smTitle,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(SpacePalette.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // サムネイルプレビュー
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(RadiusPalette.base),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF86EFAC), // green-300
                                Color(0xFF22C55E), // green-500
                              ],
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(RadiusPalette.base),
                            child: Stack(
                              children: [
                                // トーストアイコンの散らばり（デモ用）
                                Positioned(
                                  top: 20,
                                  left: 30,
                                  child: _ToastIcon(),
                                ),
                                Positioned(
                                  top: 60,
                                  right: 40,
                                  child: _ToastIcon(),
                                ),
                                Positioned(
                                  bottom: 40,
                                  left: 50,
                                  child: _ToastIcon(),
                                ),
                                Positioned(
                                  bottom: 30,
                                  right: 30,
                                  child: _ToastIcon(),
                                ),
                                Positioned(
                                  top: 100,
                                  left: 120,
                                  child: _ToastIcon(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: SpacePalette.sm,
                          right: SpacePalette.sm,
                          child: GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Image editing coming soon...')),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(SpacePalette.sm),
                              decoration: BoxDecoration(
                                color: ColorPalette.neutral800,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.edit,
                                size: 20,
                                color: ColorPalette.neutral0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: SpacePalette.lg),
                  
                  // Project Name
                  Text(
                    'Project Name',
                    style: TextStylePalette.smTitle,
                  ),
                  SizedBox(height: SpacePalette.sm),
                  TextField(
                    controller: projectNameController,
                    decoration: InputDecoration(
                      hintText: 'Groove Toast',
                      hintStyle: TextStylePalette.hintText,
                      filled: true,
                      fillColor: ColorPalette.neutral0,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(RadiusPalette.base),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.all(SpacePalette.base),
                    ),
                  ),
                  SizedBox(height: SpacePalette.base),
                  
                  // Target Views
                  Text(
                    'Target Views',
                    style: TextStylePalette.smTitle,
                  ),
                  SizedBox(height: SpacePalette.sm),
                  TextField(
                    controller: targetViewsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '200,000',
                      hintStyle: TextStylePalette.hintText,
                      suffixText: 'Views',
                      suffixStyle: TextStylePalette.normalText,
                      filled: true,
                      fillColor: ColorPalette.neutral0,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(RadiusPalette.base),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.all(SpacePalette.base),
                    ),
                  ),
                  SizedBox(height: SpacePalette.base),
                  
                  // Budget
                  Text(
                    'Budget',
                    style: TextStylePalette.smTitle,
                  ),
                  SizedBox(height: SpacePalette.sm),
                  TextField(
                    controller: budgetController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '3,000',
                      hintStyle: TextStylePalette.hintText,
                      prefixText: '¥ ',
                      prefixStyle: TextStylePalette.normalText,
                      filled: true,
                      fillColor: ColorPalette.neutral0,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(RadiusPalette.base),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.all(SpacePalette.base),
                    ),
                  ),
                  SizedBox(height: SpacePalette.base),
                  
                  // Category
                  Text(
                    'Category',
                    style: TextStylePalette.smTitle,
                  ),
                  SizedBox(height: SpacePalette.sm),
                  Container(
                    decoration: BoxDecoration(
                      color: ColorPalette.neutral0,
                      borderRadius: BorderRadius.circular(RadiusPalette.base),
                    ),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        hintText: 'Select category',
                        hintStyle: TextStylePalette.hintText,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(RadiusPalette.base),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.all(SpacePalette.base),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'Entertainment',
                          child: Text('Entertainment'),
                        ),
                        DropdownMenuItem(
                          value: 'Education',
                          child: Text('Education'),
                        ),
                        DropdownMenuItem(
                          value: 'Gaming',
                          child: Text('Gaming'),
                        ),
                        DropdownMenuItem(
                          value: 'Lifestyle',
                          child: Text('Lifestyle'),
                        ),
                        DropdownMenuItem(
                          value: 'Technology',
                          child: Text('Technology'),
                        ),
                      ],
                      onChanged: (value) {
                        // カテゴリー選択処理
                      },
                    ),
                  ),
                  SizedBox(height: SpacePalette.base),
                  
                  // Additional fields placeholder
                  Text(
                    'Views per Creator',
                    style: TextStylePalette.smTitle,
                  ),
                  SizedBox(height: SpacePalette.sm),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '1,000',
                      hintStyle: TextStylePalette.hintText,
                      suffixText: 'Views',
                      suffixStyle: TextStylePalette.normalText,
                      filled: true,
                      fillColor: ColorPalette.neutral0,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(RadiusPalette.base),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.all(SpacePalette.base),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Create/Update Projectボタン
          Container(
            padding: EdgeInsets.all(SpacePalette.base),
            decoration: BoxDecoration(
              color: ColorPalette.neutral100,
              border: Border(
                top: BorderSide(
                  color: ColorPalette.neutral200,
                  width: 1.5,
                ),
              ),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: ButtonSizePalette.button,
                child: ElevatedButton(
                  onPressed: () {
                    // プロジェクト作成/更新処理
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Project updated!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.neutral800,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(RadiusPalette.base),
                    ),
                  ),
                  child: Text(
                    projectName != null ? 'Update Project' : 'Create Project',
                    style: TextStylePalette.buttonTextWhite,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// トーストアイコン（デモ用）
class _ToastIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: ColorPalette.neutral0.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.wb_sunny,
        size: 24,
        color: ColorPalette.neutral0,
      ),
    );
  }
}