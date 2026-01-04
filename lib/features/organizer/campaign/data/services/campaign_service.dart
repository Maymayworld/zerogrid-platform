// lib/features/organizer/create/data/services/campaign_service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/project.dart';
import '../models/campaign.dart';

class CampaignService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 案件を登録
  Future<Map<String, dynamic>> createCampaign({
    required Project project,
    String? thumbnailUrl,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    final deadlineParts = project.endDate.split('/');
    final deadline = DateTime(
      int.parse(deadlineParts[0]),
      int.parse(deadlineParts[1]),
      int.parse(deadlineParts[2]),
    );

    final response = await _supabase.from('campaigns').insert({
      'organizer_id': userId,
      'name': project.projectName,
      'description': project.description,
      'thumbnail_url': thumbnailUrl,
      'budget': project.budget,
      'target_views': project.targetViews,
      'category': project.category,
      'platform': jsonEncode(project.platforms),
      'deadline': deadline.toIso8601String(),
      'resources': project.links,
      'status': 'active',
    }).select().single();

    return response;
  }

  // 案件を1件取得
  Future<Campaign?> getCampaign(String campaignId) async {
    final response = await _supabase
        .from('campaigns')
        .select()
        .eq('id', campaignId)
        .maybeSingle();

    if (response == null) return null;
    return Campaign.fromMap(response);
  }

  // 自分の案件一覧を取得
  Future<List<Campaign>> getMyCampaigns() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    final response = await _supabase
        .from('campaigns')
        .select()
        .eq('organizer_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((map) => Campaign.fromMap(map))
        .toList();
  }

  // 案件を更新
  Future<Campaign> updateCampaign({
    required String campaignId,
    String? name,
    String? description,
    String? thumbnailUrl,
    int? budget,
    int? targetViews,
    String? category,
    List<String>? platforms,
    DateTime? deadline,
    List<String>? resources,
    String? status,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (name != null) updates['name'] = name;
    if (description != null) updates['description'] = description;
    if (thumbnailUrl != null) updates['thumbnail_url'] = thumbnailUrl;
    if (budget != null) updates['budget'] = budget;
    if (targetViews != null) updates['target_views'] = targetViews;
    if (category != null) updates['category'] = category;
    if (platforms != null) updates['platform'] = jsonEncode(platforms);
    if (deadline != null) updates['deadline'] = deadline.toIso8601String();
    if (resources != null) updates['resources'] = resources;
    if (status != null) updates['status'] = status;

    final response = await _supabase
        .from('campaigns')
        .update(updates)
        .eq('id', campaignId)
        .select()
        .single();

    return Campaign.fromMap(response);
  }

  // 案件を削除
  Future<void> deleteCampaign(String campaignId) async {
    await _supabase.from('campaigns').delete().eq('id', campaignId);
  }

  // サムネイル画像アップロード
  Future<String> uploadThumbnail(Uint8List imageBytes, String fileName) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    final fileExt = fileName.split('.').last;
    final filePath = '$userId/${DateTime.now().millisecondsSinceEpoch}.$fileExt';

    await _supabase.storage.from('campaign-thumbnails').uploadBinary(
      filePath,
      imageBytes,
      fileOptions: FileOptions(upsert: true, contentType: 'image/$fileExt'),
    );

    return _supabase.storage.from('campaign-thumbnails').getPublicUrl(filePath);
  }
}