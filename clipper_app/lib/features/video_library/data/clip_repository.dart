import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

final clipRepositoryProvider = Provider<ClipRepository>((ref) {
  return ClipRepository(dio: ref.watch(dioProvider));
});

class ClipRepository {
  final Dio _dio;

  ClipRepository({required Dio dio}) : _dio = dio;

  Future<List<Map<String, dynamic>>> getClips() async {
    final response = await _dio.get('/api/clips/');
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<Map<String, dynamic>> getClipById(String id) async {
    final response = await _dio.get('/api/clips/$id');
    return response.data as Map<String, dynamic>;
  }
}
