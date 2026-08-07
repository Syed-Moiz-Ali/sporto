// ============================================================
// phone_login_screen.dart
// ============================================================
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final code = _otpControllers.map((c) => c.text).join();
    widget.onVerifyOtp(fullNumber, code.isEmpty ? '1234' : code);
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
    final top = MediaQuery.of(context).padding.top;
    final rectHeight = top + 150.0;
    final tipY = top + 380.0;

    return SingleChildScrollView(
      key: const ValueKey('login'),
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: top + 390,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ChevronHeaderPainter(
                      rectHeight: rectHeight,
                      tipY: tipY,
                      gradientColors: [cs.primary, cs.tertiary],
                    ),
                  ),
                ),
                Positioned(
                  top: top + 34,
                  left: 0,
                  right: 0,
                  child: Text(
                    'SPORTO',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 62,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: Colors.white,
                      shadows: const [
                        Shadow(
                          color: Color(0x40000000),
                          offset: Offset(0, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: top + 170,
                  left: 46,
                  right: 46,
                  height: 76,
                  child: GlassContainer(
                    borderRadius: 24,
                    blur: 20,
                    borderWidth: 1,
                    borderColor: cs.outlineVariant,
                    backgroundColor: Colors.black.withOpacity(0.55),
                    padding: EdgeInsets.zero,
                    child: Center(
                      child: Text(
                        widget.appRole == 'referee'
                            ? 'Referee Console'
                            : 'Partner Console',
                        style: tt.titleLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 36, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome!',
                  style: tt.displayMedium?.copyWith(
                    color: cs.onSurface,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign up with your mobile number.',
                  style: tt.bodyLarge?.copyWith(
                    color: cs.secondary, // emerald green from theme
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 24),
                _buildPhoneField(cs, tt),
                const SizedBox(height: 12),
                Text(
                  "You'll receive an OTP on the number above.",
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: PrimaryButton(
                    label: 'Continue',
                    loading: widget.isSubmitting,
onPressed: _sendOtp,
                  ),
                ),
                const SizedBox(height: 24),
                Center(child: _buildAccountPill(cs, tt)),
                const SizedBox(height: 26),
                Center(
                  child: GestureDetector(
                    onTap: widget.onHelpTap,
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      'Need Help?',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.secondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: _buildTermsText(cs, tt),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneField(ColorScheme cs, TextTheme tt) {
    return GlassContainer(
      height: 56,
      borderRadius: 14,
      blur: 16,
      borderWidth: 1,
      borderColor: cs.outlineVariant,
      backgroundColor: cs.surfaceContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const _IndiaFlag(width: 24, height: 16),
          const SizedBox(width: 8),
          Text(
            '+91',
            style: tt.titleLarge?.copyWith(
              color: cs.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down_rounded, color: cs.tertiary, size: 20),
          const SizedBox(width: 12),
          Container(width: 1, height: 22, color: cs.outline),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              cursorColor: cs.tertiary,
              style: tt.titleLarge?.copyWith(
                color: cs.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                hintText: 'Mobile number',
                hintStyle: tt.bodyLarge?.copyWith(
                  color: cs.onSurfaceVariant.withOpacity(0.7),
                  fontSize: 15,
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountPill(ColorScheme cs, TextTheme tt) {
    return GlassContainer(
      height: 50,
      borderRadius: 14,
      blur: 14,
      borderWidth: 1,
      borderColor: cs.outlineVariant,
      backgroundColor: cs.surfaceContainer,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Already have an account? ',
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurface,
              fontSize: 14,
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
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsText(ColorScheme cs, TextTheme tt) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: tt.labelSmall?.copyWith(
          fontSize: 12,
          height: 1.5,
          color: cs.onSurfaceVariant.withOpacity(0.85),
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
              backgroundColor: cs.onSurface.withOpacity(0.12),
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
            style: GoogleFonts.spaceGrotesk(
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
              color: cs.onSurface.withOpacity(0.75),
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
          fontWeight: FontWeight.w600,
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
            fontWeight: FontWeight.w600,
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
              fontWeight: FontWeight.w600,
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
  final double tipRadius;
  final List<Color> gradientColors;

  _ChevronHeaderPainter({
    required this.rectHeight,
    required this.tipY,
    required this.gradientColors,
    this.tipRadius = 46.0,
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
      ..color = gradientColors.first.withOpacity(0.35)
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
      oldDelegate.tipRadius != tipRadius ||
      oldDelegate.gradientColors != gradientColors;
}
