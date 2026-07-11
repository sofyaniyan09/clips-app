import 'package:flutter/material.dart';
import '../../../common/widgets/primary_gradient_button.dart';
import '../../../core/theme/colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailAsync = ref.watch(userEmailProvider);
    final email = emailAsync.value ?? 'alex@ai-clip.pro';
    final name = email.split('@').first.capitalize();
    final isGuest = emailAsync.value == null;

    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(Icons.auto_awesome, color: AppColors.primary),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
          child: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white70),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // User Info
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 15)
                ],
              ),
              padding: const EdgeInsets.all(2),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.background,
                  border: Border.all(color: AppColors.background, width: 2),
                  image: const DecorationImage(
                    image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAKUgK-VXVMOUzB1ARR6aMCMpgBRrNFloAw8ajfFhCNh0vUyhjy4mX7ziP2P3IEQEYlywyiCVDJFB_GuV0jRtm_ZTUKZ5rUp7J5LkSYdUBxZGGI43mnnonEMSaxZBYhMjTLuquAdBLurFgp5k_TKB51GdOw0ZTXhNqaBiDdH61pzKyh2j8fBLQWKiTEydR6lZt7MzBRQqyfFjQCc3FQSfQTfzWiwECGN_SRxahqz5SPWRoU0asPhreU-Q'),
                    fit: BoxFit.cover,
                  )
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(email, style: const TextStyle(color: Colors.white54)),
            const SizedBox(height: 32),

            // Subscription Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('CURRENT PLAN', style: TextStyle(fontSize: 10, color: Colors.white54, letterSpacing: 1.2)),
                          SizedBox(height: 4),
                          Text('Free Plan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('USAGE', style: TextStyle(fontSize: 10, color: Colors.white54, letterSpacing: 1.2)),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // TODO: Fetch real render quota from backend instead of hardcoded 3 of 5
                              const Text('3 ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.cyan)),
                              const Text('of 5 renders used', style: TextStyle(fontSize: 12, color: Colors.white54)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 6,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF353438),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Stack(
                      children: [
                        FractionallySizedBox(
                          widthFactor: 0.6,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              gradient: AppColors.primaryGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.cyan.withOpacity(0.5),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Upgrade CTA
            SizedBox(
              width: double.infinity,
              child: PrimaryGradientButton(
                onPressed: () {},
                child: const Text('UPGRADE TO PRO', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),
            const Column(
              children: [
                _FeatureRow('Unlimited AI Renders'),
                SizedBox(height: 8),
                _FeatureRow('4K Ultra-HD Export'),
                SizedBox(height: 8),
                _FeatureRow('Exclusive Cinematic Presets'),
              ],
            ),
            const SizedBox(height: 40),

            // My Presets
            Align(
              alignment: Alignment.centerLeft,
              child: const Text('My Presets', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            _PresetItem(
              title: 'Neon Vlog',
              imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuD0QYhZemOzAq6aD1nQFfyRfIv5jvbqBlZSY4cGvgCVb7TO_P-FUWh-RBRb8YnduD-G9J03shlk9h1OsKf1WKT6f5Fo9jWUs9kmrB5yTSH4e6G3TitvXxPdi8-RLYEkDX5ckfpZ5XJwS5oXuNCBFQg2kCDT1vsBBarTHA_f73BvLFd_sorVrp-BZEsEwZ1Sj7IiHWxtHo_ai1E8rvNyoOQeXBzv2Y2Q5wa-EcMtfPKUtRdkL5WKjfrdKQ',
            ),
            const SizedBox(height: 12),
            _PresetItem(
              title: 'Cinematic Bio',
              imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDwIwHoKIl5ys7IqrxXDQHtbRXLA4RzEEnrRwi0_VqYANmT1h9b_KQd2i9s-vSezyB5PnHzohVvapNj0EGnepkUMiAcfuPE8VEGI9ic_57iKDeds8ZE2WTNlQbq6hbmmX-RsbyNcZHp508wR9LinbAz2lkwAiCd1jjyuD-94DdRZcoluoAQdeTD7oqDqI9QIPZG943LqbBkVmtKfHey0ksdQ7LlJWXnf7MYbOdz7PumhZ71mNCpAGouYg',
            ),
            const SizedBox(height: 12),
            _PresetItem(
              title: 'Fast Cuts',
              imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCG6gIlJrBFLIZ-4GwCTQxzX-tMlMopvbic8csjGrgY2NKcgJRQy7PDIMQvMhzoej_4xuV_Iiqb0xFMnvlBm9uyxRQLCmKgfCdN5RHAhws38LEG0ao476HXSZW_zGvg3m_Pkf4zWqC_WtGnNcV1bSuPkC9_-wcIx1OD9n3av2BfAaZ9LJW70VpF2wu709b2K6ntf3u9SHQ0rjlJe6hfe5MYkC5d9TmRv8Zp7qnci7UuJGrOe-iVdQWFIQ',
            ),
            const SizedBox(height: 40),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: const Text('LOGOUT', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.redAccent, width: 1),
                  ),
                ),
                onPressed: () {
                  ref.read(authStateProvider.notifier).logout();
                },
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String text;
  const _FeatureRow(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: AppColors.cyan, size: 20),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}

class _PresetItem extends StatelessWidget {
  final String title;
  final String imageUrl;

  const _PresetItem({required this.title, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.edit, color: Colors.white54), onPressed: () {}),
              IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () {}),
            ],
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
