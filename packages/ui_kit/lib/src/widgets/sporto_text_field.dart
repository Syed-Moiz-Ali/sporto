// ============================================================
// sporto_text_field.dart
// Glass-styled input field with optional label & suffix icon.
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SportoTextField extends StatelessWidget {
  static const Color inputFill = Color(0xFF1E2128);
  static const Color inputBorder = Color(0x0FFFFFFF);

  final String? label;
  final String? hint;
  final Widget? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextEditingController? controller;

  /// When true the label renders inside the field (onboarding style).
  final bool labelInside;

  /// Overrides the default input background.
  final Color? backgroundColor;

  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const SportoTextField({
    super.key,
    this.label,
    this.hint,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
    this.controller,
    this.labelInside = false,
    this.backgroundColor,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (labelInside) return _buildInsideLabel(cs);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!,
              style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
        ],
        _buildField(cs),
      ],
    );
  }

  Widget _buildField(ColorScheme cs) {
    return GestureDetector(
      onTap: readOnly ? onTap : null,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: backgroundColor ?? inputFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: inputBorder),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _buildInput(cs)),
            if (suffixIcon != null) suffixIcon!,
          ],
        ),
      ),
    );
  }

  Widget _buildInsideLabel(ColorScheme cs) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? inputFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: inputBorder),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null) ...[
            Text(label!,
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
            const SizedBox(height: 4),
          ],
          _buildInput(cs, fontSize: 15),
        ],
      ),
    );
  }

  Widget _buildInput(ColorScheme cs, {double fontSize = 14}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      cursorColor: cs.tertiary,
      style: TextStyle(
          color: cs.onSurface,
          fontSize: fontSize,
          fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        isCollapsed: true,
        hintText: hint,
        hintStyle: TextStyle(
            color: cs.onSurfaceVariant.withOpacity(0.6),
            fontSize: fontSize,
            height: 1.2),
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
