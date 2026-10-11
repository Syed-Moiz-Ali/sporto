import 'package:flutter/material.dart';
import 'package:core/core.dart';

import 'app/app.dart';
import 'core/session/session_expiry_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();

  // Any unauthenticated API response (expired/invalid token) clears the
  // session, shows a dialog and returns the user to login.
  SportoApiClient.onUnauthenticated = handleSessionExpired;

  runApp(const PartnerApp());
}
