import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'notification_service.dart';

/// Firebase Cloud Messaging — GEDA campaigns, grid alerts, community updates.
///
/// Flow:
///  1. [PushService.start] after sign-in → asks permission, gets the device
///     token, stores it under `users/{uid}.fcmToken`, subscribes to topics
///     (`all_citizens`, `district_<name>`, `community_<id>`).
///  2. Foreground messages are shown through [NotificationService.showNow]
///     (Android does not display them automatically).
///  3. Background / terminated messages are shown by the OS.
///  4. Admin sends via the `sendCampaign` Cloud Function (functions/src/index.ts)
///     or Firebase Console → Messaging.
///
/// Web: works only when `web/firebase-messaging-sw.js` is served and a VAPID
/// key is set in [webVapidKey]; otherwise it silently skips.
class PushService {
  PushService._();

  /// Firebase Console → Project settings → Cloud Messaging → Web push
  /// certificates → "Generate key pair". Leave empty to disable web push.
  static const String webVapidKey = '';

  static StreamSubscription<RemoteMessage>? _foregroundSub;
  static StreamSubscription<String>? _tokenSub;
  static final Set<String> _topics = {};
  static String? _uid;

  static FirebaseMessaging get _fcm => FirebaseMessaging.instance;

  static String topicForDistrict(String district) =>
      'district_${district.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_')}';

  static String topicForCommunity(String id) => 'community_$id';

  /// Register this device for the signed-in citizen.
  static Future<void> start({
    required String uid,
    required String district,
    String? communityId,
    bool communityUpdates = true,
    bool peakNudge = true,
  }) async {
    if (kIsWeb && webVapidKey.isEmpty) return;
    _uid = uid;
    try {
      final settings = await _fcm.requestPermission(
          alert: true, badge: true, sound: true, provisional: false);
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('Push permission denied');
        return;
      }
      await _fcm.setForegroundNotificationPresentationOptions(
          alert: true, badge: true, sound: true);

      final token = await _fcm.getToken(
          vapidKey: kIsWeb && webVapidKey.isNotEmpty ? webVapidKey : null);
      if (token != null) await _saveToken(uid, token);
      await _tokenSub?.cancel();
      _tokenSub = _fcm.onTokenRefresh.listen((t) => _saveToken(uid, t));

      await _foregroundSub?.cancel();
      _foregroundSub = FirebaseMessaging.onMessage.listen(_onForeground);

      await syncTopics(
          district: district,
          communityId: communityId,
          communityUpdates: communityUpdates,
          peakNudge: peakNudge);
    } catch (e) {
      debugPrint('PushService.start skipped: $e');
    }
  }

  /// Keep topic subscriptions in line with the profile (district / society).
  static Future<void> syncTopics({
    required String district,
    String? communityId,
    bool communityUpdates = true,
    bool peakNudge = true,
  }) async {
    if (kIsWeb) return; // topic subscription is not supported on web
    final wanted = <String>{
      'all_citizens',
      if (peakNudge) 'peak_nudge',
      if (district.isNotEmpty) topicForDistrict(district),
      if (communityId != null && communityUpdates) topicForCommunity(communityId),
    };
    try {
      for (final t in _topics.difference(wanted)) {
        await _fcm.unsubscribeFromTopic(t);
      }
      for (final t in wanted.difference(_topics)) {
        await _fcm.subscribeToTopic(t);
      }
      _topics
        ..clear()
        ..addAll(wanted);
    } catch (e) {
      debugPrint('syncTopics failed: $e');
    }
  }

  /// Sign-out: forget the token so this device stops receiving user-targeted
  /// pushes (topic messages are also dropped because topics are cleared).
  static Future<void> stop() async {
    try {
      await _foregroundSub?.cancel();
      await _tokenSub?.cancel();
      _foregroundSub = null;
      _tokenSub = null;
      if (!kIsWeb) {
        for (final t in _topics) {
          await _fcm.unsubscribeFromTopic(t);
        }
      }
      _topics.clear();
      final uid = _uid;
      _uid = null;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set(
          {'fcmToken': FieldValue.delete(), 'updatedAt': FieldValue.serverTimestamp()},
          SetOptions(merge: true),
        );
      }
      await _fcm.deleteToken();
    } catch (e) {
      debugPrint('PushService.stop: $e');
    }
  }

  // ---------------------------------------------------------------------------

  static Future<void> _saveToken(String uid, String token) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        {
          'fcmToken': token,
          'fcmPlatform': kIsWeb ? 'web' : defaultTargetPlatform.name,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('fcmToken save failed: $e');
    }
  }

  static void _onForeground(RemoteMessage m) {
    final n = m.notification;
    final title = n?.title ?? m.data['title'] as String? ?? 'LiFE Mitra';
    final body = n?.body ?? m.data['body'] as String? ?? '';
    if (body.isEmpty) return;
    NotificationService.showNow(
        title: title, body: body, alert: true, payload: m.data['route'] as String?);
  }
}
