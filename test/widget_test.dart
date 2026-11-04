import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:life_mitra/app.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('Splash → Login renders email/password + Google', (tester) async {
    tester.view.physicalSize = const Size(1080, 2280);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const LifeMitraApp());
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 350));
    }

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.textContaining('Google'), findsWidgets);
    // No phone/OTP login anywhere.
    expect(find.textContaining('OTP'), findsNothing);
  });
}
