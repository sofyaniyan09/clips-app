import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/preset_repository.dart';

final presetsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return ref.watch(presetRepositoryProvider).getPresets();
});

final activePresetIdProvider = StateProvider.autoDispose<String?>((ref) => null);

final presetControllerProvider = Provider((ref) => PresetController(ref));

class PresetController {
  final Ref _ref;
  PresetController(this._ref);

  Future<void> savePreset(String? id, String name, String colorGrading, String fontStyle) async {
    final repo = _ref.read(presetRepositoryProvider);
    if (id != null) {
      await repo.updatePreset(id, {'name': name, 'color_grading': colorGrading, 'font_style': fontStyle});
    } else {
      await repo.createPreset({'name': name, 'color_grading': colorGrading, 'font_style': fontStyle});
    }
    _ref.invalidate(presetsProvider);
  }

  Future<void> deletePreset(String id) async {
    final repo = _ref.read(presetRepositoryProvider);
    await repo.deletePreset(id);
    _ref.invalidate(presetsProvider);
  }
}
