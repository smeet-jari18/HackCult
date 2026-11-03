import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/services/notification_service.dart';
import 'firebase_options.dart';

/// Runs in a separate isolate when a push arrives while the app is closed.
/// The OS already shows the notification; we only need to keep Firebase ready
/// for any data-only messages.
@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Background push: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
  }
  // Local reminders (peak-hour nudge 17:30, streak 20:30, bill 1st of month).
  await NotificationService.init();
  // Plus Jakarta Sans ships in assets/fonts, so no runtime download is needed.
  GoogleFonts.config.allowRuntimeFetching = false;
  await initializeDateFormatting('en_IN');
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  runApp(const LifeMitraApp(useFirebase: true));
}
