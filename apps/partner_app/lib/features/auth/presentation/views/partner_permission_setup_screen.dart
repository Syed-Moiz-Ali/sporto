import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

class PartnerPermissionSetupScreen extends StatefulWidget {
  final VoidCallback onContinue;

  const PartnerPermissionSetupScreen({
    super.key,
    required this.onContinue,
  });

  @override
  State<PartnerPermissionSetupScreen> createState() =>
      _PartnerPermissionSetupScreenState();
}

class _PartnerPermissionSetupScreenState
    extends State<PartnerPermissionSetupScreen> {
  bool _locationEnabled = true;
  bool _notificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final scale = context.sportoScale;

    return SportoScreenShell(
      body: SafeArea(
        child: SportoResponsiveContent(
          padding: EdgeInsets.fromLTRB(
            context.sportoResponsive.horizontalPadding,
            12 * scale,
            context.sportoResponsive.horizontalPadding,
            28 * scale,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _BackButtonTile(
                    onTap: widget.onContinue,
                  ),
                  SizedBox(width: 12 * scale),
                  Text(
                    'Permission Setup',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: cs.onSurface,
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 22 * scale),
              Text(
                'Location',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: cs.onSurface,
                  fontSize: 22 * scale,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 6 * scale),
              Text(
                'Required to verify venue attendance.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontSize: 15 * scale,
                  height: 1.25,
                ),
              ),
              SizedBox(height: 38 * scale),
              _PermissionOptionTile(
                title: 'Location',
                subtitle: 'Required to verify venue attendance.',
                selected: _locationEnabled,
                onTap: () => setState(() {
                  _locationEnabled = true;
                }),
              ),
              SizedBox(height: 16 * scale),
              _PermissionOptionTile(
                title: 'Notifications',
                subtitle: 'Receive match assignments.',
                selected: _notificationsEnabled,
                onTap: () => setState(() {
                  _notificationsEnabled = !_notificationsEnabled;
                }),
              ),
              SizedBox(height: 68 * scale),
              Center(
                child: PrimaryButton(
                  label: 'Continue',
                  width: 270 * scale,
                  height: 48 * scale,
                  radius: 14 * scale,
                  onPressed: widget.onContinue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackButtonTile extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButtonTile({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final scale = context.sportoScale;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10 * scale),
        child: Container(
          width: 36 * scale,
          height: 36 * scale,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: .72),
            borderRadius: BorderRadius.circular(10 * scale),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: cs.onSurface,
            size: 18 * scale,
          ),
        ),
      ),
    );
  }
}

class _PermissionOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _PermissionOptionTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final scale = context.sportoScale;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16 * scale),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: 64 * scale),
          padding: EdgeInsets.symmetric(
            horizontal: 20 * scale,
            vertical: 12 * scale,
          ),
          decoration: BoxDecoration(
            color: context.sporto.field,
            borderRadius: BorderRadius.circular(16 * scale),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .12),
                blurRadius: 16 * scale,
                offset: Offset(0, 8 * scale),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: cs.onSurface,
                        fontSize: 17 * scale,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2 * scale),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 14 * scale,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12 * scale),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 22 * scale,
                height: 22 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? cs.secondary : Colors.transparent,
                  border: selected
                      ? null
                      : Border.all(
                          color: cs.onSurfaceVariant,
                          width: 1.2 * scale,
                        ),
                ),
                alignment: Alignment.center,
                child: selected
                    ? Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16 * scale,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
