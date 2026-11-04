import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'data/app_state.dart';
import 'router/app_router.dart';

class LifeMitraApp extends StatefulWidget {
<<<<<<< HEAD
  const LifeMitraApp({
    super.key,
    this.useSupabase = false,
    this.useFirebase = false,
  });

  /// Supabase Postgres + Supabase Auth (preferred).
  final bool useSupabase;

  /// Legacy Firebase backend — still supported, takes second priority.
=======
  const LifeMitraApp({super.key, this.useFirebase = false});

>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
  final bool useFirebase;

  @override
  State<LifeMitraApp> createState() => _LifeMitraAppState();
}

class _LifeMitraAppState extends State<LifeMitraApp> {
<<<<<<< HEAD
  late final AppState _state = AppState(
    useSupabase: widget.useSupabase,
    useFirebase: widget.useFirebase,
  );
=======
  late final AppState _state = AppState(useFirebase: widget.useFirebase);
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
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
