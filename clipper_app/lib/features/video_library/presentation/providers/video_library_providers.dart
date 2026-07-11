import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/clip_repository.dart';

final videoLibraryProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return ref.watch(clipRepositoryProvider).getClips();
});

final selectedClipsProvider = StateProvider.autoDispose<Set<String>>((ref) => {});

final clipDetailProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, id) {
  return ref.watch(clipRepositoryProvider).getClipById(id);
});
