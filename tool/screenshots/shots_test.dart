// Screenshot harness (NOT part of `flutter test`; lives outside test/).
// 1. Put Inter TTFs in /tmp/inter/extras/ttf (https://github.com/rsms/inter/releases)
// 2. flutter test tool/screenshots/shots_test.dart --update-goldens
// PNGs land in tool/screenshots/out/. Material icons render as boxes in tests.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:life_mitra/app.dart';
import 'package:life_mitra/data/app_state.dart';

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 350));
    }
  }

  final routes = <String, String>{
    'splash': '/splash',
    'login': '/login',
    'signup': '/signup',
    'onb2': '/onboarding/2',
    'result': '/onboarding/result',
    'forgot': '/forgot',
    'home': '/home',
    'tasks': '/tasks',
    'taskdetail': '/tasks/ac_24',
    'gas': '/home/gas',
    'impact': '/impact',
    'community': '/community',
    'hub': '/hub',
    'solar': '/hub/solar',
    'solarresult': '/hub/solar/result/__LAST__',
    'profile': '/profile',
    'privacy': '/legal/privacy',
    'terms': '/legal/terms',
  };

  testWidgets('shots', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const LifeMitraApp());
    await settle(tester);
    // splash before sign-in
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('out/splash.png'));
    final ctx = tester.element(find.byType(Scaffold).first);
    final state = AppScope.read(ctx);
    GoRouter.of(ctx).go('/login');
    await settle(tester);
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('out/login.png'));
    GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/signup');
    await settle(tester);
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('out/signup.png'));
    GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/forgot');
    await settle(tester);
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('out/forgot.png'));
    unawaited(state.signInWithEmail('nisha@demo.com', 'Demo@1234'));
    await settle(tester);
    final a = await state.assess(monthlyUnits: 280, roofAreaM2: 32, scSt: false);
    for (final e in routes.entries) {
      if (['splash', 'login', 'signup', 'forgot'].contains(e.key)) continue;
      final c = tester.element(find.byType(Scaffold).first);
      GoRouter.of(c).go(e.value.replaceFirst('__LAST__', a.id));
      await settle(tester);
      await expectLater(
          find.byType(MaterialApp), matchesGoldenFile('out/${e.key}.png'));
      final ex = tester.takeException();
      if (ex != null) debugPrint('>>> ${e.key}: $ex');
      // scrolled variant
      final lv = find.byType(Scrollable);
      if (lv.evaluate().isNotEmpty) {
        try {
          await tester.drag(lv.first, const Offset(0, -700));
          await settle(tester);
          await expectLater(find.byType(MaterialApp),
              matchesGoldenFile('out/${e.key}_2.png'));
          final ex2 = tester.takeException();
          if (ex2 != null) debugPrint('>>> ${e.key}_2: $ex2');
        } catch (_) {}
      }
    }
  });
}
