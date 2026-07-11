import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/data/auth_repository.dart';
import '../../../common/widgets/primary_gradient_button.dart';
import '../../../core/theme/colors.dart';
import '../../../core/config/env.dart';
import 'providers/video_library_providers.dart';

class VideoLibraryScreen extends ConsumerWidget {
  const VideoLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clipsAsync = ref.watch(videoLibraryProvider);
    final selectedClips = ref.watch(selectedClipsProvider);
    
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
        title: const Text('Source: Neuroscience Documentary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () {
            ref.invalidate(videoLibraryProvider);
          }),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: clipsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $e', style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(authStateProvider.notifier).logout();
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout & Relogin'),
              )
            ],
          ),
        ),
        data: (clips) {
          if (clips.isEmpty) {
            return const Center(child: Text('No clips generated yet.'));
          }
          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Status Banner
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                                    color: Colors.white.withOpacity(0.05),
                                    boxShadow: [
                                      BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 15)
                                    ],
                                  ),
                                  child: const Icon(Icons.movie_filter, color: AppColors.cyan),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Generated ${clips.length} Clips based on Narrative Hook Analysis', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      const SizedBox(height: 4),
                                      const Text('AI analyzed 45 minutes of footage to extract the highest retention moments optimized for vertical formats.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Control Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: selectedClips.length == clips.length && clips.isNotEmpty,
                                    activeColor: AppColors.primary,
                                    onChanged: (val) {
                                      if (val == true) {
                                        ref.read(selectedClipsProvider.notifier).state = clips.map((c) => c['id'] as String).toSet();
                                      } else {
                                        ref.read(selectedClipsProvider.notifier).state = {};
                                      }
                                    },
                                  ),
                                  const Text('Select All', style: TextStyle(color: Colors.white70)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: 'virality',
                                    dropdownColor: const Color(0xFF1F1F22),
                                    items: const [
                                      DropdownMenuItem(value: 'virality', child: Text('Sort by Virality Score')),
                                      DropdownMenuItem(value: 'duration', child: Text('Sort by Duration')),
                                    ],
                                    onChanged: (val) {},
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Grid
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.55,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: clips.length,
                            itemBuilder: (context, index) {
                              final clip = clips[index];
                              final isSelected = selectedClips.contains(clip['id']);
                              
                              // Placeholder Images based on index
                              final images = [
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuDB51Sh7nLgQBCPxjVhvEREFWQ7dvDM359Z8tw2ZW3C4VcucAbgdKpqP9EOaZsQSb45BGGBstXI9shwh8cwSqNbaHWSZLkxBH09Zh1vKgj-ZQGzBggdLF5x45KonbGm2vg1seKLfAdRabZZ8opf-hzzYQ6mMI6nJniZXwfyQtUhURVXsToxVBmJDq6v8nieiYG5nFk-8df28uHxXwaMwt3thidPjHu48HRew_h82zcNQdc1ypfsEipn7g',
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuA6pYvJh2c_3bSKhnbZ7q_yFQo-M0EOOyXTUBrV4xE_vghZ3AWKfJXlsFi1tIoQNmz9YQXTWTyKgSe5HS-xGOwhbU-yZztlSuJzr0rSa-Mbu1yX0qTo0EEJdnrQJAzSSj0sepmYFQBoE1igO3qTptpDXEAm1GlXd3B1THAn84o-aUBToaIY_8ZaSt4bEIIR1E8xEsZjkCfAXlVn9mmiX7sz2vuJT_pR4Mbkhjya914R9Z_O5QJWAxmSRw',
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuCoM6b2mnSoO44kR5wznzifAO7Q9nzofjzheZzCr1rhpcnATCKY-u8KD_UTR6nVhBc4c1ogKHiw7zlfBuyaJZLsIGFXkwzzMYP4Va-n0Clg7_AEeLnerefq9qF5RkIijFplaSYx_PqBkwg4X31lp5HHg3yiGlg4lM_NKqkOCGavHikikfO0oODfCBvnUG9eoYzCN3tyqunPhma5gH4ScDR4cO7MzRXc4PmOEZkA3fiyOQboxLJSIk1RXQ',
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuCT8IofBFkn7cMjbqg9iO8EofWT765zRiMTSLwvH8pJUwUbRdaev_YgL03kWCi2KTQvuE5P4HAa5wc9xPm5LSBdg1qGGPeVkdI7PUmsH_3Za4PkKQPy1MoiMQbSnsa5rbuy7fRXARgsOpgsXpAQgMb8ZGRjUcSv463WzrrkiHuLOkIQGUeUzrM_PdutSCBgJQsvJML0-V9rpmI3w-JaRlebNyW1TgSUODxx0NYMzNu2mMLhlhq9owi7Yw'
                              ];
                              
                              String? rawUrl = clip['thumbnail_url'];
                              if (rawUrl != null && rawUrl.startsWith('/')) {
                                rawUrl = '${Env.baseUrl}$rawUrl';
                              }
                              
                              final image = rawUrl ?? images[index % images.length];

                              return GestureDetector(
                                onTap: () {
                                  context.push('/clips/${clip['id']}');
                                },
                                onLongPress: () {
                                  final currentSelected = Set<String>.from(ref.read(selectedClipsProvider));
                                  if (isSelected) {
                                    currentSelected.remove(clip['id']);
                                  } else {
                                    currentSelected.add(clip['id']);
                                  }
                                  ref.read(selectedClipsProvider.notifier).state = currentSelected;
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: isSelected ? Colors.white54 : Colors.white10),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.network(image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.movie, size: 40)),
                                            Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [Colors.black87, Colors.black.withOpacity(0.2), Colors.transparent],
                                                  begin: Alignment.bottomCenter,
                                                  end: Alignment.topCenter,
                                                )
                                              ),
                                            ),
                                            // Top Left Badge
                                            Positioned(
                                              top: 8, left: 8,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.black87,
                                                  borderRadius: BorderRadius.circular(4),
                                                  border: Border.all(color: Colors.white24),
                                                ),
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.schedule, size: 12, color: Colors.white70),
                                                    const SizedBox(width: 4),
                                                    Text(clip['duration'] ?? '15s', style: const TextStyle(fontSize: 10, color: Colors.white)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // Top Right Badge
                                            Positioned(
                                              top: 8, right: 8,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  gradient: AppColors.primaryGradient,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text('${clip['virality_score'] ?? 0}% VIRALITY', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
                                              ),
                                            ),
                                            // Play Icon Overlay
                                            const Center(
                                              child: Icon(Icons.play_circle_fill, size: 48, color: Colors.white54),
                                            ),
                                            // Checkbox Bottom Right
                                            Positioned(
                                              bottom: 8, right: 8,
                                              child: AnimatedContainer(
                                                duration: const Duration(milliseconds: 200),
                                                width: 24,
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  gradient: isSelected ? AppColors.primaryGradient : null,
                                                  color: isSelected ? null : Colors.black45,
                                                  border: Border.all(color: Colors.white, width: 1.5),
                                                ),
                                                child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.black) : null,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(clip['title'] ?? 'Clip', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                                              const SizedBox(height: 8),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Icon(Icons.auto_awesome, size: 14, color: AppColors.cyan),
                                                  const SizedBox(width: 4),
                                                  const Expanded(
                                                    child: Text('Strong narrative hook detected. High engagement predicted.', style: TextStyle(color: Colors.white70, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 80), // Padding for FAB
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (selectedClips.isNotEmpty)
                Positioned(
                  bottom: 32,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: PrimaryGradientButton(
                      onPressed: () {
                        ref.read(selectedClipsProvider.notifier).state = {};
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Export started...')));
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.download, color: Colors.white),
                          const SizedBox(width: 8),
                          Text('Export Selected (${selectedClips.length})', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        }
      ),
    );
  }
}
