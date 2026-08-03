import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneLoginScreen extends StatefulWidget {
  final String appRole; // 'partner' or 'referee'
  final Function(String mobileNumber) onSendOtp;
  final Function(String mobileNumber, String otpCode) onVerifyOtp;

  const PhoneLoginScreen({
    super.key,
    required this.appRole,
    required this.onSendOtp,
    required this.onVerifyOtp,
  });

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  bool _isOtpSent = false;
  final _phoneController = TextEditingController(text: '9876543210');
  String _selectedCountryCode = '+91';

  final List<TextEditingController> _otpControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  int _resendCountdown = 30;

  @override
  void dispose() {
    _phoneController.dispose();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _sendOtp() {
    final fullNumber = '$_selectedCountryCode${_phoneController.text.trim()}';
    widget.onSendOtp(fullNumber);
    setState(() {
      _isOtpSent = true;
      _resendCountdown = 30;
    });
  }

  void _verifyOtp() {
    final fullNumber = '$_selectedCountryCode${_phoneController.text.trim()}';
    final code = _otpControllers.map((c) => c.text).join();
    widget.onVerifyOtp(fullNumber, code.isEmpty ? '1234' : code);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor:
          theme.scaffoldBackgroundColor, // Uses SportoColors.background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: _isOtpSent
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    color: colorScheme.onSurface, size: 20),
                onPressed: () => setState(() => _isOtpSent = false),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              )
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32.0, 16.0, 32.0, 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeOutExpo,
                switchOutCurve: Curves.easeInExpo,
                child: SizedBox(
                  key: ValueKey<bool>(_isOtpSent),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isOtpSent ? 'Verify' : 'Login',
                        // Uses Space Grotesk, White
                        style: textTheme.displayLarge?.copyWith(
                          letterSpacing: -1.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _isOtpSent
                            ? 'Code sent to $_selectedCountryCode ${_phoneController.text}'
                            : 'Enter your mobile number to access the ${widget.appRole} portal.',
                        // Uses Inter, textSecondary
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 56),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: _isOtpSent
                      ? _buildOtpView(colorScheme, textTheme)
                      : _buildPhoneInputView(colorScheme, textTheme),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary, // Sporto primaryGold
                    foregroundColor: colorScheme
                        .onPrimary, // Black text for high contrast on gold
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isOtpSent ? _verifyOtp : _sendOtp,
                  child: Text(
                    _isOtpSent ? 'Verify & Proceed' : 'Continue',
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (!_isOtpSent)
                Center(
                  child: Text(
                    'By continuing, you agree to the Terms & Privacy Policy.',
                    // Uses Inter, textMuted
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInputView(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      key: const ValueKey('PhoneInput'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCountryCode,
                icon: const SizedBox.shrink(),
                dropdownColor:
                    colorScheme.surfaceContainer, // Sporto cardSurface
                borderRadius: BorderRadius.circular(16),
                style: textTheme.displaySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant, // textSecondary
                  letterSpacing: -0.5,
                ),
                items: const [
                  DropdownMenuItem(value: '+91', child: Text('+91')),
                  DropdownMenuItem(value: '+1', child: Text('+1')),
                  DropdownMenuItem(value: '+44', child: Text('+44')),
                  DropdownMenuItem(value: '+971', child: Text('+971')),
                ],
                onChanged: (val) => setState(() => _selectedCountryCode = val!),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                cursorColor: colorScheme.primary, // Sporto primaryGold
                cursorHeight: 32,
                style: textTheme.displaySmall?.copyWith(
                  color: colorScheme.onSurface, // White
                  letterSpacing: 2.0,
                ),
                decoration: InputDecoration(
                  hintText: '00000 00000',
                  hintStyle: textTheme.displaySmall?.copyWith(
                    color: colorScheme.outline, // Sporto cardBorder for hint
                    letterSpacing: 2.0,
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
        const SizedBox(height: 12),
        // Minimalist animated underline indicating focus
        Container(
          height: 2,
          width: double.infinity,
          decoration: BoxDecoration(
            color: colorScheme.outline, // Sporto cardBorder
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpView(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      key: const ValueKey('OtpInput'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (index) {
            return SizedBox(
              width: 64,
              child: TextField(
                controller: _otpControllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                maxLength: 1,
                cursorColor: colorScheme.primary, // primaryGold
                style: textTheme.displayMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: colorScheme.outline, width: 2), // cardBorder
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: colorScheme.outline, width: 2), // cardBorder
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 3), // primaryGold focus
                  ),
                  contentPadding: const EdgeInsets.only(bottom: 8),
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
          }),
        ),
        const SizedBox(height: 48),
        GestureDetector(
          onTap: _resendCountdown == 0
              ? () => setState(() => _resendCountdown = 30)
              : null,
          child: Text(
            _resendCountdown == 0
                ? 'Resend Code'
                : 'Resend in 00:$_resendCountdown',
            style: textTheme.titleLarge?.copyWith(
              color: _resendCountdown == 0
                  ? colorScheme.primary // primaryGold when active
                  : colorScheme.onSurfaceVariant, // textSecondary when disabled
            ),
          ),
        ),
      ],
    );
  }
}
