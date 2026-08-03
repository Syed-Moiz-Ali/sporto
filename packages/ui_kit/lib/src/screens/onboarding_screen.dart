import 'package:flutter/material.dart';
import '../widgets/glass_container.dart';
import '../widgets/glass_button.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onGetStarted;

  const OnboardingScreen({super.key, required this.onGetStarted});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.emoji_events,
      'title': 'Multi-Sport Tournament Management',
      'desc': 'Organize, schedule, and monetize tournaments across Cricket, Football, Basketball & Box Cricket seamlessly.',
    },
    {
      'icon': Icons.sports_score,
      'title': 'Live Ball-by-Ball Scorekeeper Engine',
      'desc': 'Real-time scoring engine with 3D Coin Toss simulation, roster verification, and instant commentary feed.',
    },
    {
      'icon': Icons.cloud_sync,
      'title': 'Offline-First Hybrid Cloud Sync',
      'desc': 'Never lose a ball or match update. Save locally to Hive Box instantly and auto-sync when back online.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (idx) => setState(() => _currentPage = idx),
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final item = _pages[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GlassContainer(
                          width: 140,
                          height: 140,
                          borderRadius: 70,
                          hasGlow: true,
                          backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
                          borderColor: colorScheme.primary,
                          child: Center(
                            child: Icon(item['icon'] as IconData, color: colorScheme.primary, size: 64),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          item['title'] as String,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          item['desc'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14, height: 1.4),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (idx) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: idx == _currentPage ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: idx == _currentPage ? colorScheme.primary : colorScheme.outline,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 30),

              // Action button
              GlassButton(
                label: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                isPrimary: true,
                onPressed: () {
                  if (_currentPage < _pages.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  } else {
                    widget.onGetStarted();
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
