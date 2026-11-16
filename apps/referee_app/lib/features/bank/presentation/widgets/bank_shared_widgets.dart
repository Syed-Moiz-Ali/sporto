import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ui_kit/ui_kit.dart';

import '../bank_icons.dart';

/// Circular back affordance plus a one-line title used by every bank screen.
///
/// The 44 px hit area keeps the target accessible while the visible surface
/// stays at the Figma 36 px size.
class BankHeader extends StatelessWidget {
  const BankHeader({
    super.key,
    required this.title,
    this.onBack,
  });

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final handleBack = onBack ?? () => Navigator.of(context).maybePop();

    return SizedBox(
      height: 44 * scale,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20 * scale),
        child: Row(
          children: [
            Semantics(
              button: true,
              label: 'Back',
              onTap: handleBack,
              excludeSemantics: true,
              child: SizedBox.square(
                dimension: 44 * scale,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12 * scale),
                    onTap: handleBack,
                    child: Center(
                      child: Container(
                        width: 36 * scale,
                        height: 36 * scale,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .10),
                          borderRadius: BorderRadius.circular(10 * scale),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .12),
                              blurRadius: 4 * scale,
                              offset: Offset(0, 2 * scale),
                            ),
                          ],
                        ),
                        child: Center(
                          child: SportoSvgIcon(
                            BankIcons.back,
                            width: 6 * scale,
                            height: 12 * scale,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 2 * scale),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: SportoTextStyles.text(
                  size: 18,
                  weight: FontWeight.w700,
                  color: Colors.white,
                  height: 23 / 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Red-tinted "no bank account" warning banner from the onboarding frame.
class BankAlertBanner extends StatelessWidget {
  const BankAlertBanner(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;

    return Semantics(
      container: true,
      liveRegion: true,
      label: message,
      child: ExcludeSemantics(
        child: Container(
          constraints: BoxConstraints(minHeight: 56 * scale),
          padding: EdgeInsets.symmetric(
            horizontal: 14 * scale,
            vertical: 10 * scale,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16 * scale),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFFFE6C6C).withValues(alpha: .10),
                const Color(0xFFFE464B).withValues(alpha: .10),
              ],
            ),
          ),
          child: Row(
            children: [
              SportoSvgIcon(BankIcons.alert, size: 26 * scale),
              SizedBox(width: 10 * scale),
              Expanded(
                child: Text(
                  message,
                  style: SportoTextStyles.text(
                    size: 14,
                    weight: FontWeight.w500,
                    color: Colors.white,
                    height: 18 / 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Green-tinted encryption reassurance strip from the add-account frame.
class BankInfoStrip extends StatelessWidget {
  const BankInfoStrip({super.key});

  static const _message =
      'Your information is encrypted, only used for payout verification.';

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;

    return Semantics(
      container: true,
      label: _message,
      child: ExcludeSemantics(
        child: Container(
          constraints: BoxConstraints(minHeight: 56 * scale),
          padding: EdgeInsets.symmetric(
            horizontal: 14 * scale,
            vertical: 10 * scale,
          ),
          decoration: BoxDecoration(
            color: context.sporto.accentGreen.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(16 * scale),
          ),
          child: Row(
            children: [
              SportoSvgIcon(BankIcons.lock, size: 22 * scale),
              SizedBox(width: 10 * scale),
              Expanded(
                child: Text(
                  _message,
                  style: SportoTextStyles.text(
                    size: 14,
                    weight: FontWeight.w500,
                    color: context.sporto.accentGreen,
                    height: 18 / 14,
                    letterSpacing: -0.15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small API-status chip used by the list and details screens.
class BankStatusPill extends StatelessWidget {
  const BankStatusPill({
    super.key,
    required this.label,
    required this.positive,
  });

  final String label;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final sporto = context.sporto;
    final color = positive ? sporto.accentGreen : sporto.muted;

    return Container(
      constraints: BoxConstraints(
        minHeight: 21 * scale,
        maxWidth: 112 * scale,
      ),
      padding: EdgeInsets.fromLTRB(
        5 * scale,
        4 * scale,
        7 * scale,
        4 * scale,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(50 * scale),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (positive)
            SportoSvgIcon(
              BankIcons.checkCircle,
              width: 12 * scale,
              height: 12 * scale,
            )
          else
            Icon(
              Icons.info_outline_rounded,
              size: 12 * scale,
              color: color,
            ),
          SizedBox(width: 3 * scale),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: SportoTextStyles.text(
                size: 10,
                weight: FontWeight.w500,
                color: color,
                height: 13 / 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Marks the payout account that receives referee settlements.
class BankDefaultPill extends StatelessWidget {
  const BankDefaultPill({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final sporto = context.sporto;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 7 * scale,
        vertical: 3 * scale,
      ),
      decoration: BoxDecoration(
        color: sporto.gold.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(50 * scale),
      ),
      child: Text(
        'Default',
        maxLines: 1,
        style: SportoTextStyles.text(
          size: 10,
          weight: FontWeight.w600,
          color: sporto.gold,
          height: 13 / 10,
        ),
      ),
    );
  }
}

/// Full-width gradient CTA used by the onboarding and add-account screens.
class BankGradientButton extends StatelessWidget {
  const BankGradientButton._({
    required this.label,
    required this.onPressed,
    required this.gradient,
    required this.glowColor,
    required this.labelWeight,
    this.icon,
    this.width,
    this.isLoading = false,
    super.key,
  });

  const BankGradientButton.gold({
    required String label,
    required VoidCallback? onPressed,
    Widget? icon,
    double? width,
    bool isLoading = false,
    Key? key,
  }) : this._(
          label: label,
          onPressed: onPressed,
          icon: icon,
          width: width,
          isLoading: isLoading,
          gradient: const LinearGradient(
            colors: [Color(0xFFED7B00), Color(0xFFCF9E24)],
          ),
          glowColor: const Color(0xFFED7B00),
          labelWeight: FontWeight.w700,
          key: key,
        );

  const BankGradientButton.sky({
    required String label,
    required VoidCallback? onPressed,
    Widget? icon,
    double? width,
    bool isLoading = false,
    Key? key,
  }) : this._(
          label: label,
          onPressed: onPressed,
          icon: icon,
          width: width,
          isLoading: isLoading,
          gradient: const LinearGradient(
            colors: [Color(0xFF7AD3FF), Color(0xFF4FBAF0)],
          ),
          glowColor: const Color(0xFF63C6F7),
          labelWeight: FontWeight.w800,
          key: key,
        );

  final String label;
  final VoidCallback? onPressed;
  final Gradient gradient;
  final Color glowColor;
  final FontWeight labelWeight;
  final Widget? icon;
  final double? width;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final enabled = onPressed != null;
    final leading = isLoading
        ? SizedBox.square(
            dimension: 16 * scale,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : icon;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      onTap: onPressed,
      excludeSemantics: true,
      child: Opacity(
        opacity: enabled ? 1 : .55,
        child: SizedBox(
          width: width,
          height: 48 * scale,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(16 * scale),
              boxShadow: [
                BoxShadow(
                  color: glowColor.withValues(alpha: .35),
                  blurRadius: 30 * scale,
                  offset: Offset(2 * scale, 10 * scale),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: .10),
                  blurRadius: 8 * scale,
                  offset: Offset(0, 2 * scale),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16 * scale),
                onTap: onPressed,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (leading != null) ...[
                        leading,
                        SizedBox(width: 6 * scale),
                      ],
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: SportoTextStyles.text(
                            size: 16,
                            weight: labelWeight,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Figma-styled form field: outside label, 48 px dark surface, inline errors.
class BankTextField extends StatelessWidget {
  const BankTextField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.focusNode,
    this.validator,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.inputFormatters,
    this.onFieldSubmitted,
    this.fieldKey,
    this.textCapitalization = TextCapitalization.none,
    this.enableSuggestions = true,
    this.autocorrect = true,
    this.autofillHints,
    this.enableIMEPersonalizedLearning = true,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onFieldSubmitted;
  final Key? fieldKey;
  final TextCapitalization textCapitalization;
  final bool enableSuggestions;
  final bool autocorrect;
  final Iterable<String>? autofillHints;
  final bool enableIMEPersonalizedLearning;

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    final sporto = context.sporto;
    final radius = BorderRadius.circular(14 * scale);

    OutlineInputBorder border(Color color, {double width = 1}) =>
        OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: color, width: width),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: SportoTextStyles.text(
            size: 14,
            weight: FontWeight.w500,
            color: sporto.muted,
            height: 18 / 14,
          ),
        ),
        SizedBox(height: 8 * scale),
        TextFormField(
          key: fieldKey,
          controller: controller,
          focusNode: focusNode,
          validator: validator,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          onFieldSubmitted: onFieldSubmitted,
          textCapitalization: textCapitalization,
          enableSuggestions: enableSuggestions,
          autocorrect: autocorrect,
          autofillHints: autofillHints,
          enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
          cursorColor: sporto.gold,
          style: SportoTextStyles.text(
            size: 14,
            weight: FontWeight.w500,
            color: Colors.white,
            height: 18 / 14,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: sporto.cardElevated,
            hintText: hint,
            hintStyle: SportoTextStyles.text(
              size: 14,
              weight: FontWeight.w500,
              color: sporto.muted,
              height: 18 / 14,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16 * scale,
              vertical: 15 * scale,
            ),
            border: border(Colors.white.withValues(alpha: .10)),
            enabledBorder: border(Colors.white.withValues(alpha: .10)),
            focusedBorder: border(sporto.gold, width: 1.2),
            errorBorder: border(sporto.red),
            focusedErrorBorder: border(sporto.red, width: 1.2),
            errorStyle: SportoTextStyles.text(
              size: 12,
              weight: FontWeight.w400,
              color: sporto.red,
              height: 1.25,
            ),
            errorMaxLines: 2,
          ),
        ),
      ],
    );
  }
}

/// Shared floating SnackBar styling for bank-flow confirmations.
void showBankSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  final sporto = context.sporto;
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: sporto.cardElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12 * context.sportoScale),
      ),
      margin: EdgeInsets.all(16 * context.sportoScale),
      content: Semantics(
        liveRegion: true,
        label: message,
        child: Row(
          children: [
            SportoSvgIcon(
              isError ? BankIcons.alert : BankIcons.checkCircle,
              size: 18 * context.sportoScale,
            ),
            SizedBox(width: 10 * context.sportoScale),
            Expanded(
              child: Text(
                message,
                style: SportoTextStyles.text(
                  size: 13,
                  weight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
