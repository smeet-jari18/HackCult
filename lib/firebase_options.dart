import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase client options for project green-energy-fb652.
///
/// Client options for the registered Android and web apps.
/// These identifiers are not service-account credentials.
class DefaultFirebaseOptions {
  static const projectId = 'green-energy-fb652';
  static const _senderId = '983072556271';
  static const _storageBucket = 'green-energy-fb652.firebasestorage.app';

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return _options(
        apiKey: 'AIzaSyDps9LGSI97xxq051fgRYqHJ9ZoYyy1tT4',
        appId: '1:983072556271:web:16d158ec53538e9924071a',
        authDomain: '$projectId.firebaseapp.com',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _options(
          apiKey: 'AIzaSyDps9LGSI97xxq051fgRYqHJ9ZoYyy1tT4',
          appId: '1:983072556271:android:3dae1dee045e568824071a',
        );
      case TargetPlatform.iOS:
        return _options(
          apiKey: const String.fromEnvironment('FIREBASE_IOS_API_KEY'),
          appId: const String.fromEnvironment('FIREBASE_IOS_APP_ID'),
          bundleId: const String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID'),
        );
      case TargetPlatform.macOS:
        return _options(
          apiKey: const String.fromEnvironment('FIREBASE_MACOS_API_KEY'),
          appId: const String.fromEnvironment('FIREBASE_MACOS_APP_ID'),
          bundleId: const String.fromEnvironment('FIREBASE_MACOS_BUNDLE_ID'),
        );
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'Firebase is configured for Android, iOS, macOS, and web only.',
        );
      case TargetPlatform.fuchsia:
        throw UnsupportedError('Firebase is not configured for Fuchsia.');
    }
  }

  static FirebaseOptions _options({
    required String apiKey,
    required String appId,
    String? authDomain,
    String? bundleId,
  }) {
    final missing = <String>[
      if (apiKey.isEmpty) 'the platform Firebase API key',
      if (appId.isEmpty) 'the platform Firebase app ID',
      if (bundleId != null && bundleId.isEmpty) 'the iOS/macOS bundle ID',
    ];
    if (missing.isNotEmpty) {
      throw StateError(
        'Firebase is not configured. Missing ${missing.join(', ')}. '
        'Register this platform app in Firebase Console and configure its '
        'Firebase options.',
      );
    }

    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: _senderId,
      projectId: projectId,
      storageBucket: _storageBucket,
      authDomain: authDomain,
      iosBundleId: bundleId,
    );
  }
}
