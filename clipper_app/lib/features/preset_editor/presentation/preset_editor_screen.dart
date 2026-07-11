import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../common/widgets/primary_gradient_button.dart';
import '../../../core/theme/colors.dart';
import 'providers/preset_providers.dart';

class PresetEditorScreen extends ConsumerStatefulWidget {
  const PresetEditorScreen({super.key});

  @override
  ConsumerState<PresetEditorScreen> createState() => _PresetEditorScreenState();
}

class _PresetEditorScreenState extends ConsumerState<PresetEditorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _nameController = TextEditingController();
  String _selectedColorGrading = 'Standard';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Defer reading providers until after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPresetData();
    });
  }

  void _loadPresetData() {
    final activeId = ref.read(activePresetIdProvider);
    if (activeId != null) {
      final presetsAsync = ref.read(presetsProvider);
      if (presetsAsync is AsyncData) {
        final presets = presetsAsync.value ?? [];
        try {
          final preset = presets.firstWhere((p) => p['id'] == activeId);
          setState(() {
            _nameController.text = preset['name'] ?? '';
            _selectedColorGrading = preset['color_grading'] ?? 'Standard';
          });
        } catch (_) {}
      }
    }
  }

  Future<void> _savePreset() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name cannot be empty')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final activeId = ref.read(activePresetIdProvider);
      await ref.read(presetControllerProvider).savePreset(
        activeId, 
        name, 
        _selectedColorGrading, 
        'Inter' // Default font style for now
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preset saved successfully')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deletePreset() async {
    final activeId = ref.read(activePresetIdProvider);
    if (activeId == null) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(presetControllerProvider).deletePreset(activeId);
      ref.read(activePresetIdProvider.notifier).state = null;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preset deleted')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = ref.watch(activePresetIdProvider) != null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
        title: Text(isEditing ? 'Edit Preset' : 'New Preset', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: _isLoading ? null : _deletePreset,
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: PrimaryGradientButton(
              onPressed: _isLoading ? null : _savePreset,
              child: _isLoading 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                  : const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PRESET NAME', style: TextStyle(fontSize: 10, letterSpacing: 1.2, color: Colors.white54)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'e.g. Mystery Trivia - Did You Know',
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                suffixIcon: const Icon(Icons.edit, color: Colors.white54),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.white24)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.white24)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.cyan)),
              ),
            ),
            const SizedBox(height: 24),
            
            // Preview
            Center(
              child: Container(
                width: 280,
                height: 498,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cyan.withOpacity(0.5)),
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 20)],
                  image: const DecorationImage(
                    image: NetworkImage('https://lh3.googleusercontent.com/aida/AP1WRLt8i-Czs2Ep9_QFZtT3lU34qgUqZRwjfN7WkWdCQ1rpaO_HYMjPuXY0IH3evK-KWAndjMvLlVz5VVCqPtUgF0h_X-vt_6R2JXEVjRpCFldv3DwCqIeBZwI4lAwJbKHcTXO05npZNc8IIkwJ4U0bORFZwGdNIgjbC-zYmTW-balO8lvWYJbgbQQ_H-te26sCRUUXu7oc3mcoVIUgh9ANhw8Axiae7NKcyZ0bYPHXdr-zmUZEtJ3k5jUCzOE7'),
                    fit: BoxFit.cover,
                    opacity: 0.8,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 16, left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.auto_awesome, color: AppColors.primary, size: 16),
                            SizedBox(width: 4),
                            Text('ProClip', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 48, left: 0, right: 0,
                      child: Column(
                        children: [
                          const Text('THIS IS HOW YOU\nTURN NOTHING INTO...', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, shadows: [Shadow(color: Colors.black87, blurRadius: 4)])),
                          const SizedBox(height: 8),
                          Text('ABSOLUTE\nAMAZING\nPROFIT!', textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.cyan, shadows: [Shadow(color: AppColors.cyan.withOpacity(0.5), blurRadius: 10)])),
                        ],
                      ),
                    ),
                    const Center(
                      child: Icon(Icons.play_circle_fill, size: 64, color: Colors.white54),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Editor Tabs Area
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    indicatorColor: AppColors.cyan,
                    labelColor: AppColors.cyan,
                    unselectedLabelColor: Colors.white54,
                    tabs: const [
                      Tab(text: 'Color Grading'),
                      Tab(text: 'Subtitle Style'),
                      Tab(text: 'Branding'),
                    ],
                  ),
                  SizedBox(
                    height: 200,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _ColorGradingTab(
                          selectedStyle: _selectedColorGrading,
                          onStyleSelected: (style) => setState(() => _selectedColorGrading = style),
                        ),
                        const Center(child: Text('Subtitle Editor Tools...')),
                        const Center(child: Text('Branding Editor Tools...')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorGradingTab extends StatelessWidget {
  final String selectedStyle;
  final ValueChanged<String> onStyleSelected;
  
  const _ColorGradingTab({required this.selectedStyle, required this.onStyleSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildThumbnail('Standard', 'https://lh3.googleusercontent.com/aida-public/AB6AXuArvWdxC5n2qZvb22Z6paVB7xZd6d6i3ecMpV3-s6-PH9DFLBD18DlKQcq3-xSNxd3D33lltzZcWpSA7IV5041Ev9ETd_Zhg_TdnGCsdQOr72NUgX2mnhcCs9CTVpBw6AHSfNyJqYCgjdWEllLsGYoIFIFfzelShyCTaxgBhbGCLO3GbpnYz9TMPI1_vCnJzXVwHm87lvdKlOewzeHCf4PzfCsubY2hFt-Ehzv1pVL9ARCvnCcsOengzw'),
                _buildThumbnail('Warm Cinematic', 'https://lh3.googleusercontent.com/aida-public/AB6AXuCa8Pkn8hq0JR8ou5-rbxfni079N_ZT3xNSvbVjCwxz4fyY9D7VCTCIXKLybGldaIXZEU5bQHMwOWhon_S7_Zx31oSmxtbyDGVYGmjAqwOlg_RKq2ZRePH_iorg4Lmt6JFWELTP-S-BSJUNaUB85SDPokcg7NebMozOFddTT5bx1f1c2-XcDFP-y6vHSj-gFhpl9dq2LEgMvnnKyBDUTxJS7mMrLkaN-SZANXMARu4_Y00Q5nRtcGYGmw'),
                _buildThumbnail('Desaturated Noir', 'https://lh3.googleusercontent.com/aida-public/AB6AXuDprVVx4-5xm1mdt31fzcaa8KxAYiEo2snhpQOWtdcyhWj0VNEUBBUNENAwMr6xWjUBS7W0qP9P5ewY5lmNSyohNJBXsOz8QSqslOVo54SFDeLdIXvZdYRYjC7p2PsMjBM9sYU9omPd5pMH5ysN8CwGNEjjLIMQBDID3L51-LZATR7c5uteEMs4HPLas7F8xjM8HkyxAdSkZK9xuPscVUU0cz8lFZBix5pPtwulIPyn359OcErniE5Y6A'),
                _buildThumbnail('High Contrast', 'https://lh3.googleusercontent.com/aida-public/AB6AXuDuRp32OlB9HPirvSZF05Je9PAvyJZJMUBqIqMRlmQEqfbpbDyF4c60TqMB2M1WN0fnaP2WK2CiMhv53aOsP2oE14_0JuOOmqeIAi9RtScFgFkxDT9oWnKUf2idstDSN_grl20uF_t3KluHO15jCLBTpTQuKPyjjlRKQpmKeusYDlO65FhI1myY9yWlNjmLLbuNpAGBgprnZ6oA0vDjq-EpCxTYQUWJlbMX5KWV4CSqqZffT9faZXHcQQ'),
                _buildThumbnail('Vibrant', 'https://lh3.googleusercontent.com/aida-public/AB6AXuBo10Q3fk6kJJQs4PVtk5H22QwydFrQbTJ789JehVeKB70LwT8DKUuUi7-BdqaiVZ3qTgG36AGfTwgoZWSNt2BN2glQfWiYp-xJg-0KPkSEYKhNqsmVd7YjkPX2oCozJK45AQN0xEzNPaZj9c-eiuALdof8m3As_XfFQQBZGTXsxBt_Qiyxz5qNyNvFcJhRT2qICHAwLR1QJNIK0eL-ii7F8Hx_yDrN5liTapGJ2hkPlRrR3YJ_aZoZTg'),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildThumbnail(String name, String url) {
    final isActive = selectedStyle == name;
    return GestureDetector(
      onTap: () => onStyleSelected(name),
      child: Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isActive ? AppColors.primary : Colors.white10, width: 2),
                image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover, colorFilter: isActive ? null : const ColorFilter.mode(Colors.black45, BlendMode.darken)),
              ),
            ),
            const SizedBox(height: 8),
            Text(name, style: TextStyle(fontSize: 10, color: isActive ? AppColors.primary : Colors.white54, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}
