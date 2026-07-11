import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_client.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    dio: ref.watch(dioProvider),
    secureStorage: ref.watch(secureStorageProvider),
  );
});

final authStateProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

final userEmailProvider = FutureProvider.autoDispose<String?>((ref) async {
  final repository = ref.watch(authRepositoryProvider);
  return repository.getUserEmail();
});

class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  AuthRepository({
    required Dio dio,
    required FlutterSecureStorage secureStorage,
  })  : _dio = dio,
        _secureStorage = secureStorage;

  Future<void> login(String email, String password) async {
    try {
      final response = await _dio.post('/api/auth/login', data: {
        'email': email,
        'password': password,
      });

      final token = response.data['access_token'];
      final user = response.data['user'];
      if (token != null) {
        await _secureStorage.write(key: 'jwt_token', value: token);
        if (user != null && user['email'] != null) {
          await _secureStorage.write(key: 'user_email', value: user['email']);
        }
      } else {
        throw Exception("No token received");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 400) {
        throw Exception(e.response?.data['detail'] ?? "Login failed");
      }
      throw Exception("Network error occurred");
    }
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'jwt_token');
    await _secureStorage.delete(key: 'user_email');
  }

  Future<String?> getUserEmail() async {
    String? email = await _secureStorage.read(key: 'user_email');
    if (email != null) return email;
    
    // Fallback: decode from JWT
    final token = await _secureStorage.read(key: 'jwt_token');
    if (token != null) {
      try {
        final parts = token.split('.');
        if (parts.length == 3) {
          String payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
          switch (payload.length % 4) {
            case 2: payload += '=='; break;
            case 3: payload += '='; break;
          }
          final decoded = utf8.decode(base64Url.decode(payload));
          final map = json.decode(decoded);
          email = map['email'];
          if (email != null) {
             await _secureStorage.write(key: 'user_email', value: email);
          }
        }
      } catch (e) {
        // ignore
      }
    }
    return email;
  }

  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.read(key: 'jwt_token');
    return token != null;
  }
}

class AuthNotifier extends StateNotifier<bool> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(false) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    state = await _repository.isAuthenticated();
  }

  Future<void> login(String email, String password) async {
    await _repository.login(email, password);
    state = true;
  }

  Future<void> logout() async {
    await _repository.logout();
    state = false;
  }
}
