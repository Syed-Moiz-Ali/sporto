import 'package:flutter/material.dart';
import 'package:core/core.dart';

import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();

  runApp(const RefereeApp());
}
