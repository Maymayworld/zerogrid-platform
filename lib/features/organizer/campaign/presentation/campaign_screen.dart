// lib/features/organizer/campaign/presentation/campaign_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../project/presentation/widgets/project_card.dart';
import '../../project/presentation/edit_page.dart';

class CampaignScreen extends HookWidget {
  const CampaignScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.neutral100,
      appBar: AppBar(
        backgroundColor: ColorPalette.neutral100,
        elevation: 0,
        title: Text(
          'Campaign',
          style: TextStylePalette.header,
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: ColorPalette.neutral800),
            onPressed: () {
              // フィルター機能
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 検索バー
          Padding(
            padding: EdgeInsets.symmetric(horizontal: SpacePalette.base),
            child: Container(
              height: ButtonSizePalette.filter,
              decoration: BoxDecoration(
                color: ColorPalette.neutral0,
                borderRadius: BorderRadius.circular(RadiusPalette.base),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStylePalette.hintText,
                  prefixIcon: Icon(
                    Icons.search,
                    color: ColorPalette.neutral400,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: SpacePalette.sm),
                ),
              ),
            ),
          ),
          SizedBox(height: SpacePalette.base),
          
          // プロジェクトリスト
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = MediaQuery.of(context).size.width;
                final cardWidth = screenWidth - (SpacePalette.base * 2);
                final cardHeight = cardWidth * 9 / 16;

                return ListView.builder(
                  padding: EdgeInsets.only(
                    left: SpacePalette.base,
                    right: SpacePalette.base,
                    bottom: 80, // フッター分の余白
                  ),
                  itemCount: 3, // モックデータ
                  itemBuilder: (context, index) {
                    final projectNames = [
                      'Project Name',
                      'Project Name Very Long Long Long Long Project Name',
                      'Project Name Very Long Long Long Long Project Name 2',
                    ];
                    
                    return Padding(
                      padding: EdgeInsets.only(bottom: SpacePalette.base),
                      child: OrganizerProjectCard(
                        width: cardWidth,
                        height: cardHeight,
                        projectName: projectNames[index],
                        budget: 30000,
                        imageUrl: 'https://picsum.photos/seed/project${index + 1}/400/225',
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProjectScreen(
                                projectName: projectNames[index],
                                budget: 30000,
                                targetViews: 100000,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}