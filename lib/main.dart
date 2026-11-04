import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/services/notification_service.dart';
import 'data/supabase/supabase_config.dart';
import 'firebase_options.dart';

/// Runs in a separate isolate when a push arrives while the app is closed.
/// The OS already shows the notification; we only need to keep Firebase ready
/// for any data-only messages.
@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Background push: ${message.messageId}');
}

// ---------------------------------------------------------------------------
// Backend selection (priority: Supabase → Firebase → demo data)
// ---------------------------------------------------------------------------
const String backendOverride =
    String.fromEnvironment('LIFE_BACKEND', defaultValue: '');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Supabase — used automatically when SUPABASE_URL + SUPABASE_ANON_KEY
  //    are supplied (see README_SUPABASE.md).
  final supabaseReady = backendOverride != 'firebase' &&
      backendOverride != 'demo' &&
      await SupabaseConfig.initialize();

  if (supabaseReady) {
    // Supabase mode: Firebase push/analytics are not used, so we skip the
    // Firebase bootstrap entirely. Local notifications still work.
    await NotificationService.init();
    GoogleFonts.config.allowRuntimeFetching = false;
    await initializeDateFormatting('en_IN');
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    runApp(const LifeMitraApp(useSupabase: true));
    return;
  }

  // 2. Firebase (legacy) or 3. demo data.
  var useFirebase = backendOverride == 'firebase';
  if (!useFirebase && backendOverride.isEmpty) {
    // No Supabase config and no explicit backend → keep the original
    // Firebase behaviour so nothing that worked before breaks.
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      useFirebase = true;
    } catch (error) {
      debugPrint('Firebase unavailable, starting in demo mode: $error');
    }
  } else if (useFirebase) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

  if (useFirebase) {
    if (!kIsWeb) {
      FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
    }
  }
  // Local reminders (peak-hour nudge 17:30, streak 20:30, bill 1st of month).
  await NotificationService.init();
  // Plus Jakarta Sans ships in assets/fonts, so no runtime download is needed.
  GoogleFonts.config.allowRuntimeFetching = false;
  await initializeDateFormatting('en_IN');
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  runApp(LifeMitraApp(useFirebase: useFirebase));
}
