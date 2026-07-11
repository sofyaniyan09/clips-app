import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/primary_gradient_button.dart';
import '../../../core/theme/colors.dart';
import '../../preset_editor/presentation/providers/preset_providers.dart';
import '../../auth/data/auth_repository.dart';
import 'providers/home_providers.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool _isUploading = false;

  Future<void> _handleUpload() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() => _isUploading = true);
    try {
      await ref.read(jobQueueProvider.notifier).uploadLink(url);
      _urlController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job added to queue!'), backgroundColor: AppColors.primary),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _handleFileUpload() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        withData: true, // Required for Web to get bytes
      );

      if (result != null) {
        final file = result.files.single;
        
        setState(() => _isUploading = true);
        
        if (file.bytes != null) {
          await ref.read(jobQueueProvider.notifier).uploadFile(bytes: file.bytes, fileName: file.name);
        } else if (file.path != null) {
          await ref.read(jobQueueProvider.notifier).uploadFile(filePath: file.path, fileName: file.name);
        } else {
          throw Exception("Could not read file data");
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Local file added to queue!'), backgroundColor: AppColors.primary),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File upload failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final presetsAsync = ref.watch(presetsProvider);
    final activePresetId = ref.watch(activePresetIdProvider);
    final jobQueueAsync = ref.watch(jobQueueProvider);
    final activePlatform = ref.watch(homeActivePlatformProvider);
    final activeDuration = ref.watch(homeActiveDurationRangeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.movie_filter, color: AppColors.primary),
            const SizedBox(width: 8),
            ShaderMask(
              shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
              child: const Text('Clipper.AI', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: const NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCpt9MTAb98QL2QfDgF6eAKE3jlOylmJH1wbluG7Vb--GKqVC23Eod_lSbFFUMYS20ocRFVnOWdNF1kbT1x_deE3hHHFaswZVAuxC4ZgwzZTS9ZrlBb-Z3JldSSsa6P6s-tzZm1xqM8FzFkpITMNuFAJHTede287iUUtdG5mEVowSfGZyoeqFP40hGrncYFr7VqtHQ8QIVm0CIL6-OtwlGeDYoQ-33vgRlvYx6n5K5TrwGtFo6dxvNn3A'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input Section
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                hintText: 'Paste YouTube, TikTok, or Drive link...',
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                prefixIcon: const Icon(Icons.link, color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.cyan),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: PrimaryGradientButton(
                onPressed: _isUploading ? null : _handleUpload,
                child: Text(_isUploading ? 'Analyzing...' : 'Analyze'),
              ),
            ),
            const SizedBox(height: 24),
            
            // Upload Local File
            GestureDetector(
              onTap: _isUploading ? null : _handleFileUpload,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24, style: BorderStyle.solid),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.cloud_upload, size: 40, color: Colors.white54),
                    SizedBox(height: 8),
                    Text('Upload Local File (MP4)', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Settings Grid
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Target Platform', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ['TikTok', 'Reels', 'Shorts'].map((platform) {
                          final isSelected = activePlatform == platform;
                          return ChoiceChip(
                            label: Text(platform),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                ref.read(homeActivePlatformProvider.notifier).state = platform;
                              }
                            },
                            backgroundColor: Colors.transparent,
                            selectedColor: AppColors.cyan.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: isSelected ? AppColors.cyan : Colors.white24),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Clip Duration', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: activeDuration,
                            dropdownColor: const Color(0xFF1F1F22),
                            items: ['15-30s', '30-60s', '60-90s'].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                ref.read(homeActiveDurationRangeProvider.notifier).state = val;
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Production Presets
            const Text('Production Presets', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: presetsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error loading presets: $e', style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => ref.read(authStateProvider.notifier).logout(),
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout & Relogin'),
                      )
                    ]
                  )
                ),
                data: (presets) => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: presets.length + 1,
                  itemBuilder: (context, index) {
                    if (index == presets.length) {
                      return Container(
                        width: 200,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                color: Colors.white.withOpacity(0.02),
                                child: const Icon(Icons.add, size: 40, color: Colors.white54),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Create Custom', style: TextStyle(fontWeight: FontWeight.bold)),
                                  SizedBox(height: 4),
                                  Text('Design your own workflow.', style: TextStyle(fontSize: 12, color: Colors.white54)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final preset = presets[index];
                    final isSelected = activePresetId == preset['id'];
                    return GestureDetector(
                      onTap: () {
                        ref.read(activePresetIdProvider.notifier).state = preset['id'];
                      },
                      child: Container(
                        width: 200,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.cyan : Colors.white10,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  image: DecorationImage(
                                    image: NetworkImage(index % 2 == 0 
                                      ? 'https://lh3.googleusercontent.com/aida-public/AB6AXuB6BOvHxsg_MOf_sbmTAO2_DDhEoRpBZMSxGtNZ9UFWj4lQHy8WbX7z0-52FdhTK0qn6zLPfOhLanoVyhheIDv2dh4JT6_MgkWyUows1V9hpnFbMYCPMnXXGF7O7nZZ_tlOpZuLl94XjSlaMePtTmCojAVJCf3_krHlT_IYHHx1avhUUO5k_zaUoBPJdXwwgltMTzIad4guSELonr2ydhwwhbTAaYvxez2LpyWbq_xhnMMWYJb7ynljHQ' 
                                      : 'https://lh3.googleusercontent.com/aida-public/AB6AXuA3HUVH-WtajD3qCqSyHj_X_Z5HD4Wj-mkq3fSX5gbCHKZNCe7AwAEJH3J6wCsy7gZBUX-hm9U0tpsaM8TWTIH6eOe7EmhpjB68Wf4_lzW7HEKdbTo6hE-5g5bEp6P8jfrqBI5Omt99lPCa5sTUyCFckA2lWvbblFp_GBXmAjHalxbP-jCfQAY3_b09k0_Eyjs_ExqvN_wdCEyAstV4SOAY_LSy6lmccydCEYInzm5KoXyRz9Rkq83gfw'),
                                    fit: BoxFit.cover,
                                  )
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(preset['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Text(preset['color_grading'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.white54)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Active Queue
            const Text('Active Queue', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            jobQueueAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error loading jobs: $e', style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => ref.read(authStateProvider.notifier).logout(),
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout & Relogin'),
                    )
                  ]
                )
              ),
              data: (jobQueue) {
                if (jobQueue.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No active jobs. Upload a link to start!', style: TextStyle(color: Colors.white54)),
                    ),
                  );
                }
                
                return Column(
                  children: jobQueue.map((job) {
                    final isProcessing = job['status'] == 'processing';
                    final isQueued = job['status'] == 'queued';
                    final isFailed = job['status'] == 'failed';
                    final isDone = job['status'] == 'done';
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border(left: BorderSide(
                          color: isFailed ? Colors.red : (isDone ? Colors.green : AppColors.cyan), 
                          width: 4
                        )),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  if (isProcessing)
                                    const Icon(Icons.autorenew, color: AppColors.cyan, size: 20),
                                  if (isDone)
                                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                                  if (isProcessing || isDone)
                                    const SizedBox(width: 8),
                                  Text(
                                    job['title'] ?? 'Unknown Job',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Text(
                                isProcessing ? '${job['progress']}%' : job['status'].toString().toUpperCase(),
                                style: TextStyle(
                                  color: isFailed ? Colors.red : (isProcessing ? AppColors.cyan : Colors.white54),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (isProcessing || isQueued) ...[
                            ShaderMask(
                              shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                              child: LinearProgressIndicator(
                                value: (job['progress'] as int) / 100,
                                backgroundColor: Colors.white10,
                                color: Colors.white,
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatusDot('Queued', true, context, isActive: isQueued),
                                _buildStatusDot('Transcribing', job['progress'] > 20, context, isActive: isProcessing && job['progress'] <= 20),
                                _buildStatusDot('Curating', job['progress'] > 50, context, isActive: isProcessing && job['progress'] > 20 && job['progress'] <= 50),
                                _buildStatusDot('Rendering', job['progress'] > 80, context, isActive: isProcessing && job['progress'] > 50),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDot(String label, bool isDone, BuildContext context, {bool isActive = false}) {
    return Column(
      children: [
        Container(
          width: isActive ? 12 : 8,
          height: isActive ? 12 : 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.transparent : (isDone ? AppColors.cyan : Colors.white24),
            border: isActive ? Border.all(color: AppColors.cyan, width: 2) : null,
          ),
          child: isActive ? Center(child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle))) : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? AppColors.cyan : (isDone ? Colors.white54 : Colors.white24),
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
