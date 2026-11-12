import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:referee_data/referee_data.dart';
import 'package:shared_domain/shared_domain.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/di/dependency_injector.dart';
import '../widgets/before_toss_widgets.dart';

/// Figma `before_toss/01_Incoming_Requests_Details` — "Match Details".
///
/// Shown for an accepted upcoming match before the toss. Team 1/Team 2 are
/// verified and START MATCH opens the OTP gate that starts the session.
class MatchVerificationScreen extends StatefulWidget {
  final String? matchId;
  final CricketMatchEntity? match;

  const MatchVerificationScreen({
    super.key,
    this.matchId,
    this.match,
  });

  @override
  State<MatchVerificationScreen> createState() =>
      _MatchVerificationScreenState();
}

class _MatchVerificationScreenState extends State<MatchVerificationScreen> {
  Future<({BeforeTossMatch match, RefereeMatchSessionResponse? session})>?
      _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<({BeforeTossMatch match, RefereeMatchSessionResponse? session})>
      _load() async {
    if (widget.match != null) {
      return (
        match: BeforeTossMatch.fromEntity(widget.match!),
        session: null,
      );
    }
    final id = widget.matchId?.trim();
    if (id == null || id.isEmpty) {
      throw const FormatException('Match id is missing.');
    }
    final remote = DependencyInjector.instance.refereeRemoteDataSource;
    final response = await remote.showMyMatchData(id);
    RefereeMatchSessionResponse? session;
    try {
      session = await remote.getMatchReadiness(id);
    } catch (_) {}
    return (match: BeforeTossMatch.fromResponse(response), session: session);
  }

  Future<void> _startMatch(BeforeTossMatch match) async {
    final id = match.matchId ?? widget.matchId ?? '';
    if (id.isEmpty) return;
    // Offline/entity-backed flows (tests, cached screens) skip the network
    // verification; live screens always arrive with a match id only.
    if (widget.match == null) {
      try {
        await DependencyInjector.instance.refereeRemoteDataSource
            .verifyMatchTeams(id);
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to verify match: $error')),
        );
        return;
      }
    }
    if (!mounted) return;
    context.push('${AppRouter.conductTossRoute}?matchId=$id', extra: match);
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    return Scaffold(
      backgroundColor: const Color(0xFF090C10),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BeforeTossHeader(
              scale: scale,
              title: 'Match Details',
              onBack: () {
                if (context.canPop()) context.pop();
              },
            ),
            Expanded(
              child: FutureBuilder<
                  ({
                    BeforeTossMatch match,
                    RefereeMatchSessionResponse? session
                  })>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _BeforeTossSkeleton(scale: scale);
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return _BeforeTossError(
                      scale: scale,
                      message: snapshot.error?.toString() ??
                          'Unable to load match details.',
                      onRetry: () => setState(() {
                        _future = _load();
                      }),
                    );
                  }
                  final payload = snapshot.data!;
                  final match = payload.match;
                  final session = payload.session;
                  final verified = session?.teamsVerified == true &&
                      session?.groundReady == true;
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      20 * scale,
                      10 * scale,
                      20 * scale,
                      40 * scale,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BeforeTossSportCard(scale: scale, match: match),
                        SizedBox(height: 20 * scale),
                        BeforeTossMatchTicket(
                          scale: scale,
                          match: match,
                          includeLocation: true,
                        ),
                        SizedBox(height: 20 * scale),
                        BeforeTossBookingDetails(scale: scale, match: match),
                        SizedBox(height: 20 * scale),
                        BeforeTossChecklist(
                          scale: scale,
                          team1Checked: verified || match.teamA.isNotEmpty,
                          team2Checked: verified || match.teamB.isNotEmpty,
                          tossChecked: session?.tossOtpVerified == true,
                        ),
                        SizedBox(height: 20 * scale),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10 * scale),
                          child: BeforeTossPrimaryButton(
                            scale: scale,
                            label: 'START MATCH',
                            onTap: () => _startMatch(match),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BeforeTossError extends StatelessWidget {
  final double scale;
  final String message;
  final VoidCallback onRetry;

  const _BeforeTossError({
    required this.scale,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFFE464B)),
            SizedBox(height: 12 * scale),
            Text(
              'Unable to load match details',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFFFFFFFF),
                fontSize: 16 * scale,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 6 * scale),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFFA0A0A0),
                fontSize: 12 * scale,
              ),
            ),
            SizedBox(height: 18 * scale),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _BeforeTossSkeleton extends StatefulWidget {
  final double scale;

  const _BeforeTossSkeleton({required this.scale});

  @override
  State<_BeforeTossSkeleton> createState() => _BeforeTossSkeletonState();
}

class _BeforeTossSkeletonState extends State<_BeforeTossSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final color = const Color(0xFF283040)
            .withValues(alpha: 0.25 + 0.3 * _controller.value);
        Widget box(double height, {double radius = 16}) => Container(
              width: double.infinity,
              height: height * s,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(radius * s),
              ),
            );
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20 * s, 10 * s, 20 * s, 40 * s),
          child: Column(
            children: [
              box(47),
              SizedBox(height: 20 * s),
              box(168),
              SizedBox(height: 20 * s),
              box(82),
              SizedBox(height: 20 * s),
              box(136),
              SizedBox(height: 20 * s),
              box(48),
            ],
          ),
        );
      },
    );
  }
}
