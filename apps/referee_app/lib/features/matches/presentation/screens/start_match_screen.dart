import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/di/dependency_injector.dart';
import '../widgets/before_toss_widgets.dart';
import '../widgets/referee_request_widgets.dart';

/// Figma `before_toss/02_Incoming_Requests_Details` — "Start Match" OTP gate.
class StartMatchScreen extends StatefulWidget {
  final BeforeTossMatch? match;
  final String? matchId;

  const StartMatchScreen({
    super.key,
    this.match,
    this.matchId,
  });

  @override
  State<StartMatchScreen> createState() => _StartMatchScreenState();
}

class _StartMatchScreenState extends State<StartMatchScreen> {
  late Future<BeforeTossMatch> _future;
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<BeforeTossMatch> _load() async {
    if (widget.match != null) return widget.match!;
    final id = widget.matchId?.trim();
    if (id == null || id.isEmpty) {
      throw const FormatException('Match id is missing.');
    }
    final response = await DependencyInjector.instance.refereeRemoteDataSource
        .showMyMatchData(id);
    return BeforeTossMatch.fromResponse(response);
  }

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _verify(BeforeTossMatch match) {
    final code = _otpController.text.trim();
    if (code.length != 6) {
      _snack('Enter the 6-digit match OTP.');
      _otpFocus.requestFocus();
      return;
    }
    final expected = match.expectedOtp;
    if (expected != null && expected.isNotEmpty && expected != code) {
      _snack('Incorrect OTP. Please check with the booking user.');
      _otpController.clear();
      _otpFocus.requestFocus();
      setState(() {});
      return;
    }
    final id = match.matchId ?? widget.matchId ?? '';
    if (id.isEmpty) {
      _snack('Match id is missing.');
      return;
    }
    if (context.canPop()) {
      context.pop(true);
    } else {
      context.pushReplacement('${AppRouter.conductTossRoute}?matchId=$id');
    }
  }

  void _showHelp() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C2026),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Having trouble?',
          style: TextStyle(
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Ask the user or partner who booked you to open their booking and '
          'show you the 6-digit match OTP.',
          style: TextStyle(color: Color(0xFFA0A0A0), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
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
              title: 'Start Match',
              subtitle: 'Match verification',
              onBack: () {
                if (context.canPop()) context.pop();
              },
            ),
            Expanded(
              child: FutureBuilder<BeforeTossMatch>(
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
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(24 * scale),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
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
                              snapshot.error?.toString() ?? '',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xFFA0A0A0),
                                fontSize: 12 * scale,
                              ),
                            ),
                            SizedBox(height: 18 * scale),
                            FilledButton(
                              onPressed: () => setState(() {
                                _future = _load();
                              }),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  final match = snapshot.data!;
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      20 * scale,
                      10 * scale,
                      20 * scale,
                      40 * scale,
                    ),
                    child: Column(
                      children: [
                        BeforeTossSportCard(scale: scale, match: match),
                        SizedBox(height: 20 * scale),
                        BeforeTossMatchTicket(scale: scale, match: match),
                        SizedBox(height: 20 * scale),
                        _StartSessionCard(
                          scale: scale,
                          otpController: _otpController,
                          otpFocus: _otpFocus,
                          onChanged: () => setState(() {}),
                          onSubmitted: () => _verify(match),
                        ),
                        SizedBox(height: 20 * scale),
                        _OtpHelpCard(scale: scale),
                        SizedBox(height: 20 * scale),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10 * scale),
                          child: BeforeTossPrimaryButton(
                            scale: scale,
                            label: 'Verify OTP & Start Match',
                            onTap: () => _verify(match),
                          ),
                        ),
                        SizedBox(height: 20 * scale),
                        GestureDetector(
                          onTap: _showHelp,
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12 * scale,
                              vertical: 6 * scale,
                            ),
                            child: Text(
                              'Having trouble?',
                              style: TextStyle(
                                fontSize: 14 * scale,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFA0A0A0),
                              ),
                            ),
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

class _StartSessionCard extends StatelessWidget {
  final double scale;
  final TextEditingController otpController;
  final FocusNode otpFocus;
  final VoidCallback onChanged;
  final VoidCallback onSubmitted;

  const _StartSessionCard({
    required this.scale,
    required this.otpController,
    required this.otpFocus,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16 * scale,
        20 * scale,
        16 * scale,
        16 * scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0x0D2BB673),
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(color: const Color(0x802BB673), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0x332BB673),
            blurRadius: 10 * scale,
            offset: Offset(1 * scale, 4 * scale),
          ),
        ],
      ),
      child: Column(
        children: [
          RefereeGradientText(
            'Start Session?',
            gradient: const LinearGradient(
              colors: [Color(0xFF99FFA3), Color(0xFF68EE76)],
            ),
            style: TextStyle(
              fontSize: 18 * scale,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10 * scale),
          Text(
            'Share this OTP with your referee to start the session.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12 * scale,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFA0A0A0),
              height: 1.3,
            ),
          ),
          SizedBox(height: 24 * scale),
          RefereeGradientText(
            'Enter 6-digit match OTP',
            gradient: const LinearGradient(
              colors: [Color(0xFF7AD3FF), Color(0xFF4FBAF0)],
            ),
            style: TextStyle(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 10 * scale),
          _OtpBoxes(
            scale: scale,
            controller: otpController,
            focusNode: otpFocus,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
          ),
        ],
      ),
    );
  }
}

class _OtpBoxes extends StatelessWidget {
  final double scale;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onChanged;
  final VoidCallback onSubmitted;

  const _OtpBoxes({
    required this.scale,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final text = controller.text;
    final activeIndex = text.isEmpty ? 0 : (text.length - 1).clamp(0, 5);
    return SizedBox(
      height: 46 * scale,
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              final active = index == activeIndex;
              final char = index < text.length ? text[index] : '|';
              final hasDigit = index < text.length;
              return Container(
                width: 44 * scale,
                height: 46 * scale,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14 * scale),
                  color: active ? null : const Color(0xFF1C2026),
                  gradient: active
                      ? const LinearGradient(
                          colors: [Color(0x0F7AD3FF), Color(0x0F4FBAF0)],
                        )
                      : null,
                  border: Border.all(
                    color: active
                        ? const Color(0xFF7AD3FF)
                        : const Color(0x80666666),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  char,
                  style: TextStyle(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w700,
                    color: hasDigit
                        ? const Color(0xFFFFFFFF)
                        : const Color(0xFFA0A0A0),
                    height: 1.0,
                  ),
                ),
              );
            }),
          ),
          Positioned.fill(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              showCursor: false,
              enableInteractiveSelection: false,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              maxLength: 6,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              style: const TextStyle(
                color: Colors.transparent,
                fontSize: 1,
                height: 1,
              ),
              cursorColor: Colors.transparent,
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                counterText: '',
                contentPadding: EdgeInsets.zero,
                isCollapsed: true,
              ),
              onChanged: (_) => onChanged(),
              onSubmitted: (_) => onSubmitted(),
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpHelpCard extends StatelessWidget {
  final double scale;

  const _OtpHelpCard({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10 * scale),
      decoration: BoxDecoration(
        color: const Color(0x6612161C),
        borderRadius: BorderRadius.circular(14 * scale),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18 * scale,
            color: const Color(0xFF2BB673),
          ),
          SizedBox(width: 8 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Haven't received the OTP?",
                  style: TextStyle(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  'Ask the user or partner who booked you to open their '
                  'booking and show you the match OTP.',
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFA0A0A0),
                    height: 1.3,
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
