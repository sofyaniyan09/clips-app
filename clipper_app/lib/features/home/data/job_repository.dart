import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

final jobRepositoryProvider = Provider<JobRepository>((ref) {
  return JobRepository(dio: ref.watch(dioProvider));
});

class JobRepository {
  final Dio _dio;

  JobRepository({required Dio dio}) : _dio = dio;

  Future<List<Map<String, dynamic>>> getJobs() async {
    final response = await _dio.get('/api/jobs/');
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<Map<String, dynamic>> uploadLink(String url) async {
    final response = await _dio.post('/api/upload/link', data: {'url': url});
    return response.data;
  }

  Future<Map<String, dynamic>> uploadFile({String? filePath, List<int>? bytes, required String fileName}) async {
    MultipartFile file;
    if (bytes != null) {
      file = MultipartFile.fromBytes(bytes, filename: fileName);
    } else if (filePath != null) {
      file = await MultipartFile.fromFile(filePath, filename: fileName);
    } else {
      throw Exception('Either filePath or bytes must be provided');
    }
    
    final formData = FormData.fromMap({
      'file': file,
    });
    final response = await _dio.post('/api/upload/file', data: formData);
    return response.data;
  }

  Future<Map<String, dynamic>> getJobStatus(String jobId) async {
    final response = await _dio.get('/api/jobs/$jobId/status');
    return response.data;
  }
}
