import 'dart:async';
import 'package:flutter/material.dart';
import '../assets/sporto_assets.dart';
import '../theme/sporto_design_tokens.dart';
import '../widgets/sporto_badge.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onGetStarted;

  const OnboardingScreen({super.key, required this.onGetStarted});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

/// Keeps the mobile carousel horizontal while giving each slide the requested
/// top-to-bottom visual and bottom-to-top copy reveal.
class _DirectionalReveal extends StatelessWidget {
  const _DirectionalReveal({
    required this.isActive,
    required this.fromTop,
    required this.child,
  });

  final bool isActive;
  final bool fromTop;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const duration = Duration(milliseconds: 450);
    return AnimatedSlide(
      offset: isActive ? Offset.zero : Offset(0, fromTop ? -0.12 : 0.12),
      duration: duration,
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: isActive ? 1 : 0,
        duration: duration,
        curve: Curves.easeOut,
        child: child,
      ),
    );
  }
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoAdvanceTimer;

  static const _amberGold = Color(0xFFED7B00);
  static const _brightGold = Color(0xFFCF9E24);
  static const _turfGreen = Color(0xFF2BB673);

  final List<Map<String, dynamic>> _slides = const [
    {
      'kicker': 'WELCOME TO SPOTO',
      'title': 'POWER SPORTS.\nCREATE CHAMPIONS.',
      'desc':
          'Join Spoto and become a trusted sports tournament partner. Create, manage and conduct professional sports tournaments through one powerful platform.',
      'type': 'welcome',
      'cta': 'Get Started',
    },
    {
      'kicker': 'WHY PARTNER WITH SPOTO',
      'title': 'YOU ORGANISE.\nWE MARKET.',
      'desc':
          'Focus on running a great tournament. Spoto helps you attract teams, engage your audience, digitalise sporting, and add real technology to every match.',
      'type': 'partner',
      'cta': 'See How It Works',
    },
    {
      'kicker': 'CREATE TOURNAMENTS',
      'title': 'YOUR TOURNAMENT.\nYOUR STAGE.',
      'desc':
          'Create tournaments in a few steps — choose your sport, format, entry fee, number of teams, prize money, rules and match format.',
      'type': 'create',
      'cta': 'Create Tournaments',
    },
    {
      'kicker': 'MANAGE EVERYTHING',
      'title': 'ONE APP.\nCOMPLETE CONTROL.',
      'desc':
          'Manage your entire tournament from registration to final whistle — players, teams, fixtures, venues, payments and results.',
      'type': 'manage',
      'cta': 'Manage With Ease',
    },
    {
      'kicker': 'CONDUCT LIKE A PRO',
      'title': 'MAKE EVERY MATCH\nCOUNT.',
      'desc':
          'Deliver a professional tournament experience with live match updates, transparent results, player statistics and leaderboards.',
      'type': 'conduct',
      'cta': 'Run Professional Tournaments',
    },
    {
      'kicker': 'BUILD YOUR LEGACY',
      'title': 'FROM LOCAL GAMES\nTO BIGGER CHAMPIONSHIPS.',
      'desc':
          'Grow with the Spoto ecosystem. Help players move from a Local Tournament all the way to the National Championship.',
      'type': 'legacy',
      'cta': 'Become a Spoto Partner',
      'tagline': 'Create. Conduct. Champion.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoAdvance();
  }

  void _startAutoAdvance() {
    _cancelAutoAdvance();
    _autoAdvanceTimer = Timer.periodic(const Duration(milliseconds: 3200), (_) {
      if (_currentPage < _slides.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.fastOutSlowIn,
        );
      } else {
        _cancelAutoAdvance();
      }
    });
  }

  void _cancelAutoAdvance() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = null;
  }

  @override
  void dispose() {
    _cancelAutoAdvance();
    _pageController.dispose();
    super.dispose();
  }

  void _nextSlide() {
    _cancelAutoAdvance();
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.fastOutSlowIn,
      );
      _startAutoAdvance();
    } else {
      widget.onGetStarted();
    }
  }

  void _previousSlide() {
    _cancelAutoAdvance();
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.fastOutSlowIn,
      );
      _startAutoAdvance();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final darkTokens = SportoDesignTokens.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background ambient glow effects
          Positioned(
            top: -70,
            left: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _turfGreen.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            bottom: -70,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _brightGold.withValues(alpha: 0.12),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // 1. Top Header Navigation Bar (Back & Skip)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentPage > 0)
                        IconButton(
                          onPressed: _previousSlide,
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 15,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: darkTokens.card,
                            side: BorderSide(color: darkTokens.border),
                            shape: const CircleBorder(),
                          ),
                        )
                      else
                        const SizedBox(width: 36),
                      TextButton(
                        onPressed: widget.onGetStarted,
                        style: TextButton.styleFrom(
                          backgroundColor: darkTokens.card,
                          side: BorderSide(color: darkTokens.border),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 4),
                          minimumSize: const Size(0, 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'Skip',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Main Onboarding PageView (Upper Visual + Lower Text Content)
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (idx) {
                      setState(() => _currentPage = idx);
                    },
                    itemCount: _slides.length,
                    itemBuilder: (context, index) {
                      final slide = _slides[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            // Top Portion: Visual Element (Hero Card)
                            Expanded(
                              flex: 5,
                              child: _DirectionalReveal(
                                isActive: index == _currentPage,
                                fromTop: true,
                                child: Center(
                                  child: SingleChildScrollView(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    child: _buildVisual(
                                      slide['type'] as String,
                                      darkTokens,
                                      colorScheme,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Bottom Portion: Text Content (Kicker, Title, Description)
                            Expanded(
                              flex: 4,
                              child: _DirectionalReveal(
                                isActive: index == _currentPage,
                                fromTop: false,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (slide['kicker'] != null) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _amberGold.withValues(
                                              alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                            color: _amberGold.withValues(
                                                alpha: 0.4),
                                          ),
                                        ),
                                        child: Text(
                                          (slide['kicker'] as String)
                                              .toUpperCase(),
                                          style: textTheme.labelSmall?.copyWith(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1.5,
                                            color: _amberGold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                    Text(
                                      slide['title'] as String,
                                      style: textTheme.titleLarge?.copyWith(
                                        fontSize: 22,
                                        height: 1.18,
                                        fontWeight: FontWeight.w800,
                                        color: colorScheme.onSurface,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      slide['desc'] as String,
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.bodyMedium?.copyWith(
                                        fontSize: 13.5,
                                        height: 1.45,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    if (slide['tagline'] != null) ...[
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.verified_rounded,
                                            color: _turfGreen,
                                            size: 15,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            slide['tagline'] as String,
                                            style:
                                                textTheme.labelLarge?.copyWith(
                                              color: _turfGreen,
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // 3. Progress Dots Indicator
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (idx) {
                      final isActive = idx == _currentPage;
                      final isDone = idx < _currentPage;
                      return GestureDetector(
                        onTap: () {
                          _cancelAutoAdvance();
                          _pageController.animateToPage(
                            idx,
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.fastOutSlowIn,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: isActive ? 24 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: isActive
                                ? _amberGold
                                : (isDone ? _turfGreen : darkTokens.card),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isActive
                                  ? _amberGold
                                  : (isDone ? _turfGreen : darkTokens.border),
                              width: 1,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // 4. Bottom Action CTA Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [_amberGold, _brightGold],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _amberGold.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _nextSlide,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _slides[_currentPage]['cta'] as String,
                              style: textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildVisual(
    String type,
    SportoDesignTokens darkTokens,
    ColorScheme colorScheme,
  ) {
    switch (type) {
      case 'welcome':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: darkTokens.card,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: darkTokens.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SportoBadge(text: 'PARTNER ENGINE', color: _turfGreen),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: _turfGreen,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '100% ONLINE',
                        style: TextStyle(
                          fontFamily: 'packages/ui_kit/Quicksand',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Image.asset(
                SportoAssets.playAndWin,
                package: SportoAssets.package,
                height: 80,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 12),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('⚡ Auto Fixtures',
                      style: TextStyle(
                          fontSize: 10,
                          color: _brightGold,
                          fontWeight: FontWeight.w700)),
                  Text('🏆 Real Scoring',
                      style: TextStyle(
                          fontSize: 10,
                          color: _turfGreen,
                          fontWeight: FontWeight.w700)),
                  Text('💳 Payouts',
                      style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF4FBAF0),
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        );

      case 'partner':
        final features = [
          {
            'icon': Icons.campaign_rounded,
            'title': 'You Organise,\nWe Market',
            'tag': 'Spoto Promotion'
          },
          {
            'icon': Icons.groups_rounded,
            'title': 'Attract Teams,\nEngage Audience',
            'tag': '50K+ Players'
          },
          {
            'icon': Icons.bolt_rounded,
            'title': 'Digitalise\nSporting',
            'tag': 'Cloud Sync'
          },
          {
            'icon': Icons.track_changes_rounded,
            'title': 'Add Tech To\nYour Matches',
            'tag': 'Live Engine'
          },
        ];
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.5,
          children: features.map((f) {
            return Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: darkTokens.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: darkTokens.border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(f['icon'] as IconData, color: _amberGold, size: 15),
                      const SizedBox(width: 4),
                      Text(
                        f['tag'] as String,
                        style: const TextStyle(
                          fontFamily: 'packages/ui_kit/Quicksand',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: _brightGold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    f['title'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'packages/ui_kit/Quicksand',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );

      case 'create':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: darkTokens.card,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: darkTokens.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.emoji_events_rounded,
                          color: _amberGold, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Tournament Studio',
                        style: TextStyle(
                          fontFamily: 'packages/ui_kit/Quicksand',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SportoBadge(text: 'CRICKET T20', color: _brightGold),
                ],
              ),
              const SizedBox(height: 8),
              const Wrap(
                spacing: 5,
                runSpacing: 5,
                children: [
                  SportoBadge(text: 'Knockout', color: _turfGreen),
                  SportoBadge(text: '32 Teams', color: Color(0xFF4FBAF0)),
                  SportoBadge(text: 'Entry ₹500', color: _amberGold),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: darkTokens.field,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: darkTokens.fieldBorder),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('🏆 Winner: ₹15,000',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    Text('🥈 Runner Up: ₹7,000',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _brightGold)),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Icon(Icons.location_on_rounded,
                      color: colorScheme.onSurfaceVariant, size: 12),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'GHMC Sports Complex, Gachibowli',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'packages/ui_kit/Quicksand',
                        fontSize: 10,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

      case 'manage':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: darkTokens.card,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: darkTokens.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Operations Control Room',
                    style: TextStyle(
                      fontFamily: 'packages/ui_kit/Quicksand',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SportoBadge(
                      text: 'LIVE OPERATIONAL', color: _turfGreen),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _statBox('24 Teams', 'Registered', _amberGold,
                        darkTokens, colorScheme),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _statBox('6 Referees', 'Assigned', _turfGreen,
                        darkTokens, colorScheme),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: _statBox('32 Matches', 'Generated',
                        const Color(0xFF4FBAF0), darkTokens, colorScheme),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _statBox('₹38,400', 'Revenue', _brightGold,
                        darkTokens, colorScheme),
                  ),
                ],
              ),
            ],
          ),
        );

      case 'conduct':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: darkTokens.card,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: darkTokens.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'LIVE SUPER OVER MATCH 03',
                    style: TextStyle(
                      fontFamily: 'packages/ui_kit/Quicksand',
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  const SportoBadge(text: 'Over 2.2', color: _amberGold),
                ],
              ),
              const SizedBox(height: 7),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Delhi Warriors',
                    style: TextStyle(
                      fontFamily: 'packages/ui_kit/Quicksand',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const Text(
                    '34/2',
                    style: TextStyle(
                      fontFamily: 'packages/ui_kit/Space Grotesk',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _turfGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Falcons XI',
                    style: TextStyle(
                      fontFamily: 'packages/ui_kit/Quicksand',
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'Yet to bat',
                    style: TextStyle(
                      fontFamily: 'packages/ui_kit/Quicksand',
                      fontSize: 10,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: ['1', '4', 'W', '6', '2', '1'].map((b) {
                  final isW = b == 'W';
                  final isSix = b == '6';
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isW
                          ? Colors.redAccent
                          : (isSix ? _brightGold : darkTokens.field),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      b,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: isW || isSix ? Colors.black : Colors.white,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );

      case 'legacy':
        final stages = [
          {'name': 'Local Tournament', 'status': 'Completed', 'done': true},
          {'name': 'City Championship', 'status': 'Completed', 'done': true},
          {
            'name': 'District Championship',
            'status': 'Active Stage',
            'active': true
          },
          {'name': 'State Championship', 'status': 'Qualified', 'locked': true},
          {
            'name': 'National Championship 🏆',
            'status': 'Mega Final',
            'crown': true
          },
        ];
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: darkTokens.card,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: darkTokens.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: stages.asMap().entries.map((e) {
              final isLast = e.key == stages.length - 1;
              final item = e.value;
              final isDone = item['done'] == true;
              final isActive = item['active'] == true;
              final isCrown = item['crown'] == true;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCrown
                              ? _brightGold
                              : (isActive
                                  ? _amberGold
                                  : (isDone ? _turfGreen : darkTokens.field)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          isCrown ? '👑' : (isDone ? '✓' : '${e.key + 1}'),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color:
                                isDone || isCrown ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item['name'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'packages/ui_kit/Quicksand',
                            fontSize: 10.5,
                            fontWeight: isActive || isCrown
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isActive || isCrown
                                ? Colors.white
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      SportoBadge(
                        text: item['status'] as String,
                        color: isCrown
                            ? _brightGold
                            : (isActive ? _amberGold : _turfGreen),
                      ),
                    ],
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 4,
                      margin: const EdgeInsets.only(left: 9, top: 1, bottom: 1),
                      color: isActive ? _amberGold : darkTokens.border,
                    ),
                ],
              );
            }).toList(),
          ),
        );

      default:
        return const SizedBox();
    }
  }

  Widget _statBox(
    String title,
    String label,
    Color color,
    SportoDesignTokens darkTokens,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: darkTokens.field,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: darkTokens.fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'packages/ui_kit/Space Grotesk',
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'packages/ui_kit/Quicksand',
              fontSize: 8.5,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
