import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

final presetRepositoryProvider = Provider<PresetRepository>((ref) {
  return PresetRepository(dio: ref.watch(dioProvider));
});

class PresetRepository {
  final Dio _dio;

  PresetRepository({required Dio dio}) : _dio = dio;

  Future<List<Map<String, dynamic>>> getPresets() async {
    final response = await _dio.get('/api/presets/');
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<Map<String, dynamic>> createPreset(Map<String, dynamic> data) async {
    final response = await _dio.post('/api/presets/', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> updatePreset(String id, Map<String, dynamic> data) async {
    final response = await _dio.put('/api/presets/$id', data: data);
    return response.data;
  }

  Future<void> deletePreset(String id) async {
    await _dio.delete('/api/presets/$id');
  }
}
