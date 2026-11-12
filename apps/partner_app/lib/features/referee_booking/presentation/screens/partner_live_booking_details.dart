import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:partner_data/partner_data.dart';

import '../../../../core/di/dependency_injector.dart';

/// Live partner booking details backed by the referee-booking APIs.
class PartnerLiveBookingDetails extends StatefulWidget {
  final String bookingId;

  const PartnerLiveBookingDetails({super.key, required this.bookingId});

  @override
  State<PartnerLiveBookingDetails> createState() =>
      _PartnerLiveBookingDetailsState();
}

class _PartnerLiveBookingDetailsState extends State<PartnerLiveBookingDetails> {
  PartnerRemoteDataSource get _remote =>
      DependencyInjector.instance.partnerRemoteDataSource;

  late Future<PartnerBooking> _future;
  PartnerBookingSessionOtp? _otp;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _future = _remote.getPartnerBooking(widget.bookingId);
  }

  void _refresh() {
    setState(() {
      _future = _remote.getPartnerBooking(widget.bookingId);
    });
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _issueOtp(String phase) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final otp = await _remote.issuePartnerBookingSessionOtp(
        widget.bookingId,
        phase: phase,
      );
      if (!mounted) return;
      setState(() => _otp = otp);
      _refresh();
    } catch (error) {
      if (!mounted) return;
      _snack('Unable to issue ${phase.toUpperCase()} OTP: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pay(PartnerBooking booking) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final initiate = await _remote.initiatePartnerBookingPayment(
        widget.bookingId,
        PartnerBookingPaymentInitiateRequest(
          idempotencyKey:
              'partner-pay-${widget.bookingId}-${DateTime.now().millisecondsSinceEpoch}',
        ),
      );
      final payment = initiate.payment;
      await _remote.verifyPartnerBookingPayment(
        widget.bookingId,
        PartnerBookingPaymentVerifyRequest(
          paymentId: payment.gatewayPaymentId ?? '${payment.id ?? ''}',
          transactionId: payment.gatewayTransactionId ?? '${payment.id ?? ''}',
        ),
      );
      _refresh();
      _snack('Payment verified. Finding a referee…');
    } catch (error) {
      if (!mounted) return;
      _snack('Payment failed: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel(PartnerBooking booking) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1C2026),
        title: const Text(
          'Cancel booking?',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Reason',
            labelStyle: TextStyle(color: Color(0xFFA0A0A0)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) Navigator.pop(dialogContext, text);
            },
            child: const Text('Cancel booking'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (reason == null || !mounted) return;
    setState(() => _busy = true);
    try {
      await _remote.cancelPartnerBooking(widget.bookingId, reason);
      _refresh();
      _snack('Booking cancelled.');
    } catch (error) {
      if (!mounted) return;
      _snack('Unable to cancel: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _assignMatch(PartnerBooking booking) async {
    final teamAController = TextEditingController();
    final teamBController = TextEditingController();
    final formatController = TextEditingController(text: '1');
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1C2026),
        title: const Text(
          'Configure scoring match',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: teamAController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Team A id'),
            ),
            TextField(
              controller: teamBController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Team B id'),
            ),
            TextField(
              controller: formatController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Sport format id'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Assign'),
          ),
        ],
      ),
    );
    final teamA = int.tryParse(teamAController.text.trim());
    final teamB = int.tryParse(teamBController.text.trim());
    final format = int.tryParse(formatController.text.trim()) ?? 1;
    teamAController.dispose();
    teamBController.dispose();
    formatController.dispose();
    if (ok != true || teamA == null || teamB == null || teamA == teamB) {
      return;
    }
    setState(() => _busy = true);
    try {
      await _remote.assignBookingMatch(
        widget.bookingId,
        PartnerAssignMatchRequest(
          sportFormatId: format,
          teamIds: [teamA, teamB],
        ),
      );
      _refresh();
      _snack('Scoring match configured.');
    } catch (error) {
      if (!mounted) return;
      _snack('Unable to configure match: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090C10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF090C10),
        foregroundColor: Colors.white,
        title: const Text('Booking Details'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<PartnerBooking>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2BB673)),
            );
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return _ErrorView(
              message:
                  snapshot.error?.toString() ?? 'Unable to load the booking.',
              onRetry: _refresh,
            );
          }
          return _buildBody(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildBody(PartnerBooking booking) {
    final matchId = booking.raw['match_id'];
    final status = booking.bookingStatus ?? '';
    final session = booking.raw['session_status']?.toString() ?? 'NOT_STARTED';
    final cancelled = status == 'CANCELLED';
    final completed = status == 'COMPLETED';
    final pendingPayment = status == 'PENDING_PAYMENT';
    final confirmed = status == 'CONFIRMED';
    final ongoing = status == 'ONGOING' || session == 'STARTED';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        _StatusCard(booking: booking),
        const SizedBox(height: 14),
        _InfoCard(
          title: 'Booking',
          rows: {
            'Booking': booking.bookingNumber ?? '#${booking.id}',
            'Referee': booking.raw['referee_name']?.toString() ??
                booking.raw['selected_referee_name']?.toString() ??
                'Awaiting assignment',
            'Sport': booking.raw['sport_name']?.toString() ?? 'Cricket',
            'Venue': booking.raw['venue_name']?.toString() ?? '—',
            'Date': booking.raw['booking_date']?.toString() ?? '—',
            'Time': booking.raw['start_time']?.toString() ?? '—',
            'Amount': '${booking.totalAmount ?? '—'} ${booking.currency ?? ''}',
            'Match': matchId?.toString() ?? 'Not configured',
            'Session': session,
          },
        ),
        if (_otp != null) ...[
          const SizedBox(height: 14),
          _OtpCard(otp: _otp!, onCopy: _copyOtp),
        ],
        if (pendingPayment) ...[
          const SizedBox(height: 18),
          _PrimaryButton(
            label: _busy ? 'Processing…' : 'PAY NOW (SIMULATED)',
            onTap: _busy ? null : () => _pay(booking),
          ),
        ],
        if (confirmed && matchId == null) ...[
          const SizedBox(height: 18),
          _PrimaryButton(
            label: 'CONFIGURE SCORING MATCH',
            onTap: _busy ? null : () => _assignMatch(booking),
          ),
        ],
        if (confirmed) ...[
          const SizedBox(height: 18),
          _PrimaryButton(
            label: 'ISSUE TOSS OTP',
            onTap: _busy ? null : () => _issueOtp('toss'),
          ),
          const SizedBox(height: 10),
          _SecondaryButton(
            label: 'ISSUE START OTP',
            onTap: _busy ? null : () => _issueOtp('start'),
          ),
        ],
        if (ongoing) ...[
          const SizedBox(height: 18),
          _PrimaryButton(
            label: 'ISSUE END OTP',
            onTap: _busy ? null : () => _issueOtp('end'),
          ),
        ],
        if (completed) ...[
          const SizedBox(height: 18),
          const _SuccessCard(),
        ],
        if (!completed && !cancelled) ...[
          const SizedBox(height: 18),
          _SecondaryButton(
            label: 'CANCEL BOOKING',
            onTap: _busy ? null : () => _cancel(booking),
          ),
        ],
      ],
    );
  }

  Future<void> _copyOtp() async {
    final otp = _otp?.otp;
    if (otp == null || otp.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: otp));
    if (!mounted) return;
    _snack('OTP copied.');
  }
}

class _StatusCard extends StatelessWidget {
  final PartnerBooking booking;

  const _StatusCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final status = booking.bookingStatus ?? '—';
    final color = switch (status) {
      'COMPLETED' => const Color(0xFF2BB673),
      'ONGOING' => const Color(0xFF7AD3FF),
      'CONFIRMED' => const Color(0xFF2BB673),
      'PENDING_PAYMENT' => const Color(0xFFF4B41A),
      'CANCELLED' => const Color(0xFFFE464B),
      _ => const Color(0xFFA0A0A0),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF12161C),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            status.replaceAll('_', ' '),
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            booking.displayStatus ?? booking.paymentStatus ?? '',
            style: const TextStyle(color: Color(0xFFA0A0A0), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Map<String, String> rows;

  const _InfoCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF12161C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1AFFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          for (final entry in rows.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        color: Color(0xFFA0A0A0),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    entry.value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
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

class _OtpCard extends StatelessWidget {
  final PartnerBookingSessionOtp otp;
  final VoidCallback onCopy;

  const _OtpCard({required this.otp, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x142BB673),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x802BB673)),
      ),
      child: Column(
        children: [
          Text(
            '${(otp.phase ?? 'session').toUpperCase()} OTP',
            style: const TextStyle(
              color: Color(0xFF2BB673),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            otp.otp,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w700,
              letterSpacing: 6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            otp.delivery ?? 'Share this OTP with the confirmed referee.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFA0A0A0),
              fontSize: 11,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onCopy,
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Copy OTP'),
          ),
        ],
      ),
    );
  }
}

class _SuccessCard extends StatelessWidget {
  const _SuccessCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x142BB673),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x802BB673)),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified_rounded, color: Color(0xFF2BB673)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Booking completed. The referee finished the session and the result is live.',
              style: TextStyle(
                color: Color(0xFFA0A0A0),
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF2BB673),
          foregroundColor: const Color(0xFF07110C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _SecondaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Color(0x4DFFFFFF)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
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
