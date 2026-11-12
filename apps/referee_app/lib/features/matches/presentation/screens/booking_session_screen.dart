import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:referee_data/referee_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/di/dependency_injector.dart';

/// Referee-side session gate for an independent partner booking.
///
/// The partner configures a scoring match (`assign-match`) and issues three
/// OTPs: toss, start and end. This screen verifies the toss/start OTPs and
/// forwards the referee into the existing toss/scoring screens.
class BookingSessionScreen extends StatefulWidget {
  final String? bookingId;
  final String? matchId;

  const BookingSessionScreen({
    super.key,
    this.bookingId,
    this.matchId,
  });

  @override
  State<BookingSessionScreen> createState() => _BookingSessionScreenState();
}

class _BookingSessionScreenState extends State<BookingSessionScreen> {
  RefereeRemoteDataSource get _remote =>
      DependencyInjector.instance.refereeRemoteDataSource;

  late Future<RefereeBookingSessionResponse> _future;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<RefereeBookingSessionResponse> _load() {
    final id = widget.bookingId?.trim();
    if (id == null || id.isEmpty) {
      throw const FormatException('Booking id is missing.');
    }
    return _remote.getBookingSession(id);
  }

  void _refresh() {
    setState(() => _future = _load());
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _verifyTossOtp(RefereeBookingSessionResponse session) async {
    final otp = await _askOtp(
      title: 'Toss OTP',
      message: 'Ask the organiser for the booking Toss OTP.',
    );
    if (otp == null || !mounted) return;
    setState(() => _busy = true);
    try {
      final updated = await _remote.verifyBookingTossOtp(
        session.bookingId,
        otp: otp,
      );
      if (!mounted) return;
      _openToss(updated.matchId ?? session.matchId);
    } catch (error) {
      if (!mounted) return;
      _snack('Unable to verify Toss OTP: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openToss(int? matchId) async {
    if (matchId == null || matchId <= 0) {
      _snack('The organiser has not configured a scoring match yet.');
      return;
    }
    await context.push(
      '${AppRouter.conductTossRoute}?matchId=$matchId'
      '&bookingId=${widget.bookingId}&skipTossOtp=true',
    );
    if (mounted) _refresh();
  }

  Future<void> _openStartOtp(RefereeBookingSessionResponse session) async {
    final matchId = session.matchId;
    if (matchId == null || matchId <= 0) {
      _snack('The organiser has not configured a scoring match yet.');
      return;
    }
    await context.push(
      '${AppRouter.startMatchRoute}?matchId=$matchId'
      '&bookingId=${widget.bookingId}',
    );
    if (mounted) _refresh();
  }

  Future<void> _openScoring(RefereeBookingSessionResponse session) async {
    final matchId = session.matchId ?? int.tryParse(widget.matchId ?? '');
    if (matchId == null || matchId <= 0) {
      _snack('The scoring match is not available yet.');
      return;
    }
    await context.push(
      '${AppRouter.liveScoringRoute}?matchId=$matchId'
      '&bookingId=${widget.bookingId}',
    );
    if (mounted) _refresh();
  }

  void _openResult(int? matchId) {
    if (matchId == null || matchId <= 0) return;
    context.push('${AppRouter.matchResultRoute}?matchId=$matchId');
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
            _Header(scale: scale, onBack: () => context.pop()),
            Expanded(
              child: FutureBuilder<RefereeBookingSessionResponse>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2BB673),
                      ),
                    );
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return _ErrorView(
                      message: snapshot.error?.toString() ??
                          'Unable to load the booking session.',
                      onRetry: _refresh,
                    );
                  }
                  return _buildBody(snapshot.data!, scale);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(RefereeBookingSessionResponse session, double scale) {
    final matchId = session.matchId ?? int.tryParse(widget.matchId ?? '');
    final tossDone = session.tossVerifiedAt != null;
    final started = session.isStarted || session.bookingStatus == 'ONGOING';
    final completed =
        session.isCompleted || session.bookingStatus == 'COMPLETED';

    return ListView(
      padding: EdgeInsets.fromLTRB(20 * scale, 4, 20 * scale, 32 * scale),
      children: [
        _StatusCard(scale: scale, session: session),
        SizedBox(height: 16 * scale),
        _InfoCard(
          scale: scale,
          title: 'Booking',
          rows: {
            'Booking ID': '${session.bookingId}',
            'Match ID': matchId?.toString() ?? 'Not configured',
            'Payment': session.paymentStatus ?? '—',
            'Booking status': session.bookingStatus ?? '—',
          },
        ),
        SizedBox(height: 20 * scale),
        if (completed)
          _PrimaryButton(
            scale: scale,
            label: 'VIEW RESULT',
            onTap: () => _openResult(matchId),
          )
        else if (started)
          _PrimaryButton(
            scale: scale,
            label: 'CONTINUE SCORING',
            onTap: () => _openScoring(session),
          )
        else if (tossDone)
          _PrimaryButton(
            scale: scale,
            label: 'START SESSION (START OTP)',
            onTap: () => _openStartOtp(session),
          )
        else
          _PrimaryButton(
            scale: scale,
            label: 'VERIFY TOSS OTP',
            onTap: _busy ? null : () => _verifyTossOtp(session),
          ),
        SizedBox(height: 12 * scale),
        if (!completed && !started && tossDone)
          _SecondaryButton(
            scale: scale,
            label: 'CONDUCT TOSS',
            onTap: () => _openToss(matchId),
          ),
        if (!completed && !started && !tossDone) ...[
          SizedBox(height: 12 * scale),
          _SecondaryButton(
            scale: scale,
            label: 'OPEN TOSS',
            onTap: matchId == null ? null : () => _openToss(matchId),
          ),
        ],
        SizedBox(height: 18 * scale),
        Center(
          child: Text(
            'Session OTPs are issued by the organiser in the partner app.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11 * scale,
              color: const Color(0xFFA0A0A0),
            ),
          ),
        ),
      ],
    );
  }

  Future<String?> _askOtp({
    required String title,
    required String message,
  }) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1C2026),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(
                color: Color(0xFFA0A0A0),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 6,
              autofocus: true,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Enter 6-digit OTP',
                hintStyle: TextStyle(color: Color(0xFFA0A0A0)),
                counterText: '',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.length == 6) {
                Navigator.of(dialogContext).pop(text);
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }
}

class _Header extends StatelessWidget {
  final double scale;
  final VoidCallback onBack;

  const _Header({required this.scale, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.fromLTRB(16 * scale, 12 * scale, 16 * scale, 12 * scale),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            color: Colors.white,
          ),
          SizedBox(width: 4 * scale),
          Expanded(
            child: Text(
              'Booking Session',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18 * scale,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final double scale;
  final RefereeBookingSessionResponse session;

  const _StatusCard({required this.scale, required this.session});

  @override
  Widget build(BuildContext context) {
    final started = session.isStarted || session.bookingStatus == 'ONGOING';
    final completed =
        session.isCompleted || session.bookingStatus == 'COMPLETED';
    final accent = completed
        ? const Color(0xFF2BB673)
        : started
            ? const Color(0xFF7AD3FF)
            : const Color(0xFFF4B41A);
    final label = completed
        ? 'Session completed'
        : started
            ? 'Session in progress'
            : session.tossVerifiedAt != null
                ? 'Toss verified — start session'
                : 'Ready for Toss OTP';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF12161C),
        borderRadius: BorderRadius.circular(18 * scale),
        border: Border.all(color: accent.withValues(alpha: 0.55)),
      ),
      child: Row(
        children: [
          Icon(
            completed
                ? Icons.verified_rounded
                : started
                    ? Icons.play_circle_fill_rounded
                    : Icons.shield_outlined,
            color: accent,
            size: 28 * scale,
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3 * scale),
                Text(
                  'Session: ${session.sessionStatus}'
                  '${session.startedAt != null ? ' · started' : ''}',
                  style: TextStyle(
                    color: const Color(0xFFA0A0A0),
                    fontSize: 11 * scale,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final double scale;
  final String title;
  final Map<String, String> rows;

  const _InfoCard({
    required this.scale,
    required this.title,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF12161C),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: const Color(0x1AFFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14 * scale,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8 * scale),
          for (final entry in rows.entries)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 3 * scale),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        color: const Color(0xFFA0A0A0),
                        fontSize: 12 * scale,
                      ),
                    ),
                  ),
                  Text(
                    entry.value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final double scale;
  final String label;
  final VoidCallback? onTap;

  const _PrimaryButton({
    required this.scale,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48 * scale,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF2BB673),
          foregroundColor: const Color(0xFF07110C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14 * scale),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13 * scale,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final double scale;
  final String label;
  final VoidCallback? onTap;

  const _SecondaryButton({
    required this.scale,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46 * scale,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Color(0x4DFFFFFF)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14 * scale),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12 * scale,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFFE464B)),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFA0A0A0), fontSize: 12),
            ),
            const SizedBox(height: 14),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
