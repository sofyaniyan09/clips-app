import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../main.dart';
import '../../../common/widgets/primary_gradient_button.dart';
import '../../../core/theme/colors.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Ambient Glow Background
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2,
            left: MediaQuery.of(context).size.width * 0.2,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.15),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.2,
            right: MediaQuery.of(context).size.width * 0.2,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cyan.withOpacity(0.1),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Top App Bar Area
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close, color: AppColors.primary),
                          onPressed: () {},
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/queue'), 
                        child: const Text('Skip', style: TextStyle(color: AppColors.primary, fontSize: 14)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: const [
                      _Step1(),
                      _Step2(),
                      _Step3(),
                    ],
                  ),
                ),
                
                // Indicators & Action Button
                if (_currentPage != 2) // Step 3 has its own button and dots in the bottom card design
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_currentPage == 0)
                          SizedBox(
                            width: double.infinity,
                            child: PrimaryGradientButton(
                              onPressed: () {
                                _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Continue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                                ],
                              ),
                            ),
                          ),
                        if (_currentPage == 0) const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildDot(0),
                            const SizedBox(width: 12),
                            _buildDot(1),
                            const SizedBox(width: 12),
                            _buildDot(2),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    bool isActive = _currentPage == index;
    return Container(
      width: isActive ? 12 : 8,
      height: isActive ? 12 : 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.cyan : Colors.white24,
        shape: BoxShape.circle,
        boxShadow: isActive ? [BoxShadow(color: AppColors.cyan.withOpacity(0.5), blurRadius: 10)] : null,
      ),
    );
  }
}

class _Step1 extends StatelessWidget {
  const _Step1();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: AppColors.cyan.withOpacity(0.15), blurRadius: 30)],
            ),
            child: Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCOtfNeokLHf6z8LDbGcqQvqM3fBZm420kP82sXy-SdcilbNPTXYJIQ4YTtA3RKVrFdtVETkRuDD97_eTh11tgbzKXmXNbWvJRdUzScBnlAWnr9V08MNDPhZLIrUuq_MRsP6s15sDMpG_63jFNA0V-fby4w1wiMutfPmRlk70tSqnprjaefVOLwN8LxTUxQEkxsGdOgrisEEzA7Si7aQbbKwwCvdAg0aXVxraF8G6kUxF3-gRhG7uMXcw',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 40),
          ShaderMask(
            shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
            child: const Text(
              'Automated\nProduction Studio',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'One input, fully edited cinematic output. No manual editing needed.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.white54, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _Step2 extends StatelessWidget {
  const _Step2();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AspectRatio(
            aspectRatio: 21 / 9,
            child: Container(
              width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 40)],
              image: const DecorationImage(
                image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDFI0duX2Ne-LWbwLB0cWzo8Ad3cc9ZKjeRxTI4ENDl8hlcKse82XcgG47hhAZYD43HL93q9yEMeUQzxp5nbUbky4Mfb_i02vB-6Ru_bJ9die2AZxGCKz1YoOCjGzGkhwmfgtpjd6XZidpQXw9H3dFLl2TUFQw5YMX18S9QweidKZ_AEQTn5AXnrERI304XXj67hvZI5VakUAg99g0XiPBusUmyJiJV8NYRlXu4vaLKAnIfGtcf24xk8Q'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: 16, left: 16,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white24)),
                        child: const Row(children: [Icon(Icons.crop_free, size: 14, color: AppColors.cyan), SizedBox(width: 4), Text('16:9 RAW', style: TextStyle(fontSize: 10))]),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_right_alt, color: Colors.white54),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.8), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.primary), boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10)]),
                        child: const Row(children: [Icon(Icons.smartphone, size: 14, color: Colors.black), SizedBox(width: 4), Text('9:16 AI CROP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black))]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ),
          const SizedBox(height: 40),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(colors: [AppColors.primary, AppColors.cyan]).createShader(bounds),
            child: const Text('Smart Cinematic Cropping', textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(height: 16),
          const Text('AI-powered face tracking and bokeh blur transform your horizontal footage into viral vertical clips instantly.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.white54, height: 1.5)),
        ],
      ),
    );
  }
}

class _Step3 extends StatelessWidget {
  const _Step3();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 200, height: 200,
                  decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 100)]),
                ),
                Container(
                  width: 240,
                  height: double.infinity,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1B1E),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: const Color(0xFF353438), width: 6),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 50, offset: const Offset(0, 20))],
                    image: const DecorationImage(
                      image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDLiJz5ZbD_pZE3K1T52SnQlzo_wapyEwgMrpBW_EMU_d1W7_2ys7E8HsfsFYsDuFz7Oi-Oe-foTAVf29IbW-fBuhFu-6S9jOghUp18OTyUy-677GA8JgP4Vn9yDqYxx5C8acFFv3pOAVQ-81X5wJvfsgR9Gq7IXIoURcynbGK71rTz4AXSHa_OkYcZ7TRZCWtnfy098Vvob2JBP_wHuUVrmFGJWGV81ob2-EYt72nDPFiJjOysYXtCDQ'),
                      fit: BoxFit.cover,
                      opacity: 0.9,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 40, left: 0, right: 0,
                        child: Column(
                          children: [
                            const Text('ABSOLUTE', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.cyan, letterSpacing: 2, shadows: [Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(0, 2))])),
                            const Text('AMAZING\nPROFIT!', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.cyan, letterSpacing: 2, height: 1.1, shadows: [Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(0, 2))])),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(margin: const EdgeInsets.only(top: 10), width: 80, height: 20, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10))),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            border: const Border(top: BorderSide(color: Colors.white10)),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              const Text('Viral-Ready Captions', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('Engagement-boosting \'Emotional Subtitles\' with Niche Presets and custom watermarking.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.white54)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle)),
                  const SizedBox(width: 12),
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle)),
                  const SizedBox(width: 12),
                  Container(width: 24, height: 8, decoration: BoxDecoration(color: AppColors.cyan, borderRadius: BorderRadius.circular(4), boxShadow: [BoxShadow(color: AppColors.cyan.withOpacity(0.6), blurRadius: 12)])),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: PrimaryGradientButton(
                  onPressed: () => context.go('/queue'), 
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('GET STARTED', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.white)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
