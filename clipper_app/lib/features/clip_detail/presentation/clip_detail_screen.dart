import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../common/widgets/primary_gradient_button.dart';
import '../../../core/theme/colors.dart';
import '../../../core/config/env.dart';
import '../../video_library/presentation/providers/video_library_providers.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../video_library/presentation/providers/video_library_providers.dart';

class ClipDetailScreen extends ConsumerStatefulWidget {
  final String clipId;

  const ClipDetailScreen({super.key, required this.clipId});

  @override
  ConsumerState<ClipDetailScreen> createState() => _ClipDetailScreenState();
}

class _ClipDetailScreenState extends ConsumerState<ClipDetailScreen> {
  int _activeTabIndex = 0;

  final List<Map<String, dynamic>> _subtitles = [
    {"text": "So I tried this new tool and", "isHighlight": false},
    {"text": "it was absolutely", "isHighlight": false},
    {"text": "AMAZING", "isHighlight": true},
    {"text": "how fast it worked.", "isHighlight": false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Clip Editor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: ref.watch(clipDetailProvider(widget.clipId)).when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
        data: (clip) {
          String? rawUrl = clip['thumbnail_url'];
          if (rawUrl != null && rawUrl.startsWith('/')) {
            rawUrl = '${Env.baseUrl}$rawUrl';
          }
          final thumbnailUrl = rawUrl ?? 'https://lh3.googleusercontent.com/aida-public/AB6AXuBmO5bu8wVK-8VObG0WuPGqxZ9lpF0m8wEbgyjVUj0fbxDO68bCrERbE1kusuVj3Bo6dYcaEYPdoWNVbuZoAkf3hpdwMWATWp1slmUh2OXUUjMpUQ107Rmf_aKt5taGjOeULe0kaUTXG_W3yQHdaaDqbjoTr911xMTGC6yXFw7jYL7Ne2-heoa9EHRGxOM6pjUWzcN5O-oHRgwoFL2L1dSYa4rURZMKY82QNjrRzBf1b7bkHogVqkpiLw';
          
          final viralityScore = clip['virality_score'] ?? 98;
          final title = clip['title'] ?? 'Clip Editor';

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 800;
              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
                    child: Flex(
                      direction: isDesktop ? Axis.horizontal : Axis.vertical,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Video Section
                        SizedBox(
                          width: isDesktop ? constraints.maxWidth * 0.4 : double.infinity,
                          child: AspectRatio(
                            aspectRatio: 9 / 16,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white10),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: (clip['video_url'] != null && clip['video_url'].toString().endsWith('.mp4'))
                                  ? ClipVideoPlayer(
                                      videoUrl: clip['video_url'].startsWith('/') 
                                          ? '${Env.baseUrl}${clip['video_url']}' 
                                          : clip['video_url']
                                    )
                                  : Stack(
                                      children: [
                                        Image.network(thumbnailUrl, fit: BoxFit.cover, width: double.infinity, height: double.infinity, opacity: const AlwaysStoppedAnimation(0.4)),
                                        const Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Text('Video belum dirender oleh FFmpeg.\nSilakan buat Job baru untuk menguji Fase 4.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)),
                                          )
                                        )
                                      ],
                                    ),
                            ),
                          ),
                        ),
                        if (isDesktop) const SizedBox(width: 24) else const SizedBox(height: 24),
                        
                        // Editor Controls
                        Expanded(
                          flex: isDesktop ? 1 : 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              const SizedBox(height: 16),
                              // AI Analysis Card
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: Row(
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.cyan.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: AppColors.cyan.withOpacity(0.5)),
                                          ),
                                          child: Text('${viralityScore.toStringAsFixed(0)}%', style: const TextStyle(color: AppColors.cyan, fontSize: 24, fontWeight: FontWeight.bold)),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text('VIRALITY SCORE', style: TextStyle(fontSize: 8, letterSpacing: 1.2, color: Colors.white54)),
                                      ],
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Row(
                                            children: [
                                              Icon(Icons.auto_awesome, color: AppColors.primary, size: 16),
                                              SizedBox(width: 4),
                                              Text('AI Analysis', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          RichText(
                                            text: const TextSpan(
                                              style: TextStyle(color: Colors.white, fontSize: 12, height: 1.5),
                                              children: [
                                                TextSpan(text: 'Strong narrative hook detected in the first 3 seconds. High emotional valence. '),
                                                TextSpan(text: 'Ideal for TikTok/Reels.', style: TextStyle(color: AppColors.cyan)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // Tabs
                              Row(
                                children: [
                                  _buildTab(0, 'TRIM'),
                                  const SizedBox(width: 24),
                                  _buildTab(1, 'SUBTITLE'),
                                  const SizedBox(width: 24),
                                  _buildTab(2, 'PRESET'),
                                ],
                              ),
                              const Divider(color: Colors.white10, height: 1),
                              const SizedBox(height: 16),
                              
                              // Dynamic Tab Content
                              _buildTabContent(clip),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Bottom Action Bar
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        border: const Border(top: BorderSide(color: Colors.white10)),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, -5)),
                        ]
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white24),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            ),
                            child: const Text('SAVE AS DRAFT'),
                          ),
                          const SizedBox(width: 16),
                          PrimaryGradientButton(
                            onPressed: () {},
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                              child: Text('EXPORT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
          );
        }
      ),
    );
  }

  Widget _buildTab(int index, String title) {
    final isActive = _activeTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTabIndex = index),
      child: Container(
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? AppColors.cyan : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? AppColors.cyan : Colors.white54,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(Map<String, dynamic> clip) {
    switch (_activeTabIndex) {
      case 0:
        return _buildTrimTab(clip);
      case 1:
        return _buildSubtitleTab(clip);
      case 2:
        return _buildPresetTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTrimTab(Map<String, dynamic> clip) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Selection: ${clip['start_time'] ?? 0}s - ${clip['end_time'] ?? 15}s', style: const TextStyle(fontSize: 12)),
              Text('Duration: ${((clip['end_time'] ?? 15) - (clip['start_time'] ?? 0)).toStringAsFixed(1)}s', style: const TextStyle(fontSize: 12, color: Colors.white54)),
            ],
          ),
          const SizedBox(height: 12),
          // Fake Timeline
          Container(
            height: 64,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white10),
            ),
            child: Stack(
              children: [
                // Selected area
                Positioned(
                  left: 50, right: 100, top: 0, bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      border: const Border(
                        top: BorderSide(color: AppColors.primary),
                        bottom: BorderSide(color: AppColors.primary),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(width: 8, color: AppColors.primary),
                        Container(width: 8, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
                // Playhead
                Positioned(
                  left: 120, top: 0, bottom: 0,
                  child: Container(
                    width: 2,
                    decoration: BoxDecoration(
                      color: AppColors.cyan,
                      boxShadow: [BoxShadow(color: AppColors.cyan.withOpacity(0.5), blurRadius: 4)],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitleTab(Map<String, dynamic> clip) {
    // If transcript_segments exist, use them instead of dummy data
    List<dynamic> segments = [];
    if (clip['transcript_segments'] != null && clip['transcript_segments'] is List) {
      segments = clip['transcript_segments'];
    } else {
      segments = _subtitles; // Fallback to dummy
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tap a line to toggle emotional highlight', style: TextStyle(fontSize: 12, color: Colors.white54)),
          const SizedBox(height: 16),
          ...segments.asMap().entries.map((entry) {
            int index = entry.key;
            var sub = entry.value;
            bool isHighlight = sub['isHighlight'] ?? false;
            return GestureDetector(
              onTap: () {
                // Not fully interactive for API data yet
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isHighlight ? AppColors.cyan.withOpacity(0.1) : Colors.white.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isHighlight ? AppColors.cyan.withOpacity(0.5) : Colors.white10),
                ),
                child: Text(
                  sub['text'],
                  style: TextStyle(
                    color: isHighlight ? AppColors.cyan : Colors.white,
                    fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPresetTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('QUICK PRESETS', style: TextStyle(fontSize: 10, letterSpacing: 1.2, color: Colors.white54)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildQuickPreset('Split View', 'https://lh3.googleusercontent.com/aida-public/AB6AXuB2-tWjNzg-z7ewunnqnCmECO1vON7etWe4C82k2BFsfjXZCfqj8pgZgwDWzlF4X8MoghTKfOVo9pjr8nNbtnCc3bLb8fB8iBvd-oXBXac3NAPuYgN_x33BFbdoL0CcQhqhOYmtVA0iEFtLjJu2tnwvRdPCzA4c2LSoniLTdUBrAIcdZgNcEVl461Am7Q-Mkt-tth-Q52Sa2x3dTevtdH7P8NzzZ1hwoXTku14ObqUm3E1TFBcLddN6MA', true),
            _buildQuickPreset('Face + Text', 'https://lh3.googleusercontent.com/aida-public/AB6AXuD_rVFf3vKyMgD4s7IGES_CVKfR8RLNI5f3kDyWGs26cvBQoyFsyi14LBmNqBdKt1DkrvdOZo1ssrmcbgszHhga9pEadYlFbVtVdAyMwKXUsreJJKkGp2FM8OW-VX253SsCdY84hiJkr6wkQupotU9MJBGbWuNOQr_2oR2A2nwjyvbkIUNroLhwK0BQA4Uo6s5S_K3WEy6FiPmY7Crj6Nw-FCTBlpx8agpDvM8N1IwonNRg16Ziw5v6TA', false),
            _buildQuickPreset('B-Roll', 'https://lh3.googleusercontent.com/aida-public/AB6AXuCP6loCRdAYXmJB7d3v5EzQwcsyK6wtA_b1APR5COuwW2Bj-dtrc5pteiN_cPVr4HtOVEofYpCWgiJG0bm3LwP6K5rcAc21WIgHinoKesNFjnB7o0486EYKVGiiZ-j3MiCu0s6193tpUWq4CZFG_x695tlL9RdwPfZv2lv6NneYfJT61Pabb333PzwZcLI8pv8Zd3cDzzqvnz1UO_wJVeIo5ufRHNk-zfFAi7yevlMqAxO9NfA_wO2AfQ', false),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickPreset(String title, String imageUrl, bool isActive) {
    return Container(
      width: 80,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isActive ? AppColors.primary : Colors.white10, width: isActive ? 2 : 1),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
          colorFilter: isActive ? null : ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
        )
      ),
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        color: Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10)),
      ),
    );
  }
}

class ClipVideoPlayer extends StatefulWidget {
  final String videoUrl;
  const ClipVideoPlayer({super.key, required this.videoUrl});

  @override
  State<ClipVideoPlayer> createState() => _ClipVideoPlayerState();
}

class _ClipVideoPlayerState extends State<ClipVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  void _initPlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    await _videoPlayerController.initialize();
    
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: true,
      aspectRatio: 9 / 16,
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_chewieController != null && _chewieController!.videoPlayerController.value.isInitialized) {
      return Chewie(controller: _chewieController!);
    } else {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
  }
}
