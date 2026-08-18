// ============================================================
// phone_login_screen.dart
// ============================================================
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ui_kit/ui_kit.dart';

class PhoneLoginScreen extends StatefulWidget {
  final String appRole; // 'partner' or 'referee'
  final Function(String mobileNumber) onSendOtp;
  final Function(String mobileNumber, String otpCode) onVerifyOtp;
  final VoidCallback? onLoginTap;
  final VoidCallback? onHelpTap;

  /// When provided the screen opens directly in OTP mode (e.g. after the
  /// app re-renders it following an [OtpSentState]).
  final String? initialMobileNumber;

  /// Shows a spinner inside the Continue/Verify button while `true`.
  final bool isSubmitting;

  const PhoneLoginScreen({
    super.key,
    required this.appRole,
    required this.onSendOtp,
    required this.onVerifyOtp,
    this.onLoginTap,
    this.onHelpTap,
    this.initialMobileNumber,
    this.isSubmitting = false,
  });

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  bool _isOtpSent = false;
  final _phoneController = TextEditingController();
  static const String _countryCode = '+91';
  final List<TextEditingController> _otpControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  int _resendCountdown = 30;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    final initialNumber = widget.initialMobileNumber;
    if (initialNumber != null && initialNumber.isNotEmpty) {
      _phoneController.text = initialNumber.replaceFirst(_countryCode, '');
      _isOtpSent = true;
      _startCountdown();
    }
  }

  @override
  void didUpdateWidget(covariant PhoneLoginScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newNumber = widget.initialMobileNumber;
    if (newNumber != null && newNumber != oldWidget.initialMobileNumber) {
      _phoneController.text = newNumber.replaceFirst(_countryCode, '');
      if (!_isOtpSent) {
        setState(() {
          _isOtpSent = true;
          _resendCountdown = 30;
        });
      }
      _startCountdown();
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  void _sendOtp() {
    final fullNumber = '$_countryCode${_phoneController.text.trim()}';
    widget.onSendOtp(fullNumber);
  }

  void _startCountdown() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown <= 1) {
        timer.cancel();
        if (mounted) setState(() => _resendCountdown = 0);
      } else {
        if (mounted) setState(() => _resendCountdown--);
      }
    });
  }

  void _resendOtp() {
    final fullNumber = '$_countryCode${_phoneController.text.trim()}';
    widget.onSendOtp(fullNumber);
    setState(() => _resendCountdown = 30);
    _startCountdown();
  }

  void _verifyOtp() {
    final fullNumber = '$_countryCode${_phoneController.text.trim()}';
    final code = _otpControllers.map((c) => c.text.trim()).join();
    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter all 4 digits of the OTP.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    widget.onVerifyOtp(fullNumber, code);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          const SportoAmbientBackground(),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: _isOtpSent
                ? _buildOtpScreen(cs, tt)
                : _buildLoginScreen(cs, tt),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // ------------------------------------------------------------
  // LOGIN STATE — orange chevron header + welcome form
  // ------------------------------------------------------------
  Widget _buildLoginScreen(ColorScheme cs, TextTheme tt) {
    final tokens = context.sporto;
    final spacing = context.sportoLayout;
    final size = MediaQuery.sizeOf(context);
    final scale = context.sportoScale;
    double scaled(double value) => value * scale;

    return SingleChildScrollView(
      key: const ValueKey('login'),
      physics: const ClampingScrollPhysics(),
      child: ConstrainedBox(
        constraints:
            BoxConstraints(minHeight: math.max(size.height, scaled(844))),
        child: Stack(
          children: [
            SizedBox(
              height: scaled(314),
              child: CustomPaint(
                painter: _ChevronHeaderPainter(
                  rectHeight: scaled(122),
                  tipY: scaled(317),
                  gradientColors: tokens.primaryGradient.colors,
                ),
                child: Stack(
                  children: [
                    Positioned(
                       top: scaled(88),
                      left: 0,
                      right: 0,
                      child: Transform.scale(
                        scaleX: 1.14,
                        scaleY: .94,
                        child: Text(
                          'SPORTO',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .primaryTextTheme
                              .displayLarge
                              ?.copyWith(
                            color: cs.onPrimary,
                            fontSize: scaled(68),
                            shadows: [
                              Shadow(
                                color: const Color(0x40000000),
                                offset: Offset(0, scaled(3)),
                                blurRadius: scaled(6),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: scaled(190),
                      left: scaled(50),
                      right: scaled(50),
                      height: scaled(65),
                      child: GlassContainer(
                        borderRadius: scaled(30),
                        blur: scaled(20),
                        borderWidth: 0,
                        backgroundColor: tokens.authBadge,
                        padding: EdgeInsets.zero,
                        child: Center(
                          child: Text(
                            widget.appRole == 'referee'
                                ? 'Referee Console'
                                : 'Partner Console',
                            style: tt.titleLarge?.copyWith(
                              color: cs.onPrimary,
                              fontSize: scaled(20),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              key: const ValueKey('login-form-panel'),
              margin: EdgeInsets.only(top: scaled(314)),
              constraints: BoxConstraints(
                minHeight: math.max(
                  scaled(530),
                  size.height - scaled(314),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                scaled(spacing.space20),
                 scaled(spacing.space24),
                scaled(spacing.space20),
                scaled(spacing.space20),
              ),
              decoration: BoxDecoration(
                gradient: tokens.authPanelGradient,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(
                    scaled(spacing.radius20 + spacing.radius16),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome!',
                    style: tt.displayMedium?.copyWith(
                      color: cs.onSurface,
                       fontSize: scaled(27),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: scaled(spacing.space4)),
                  Text(
                    'Sign up with your mobile number.',
                    style: tt.bodyLarge?.copyWith(
                      color: cs.secondary, // emerald green from theme
                      fontSize: scaled(16),
                    ),
                  ),
                  SizedBox(
                    height: scaled(spacing.space24 + spacing.space16),
                  ),
                  _buildPhoneField(cs, tt),
                  SizedBox(height: scaled(spacing.space16)),
                  Text(
                    "You'll receive an OTP on the number above.",
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontSize: scaled(14),
                    ),
                  ),
                  SizedBox(
                    height: scaled(spacing.space30 + spacing.space24),
                  ),
                  Center(
                    child: PrimaryButton(
                      width: scaled(270),
                      height: scaled(48),
                      radius: scaled(spacing.radius14),
                      label: 'Continue',
                      loading: widget.isSubmitting,
                      onPressed: _sendOtp,
                    ),
                  ),
                  SizedBox(
                    height: scaled(spacing.space30 + spacing.space8),
                  ),
                  Center(child: _buildAccountPill(cs, tt)),
                  SizedBox(
                    height: scaled(spacing.space30 + spacing.space10),
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: widget.onHelpTap,
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        'Need Help?',
                        style: tt.bodyMedium?.copyWith(
                          color: cs.secondary,
                          fontSize: scaled(12),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: scaled(spacing.space30 + spacing.space10),
                  ),
                   _buildTermsText(cs, tt),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneField(ColorScheme cs, TextTheme tt) {
    final tokens = context.sporto;
    final spacing = context.sportoLayout;
    final scale = context.sportoScale;

    return SportoTextField(
      controller: _phoneController,
      hint: 'Mobile number',
      keyboardType: TextInputType.phone,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      backgroundColor: tokens.field,
      borderColor: tokens.authFieldBorder,
      focusedBorderColor: tokens.fieldBorderFocused,
      prefix: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _IndiaFlag(width: 22 * scale, height: 15 * scale),
          SizedBox(width: spacing.space4 * scale),
          Text(
            '+91',
            style: tt.bodyLarge?.copyWith(
              color: cs.onTertiary,
              fontSize: 14 * scale,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: spacing.space6 * scale),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: cs.tertiary,
            size: 16 * scale,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountPill(ColorScheme cs, TextTheme tt) {
    final scale = context.sportoScale;
    return GlassContainer(
      width: 252 * scale,
      height: 45 * scale,
      borderRadius: 14 * scale,
      blur: 14 * scale,
      borderWidth: scale,
      borderColor: cs.outlineVariant,
      backgroundColor: cs.surfaceContainer,
      padding: EdgeInsets.symmetric(horizontal: 14 * scale),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Already have an account? ',
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurface,
              fontSize: 14 * scale,
              fontWeight: FontWeight.w500,
            ),
          ),
          GestureDetector(
            onTap: widget.onLoginTap,
            behavior: HitTestBehavior.opaque,
            child: Text(
              'Login',
              style: tt.bodyMedium?.copyWith(
                color: cs.tertiary,
                fontSize: 14 * scale,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsText(ColorScheme cs, TextTheme tt) {
    final scale = context.sportoScale;
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: tt.labelSmall?.copyWith(
          fontSize: 12 * scale,
          height: 1.5,
          color: cs.onSurfaceVariant.withValues(alpha: 0.85),
        ),
        children: [
          const TextSpan(text: 'By continuing, you agree to our '),
          TextSpan(
            text: 'Terms of Service',
            style: TextStyle(color: cs.onTertiary),
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy.',
            style: TextStyle(color: cs.onTertiary),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // OTP STATE — verify screen (full-screen layout)
  // ------------------------------------------------------------
  Widget _buildOtpScreen(ColorScheme cs, TextTheme tt) {
    final top = MediaQuery.of(context).padding.top;

    return Padding(
      key: const ValueKey('otp'),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: top + 10),
          GestureDetector(
            onTap: () => setState(() => _isOtpSent = false),
            behavior: HitTestBehavior.opaque,
            child: GlassContainer(
              width: 40,
              height: 40,
              borderRadius: 12,
              blur: 12,
              borderWidth: 1,
              borderColor: cs.outlineVariant,
              backgroundColor: cs.onSurface.withValues(alpha: 0.12),
              padding: EdgeInsets.zero,
              child: Center(
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    color: cs.onSurface, size: 18),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Verify Your Number',
            style: tt.displayMedium?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: cs.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Enter 6-digit OTP',
            style: tt.bodyLarge?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.75),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          GlassContainer(
            borderRadius: 24,
            blur: 18,
            borderWidth: 1,
            borderColor: cs.outlineVariant,
            backgroundColor: cs.surfaceContainer,
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    4,
                    (index) => _buildOtpBox(index, cs, tt),
                  ),
                ),
                const SizedBox(height: 24),
                _buildResendRow(cs, tt),
              ],
            ),
          ),
          const SizedBox(height: 48),
          Center(
            child: PrimaryButton(
              label: 'Verify OTP',
              loading: widget.isSubmitting,
              onPressed: _verifyOtp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpBox(int index, ColorScheme cs, TextTheme tt) {
    return SizedBox(
      width: 56,
      height: 50,
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textAlign: TextAlign.center,
        maxLength: 1,
        cursorColor: cs.tertiary,
        style: tt.displayMedium?.copyWith(
          color: cs.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: cs.surfaceContainerHigh,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.outline, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.outline, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.onTertiary, width: 1.5),
          ),
        ),
        onChanged: (val) {
          if (val.isNotEmpty && index < 3) {
            _focusNodes[index + 1].requestFocus();
          } else if (val.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }

  Widget _buildResendRow(ColorScheme cs, TextTheme tt) {
    if (_resendCountdown == 0) {
      return GestureDetector(
        onTap: _resendOtp,
        behavior: HitTestBehavior.opaque,
        child: Text(
          'Resend Code',
          style: tt.bodyLarge?.copyWith(
            color: cs.tertiary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    final timeLabel = '00:${_resendCountdown.toString().padLeft(2, '0')}';
    return RichText(
      text: TextSpan(
        style: tt.bodyLarge?.copyWith(
          color: cs.onSurfaceVariant,
          fontSize: 14,
        ),
        children: [
          const TextSpan(text: 'Resend code '),
          TextSpan(
            text: timeLabel,
            style: TextStyle(
              color: cs.onTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Indian tricolor flag (vector, no assets)
// ============================================================
class _IndiaFlag extends StatelessWidget {
  final double width;
  final double height;

  const _IndiaFlag({this.width = 24, this.height = 16});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: SizedBox(
        width: width,
        height: height,
        child: CustomPaint(painter: _IndiaFlagPainter()),
      ),
    );
  }
}

class _IndiaFlagPainter extends CustomPainter {
  static const Color _saffron = Color(0xFFFF9933);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _green = Color(0xFF138808);
  static const Color _navy = Color(0xFF000080);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bandH = h / 3;

    canvas.drawRect(Rect.fromLTWH(0, 0, w, bandH), Paint()..color = _saffron);
    canvas.drawRect(Rect.fromLTWH(0, bandH, w, bandH), Paint()..color = _white);
    canvas.drawRect(
        Rect.fromLTWH(0, bandH * 2, w, bandH), Paint()..color = _green);

    final center = Offset(w / 2, h / 2);
    final radius = bandH * 0.42;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = _navy
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.6, w * 0.018),
    );

    final spokePaint = Paint()
      ..color = _navy
      ..strokeWidth = math.max(0.4, w * 0.012);
    for (var i = 0; i < 24; i++) {
      final angle = (i * 2 * math.pi) / 24;
      final end = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(center, end, spokePaint);
    }

    canvas.drawCircle(center, radius * 0.16, Paint()..color = _navy);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================
// Orange chevron header (rectangle + rounded downward tip)
// Gradient colors are injected from the theme — no SportoColors.
// ============================================================
class _ChevronHeaderPainter extends CustomPainter {
  final double rectHeight;
  final double tipY;
  static const double tipRadius = 46;
  final List<Color> gradientColors;

  _ChevronHeaderPainter({
    required this.rectHeight,
    required this.tipY,
    required this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final halfW = w / 2;

    final leftDx = -halfW;
    final leftDy = rectHeight - tipY;
    final leftLen = math.sqrt(leftDx * leftDx + leftDy * leftDy);

    final rightDx = halfW;
    final rightDy = rectHeight - tipY;
    final rightLen = math.sqrt(rightDx * rightDx + rightDy * rightDy);

    final r = tipRadius.clamp(0.0, leftLen / 2).clamp(0.0, rightLen / 2);

    final leftStartX = halfW + (leftDx / leftLen) * r;
    final leftStartY = tipY + (leftDy / leftLen) * r;
    final rightEndX = halfW + (rightDx / rightLen) * r;
    final rightEndY = tipY + (rightDy / rightLen) * r;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, rectHeight)
      ..lineTo(rightEndX, rightEndY)
      ..quadraticBezierTo(halfW, tipY, leftStartX, leftStartY)
      ..lineTo(0, rectHeight)
      ..close();

    final glowPaint = Paint()
      ..color = gradientColors.first.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawPath(path, glowPaint);

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: gradientColors,
      ).createShader(Offset.zero & size);
    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _ChevronHeaderPainter oldDelegate) =>
      oldDelegate.rectHeight != rectHeight ||
      oldDelegate.tipY != tipY ||
      oldDelegate.gradientColors != gradientColors;
}
