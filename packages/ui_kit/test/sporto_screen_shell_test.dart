import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  for (final variant in SportoAppBackground.values) {
    testWidgets('authenticated shell uses the ${variant.name} Figma artwork',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: SportoTheme.darkTheme,
          home: SportoAppBackgroundScope(
            background: variant,
            child: const SportoScreenShell(body: SizedBox.shrink()),
          ),
        ),
      );

      final image = tester.widget<Image>(find.byType(Image));
      final expectedAsset = switch (variant) {
        SportoAppBackground.referee => 'assets/backgrounds/referee_app_bg.png',
        SportoAppBackground.partner => 'assets/backgrounds/partner_app_bg.png',
      };
      final assetImage = image.image as AssetImage;

      expect(assetImage.assetName, expectedAsset);
      expect(assetImage.package, 'ui_kit');
      expect(image.alignment, Alignment.topCenter);
      expect(image.fit, BoxFit.cover);

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, Colors.transparent);
    });
  }
}
