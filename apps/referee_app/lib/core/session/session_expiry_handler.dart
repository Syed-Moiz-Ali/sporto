import 'package:flutter/material.dart';
import 'package:core/core.dart';

import '../../app/router/app_router.dart';
import '../di/dependency_injector.dart';

bool _handlingSessionExpiry = false;

/// Global handler for unauthenticated API responses.
///
/// Clears the stored session + cached user, resets the auth state so the login
/// screen is shown, notifies the user and routes back to login. Safe to call
/// repeatedly (further calls while handling are ignored).
Future<void> handleSessionExpired() async {
  if (_handlingSessionExpiry) return;
  _handlingSessionExpiry = true;
  try {
    await AuthSessionStore().clear();
    // Reset auth state (drops the cached user from memory) so the app falls
    // back to the login screen instead of showing screen-level auth errors.
    DependencyInjector.instance.authBloc.add(SessionExpiredEvent());

    final context = AppRouter.navigatorKey.currentContext;
    final location =
        AppRouter.router.routerDelegate.currentConfiguration.uri.path;
    final alreadyOnLogin = location == AppRouter.homePath;

    if (context != null && context.mounted && !alreadyOnLogin) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Session expired'),
          content: const Text(
            'Your login has expired. Please login again to continue.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Login again'),
            ),
          ],
        ),
      );
    }
  } finally {
    AppRouter.router.go(AppRouter.homePath);
    _handlingSessionExpiry = false;
  }
}
