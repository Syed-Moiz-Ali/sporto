import 'dart:io';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/ui_kit.dart';

/// Loads every SVG registered in [SportoRefereeBookingIcons] through the same
/// vector-graphics pipeline `flutter_svg` uses at runtime.
///
/// Fails on:
///  - a missing file
///  - a parse error
///  - a zero-sized render
///  - an unsupported SVG feature that makes the render diverge from the Figma
///    preview PNG (filters, patterns, images, text, masks, etc.)
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // flutter_svg does not implement these; their presence flips best-effort
  // rendering and can diverge from the Figma export.
  const unsupported = <String, String>{
    r'<filter': 'filter',
    r'feGaussianBlur': 'feGaussianBlur (filter)',
    r'feOffset': 'feOffset (filter)',
    r'feColorMatrix': 'feColorMatrix (filter)',
    r'<pattern': 'pattern',
    r'<mask': 'mask',
    r'<image': 'embedded image',
    r'<text': 'text element',
    r'<foreignObject': 'foreignObject',
  };

  test('all referee-booking SVGs load and render', () async {
    final failures = <String>[];
    final divergent = <String>[];

    expect(SportoRefereeBookingIcons.all, isNotEmpty);

    for (final asset in SportoRefereeBookingIcons.all) {
      final file = File(asset);
      if (!file.existsSync()) {
        failures.add('MISSING: $asset');
        continue;
      }

      final svg = file.readAsStringSync();
      for (final entry in unsupported.entries) {
        if (svg.contains(entry.key)) {
          divergent.add('$asset -> unsupported ${entry.value}');
        }
      }

      try {
        final info = await vg.loadPicture(SvgStringLoader(svg), null);
        final size = info.size;
        if (size.width <= 0 || size.height <= 0) {
          failures.add('ZERO-SIZE: $asset (${size.width}x${size.height})');
        }
        info.picture.dispose();
      } catch (error) {
        failures.add('PARSE-ERROR: $asset -> $error');
      }
    }

    if (divergent.isNotEmpty) {
      // ignore: avoid_print
      print('Assets that may render differently from the Figma preview:'
          '\n${divergent.join('\n')}');
    }

    expect(failures, isEmpty, reason: failures.join('\n'));
    expect(
      divergent,
      isEmpty,
      reason: 'Unsupported SVG features detected (may differ from Figma):'
          '\n${divergent.join('\n')}',
    );
  });
}
