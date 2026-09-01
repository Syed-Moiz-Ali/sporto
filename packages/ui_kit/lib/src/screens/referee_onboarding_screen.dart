import 'package:flutter/material.dart';

import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import '../widgets/sporto_badge.dart';
import '../widgets/sporto_card.dart';

class RefereeOnboardingScreen extends StatefulWidget {
  const RefereeOnboardingScreen({
    super.key,
    required this.onGetStarted,
    this.initialPage = 0,
  });

  final VoidCallback onGetStarted;
  final int initialPage;

  @override
  State<RefereeOnboardingScreen> createState() =>
      _RefereeOnboardingScreenState();
}

class _RefereeOnboardingScreenState extends State<RefereeOnboardingScreen> {
  static const _background = Color(0xFF0E0C08);
  static const _card = Color(0xFF171717);
  static const _cardRaised = Color(0xFF1C2026);
  static const _border = Color(0xFF283040);
  static const _amber = Color(0xFFED7B00);
  static const _green = Color(0xFF2BB673);
  static const _text = Color(0xFFF4F4F5);
  static const _muted = Color(0xFF92949A);
  static const _faint = Color(0xFF6E7076);

  late final PageController _controller;
  late int _page;

  static const _slides = <_Slide>[
    _Slide(
      eyebrow: 'OFFICIAL REFEREE NETWORK',
      before: 'STEP ONTO THE PITCH.\n',
      highlight: 'GET PAID FOR IT.',
      description:
          'Every match needs a referee who shows up ready. Spoto puts real bookings, real organisers and real pay in your hands.',
      visual: _Visual.stadium,
      initialCta: true,
    ),
    _Slide(
      eyebrow: 'SCREEN 02 / MATCH REQUESTS',
      before: 'ORGANISERS ARE ',
      highlight: 'LOOKING FOR YOU.',
      description:
          'Tournament organisers post their fixtures right on Spoto. You get the call — accept the ones that fit your calendar.',
      visual: _Visual.booking,
      keyMessage: 'Every match is a fresh opportunity.',
    ),
    _Slide(
      eyebrow: 'SCREEN 03 / OPEN FIXTURES',
      before: 'PICK MATCHES THAT ',
      highlight: 'FIT YOUR GAME.',
      description:
          'Browse open fixtures across sports, filtered by location, timing and your experience level.',
      visual: _Visual.matches,
      keyMessage: 'You decide when you officiate.',
    ),
    _Slide(
      eyebrow: 'SCREEN 04 / PAYOUTS',
      before: 'FINAL WHISTLE.\n',
      highlight: 'INSTANT PAYOUT.',
      description:
          'The moment your match wraps and gets verified, your fee lands straight in your Spoto wallet.',
      visual: _Visual.payout,
      keyMessage: 'Zero delays. Zero follow-ups.',
    ),
    _Slide(
      eyebrow: 'SCREEN 05 / YOUR NUMBERS',
      before: 'TRACK EVERY ',
      highlight: 'RUPEE YOU EARN.',
      description:
          'See your matches, your bookings and your total payout for the month — all in one dashboard.',
      visual: _Visual.earnings,
      keyMessage: 'The more you officiate, the more it adds up.',
    ),
    _Slide(
      eyebrow: 'SCREEN 06 / YOUR REPUTATION',
      before: 'A PROFILE ORGANISERS ',
      highlight: 'TRUST.',
      description:
          'Every match you officiate builds your record — ratings, experience and verified credentials.',
      visual: _Visual.profile,
      keyMessage: 'Reputation gets you the next booking.',
    ),
    _Slide(
      eyebrow: 'SCREEN 07 / THE PATH FORWARD',
      before: 'FROM LOCAL FIXTURES TO BIG-STAGE ',
      highlight: 'MATCHES.',
      description:
          'Consistency builds your ranking. Better ratings unlock bigger tournaments and better fees.',
      visual: _Visual.journey,
      keyMessage: 'Every whistle blown moves you forward.',
    ),
    _Slide(
      eyebrow: 'JOIN NOW',
      before: 'THE PITCH IS ',
      highlight: 'WAITING.',
      description:
          'Create your Spoto referee profile and start receiving match requests today.',
      visual: _Visual.finalStadium,
      finalCta: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _page = widget.initialPage < 0
        ? 0
        : widget.initialPage >= _slides.length
            ? _slides.length - 1
            : widget.initialPage;
    _controller = PageController(initialPage: _page);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    final target = page < 0
        ? 0
        : page >= _slides.length
            ? _slides.length - 1
            : page;
    _controller.animateToPage(
      target,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final finalPage = _page == _slides.length - 1;
    return MediaQuery.withNoTextScaling(
      child: Scaffold(
        key: const ValueKey('referee_onboarding_scaffold'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: (page) => setState(() => _page = page),
                  itemBuilder: (context, index) => Padding(
                    padding: EdgeInsets.fromLTRB(
                      26,
                      66,
                      26,
                      finalPage ? 18 : 124,
                    ),
                    child: _pageContent(_slides[index]),
                  ),
                ),
              ),
              Positioned(top: 0, left: 22, right: 22, child: _topBar()),
              if (!finalPage)
                Positioned(
                    left: 24, right: 24, bottom: 18, child: _bottomNav()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar() => SizedBox(
        height: 52,
        child: Row(
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(color: _amber, shape: BoxShape.circle),
              child: SizedBox(width: 8, height: 8),
            ),
            const SizedBox(width: 7),
            const Text(
              'SPOTO',
              style: TextStyle(
                fontFamily: 'packages/ui_kit/Space Grotesk',
                color: _text,
                fontSize: 21,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const Spacer(),
            if (_page != _slides.length - 1)
              TextButton(
                onPressed: () => _goTo(_slides.length - 1),
                style: TextButton.styleFrom(
                  foregroundColor: _muted,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  minimumSize: const Size(0, 34),
                  side: const BorderSide(color: _border),
                  shape: const StadiumBorder(),
                ),
                child: const Text(
                  'SKIP',
                  style: TextStyle(
                    fontFamily: 'packages/ui_kit/Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ),
          ],
        ),
      );

  Widget _bottomNav() => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_slides.length, (index) {
              final active = index == _page;
              return GestureDetector(
                onTap: () => _goTo(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: active ? 22 : 7,
                  height: 7,
                  margin: const EdgeInsets.symmetric(horizontal: 3.5),
                  decoration: BoxDecoration(
                    color: active ? _amber : _border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                onPressed: _page == 0 ? null : () => _goTo(_page - 1),
                icon: const Icon(Icons.chevron_left_rounded),
                color: _muted,
                disabledColor: _faint.withValues(alpha: .35),
                style: IconButton.styleFrom(
                  fixedSize: const Size(44, 44),
                  side: const BorderSide(color: _border),
                  shape: const CircleBorder(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  label: _page == _slides.length - 2 ? 'FINISH ›' : 'NEXT ›',
                  onPressed: () => _goTo(_page + 1),
                  width: double.infinity,
                  height: 44,
                  radius: 22,
                ),
              ),
            ],
          ),
        ],
      );

  Widget _pageContent(_Slide slide) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            slide.eyebrow,
            style: TextStyle(
              fontFamily: 'packages/ui_kit/Space Grotesk',
              color: _amber,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 14),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: slide.before),
                TextSpan(
                  text: slide.highlight,
                  style: const TextStyle(color: _amber),
                ),
              ],
            ),
            style: TextStyle(
              fontFamily: 'packages/ui_kit/Space Grotesk',
              color: _text,
              fontSize: slide.visual == _Visual.journey ? 29 : 34,
              height: 1,
              fontWeight: FontWeight.w700,
              letterSpacing: .2,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            slide.description,
            style: const TextStyle(
              fontFamily: 'packages/ui_kit/Inter',
              color: _muted,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(child: Center(child: _visual(slide.visual))),
          if (slide.keyMessage != null) _keyMessage(slide.keyMessage!),
          if (slide.initialCta) _initialActions(),
          if (slide.finalCta) _finalActions(),
        ],
      );

  Widget _keyMessage(String message) => Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 16, bottom: 5),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: _border)),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'packages/ui_kit/Inter',
            color: _muted,
            fontSize: 13,
            height: 1.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  Widget _initialActions() => Column(
        children: [
          const Divider(color: _border, height: 22),
          PrimaryButton(
            label: 'GET STARTED',
            onPressed: () => _goTo(1),
            width: double.infinity,
            height: 48,
            radius: 12,
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: 'LOGIN',
            onPressed: widget.onGetStarted,
            height: 48,
            radius: 12,
            fontSize: 14,
          ),
        ],
      );

  Widget _finalActions() => Column(
        children: [
          const Text(
            'SIGN UP. GET BOOKED. GET PAID.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'packages/ui_kit/Space Grotesk',
              color: _amber,
              fontSize: 11,
              height: 1.6,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'BECOME A SPOTO REFEREE',
            onPressed: widget.onGetStarted,
            width: double.infinity,
            height: 48,
            radius: 12,
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: 'I ALREADY HAVE AN ACCOUNT',
            onPressed: widget.onGetStarted,
            height: 48,
            radius: 12,
            fontSize: 13,
          ),
        ],
      );

  Widget _visual(_Visual visual) {
    switch (visual) {
      case _Visual.stadium:
        return _stadium('SPOTO · LIVE', 'REFEREE');
      case _Visual.finalStadium:
        return _stadium('WELCOME · SPOTO', 'KICKOFF IS SOON');
      case _Visual.booking:
        return _bookingCard();
      case _Visual.matches:
        return _matchStack();
      case _Visual.payout:
        return _payoutCard();
      case _Visual.earnings:
        return _earningsCard();
      case _Visual.profile:
        return _profileCard();
      case _Visual.journey:
        return _journey();
    }
  }

  SportoCard _flatCard({required Widget child, EdgeInsets? padding}) =>
      SportoCard(
        width: double.infinity,
        radius: 14,
        blur: 0,
        backgroundColor: _card,
        borderColor: _border,
        padding: padding ?? const EdgeInsets.all(20),
        child: child,
      );

  Widget _stadium(String score, String caption) => SizedBox(
        width: double.infinity,
        height: 220,
        child: _flatCard(
          padding: EdgeInsets.zero,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 14,
                child: SportoBadge(
                  text: score,
                  color: _amber,
                  outlined: true,
                  radius: 6,
                  fontSize: 11,
                ),
              ),
              for (final left in [54.0, null])
                Positioned(
                  left: left,
                  right: left == null ? 54 : null,
                  bottom: 0,
                  child: Column(
                    children: [
                      Container(width: 22, height: 10, color: _amber),
                      Container(width: 3, height: 102, color: _faint),
                    ],
                  ),
                ),
              Positioned(
                bottom: 27,
                left: 46,
                right: 46,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    _PlayerMark(color: _faint),
                    _PlayerMark(color: _amber),
                    _PlayerMark(color: _amber),
                    _PlayerMark(color: _faint),
                  ],
                ),
              ),
              Positioned(
                bottom: 21,
                child: Column(
                  children: [
                    const CircleAvatar(
                        radius: 7, backgroundColor: Color(0xFFD8AB7A)),
                    Container(
                      width: 30,
                      height: 54,
                      decoration: BoxDecoration(
                        color: _text,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: const Center(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                              color: _amber, shape: BoxShape.circle),
                          child: SizedBox(width: 5, height: 5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      caption,
                      style: const TextStyle(
                        fontFamily: 'packages/ui_kit/Space Grotesk',
                        color: _amber,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _bookingCard() => _flatCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              children: [
                _SquareIcon(icon: Icons.notifications_none_rounded),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'NEW BOOKING REQUEST',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _amberLabel,
                  ),
                ),
                SizedBox(width: 6),
                Text('2m ago', style: TextStyle(color: _faint, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 10),
            const Text('🏏  Cricket Tournament',
                style: TextStyle(
                    color: _text, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('📍  Hyderabad', style: _infoText),
            const SizedBox(height: 6),
            const Text('📅  24 August   ·   🕒  6:00 PM', style: _infoText),
            const SizedBox(height: 8),
            SportoBadge(
              text: '₹1,500   REFEREE FEE',
              color: _green,
              radius: 8,
              fontSize: 13,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child:
                        _demoButton('Accept', _green, const Color(0xFF0A2214))),
                const SizedBox(width: 10),
                Expanded(
                    child: _demoButton('Decline', Colors.transparent, _muted,
                        border: true)),
              ],
            ),
          ],
        ),
      );

  Widget _demoButton(String label, Color background, Color foreground,
          {bool border = false}) =>
      Container(
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(10),
          border: border ? Border.all(color: _border) : null,
        ),
        child: Text(label,
            style: TextStyle(
                color: foreground, fontSize: 13, fontWeight: FontWeight.w700)),
      );

  Widget _matchStack() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _matchCard('🏏', 'Cricket — T20', 'Today · 6:00 PM', '₹1,500'),
          const SizedBox(height: 12),
          _matchCard(
              '⚽', 'Football — 5-a-side', 'Tomorrow · 7:00 PM', '₹1,000'),
          const SizedBox(height: 14),
          const Text('VIEW ALL MATCHES', style: _amberLabel),
        ],
      );

  Widget _matchCard(String icon, String sport, String meta, String fee) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SportoBadge(
              text: 'MATCH AVAILABLE', color: _green, radius: 20, fontSize: 9),
          const SizedBox(height: 8),
          _flatCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: _cardRaised,
                      border: Border.all(color: _border),
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(icon, style: const TextStyle(fontSize: 19)),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(sport,
                          style: const TextStyle(
                              color: _text,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700)),
                      Text(meta,
                          style:
                              const TextStyle(color: _faint, fontSize: 11.5)),
                    ])),
                Text(fee,
                    style: const TextStyle(
                        fontFamily: 'packages/ui_kit/Space Grotesk',
                        color: _text,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      );

  Widget _payoutCard() => _flatCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: _cardRaised,
                  shape: BoxShape.circle,
                  border: Border.all(color: _border)),
              child: const Icon(Icons.check_rounded, color: _green, size: 28),
            ),
            const SizedBox(height: 14),
            const Text('MATCH COMPLETED',
                style: TextStyle(
                    fontFamily: 'packages/ui_kit/Space Grotesk',
                    color: _green,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2)),
            const SizedBox(height: 7),
            const Text('REFEREE FEE',
                style: TextStyle(
                    color: _faint,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1)),
            const SizedBox(height: 6),
            const Text('₹1,500',
                style: TextStyle(
                    fontFamily: 'packages/ui_kit/Space Grotesk',
                    color: _text,
                    fontSize: 34,
                    fontWeight: FontWeight.w800)),
            const Divider(color: _border, height: 30),
            const Row(children: [
              Text('Wallet Balance',
                  style: TextStyle(
                      color: _muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
              Spacer(),
              Text('₹8,750',
                  style: TextStyle(
                      fontFamily: 'packages/ui_kit/Space Grotesk',
                      color: _text,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
            ]),
          ],
        ),
      );

  Widget _earningsCard() => _flatCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('THIS MONTH',
                style: TextStyle(
                    fontFamily: 'packages/ui_kit/Space Grotesk',
                    color: _faint,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2)),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _stat('18', 'MATCHES OFFICIATED')),
              const SizedBox(width: 10),
              Expanded(child: _stat('21', 'BOOKINGS ACCEPTED')),
            ]),
            const SizedBox(height: 16),
            const Text('TOTAL EARNINGS',
                style: TextStyle(
                    color: _muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1)),
            const SizedBox(height: 5),
            const Text('₹27,000',
                style: TextStyle(
                    fontFamily: 'packages/ui_kit/Space Grotesk',
                    color: _green,
                    fontSize: 32,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 15),
            SizedBox(
                height: 58,
                child:
                    Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  for (final height in [
                    20.0,
                    28.0,
                    23.0,
                    36.0,
                    32.0,
                    45.0,
                    58.0,
                  ])
                    Expanded(
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Container(
                                height: height,
                                decoration: const BoxDecoration(
                                    color: _amber,
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(3))))))
                ])),
          ],
        ),
      );

  Widget _stat(String value, String label) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: _cardRaised,
            border: Border.all(color: _border),
            borderRadius: BorderRadius.circular(10)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value,
              style: const TextStyle(
                  fontFamily: 'packages/ui_kit/Space Grotesk',
                  color: _text,
                  fontSize: 22,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 5),
          Text(label,
              style: const TextStyle(
                  color: _faint, fontSize: 9, height: 1.3, letterSpacing: .5)),
        ]),
      );

  Widget _profileCard() => _flatCard(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Row(children: [
            _SquareIcon(icon: Icons.sports_rounded, size: 56),
            SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Rahul Kumar',
                  style: TextStyle(
                      color: _text, fontSize: 17, fontWeight: FontWeight.w700)),
              SizedBox(height: 5),
              Text('✓  VERIFIED REFEREE',
                  style: TextStyle(
                      color: _green,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .5)),
            ]),
          ]),
          const Divider(color: _border, height: 28),
          Row(children: [
            Expanded(child: _profileStat('5 Yrs', 'EXPERIENCE')),
            const SizedBox(height: 35, child: VerticalDivider(color: _border)),
            Expanded(child: _profileStat('248', 'MATCHES')),
            const SizedBox(height: 35, child: VerticalDivider(color: _border)),
            Expanded(child: _profileStat('4.9 ★', 'RATING')),
          ]),
          const Divider(color: _border, height: 28),
          const Wrap(spacing: 8, runSpacing: 8, children: [
            SportoBadge(
                text: 'VERIFIED',
                color: Color(0xFF8FB8E8),
                outlined: true,
                radius: 20,
                fontSize: 9.5),
            SportoBadge(
                text: 'TOP RATED',
                color: _amber,
                outlined: true,
                radius: 20,
                fontSize: 9.5),
            SportoBadge(
                text: 'EXPERIENCED',
                color: _green,
                outlined: true,
                radius: 20,
                fontSize: 9.5),
          ]),
        ]),
      );

  Widget _profileStat(String value, String label) => Column(children: [
        Text(value,
            style: const TextStyle(
                fontFamily: 'packages/ui_kit/Space Grotesk',
                color: _text,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: _faint, fontSize: 9.5)),
      ]);

  Widget _journey() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 5; i++) ...[
            _journeyStep(
                i + 1,
                const [
                  'Local Matches',
                  'Tournaments',
                  'More Bookings',
                  'Higher Profile',
                  'Bigger Opportunities'
                ][i],
                i >= 3),
            if (i != 4) Container(width: 2, height: 4, color: _border),
          ],
        ],
      );

  Widget _journeyStep(int number, String label, bool highlighted) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
            color: _cardRaised,
            border: Border.all(color: highlighted ? _amber : _border),
            borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: highlighted ? _amber : _background,
                shape: BoxShape.circle,
                border: Border.all(color: highlighted ? _amber : _border)),
            child: Text('$number',
                style: TextStyle(
                    fontFamily: 'packages/ui_kit/Space Grotesk',
                    color: highlighted ? const Color(0xFF241900) : _muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 14),
          Text(label,
              style: const TextStyle(
                  color: _text, fontSize: 13.5, fontWeight: FontWeight.w700)),
        ]),
      );

  static const _amberLabel = TextStyle(
      fontFamily: 'packages/ui_kit/Space Grotesk',
      color: _amber,
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.3);
  static const _infoText = TextStyle(
      fontFamily: 'packages/ui_kit/Inter',
      color: _muted,
      fontSize: 13,
      height: 1.4);
}

class _PlayerMark extends StatelessWidget {
  const _PlayerMark({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
      width: 7,
      height: 18,
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)));
}

class _SquareIcon extends StatelessWidget {
  const _SquareIcon({required this.icon, this.size = 30});
  final IconData icon;
  final double size;
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: _RefereeOnboardingScreenState._cardRaised,
            border: Border.all(color: _RefereeOnboardingScreenState._border),
            borderRadius: BorderRadius.circular(size == 30 ? 8 : 14)),
        child: Icon(icon,
            color: _RefereeOnboardingScreenState._text, size: size * .42),
      );
}

enum _Visual {
  stadium,
  booking,
  matches,
  payout,
  earnings,
  profile,
  journey,
  finalStadium
}

class _Slide {
  const _Slide({
    required this.eyebrow,
    required this.before,
    required this.highlight,
    required this.description,
    required this.visual,
    this.keyMessage,
    this.initialCta = false,
    this.finalCta = false,
  });
  final String eyebrow;
  final String before;
  final String highlight;
  final String description;
  final _Visual visual;
  final String? keyMessage;
  final bool initialCta;
  final bool finalCta;
}
