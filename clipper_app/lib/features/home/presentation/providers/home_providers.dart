import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/job_repository.dart';

final jobQueueProvider = StateNotifierProvider.autoDispose<JobQueueNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return JobQueueNotifier(ref.watch(jobRepositoryProvider));
});

class JobQueueNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final JobRepository _repo;
  Timer? _timer;

  JobQueueNotifier(this._repo) : super(const AsyncLoading()) {
    fetchJobs();
    _startPolling();
  }

  Future<void> fetchJobs() async {
    try {
      final jobs = await _repo.getJobs();
      // Sort jobs: active ones first, then by creation date
      jobs.sort((a, b) {
        final statusPriority = {'processing': 0, 'queued': 1, 'failed': 2, 'done': 3};
        final aPriority = statusPriority[a['status']] ?? 99;
        final bPriority = statusPriority[b['status']] ?? 99;
        if (aPriority != bPriority) return aPriority.compareTo(bPriority);
        return DateTime.parse(b['created_at']).compareTo(DateTime.parse(a['created_at']));
      });
      state = AsyncData(jobs);
    } catch (e, st) {
      if (state is! AsyncData) {
        state = AsyncError(e, st);
      }
    }
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      final currentState = state;
      if (currentState is AsyncData) {
        final jobs = currentState.value!;
        final hasActiveJobs = jobs.any((j) => j['status'] == 'queued' || j['status'] == 'processing');
        if (hasActiveJobs) {
          fetchJobs();
        }
      }
    });
  }

  Future<void> uploadLink(String url) async {
    try {
      await _repo.uploadLink(url);
      await fetchJobs();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadFile({String? filePath, List<int>? bytes, required String fileName}) async {
    try {
      await _repo.uploadFile(filePath: filePath, bytes: bytes, fileName: fileName);
      await fetchJobs();
    } catch (e) {
      rethrow;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// Local UI states
final homeActivePlatformProvider = StateProvider.autoDispose<String>((ref) => 'TikTok');
final homeActiveDurationRangeProvider = StateProvider.autoDispose<String>((ref) => '30-60s');
