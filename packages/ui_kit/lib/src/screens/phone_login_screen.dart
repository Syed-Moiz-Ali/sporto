import 'package:flutter/material.dart';
import '../widgets/glass_container.dart';
import '../widgets/glass_button.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _isOtpSent
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                onPressed: () => setState(() => _isOtpSent = false),
              )
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isOtpSent ? 'Verify Your Number' : 'Enter Mobile Number',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                _isOtpSent
                    ? 'Enter 4-digit OTP sent to $_selectedCountryCode${_phoneController.text}'
                    : 'Log in or sign up to access your ${widget.appRole.toUpperCase()} portal',
                style: TextStyle(
                    color: colorScheme.onSurfaceVariant, fontSize: 13),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: SingleChildScrollView(
                  child: _isOtpSent
                      ? _buildOtpView(colorScheme)
                      : _buildPhoneInputView(colorScheme),
                ),
              ),
              GlassButton(
                label: _isOtpSent ? 'Verify OTP' : 'Continue',
                isPrimary: true,
                onPressed: _isOtpSent ? _verifyOtp : _sendOtp,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInputView(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassContainer(
          padding: const EdgeInsets.all(20),
          hasGlow: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mobile Number',
                  style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.outline),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCountryCode,
                        dropdownColor: colorScheme.surface,
                        items: const [
                          DropdownMenuItem(
                              value: '+91', child: Text('🇮🇳 +91')),
                          DropdownMenuItem(value: '+1', child: Text('🇺🇸 +1')),
                          DropdownMenuItem(
                              value: '+44', child: Text('🇬🇧 +44')),
                          DropdownMenuItem(
                              value: '+971', child: Text('🇦🇪 +971')),
                        ],
                        onChanged: (val) =>
                            setState(() => _selectedCountryCode = val!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: colorScheme.surfaceContainer,
                        hintText: '9876543210',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            'By continuing, you agree to SPORTO Terms of Service & Privacy Policy.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpView(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (index) {
            return SizedBox(
              width: 60,
              height: 64,
              child: TextField(
                controller: _otpControllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: colorScheme.surfaceContainer,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        BorderSide(color: colorScheme.primary, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colorScheme.outline),
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
          }),
        ),
        const SizedBox(height: 24),
        Text(
          'Resend code in 00:$_resendCountdown',
          style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
