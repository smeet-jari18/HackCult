import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'data/app_state.dart';
import 'router/app_router.dart';

class LifeMitraApp extends StatefulWidget {
  const LifeMitraApp({
    super.key,
    this.useSupabase = false,
    this.useFirebase = false,
  });

  /// Supabase Postgres + Supabase Auth (preferred).
  final bool useSupabase;

  /// Legacy Firebase backend — still supported, takes second priority.
  final bool useFirebase;

  @override
  State<LifeMitraApp> createState() => _LifeMitraAppState();
}

class _LifeMitraAppState extends State<LifeMitraApp> {
  late final AppState _state = AppState(
    useSupabase: widget.useSupabase,
    useFirebase: widget.useFirebase,
  );
  late final GoRouter _router = buildRouter(_state);

  @override
  void dispose() {
    _router.dispose();
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: _state,
      child: MaterialApp.router(
        title: 'LiFE Mitra Gujarat',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        routerConfig: _router,
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          // Desktop/web: allow mouse-drag scrolling for the demo.
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
            PointerDeviceKind.stylus
          },
        ),
      ),
    );
  }
}
