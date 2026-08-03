import 'package:flutter/material.dart';
import 'glass_container.dart';

class GlassModal extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onClose;

  const GlassModal({
    super.key,
    required this.title,
    required this.child,
    this.onClose,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => GlassModal(title: title, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 60,
      ),
      child: GlassContainer(
        borderRadius: 28,
        blur: 25,
        backgroundColor: colorScheme.surface.withValues(alpha: 0.85),
        borderColor: colorScheme.primary.withValues(alpha: 0.35),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
                  onPressed: onClose ?? () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Divider(color: colorScheme.outline, height: 24),
            child,
          ],
        ),
      ),
    );
  }
}
