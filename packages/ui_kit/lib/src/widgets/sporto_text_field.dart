import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/sporto_design_tokens.dart';

/// Theme-driven SPORTO input matching the outlined Figma field treatment.
class SportoTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final Widget? suffixIcon;
  final Widget? prefix;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  /// Places the label within the outlined surface above the editable value.
  final bool labelInside;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final double? height;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final String? errorText;

  const SportoTextField({
    super.key,
    this.label,
    this.hint,
    this.suffixIcon,
    this.prefix,
    this.readOnly = false,
    this.onTap,
    this.controller,
    this.focusNode,
    this.labelInside = false,
    this.backgroundColor,
    this.borderColor,
    this.focusedBorderColor,
    this.height,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.errorText,
  });

  @override
  State<SportoTextField> createState() => _SportoTextFieldState();
}

class _SportoTextFieldState extends State<SportoTextField> {
  late final FocusNode _ownedFocusNode;

  FocusNode get _focusNode => widget.focusNode ?? _ownedFocusNode;

  @override
  void initState() {
    super.initState();
    _ownedFocusNode = FocusNode();
    _focusNode.addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(covariant SportoTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownedFocusNode)
          .removeListener(_handleFocusChanged);
      _focusNode.addListener(_handleFocusChanged);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChanged);
    _ownedFocusNode.dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.sportoLayout;

    if (widget.labelInside) return _buildInsideLabel(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
               fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: spacing.space8),
        ],
        _buildField(context),
        if (widget.errorText != null) ...[
          SizedBox(height: spacing.space6),
          Text(
            widget.errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
              fontSize: 12,
              height: 1.25,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildField(BuildContext context) {
    final spacing = context.sportoLayout;
    final scale = _responsiveScale(context);

    return GestureDetector(
      onTap: widget.readOnly ? widget.onTap : null,
      behavior: HitTestBehavior.opaque,
      child: _fieldSurface(
        context,
        height: widget.height ?? spacing.space24 * 2 * scale,
        padding: EdgeInsets.symmetric(horizontal: spacing.space16 * scale),
        child: Row(
          children: [
            if (widget.prefix != null) ...[
              widget.prefix!,
              SizedBox(width: spacing.space12 * scale),
            ],
            Expanded(child: _buildInput(context)),
            if (widget.suffixIcon != null) ...[
              SizedBox(width: spacing.space8),
              widget.suffixIcon!,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInsideLabel(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.sportoLayout;
    final scale = _responsiveScale(context);

    return GestureDetector(
      onTap: widget.readOnly ? widget.onTap : null,
      behavior: HitTestBehavior.opaque,
      child: _fieldSurface(
        context,
        constraints: BoxConstraints(minHeight: 62 * scale),
        padding: EdgeInsets.fromLTRB(
          spacing.space16 * scale,
          spacing.space10 * scale,
          spacing.space16 * scale,
          spacing.space10 * scale,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.label != null) ...[
              Text(
                widget.label!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: spacing.space4),
            ],
            _buildInput(context, fontSize: 15),
          ],
        ),
      ),
    );
  }

  Widget _fieldSurface(
    BuildContext context, {
    required Widget child,
    double? height,
    BoxConstraints? constraints,
    required EdgeInsetsGeometry padding,
  }) {
    final tokens = context.sporto;
    final spacing = context.sportoLayout;
    final focused = _focusNode.hasFocus;
    final scale = _responsiveScale(context);
    final hasError = widget.errorText != null;

    final borderColor = hasError
        ? Theme.of(context).colorScheme.error
        : focused
            ? (widget.focusedBorderColor ?? tokens.fieldBorderFocused)
            : (widget.borderColor ?? tokens.fieldBorder);
    return Container(
      key: const ValueKey('sporto_text_field_surface'),
      height: height,
      constraints: constraints,
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? tokens.field,
        borderRadius: BorderRadius.circular(spacing.radius14 * scale),
        border: Border.all(color: borderColor, width: 1.2 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .34),
            blurRadius: 10 * scale,
            offset: Offset(0, 4 * scale),
          ),
          if (focused)
            BoxShadow(
              color: borderColor.withValues(alpha: .12),
              blurRadius: 12 * scale,
            ),
        ],
      ),
      alignment: Alignment.centerLeft,
      child: child,
    );
  }

  double _responsiveScale(BuildContext context) => context.sportoScale;

  Widget _buildInput(BuildContext context, {double fontSize = 14}) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      onChanged: widget.onChanged,
      cursorColor: context.sporto.fieldBorderFocused,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: cs.onSurface,
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        isCollapsed: true,
        filled: false,
        fillColor: Colors.transparent,
        hintText: widget.hint,
        hintStyle: theme.textTheme.bodyLarge?.copyWith(
          color: cs.onSurfaceVariant.withValues(alpha: .72),
          fontSize: fontSize,
          fontWeight: FontWeight.w400,
          height: 1.2,
        ),
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
