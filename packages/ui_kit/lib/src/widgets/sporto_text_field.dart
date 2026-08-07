// ============================================================
// sporto_text_field.dart
// Glass-styled input field with optional label & suffix icon.
// ============================================================
import 'package:flutter/material.dart';

class SportoTextField extends StatelessWidget {
  static const Color inputFill = Color(0xFF1E2128);
  static const Color inputBorder = Color(0x0FFFFFFF);

  final String? label;
  final String? hint;
  final Widget? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextEditingController? controller;

  const SportoTextField({
    super.key,
    this.label,
    this.hint,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
        GestureDetector(
          onTap: readOnly ? onTap : null,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: inputFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: inputBorder),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: controller != null
                      ? TextField(
                          controller: controller,
                          readOnly: readOnly,
                          style: TextStyle(color: cs.onSurface, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: hint,
                            hintStyle: TextStyle(
                                color: cs.onSurfaceVariant.withOpacity(0.6),
                                fontSize: 14),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        )
                      : Text(hint ?? '',
                          style: TextStyle(
                              color: cs.onSurfaceVariant.withOpacity(0.6),
                              fontSize: 14)),
                ),
                if (suffixIcon != null) suffixIcon!,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
