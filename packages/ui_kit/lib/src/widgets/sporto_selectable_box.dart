import 'package:flutter/material.dart';

import '../theme/sporto_design_tokens.dart';

/// Reusable deep selection surface used by sport, format and option pickers.
class SportoSelectableBox extends StatelessWidget {
  const SportoSelectableBox({
    super.key,
    required this.selected,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(14),
    this.height,
    this.showCheck = false,
  });

  final bool selected;
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double? height;
  final bool showCheck;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tokens = context.sporto;
    final scale = context.sportoScale;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14 * scale),
        child: Container(
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: tokens.field.withValues(alpha: selected ? .98 : .82),
            borderRadius: BorderRadius.circular(14 * scale),
            border: Border.all(
              color: selected
                  ? cs.secondary.withValues(alpha: .28)
                  : tokens.border.withValues(alpha: .58),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .24),
                blurRadius: 8 * scale,
                offset: Offset(0, 3 * scale),
              ),
              if (selected)
                BoxShadow(
                  color: cs.secondary.withValues(alpha: .09),
                  blurRadius: 12 * scale,
                  offset: Offset(0, 4 * scale),
                ),
            ],
          ),
          child: Row(children: [
            Expanded(child: child),
            if (showCheck && selected) ...[
              SizedBox(width: 10 * scale),
              Container(
                width: 22 * scale,
                height: 22 * scale,
                decoration: BoxDecoration(
                  color: cs.secondary,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(
                    color: cs.secondary.withValues(alpha: .24),
                    blurRadius: 8 * scale,
                  )],
                ),
                child: Icon(Icons.check_rounded,
                    size: 15 * scale, color: Colors.black),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}
