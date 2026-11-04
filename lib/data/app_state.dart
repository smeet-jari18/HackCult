import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:google_sign_in/google_sign_in.dart';
<<<<<<< HEAD
import 'package:supabase_flutter/supabase_flutter.dart';
=======
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47

import '../core/logic/calculators.dart';
import '../core/services/notification_service.dart';
import '../core/services/push_service.dart';
import 'bill_proof_storage.dart';
import 'mock_data.dart';
import 'models.dart';
<<<<<<< HEAD
import 'supabase/supabase_config.dart';
import 'supabase/supabase_repo.dart';
=======
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47

/// App state backed by Firebase in production and deterministic mock data in tests.
/// Fires only when the *auth/route-gating* state changes (sign-in, sign-out,
/// onboarding complete). GoRouter listens to this instead of the whole
/// [AppState], so routine data updates (points, tasks, profile edits) never
/// rebuild the navigator stack — which is what caused black screens when a
/// dialog or pushed page was open.
class AuthChanges extends ChangeNotifier {
  void bump() => notifyListeners();
}

Community _communityFromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document) {
  return _communityFromData(document.id, document.data());
}

Community _communityFromData(String id, Map<String, dynamic> data) {
  return Community(
    id: id,
    name: data['name'] as String,
    type: data['type'] as String,
    district: data['district'] as String,
    pincode: data['pincode'] as String,
    memberCount: data['memberCount'] as int? ?? 1,
    joinCode: data['joinCode'] as String,
    totalUnitsSaved: (data['totalUnitsSaved'] as num?)?.toDouble() ?? 0,
  );
}

CommunityGoal? _goalFromCommunityDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document) {
  return _goalFromCommunityData(document.id, document.data());
}

CommunityGoal? _goalFromCommunityData(String id, Map<String, dynamic> data) {
  final endDate = data['goalEndDate'];
  if (data['goalTitle'] is! String || endDate is! Timestamp) return null;
  return CommunityGoal(
    id: id,
    communityId: id,
    title: data['goalTitle'] as String,
    metric: data['goalMetric'] as String? ?? 'units',
    target: (data['goalTarget'] as num?)?.toDouble() ?? 100,
    progress: 0,
    endDate: endDate.toDate(),
    bonusPoints: 0,
  );
}

class AppState extends ChangeNotifier {
  final AuthChanges authChanges = AuthChanges();
<<<<<<< HEAD

  /// [useSupabase] takes priority: Supabase Postgres + Supabase Auth.
  /// [useFirebase] (legacy) is still supported so the old backend keeps working.
  /// With both false the app runs on in-memory demo data (tests / offline demo).
  AppState({this.useSupabase = false, this.useFirebase = false}) {
    if (useSupabase) {
      _supabaseRepo = SupabaseRepo(footprintCalc);
      SupabaseRepo.taskResolver = MockData.taskByIdOrNull;
      _supabaseAuthSubscription =
          SupabaseConfig.client.auth.onAuthStateChange.listen(
        (state) => unawaited(_applySupabaseUser(state.session?.user)),
        onError: (Object error, StackTrace stackTrace) {
          FlutterError.reportError(FlutterErrorDetails(
            exception: error,
            stack: stackTrace,
            library: 'Supabase authentication',
          ));
        },
      );
      // Catch an already-restored session (page reload / app resume).
      final restored = SupabaseConfig.client.auth.currentUser;
      if (restored != null) unawaited(_applySupabaseUser(restored));
    } else if (useFirebase) {
=======
  AppState({this.useFirebase = false}) {
    if (useFirebase) {
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
      _authSubscription = _auth.authStateChanges().listen(
        (firebaseUser) => unawaited(_applyAuthUser(firebaseUser)),
        onError: (Object error, StackTrace stackTrace) {
          FlutterError.reportError(FlutterErrorDetails(
            exception: error,
            stack: stackTrace,
            library: 'Firebase authentication',
          ));
        },
      );
    } else {
      _seedDemoAccounts();
    }
  }

<<<<<<< HEAD
  final bool useSupabase;
  final bool useFirebase;

  /// Any live backend (Supabase or Firebase) — used by the UI to hide
  /// demo-only shortcuts.
  bool get isLiveBackend => useSupabase || useFirebase;

  static const googleCancelled = 'google-sign-in-cancelled';

  SupabaseRepo? _supabaseRepo;
  SupabaseRepo get supabaseRepo => _supabaseRepo!;

  StreamSubscription<AuthState>? _supabaseAuthSubscription;
  StreamSubscription<firebase_auth.User?>? _authSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _profileSubscription;
  StreamSubscription<Map<String, dynamic>>? _supabaseProfileSubscription;
  RealtimeChannel? _supabaseProfileChannel;
=======
  final bool useFirebase;
  StreamSubscription<firebase_auth.User?>? _authSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _profileSubscription;
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
  firebase_auth.FirebaseAuth get _auth => firebase_auth.FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  @override
  void dispose() {
<<<<<<< HEAD
    unawaited(_supabaseAuthSubscription?.cancel());
    unawaited(_authSubscription?.cancel());
    unawaited(_profileSubscription?.cancel());
    unawaited(_supabaseProfileSubscription?.cancel());
    final channel = _supabaseProfileChannel;
    if (channel != null) {
      unawaited(SupabaseConfig.client.removeChannel(channel));
    }
=======
    unawaited(_authSubscription?.cancel());
    unawaited(_profileSubscription?.cancel());
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
    authChanges.dispose();
    super.dispose();
  }

  final config = const AppConfig();
  late final footprintCalc = FootprintCalculator(config);
  late final solarCalc = SolarCalculator(config);
  late final BillProofStorage billProofStorage = BillProofStorage();

<<<<<<< HEAD
  /// Bill-proof uploads go to Supabase Storage in Supabase mode and to
  /// Firebase Storage otherwise.
  Future<String> uploadBillProof({
    required Uint8List bytes,
    required String contentType,
  }) {
    if (useSupabase) {
      return supabaseRepo.uploadBillProof(
          bytes: bytes, contentType: contentType);
    }
    return billProofStorage.uploadBillProof(
        bytes: bytes, contentType: contentType);
  }

=======
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
  // ---------- Auth ----------
  AppUser? user;
  final Map<String, (String password, AppUser user)> _accounts = {};
  bool get isSignedIn => user != null;
  final Map<String, Community> _communities = {};
  final Map<String, CommunityGoal> _communityGoals = {};
  List<Community> get communities =>
<<<<<<< HEAD
      isLiveBackend ? _communities.values.toList() : MockData.communities;
=======
      useFirebase ? _communities.values.toList() : MockData.communities;
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47

  void _seedDemoAccounts() {
    final nisha = AppUser(
      uid: 'u_nisha',
      email: 'nisha@demo.com',
      displayName: 'Nisha Patel',
      role: UserRole.citizen,
      authProvider: AuthProvider.password,
      onboardingComplete: true,
      communityId: 'c1',
      points: 1240,
      weeklyPoints: 180,
      streak: 5,
      longestStreak: 12,
      badges: const ['first_step', 'peak_shifter', 'bill_verified', 'streak_7'],
    );
    final admin = AppUser(
      uid: 'u_admin',
      email: 'admin@geda.demo',
      displayName: 'GEDA Programme Officer',
      role: UserRole.admin,
      authProvider: AuthProvider.password,
      onboardingComplete: true,
      district: 'Gandhinagar',
    );
    _accounts['nisha@demo.com'] = ('Demo@1234', nisha);
    _accounts['admin@geda.demo'] = ('Admin@1234', admin);
  }

  /// Returns an error message or null on success.
  Future<String?> signInWithEmail(String email, String password) async {
<<<<<<< HEAD
    if (useSupabase) {
      try {
        final authUser = await supabaseRepo.signInWithEmail(email, password);
        await _applySupabaseUser(authUser);
        return null;
      } catch (error) {
        return SupabaseRepo.friendlyError(error);
      }
    }
=======
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
    if (useFirebase) {
      try {
        final credential = await _auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        await _applyAuthUser(credential.user);
        return null;
      } on firebase_auth.FirebaseAuthException catch (error) {
        return _authError(error);
      } on FirebaseException catch (error, stackTrace) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'Firebase sign-in profile loading',
        ));
        return switch (error.code) {
          'permission-denied' =>
            'Signed in, but your account data could not be loaded due to access permissions.',
          'unavailable' ||
          'network-request-failed' =>
            'Could not load your account data. Check your connection and try again.',
          _ =>
            'Could not finish loading your account (${error.code}). Please try again.',
        };
      }
    }

    await Future<void>.delayed(const Duration(milliseconds: 700));
    final key = email.trim().toLowerCase();
    final account = _accounts[key];
    if (account == null) {
      return 'No account found with this email. Create one or continue with Google.';
    }
    if (account.$2.authProvider == AuthProvider.google) {
      return 'This email uses Google sign-in. Please continue with Google.';
    }
    if (account.$1 != password) {
      return 'Incorrect password. Try again or reset it.';
    }
    _setUser(account.$2);
    return null;
  }

  Future<String?> signUpWithEmail(
      {required String name,
      required String email,
      required String password}) async {
<<<<<<< HEAD
    if (useSupabase) {
      try {
        final authUser = await supabaseRepo.signUpWithEmail(
            name: name, email: email, password: password);
        await _applySupabaseUser(authUser);
        return null;
      } catch (error) {
        return SupabaseRepo.friendlyError(error);
      }
    }
=======
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
    if (useFirebase) {
      try {
        final credential = await _auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        final newUser = credential.user!;
        await newUser.updateDisplayName(name.trim());
        await _writeInitialProfile(newUser, displayName: name.trim());
        await _applyAuthUser(newUser);
        return null;
      } on firebase_auth.FirebaseAuthException catch (error) {
        return _authError(error);
      }
    }

    await Future<void>.delayed(const Duration(milliseconds: 800));
    final key = email.trim().toLowerCase();
    if (_accounts.containsKey(key)) return 'email-already-in-use';
    final u = AppUser(
      uid: 'u_${Random().nextInt(1 << 30)}',
      email: key,
      displayName: name.trim(),
      role: key.endsWith('@geda.gujarat.gov.in')
          ? UserRole.admin
          : UserRole.citizen,
      authProvider: AuthProvider.password,
      onboardingComplete: key.endsWith('@geda.gujarat.gov.in'),
      points: 0,
    );
    _accounts[key] = (password, u);
    _setUser(u);
    return null;
  }

  /// Sentinel returned when the user dismissed the Google account picker.
  /// Screens treat it as "do nothing" (no error banner).
<<<<<<< HEAD
=======
  static const googleCancelled = 'google-sign-in-cancelled';
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47

  /// Web OAuth client of Firebase project `green-energy-fb652`
  /// (Google Cloud → APIs & Services → Credentials → "Web client (auto
  /// created by Google Service)"). Public by design.
<<<<<<< HEAD
  static const googleWebClientId =
      '983072556271-5piiu6gfphbvf3moj1ss2kn396oncr2k.apps.googleusercontent.com';
=======
  static const googleWebClientId = '983072556271-5piiu6gfphbvf3moj1ss2kn396oncr2k.apps.googleusercontent.com';
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47

  firebase_auth.GoogleAuthProvider _googleProvider() =>
      firebase_auth.GoogleAuthProvider()
        ..addScope('email')
        ..setCustomParameters({'prompt': 'select_account'});

  Future<String?> signInWithGoogle({bool adminPortal = false}) async {
<<<<<<< HEAD
    if (useSupabase) {
      try {
        await supabaseRepo.signInWithGoogle(adminPortal: adminPortal);
        // Web: the browser navigates away and comes back with a session,
        // which the auth listener above picks up. Mobile: the OAuth sheet
        // returns to the app and the same listener completes the sign-in.
        return null;
      } catch (error) {
        return SupabaseRepo.friendlyError(error);
      }
    }
=======
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
    if (useFirebase) {
      try {
        firebase_auth.UserCredential credential;
        if (kIsWeb) {
          // Web: Firebase popup flow. No google_sign_in plugin / client-id
          // meta tag needed; only the Google provider must be enabled in
          // Firebase console and the hosting domain must be authorised.
          credential = await _auth.signInWithPopup(_googleProvider());
        } else {
          credential = await _signInWithGoogleMobile();
        }
        await _applyAuthUser(credential.user);
        return null;
      } on _GoogleCancelled {
        return googleCancelled;
      } on firebase_auth.FirebaseAuthException catch (error) {
        return _authError(error);
      } on PlatformException catch (error, stackTrace) {
        _report(error, stackTrace);
        return _googlePlatformError(error);
      } catch (error, stackTrace) {
        _report(error, stackTrace);
        return 'Google sign-in failed. Please try again or use email & '
            'password.';
      }
    }

    await Future<void>.delayed(const Duration(milliseconds: 900));
    final key =
        adminPortal ? 'officer@geda.gujarat.gov.in' : 'nisha.patel@gmail.com';
    var account = _accounts[key];
    if (account == null) {
      final u = AppUser(
        uid: 'u_g_${Random().nextInt(1 << 30)}',
        email: key,
        displayName: adminPortal ? 'Officer (Google Workspace)' : 'Nisha Patel',
        role: adminPortal ? UserRole.admin : UserRole.citizen,
        authProvider: AuthProvider.google,
        onboardingComplete: adminPortal,
      );
      account = ('', u);
      _accounts[key] = account;
    }
    _setUser(account.$2);
    return null;
  }

  Future<String?> sendPasswordReset(String email) async {
<<<<<<< HEAD
    if (useSupabase) {
      try {
        await supabaseRepo.sendPasswordReset(email);
        return null;
      } catch (error) {
        return SupabaseRepo.friendlyError(error);
      }
    }
=======
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
    if (useFirebase) {
      try {
        await _auth.sendPasswordResetEmail(email: email.trim());
        return null;
      } on firebase_auth.FirebaseAuthException catch (error) {
        return _authError(error);
      }
    }

    await Future<void>.delayed(const Duration(milliseconds: 600));
    return null;
  }

  void signOut() {
    unawaited(_profileSubscription?.cancel());
    _profileSubscription = null;
<<<<<<< HEAD
    unawaited(_supabaseProfileSubscription?.cancel());
    _supabaseProfileSubscription = null;
    final channel = _supabaseProfileChannel;
    _supabaseProfileChannel = null;
    if (channel != null) {
      unawaited(SupabaseConfig.client.removeChannel(channel));
    }
    if (useSupabase) {
      unawaited(PushService.stop());
      unawaited(NotificationService.cancelAll());
      unawaited(
          supabaseRepo.signOut().catchError((Object error, StackTrace st) {
        FlutterError.reportError(FlutterErrorDetails(
            exception: error, stack: st, library: 'Supabase sign-out'));
      }));
    }
=======
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
    if (useFirebase) {
      unawaited(PushService.stop());
      unawaited(NotificationService.cancelAll());
      unawaited(_auth.signOut().catchError((Object error, StackTrace stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'Firebase sign-out',
        ));
      }));
      if (_auth.currentUser != null) {
        unawaited(GoogleSignIn().signOut());
      }
    }
    user = null;
    _resetSession();
    notifyListeners();
    authChanges.bump();
  }

  /// Android / iOS Google sign-in.
  ///
  /// 1. Native account picker via google_sign_in (fast, best UX). This needs
  ///    the SHA-1/SHA-256 of the signing key registered in Firebase console
  ///    (google-services.json must contain an `oauth_client` entry).
  /// 2. If that is not configured yet (DEVELOPER_ERROR / ApiException 10,
  ///    missing idToken, etc.) we transparently fall back to Firebase's own
  ///    browser-based provider flow, which only needs the Google provider to
  ///    be enabled in Firebase console. So Google login keeps working even
  ///    on a fresh clone/debug build.
  Future<firebase_auth.UserCredential> _signInWithGoogleMobile() async {
    try {
      // serverClientId = the project's *Web* OAuth client. It makes Android
      // return an idToken once the SHA-1 is registered in Firebase console.
      final googleUser = await GoogleSignIn(
        scopes: const ['email'],
        serverClientId: kIsWeb ? null : googleWebClientId,
      ).signIn();
      if (googleUser == null) throw const _GoogleCancelled();
      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null && googleAuth.accessToken == null) {
        throw PlatformException(
            code: 'sign_in_failed', message: 'No Google token returned');
      }
      final oauthCredential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await _auth.signInWithCredential(oauthCredential);
    } on _GoogleCancelled {
      rethrow;
    } on PlatformException catch (error, stackTrace) {
      if (error.code == 'sign_in_canceled' || error.code == 'canceled') {
        throw const _GoogleCancelled();
      }
      _report(error, stackTrace);
      // Native picker is not configured for this build -> provider flow.
      return _auth.signInWithProvider(_googleProvider());
    } on firebase_auth.FirebaseAuthException catch (error) {
      if (error.code == 'invalid-credential' ||
          error.code == 'operation-not-allowed') {
        rethrow;
      }
      return _auth.signInWithProvider(_googleProvider());
    }
  }

  String _googlePlatformError(PlatformException error) {
    final msg = error.message ?? '';
    if (msg.contains('10') || msg.contains('DEVELOPER_ERROR')) {
      return 'Google sign-in is not configured for this build '
          '(SHA-1 fingerprint missing in Firebase). Use email & password or '
          'contact the administrator.';
    }
    if (msg.contains('7') || msg.toLowerCase().contains('network')) {
      return 'Network error. Check your connection and try again.';
    }
    return 'Google sign-in failed (${error.code}). Please try again.';
  }

  void _report(Object error, StackTrace stackTrace) {
    FlutterError.reportError(FlutterErrorDetails(
      exception: error,
      stack: stackTrace,
      library: 'Google sign-in',
    ));
  }

  String _authError(firebase_auth.FirebaseAuthException error) {
    return switch (error.code) {
      'email-already-in-use' => 'email-already-in-use',
      'invalid-email' => 'Enter a valid email address.',
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' =>
        'Email or password is incorrect.',
      'weak-password' => 'Choose a stronger password.',
      'user-disabled' => 'This account has been disabled.',
      'too-many-requests' => 'Too many attempts. Please try again later.',
      'network-request-failed' =>
        'Network error. Check your connection and try again.',
      'popup-closed-by-user' ||
      'web-context-cancelled' ||
      'cancelled-popup-request' ||
      'web-context-canceled' =>
        googleCancelled,
      'popup-blocked' =>
        'Your browser blocked the Google pop-up. Allow pop-ups for this '
            'site and try again.',
      'unauthorized-domain' =>
        'This website address is not authorised for Google sign-in yet '
            '(add it under Firebase → Authentication → Settings → '
            'Authorized domains).',
      'operation-not-allowed' =>
        'Google sign-in is not enabled for this project yet '
            '(Firebase → Authentication → Sign-in method → Google).',
      'account-exists-with-different-credential' =>
        'This email is already registered with a password. Sign in with '
            'email & password instead.',
      'internal-error' ||
      'app-not-authorized' =>
        'Google sign-in could not start (${error.code}). Check the Firebase '
            'configuration for this app.',
      _ => error.message ?? 'Authentication failed (${error.code}).',
    };
  }

<<<<<<< HEAD
  // ======================================================================
  // Supabase session lifecycle
  // ======================================================================

  /// Builds the in-memory session from Supabase (profile row + snapshot data),
  /// then keeps points/streak/badges in sync with the server via Realtime.
  Future<void> _applySupabaseUser(User? authUser) async {
    if (authUser == null) {
      if (user != null) {
        user = null;
        _resetSession();
        notifyListeners();
        authChanges.bump();
      }
      return;
    }

    final repo = supabaseRepo;
    final provider = authUser.appMetadata['provider'] == 'google'
        ? AuthProvider.google
        : AuthProvider.password;
    Map<String, dynamic> profile;
    try {
      profile = await repo.ensureProfile(authUser);
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'Supabase profile loading',
      ));
      return;
    }
    if (repo.currentUid != authUser.id) return; // signed out while loading

    final loadedUser = SupabaseRepo.userFromProfile(
      profile,
      emailOverride: authUser.email,
      provider: provider,
    );
    _setUser(loadedUser);
    _restoreGasConnection(profile);

    try {
      final results = await Future.wait<Object?>([
        repo.communities(),
        repo.goalProgressView(),
        repo.todayTaskLogs(authUser.id),
        repo.footprints(authUser.id),
        repo.solarAssessments(authUser.id),
        repo.surveyRequests(authUser.id),
        repo.notApplicableTaskIds(authUser.id),
        loadedUser.communityId == null
            ? Future<double>.value(0)
            : repo.myGoalContribution(loadedUser.communityId!, authUser.id),
      ]);
      if (user?.uid != authUser.id) return;

      final communityList = results[0] as List<Community>;
      final goalRows = results[1] as List<Map<String, dynamic>>;
      _communities
        ..clear()
        ..addEntries(communityList.map((c) => MapEntry(c.id, c)));
      _communityGoals.clear();
      for (final row in goalRows) {
        final goal = SupabaseRepo.goalFromProgressRow(row);
        if (goal != null) _communityGoals[goal.communityId] = goal;
      }
      final myCommunityId = loadedUser.communityId;
      if (myCommunityId != null) {
        final goal = _communityGoals[myCommunityId];
        final mine = results[7] as double;
        if (goal != null) goal.myContribution = mine;
      }

      taskLogs
        ..clear()
        ..addAll(results[2] as List<TaskLog>);
      footprints
        ..clear()
        ..addAll(results[3] as List<FootprintEntry>)
        ..sort((a, b) => a.month.compareTo(b.month));
      assessments
        ..clear()
        ..addAll(results[4] as List<SolarAssessment>);
      myLeads
        ..clear()
        ..addAll(results[5] as List<Lead>);
      notApplicable
        ..clear()
        ..addAll(results[6] as Set<String>);
      notifyListeners();

      unawaited(_loadSupabaseLedger(authUser.id));
      _listenToSupabaseProfile(authUser.id);
      _startDeviceServices(loadedUser);
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'Supabase account data loading',
      ));
    }
  }

  Future<void> _loadSupabaseLedger(String uid) async {
    try {
      final entries = await supabaseRepo.ledger(uid);
      if (user?.uid != uid) return;
      ledger
        ..clear()
        ..addAll(entries);
      notifyListeners();
    } catch (e) {
      debugPrint('points ledger load failed: $e');
    }
  }

  /// Realtime updates for points / streak / badges / role.
  void _listenToSupabaseProfile(String uid) {
    unawaited(_supabaseProfileSubscription?.cancel());
    try {
      _supabaseProfileSubscription =
          supabaseRepo.profileStream(uid).listen((data) {
        final u = user;
        if (u == null || u.uid != uid || data.isEmpty) return;
        var changed = false;
        void setInt(int current, String key, void Function(int) assign) {
          final v = data[key];
          if (v is num && v.toInt() != current) {
            assign(v.toInt());
            changed = true;
          }
        }

        setInt(u.points, 'points', (v) => u.points = v);
        setInt(u.weeklyPoints, 'weekly_points', (v) => u.weeklyPoints = v);
        setInt(u.streak, 'streak', (v) => u.streak = v);
        setInt(u.longestStreak, 'longest_streak', (v) => u.longestStreak = v);
        setInt(u.freezeTokens, 'freeze_tokens', (v) => u.freezeTokens = v);
        final badges = data['badges'];
        if (badges is List) {
          final list = badges.map((e) => '$e').toList();
          if (list.length != u.badges.length ||
              !list.every(u.badges.contains)) {
            u.badges = list;
            changed = true;
          }
        }
        final role = data['role'];
        if (role is String) {
          final parsed = UserRole.values
              .firstWhere((r) => r.name == role, orElse: () => u.role);
          if (parsed != u.role) {
            u.role = parsed;
            changed = true;
          }
        }
        final communityId = data['community_id'];
        if (communityId is String && communityId != u.communityId) {
          u.communityId = communityId;
          changed = true;
        }
        if (changed) notifyListeners();
      }, onError: (Object e) => debugPrint('supabase profile stream: $e'));
    } catch (e) {
      debugPrint('supabase profile stream unavailable: $e');
    }
  }

  void _restoreGasConnection(Map<String, dynamic> profile) {
    final raw = profile['gas_connection'];
    if (raw is! Map) return;
    gas = GasConnection(
      type: (raw['type'] as String?) ?? 'lpg',
      provider: (raw['provider'] as String?) ?? '',
      consumerNumber: (raw['consumerNumber'] as String?) ?? '',
      agency: (raw['agency'] as String?) ?? '',
      cylindersPerMonth: ((raw['cylindersPerMonth'] as num?) ?? 1).toInt(),
      scmPerMonth: ((raw['scmPerMonth'] as num?) ?? 15).toInt(),
      pmuy: raw['pmuy'] == true,
      proofAttached: raw['proofAttached'] == true,
    );
  }

=======
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
  Future<void> _writeInitialProfile(
    firebase_auth.User authUser, {
    String? displayName,
  }) async {
    final ref = _firestore.collection('users').doc(authUser.uid);
    final snapshot = await ref.get();
    if (snapshot.exists) return;
    await ref.set({
      'uid': authUser.uid,
      'email': authUser.email ?? '',
      'displayName': displayName ??
          authUser.displayName ??
          authUser.email?.split('@').first ??
          'Citizen',
      'role': 'citizen',
      'authProvider': authUser.providerData
              .any((provider) => provider.providerId == 'google.com')
          ? 'google'
          : 'password',
      'onboardingComplete': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _applyAuthUser(firebase_auth.User? authUser) async {
    if (authUser == null) {
      if (user != null) {
        user = null;
        _resetSession();
        notifyListeners();
        authChanges.bump();
      }
      return;
    }

    final claims = (await authUser.getIdTokenResult(true)).claims ?? {};
    final isAdmin = claims['admin'] == true;
    final isCaptain = claims['captain'] == true;
    final provider =
        authUser.providerData.any((info) => info.providerId == 'google.com');
    Map<String, dynamic> profile;
    try {
      await _writeInitialProfile(authUser);
      profile = (await _firestore.collection('users').doc(authUser.uid).get())
              .data() ??
          {};
    } on FirebaseException catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'Firebase sign-in profile loading',
      ));
      _setUser(AppUser(
        uid: authUser.uid,
        email: authUser.email ?? '',
        displayName: authUser.displayName ??
            authUser.email?.split('@').first ??
            'Citizen',
        role: isAdmin
            ? UserRole.admin
            : isCaptain
                ? UserRole.captain
                : UserRole.citizen,
        authProvider: provider ? AuthProvider.google : AuthProvider.password,
        photoUrl: authUser.photoURL,
      ));
      return;
    }
    final name = (profile['displayName'] as String?) ??
        authUser.displayName ??
        authUser.email?.split('@').first ??
        'Citizen';
    final loadedUser = AppUser(
      uid: authUser.uid,
      email: authUser.email ?? '',
      displayName: name,
      role: isAdmin
          ? UserRole.admin
          : isCaptain
              ? UserRole.captain
              : UserRole.citizen,
      authProvider: provider ? AuthProvider.google : AuthProvider.password,
      photoUrl: authUser.photoURL,
      language: profile['language'] as String? ?? 'en',
      district: profile['district'] as String? ?? 'Ahmedabad',
      pincode: profile['pincode'] as String? ?? '380015',
      householdSize: profile['householdSize'] as int? ?? 4,
      homeType: profile['homeType'] as String? ?? 'flat',
      roofAccess: profile['roofAccess'] as String? ?? 'yes',
      appliances: List<String>.from(profile['appliances'] as List? ??
          const ['ac', 'fridge', 'washing_machine', 'geyser']),
      travelMode: profile['travelMode'] as String? ?? 'two_wheeler',
      weeklyKm: (profile['weeklyKm'] as num?)?.toDouble() ?? 70,
      baselineUnits: (profile['baselineUnits'] as num?)?.toDouble() ?? 250,
      baselineCo2Kg: (profile['baselineCo2Kg'] as num?)?.toDouble() ?? 226.9,
      goalPercent: profile['goalPercent'] as int? ?? 15,
      onboardingComplete: profile['onboardingComplete'] as bool? ?? false,
      communityId: profile['communityId'] as String?,
      points: profile['points'] as int? ?? 0,
      weeklyPoints: profile['weeklyPoints'] as int? ?? 0,
      streak: profile['streak'] as int? ?? 0,
      longestStreak: profile['longestStreak'] as int? ?? 0,
      freezeTokens: profile['freezeTokens'] as int? ?? 1,
      badges: List<String>.from(profile['badges'] as List? ?? const []),
      peakNudge: profile['peakNudge'] as bool? ?? true,
      weatherNudge: profile['weatherNudge'] as bool? ?? true,
      communityUpdates: profile['communityUpdates'] as bool? ?? true,
      streakReminders: profile['streakReminders'] as bool? ?? true,
    );
    _setUser(loadedUser);
    if (isAdmin) {
      return;
    }
    _startDeviceServices(loadedUser);
    _listenToProfile(authUser.uid);

    try {
      final results = await Future.wait([
        _firestore
            .collection('users')
            .doc(authUser.uid)
            .collection('footprints')
            .get(),
        _firestore
            .collection('users')
            .doc(authUser.uid)
            .collection('taskLogs')
            .where(
              'date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(
                DateTime(DateTime.now().year, DateTime.now().month,
                    DateTime.now().day),
              ),
            )
            .get(),
        _firestore.collection('communities').limit(100).get(),
        _firestore
            .collection('users')
            .doc(authUser.uid)
            .collection('solarAssessments')
            .orderBy('createdAt', descending: true)
            .limit(20)
            .get(),
        _firestore
            .collection('users')
            .doc(authUser.uid)
            .collection('surveyRequests')
            .orderBy('createdAt', descending: true)
            .limit(20)
            .get(),
      ]);
      if (user?.uid != authUser.uid) return;

      final footprintSnapshot = results[0];
      final taskSnapshot = results[1];
      final communitySnapshot = results[2];
      final assessmentSnapshot = results[3];
      final surveySnapshot = results[4];
      _communities
        ..clear()
        ..addEntries(communitySnapshot.docs.map((document) => MapEntry(
              document.id,
              _communityFromDocument(document),
            )));
      _communityGoals.clear();
      for (final document in communitySnapshot.docs) {
        final goal = _goalFromCommunityDocument(document);
        if (goal != null) _communityGoals[document.id] = goal;
      }
      if (loadedUser.communityId != null &&
          !_communities.containsKey(loadedUser.communityId)) {
        final activeCommunity = await _firestore
            .collection('communities')
            .doc(loadedUser.communityId)
            .get();
        if (user?.uid != authUser.uid) return;
        final data = activeCommunity.data();
        if (data == null) {
          loadedUser.communityId = null;
          await _firestore.collection('users').doc(authUser.uid).set(
            {
              'communityId': null,
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
        } else {
          _communities[activeCommunity.id] =
              _communityFromData(activeCommunity.id, data);
          final goal = _goalFromCommunityData(activeCommunity.id, data);
          if (goal != null) _communityGoals[activeCommunity.id] = goal;
        }
      }
      if (loadedUser.communityId != null &&
          _communities.containsKey(loadedUser.communityId)) {
        final memberSnapshot = await _firestore
            .collection('communities')
            .doc(loadedUser.communityId)
            .collection('members')
            .get();
        if (user?.uid != authUser.uid) return;
        final ownMember = memberSnapshot.docs
            .where((document) => document.id == loadedUser.uid)
            .firstOrNull;
        final goal = _communityGoals[loadedUser.communityId];
        if (goal != null) {
          goal.progress = memberSnapshot.docs.fold<double>(
            0,
            (total, document) =>
                total +
                ((document.data()['goalContribution'] as num?)?.toDouble() ??
                    0),
          );
          goal.myContribution =
              (ownMember?.data()['goalContribution'] as num?)?.toDouble() ?? 0;
        }
      }
      notApplicable.addAll(
        List<String>.from(
          profile['notApplicableTaskIds'] as List? ?? const [],
        ),
      );
      footprints
        ..clear()
        ..addAll(footprintSnapshot.docs.map(_footprintFromDocument))
        ..sort((a, b) => a.month.compareTo(b.month));
      taskLogs
        ..clear()
        ..addAll(taskSnapshot.docs.map(_taskLogFromDocument));
      assessments
        ..clear()
        ..addAll(assessmentSnapshot.docs.map(_assessmentFromDocument));
      myLeads
        ..clear()
        ..addAll(surveySnapshot.docs.map(_leadFromDocument));
      notifyListeners();
      unawaited(_loadPointsLedger(authUser.uid));
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'Firebase account data loading',
      ));
    }
  }

  /// Server-written points history (Cloud Functions → users/{uid}/pointsLedger).
  Future<void> _loadPointsLedger(String uid) async {
    try {
      final snap = await _firestore
          .collection('users')
          .doc(uid)
          .collection('pointsLedger')
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();
      if (user?.uid != uid) return;
      ledger
        ..clear()
        ..addAll(snap.docs.map((d) {
          final data = d.data();
          final taskId = data['taskId'] as String?;
          final task = taskId == null
              ? null
              : MockData.tasks.where((t) => t.id == taskId).firstOrNull;
          return PointsEntry(
            delta: ((data['delta'] as num?) ?? 0).toInt(),
            reason: task == null
                ? (data['reason'] as String? ?? 'Points')
                : 'Task · ${task.title}',
            createdAt:
                (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            icon: task?.theme.icon ?? Icons.stars_rounded,
          );
        }));
      notifyListeners();
    } catch (e) {
      debugPrint('pointsLedger load failed: $e');
    }
  }

  TaskLog _taskLogFromDocument(
      QueryDocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    final date = data['date'] as Timestamp;
    return TaskLog(
      taskId: data['taskId'] as String,
      date: date.toDate(),
      status: TaskStatus.values.byName(data['status'] as String),
    );
  }

  FootprintEntry _footprintFromDocument(
      QueryDocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    final timestamp = data['month'];
    final month = timestamp is Timestamp
        ? timestamp.toDate()
        : DateTime.tryParse(document.id.replaceFirst('baseline_', '')) ??
            DateTime.now();
    return FootprintEntry(
      month: DateTime(month.year, month.month),
      electricityUnits: (data['electricityUnits'] as num?)?.toDouble() ?? 0,
      electricityKg: (data['electricityKg'] as num?)?.toDouble() ?? 0,
      cookingKg: (data['cookingKg'] as num?)?.toDouble() ?? 0,
      transportKg: (data['transportKg'] as num?)?.toDouble() ?? 0,
      source: data['source'] as String? ?? 'manual',
      isBaseline: data['isBaseline'] as bool? ?? false,
      unitsSaved: (data['unitsSaved'] as num?)?.toDouble() ?? 0,
      rupeesSaved: (data['rupeesSaved'] as num?)?.toDouble() ?? 0,
      percentChange: (data['percentChange'] as num?)?.toDouble() ?? 0,
      pointsAwarded: data['pointsAwarded'] as int? ?? 0,
    );
  }

  SolarAssessment _assessmentFromDocument(
      QueryDocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    return SolarAssessment(
      id: document.id,
      monthlyUnits: (data['monthlyUnits'] as num).toDouble(),
      roofAreaM2: (data['roofAreaM2'] as num).toDouble(),
      category: data['category'] as String,
      sizeKw: (data['sizeKw'] as num).toDouble(),
      annualGenUnits: (data['annualGenUnits'] as num).toDouble(),
      grossCost: (data['grossCost'] as num).toDouble(),
      centralSubsidy: (data['centralSubsidy'] as num).toDouble(),
      stateSubsidy: (data['stateSubsidy'] as num).toDouble(),
      netCost: (data['netCost'] as num).toDouble(),
      annualSavings: (data['annualSavings'] as num).toDouble(),
      paybackYears: (data['paybackYears'] as num?)?.toDouble(),
      co2Avoided25yKg: (data['co2Avoided25yKg'] as num).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Lead _leadFromDocument(QueryDocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    return Lead(
      id: document.id,
      userName: data['userName'] as String,
      district: data['district'] as String,
      sizeKw: (data['sizeKw'] as num).toDouble(),
      netCost: (data['netCost'] as num).toDouble(),
      type: data['type'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      vendorName: data['vendorName'] as String?,
      status: data['status'] as String? ?? 'new',
      phone: data['phone'] as String?,
      preferredSlot: data['preferredSlot'] as String?,
      ownerUid: document.reference.parent.parent?.id,
    );
  }

  void _setUser(AppUser u) {
    user = u;
    _resetSession();
    if (u.uid == 'u_nisha') _seedNishaHistory();
    notifyListeners();
    authChanges.bump();
  }

  // ---------- Session data (per user) ----------
  final List<TaskLog> taskLogs = [];
  final List<FootprintEntry> footprints = [];
  final List<PointsEntry> ledger = [];
  final List<SolarAssessment> assessments = [];
  final List<Lead> myLeads = [];
  final List<Lead> adminLeads = [];
  final Set<String> notApplicable = {};
  final Set<String> dismissedNudges = {};
  int pointsTodaySelf = 0;

  void _resetSession() {
    taskLogs.clear();
    footprints.clear();
    ledger.clear();
    assessments.clear();
    myLeads.clear();
    adminLeads.clear();
    notApplicable.clear();
    dismissedNudges.clear();
    _communities.clear();
    _communityGoals.clear();
    pointsTodaySelf = 0;
    gas = null;
  }

  void _seedNishaHistory() {
    gas = GasConnection(
        type: 'lpg',
        provider: 'Indane (IOCL) - Indian Oil',
        consumerNumber: '2847192048',
        agency: 'Sabarmati Indane Gas Agency, Ahmedabad',
        cylindersPerMonth: 1);
    final now = DateTime.now();
    DateTime m(int back) => DateTime(now.year, now.month - back);
    final res = footprintCalc.calculate(
        const FootprintInput(electricityUnits: 250, lpgKg: 11.4, petrolL: 6.7));
    footprints.add(FootprintEntry(
      month: m(3),
      electricityUnits: 250,
      electricityKg: res.electricityKg,
      cookingKg: res.cookingKg,
      transportKg: res.transportKg,
      source: 'manual',
      isBaseline: true,
    ));
    for (final (back, units, src) in [
      (2, 238.0, 'manual'),
      (1, 221.0, 'bill'),
      (0, 210.0, 'bill')
    ]) {
      final r = footprintCalc.calculate(
          FootprintInput(electricityUnits: units, lpgKg: 11.4, petrolL: 6.2));
      final saved = 250 - units;
      footprints.add(FootprintEntry(
        month: m(back),
        electricityUnits: units,
        electricityKg: r.electricityKg,
        cookingKg: r.cookingKg,
        transportKg: r.transportKg,
        source: src,
        unitsSaved: saved,
        rupeesSaved: saved * config.avgTariffPerUnit,
        percentChange: (r.totalKg - res.totalKg) / res.totalKg * 100,
        pointsAwarded:
            src == 'bill' ? (saved * config.pointsPerUnitSaved).round() : 0,
      ));
    }
    ledger.addAll([
      PointsEntry(
          delta: 80,
          reason: 'Bill verified · 40 units saved',
          createdAt: now.subtract(const Duration(days: 2)),
          icon: Icons.receipt_long_rounded),
      PointsEntry(
          delta: 20,
          reason: 'Task · Set AC to 24°C',
          createdAt: now.subtract(const Duration(days: 1, hours: 3)),
          icon: Icons.bolt_rounded),
      PointsEntry(
          delta: 15,
          reason: 'Task · Load shift washing machine',
          createdAt: now.subtract(const Duration(days: 1, hours: 5)),
          icon: Icons.schedule_rounded),
      PointsEntry(
          delta: 50,
          reason: '7-day streak bonus',
          createdAt: now.subtract(const Duration(days: 3)),
          icon: Icons.local_fire_department_rounded),
      PointsEntry(
          delta: 10,
          reason: 'Task · Segregate waste',
          createdAt: now.subtract(const Duration(days: 3, hours: 2)),
          icon: Icons.recycling_rounded),
    ]);
    taskLogs.add(TaskLog(
        taskId: 'standby_off',
        date: now,
        status: TaskStatus.done,
        pointsAwarded: 5));
    pointsTodaySelf = 5;
  }

  // ---------- Onboarding ----------
  // Writes: footprints (isBaseline) + users profile fields (backendschema §2.1, §2.8)
  Future<void> completeOnboarding({
    required String pincode,
    required String district,
    required int householdSize,
    required String homeType,
    required String roofAccess,
    required double electricityUnits,
    required double lpgCylinders,
    required String travelMode,
    required double weeklyKm,
    required List<String> appliances,
    required int goalPercent,
    required String source,
  }) async {
    final u = user!;
    final input = FootprintInput(
      electricityUnits: electricityUnits,
      lpgKg: lpgCylinders * 14.2,
      petrolL: footprintCalc.petrolLitresFromKm(travelMode, weeklyKm),
      busKm: travelMode == 'bus_metro' ? weeklyKm * 4.33 : 0,
    );
    final r = footprintCalc.calculate(input);
    final month = DateTime(DateTime.now().year, DateTime.now().month);
<<<<<<< HEAD
    if (useSupabase) {
      final uid = u.uid;
      u
        ..pincode = pincode
        ..district = district
        ..householdSize = householdSize
        ..homeType = homeType
        ..roofAccess = roofAccess
        ..travelMode = travelMode
        ..weeklyKm = weeklyKm
        ..appliances = appliances
        ..baselineUnits = electricityUnits
        ..baselineCo2Kg = r.totalKg
        ..goalPercent = goalPercent
        ..onboardingComplete = true;
      await supabaseRepo.saveProfile(uid, {
        ...SupabaseRepo.profilePatch(u),
        'community_id': u.communityId,
      });
      await supabaseRepo.saveBaseline(
        uid: uid,
        month: month,
        units: electricityUnits,
        electricityKg: r.electricityKg,
        cookingKg: r.cookingKg,
        transportKg: r.transportKg,
        source: source,
        lpgCylinders: lpgCylinders,
      );
      footprints
        ..clear()
        ..add(FootprintEntry(
          month: month,
          electricityUnits: electricityUnits,
          electricityKg: r.electricityKg,
          cookingKg: r.cookingKg,
          transportKg: r.transportKg,
          source: source,
          isBaseline: true,
        ));
      notifyListeners();
      authChanges.bump();
      return;
    }
=======
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
    if (useFirebase) {
      final uid = user!.uid;
      final monthId = '${month.year}-${month.month.toString().padLeft(2, '0')}';
      final batch = _firestore.batch();
      batch.set(
        _firestore.collection('users').doc(uid),
        {
          'pincode': pincode,
          'district': district,
          'householdSize': householdSize,
          'homeType': homeType,
          'roofAccess': roofAccess,
          'travelMode': travelMode,
          'weeklyKm': weeklyKm,
          'appliances': appliances,
          'baselineUnits': electricityUnits,
          'baselineCo2Kg': r.totalKg,
          'goalPercent': goalPercent,
          'onboardingComplete': true,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      batch.set(
        _firestore
            .collection('users')
            .doc(uid)
            .collection('footprints')
            .doc('baseline_$monthId'),
        {
          'month': Timestamp.fromDate(month),
          'electricityUnits': electricityUnits,
          'electricityKg': r.electricityKg,
          'cookingKg': r.cookingKg,
          'transportKg': r.transportKg,
          'source': source,
          'isBaseline': true,
          'unitsSaved': 0,
          'rupeesSaved': 0,
          'percentChange': 0,
          'pointsAwarded': 0,
          'lpgCylinders': lpgCylinders,
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      await batch.commit();
    }

    u
      ..pincode = pincode
      ..district = district
      ..householdSize = householdSize
      ..homeType = homeType
      ..roofAccess = roofAccess
      ..travelMode = travelMode
      ..weeklyKm = weeklyKm
      ..appliances = appliances
      ..baselineUnits = electricityUnits
      ..baselineCo2Kg = r.totalKg
      ..goalPercent = goalPercent
      ..onboardingComplete = true;
    footprints
      ..clear()
      ..add(FootprintEntry(
        month: month,
        electricityUnits: electricityUnits,
        electricityKg: r.electricityKg,
        cookingKg: r.cookingKg,
        transportKg: r.transportKg,
        source: source,
        isBaseline: true,
      ));
    notifyListeners();
    authChanges.bump();
  }

  // ---------- Tasks & points ----------
  List<TaskItem> get todayTasks {
    final u = user;
    if (u == null) return const [];
    final today = DateTime.now();
    var seed = 0x811c9dc5;
    for (final codeUnit
        in '${u.uid}:${today.year}-${today.month}-${today.day}'.codeUnits) {
      seed = ((seed ^ codeUnit) * 0x01000193) & 0x7fffffff;
    }
    final rnd = Random(seed);
    final pool = MockData.tasks.where((t) {
      if (notApplicable.contains(t.id)) return false;
      if (t.applianceTags.isNotEmpty &&
          !t.applianceTags.any(u.appliances.contains)) {
        return false;
      }
      if (t.seasonTags.contains('diwali') &&
          DateTime.now().month != 10 &&
          DateTime.now().month != 11) {
        return false;
      }
      return t.verification != Verification.bill &&
          t.verification != Verification.vendor;
    }).toList();
    TaskItem pick(bool Function(TaskItem) f, Set<String> used) {
      final c = pool.where((t) => f(t) && !used.contains(t.id)).toList();
      final list =
          c.isEmpty ? pool.where((t) => !used.contains(t.id)).toList() : c;
      return list[rnd.nextInt(list.length)];
    }

    final used = <String>{};
    final a = pick(
        (t) =>
            t.difficulty == Difficulty.easy && t.theme == LifeTheme.saveEnergy,
        used);
    used.add(a.id);
    final b = pick((t) => t.difficulty == Difficulty.medium, used);
    used.add(b.id);
    final c = pick((t) => t.theme != LifeTheme.saveEnergy, used);
    return [a, b, c];
  }

  TaskStatus statusOf(String taskId) {
    final today = DateTime.now();
    for (final l in taskLogs.reversed) {
      if (l.taskId == taskId &&
          l.date.year == today.year &&
          l.date.month == today.month &&
          l.date.day == today.day) {
        return l.status;
      }
    }
    return TaskStatus.pending;
  }

  int get tasksDoneToday =>
      todayTasks.where((t) => statusOf(t.id) == TaskStatus.done).length;

  Future<void> _saveTaskStatus(
      TaskItem task, DateTime date, TaskStatus status) async {
<<<<<<< HEAD
    if (useSupabase) {
      await supabaseRepo.saveTaskStatus(
        uid: user!.uid,
        taskId: task.id,
        date: date,
        status: status,
      );
      return;
    }
=======
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
    if (!useFirebase) return;
    await _taskLogReference(task, date).set({
      'taskId': task.id,
      'date': Timestamp.fromDate(_dayStart(date)),
      'status': status.name,
    }, SetOptions(merge: true));
  }

  DateTime _dayStart(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  DocumentReference<Map<String, dynamic>> _taskLogReference(
      TaskItem task, DateTime date) {
    final day = _dayStart(date);
    final dayId =
        '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    return _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('taskLogs')
        .doc('${dayId}_${task.id}');
  }

  /// Completes a task. Returns a result describing points and unlocks.
  Future<TaskCompletion> completeTask(TaskItem task,
<<<<<<< HEAD
      {bool withPhoto = false, String? proofPath}) async {
    if (useSupabase) {
      final now = DateTime.now();
      final badgesBefore = List<String>.from(user!.badges);
      final pointsOffered = task.points + (withPhoto ? config.photoBonus : 0);
      Map<String, dynamic> result;
      try {
        result = await supabaseRepo.awardTaskPoints(
          taskId: task.id,
          points: pointsOffered,
          verification: task.verification.name,
          estUnits: task.estUnitsSaved,
          estCo2: task.estCo2Kg,
          withPhoto: withPhoto,
          proofPath: proofPath,
        );
      } catch (error) {
        throw StateError(SupabaseRepo.friendlyError(error));
      }
      final awarded = ((result['points_awarded'] as num?) ?? 0).toInt();
      final capped = result['capped'] == true;
      final badges = result['new_badges'];
      if (result['total_points'] is num) {
        user!.points = (result['total_points'] as num).toInt();
      } else {
        user!.points += awarded;
      }
      if (result['streak'] is num) {
        user!.streak = (result['streak'] as num).toInt();
      }
      if (badges is List) {
        user!.badges = badges.map((e) => '$e').toList();
      }
      user!.weeklyPoints += awarded;
      if (awarded > 0) {
        ledger.insert(
            0,
            PointsEntry(
                delta: awarded,
                reason: 'Task · ${task.title}',
                createdAt: now,
                icon: task.theme.icon));
      }
      taskLogs.removeWhere((log) =>
          log.taskId == task.id &&
          log.date.year == now.year &&
          log.date.month == now.month &&
          log.date.day == now.day);
      taskLogs.add(TaskLog(
        taskId: task.id,
        date: now,
        status: TaskStatus.done,
        pointsAwarded: awarded,
        hasProof: withPhoto,
      ));
      unawaited(NotificationService.markTaskDoneToday(
          streakReminders: user!.streakReminders));
      unawaited(refreshCommunityProgress());
      notifyListeners();
      final newBadges = [
        for (final id in user!.badges)
          if (!badgesBefore.contains(id)) MockData.badgeById(id),
      ];
      final levelUp = result['leveled_up'] as String?;
      return TaskCompletion(
        points: awarded,
        capped: capped,
        leveledUp: levelUp,
        newBadges: newBadges,
      );
    }
=======
      {bool withPhoto = false}) async {
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
    if (useFirebase) {
      final now = DateTime.now();
      final communityId = user?.communityId;
      final goal = communityId == null ? null : myGoal;
      final contribution = goal == null
          ? 0.0
          : goal.metric == 'tasks'
              ? 1.0
              : goal.metric == 'units'
                  ? task.estUnitsSaved
                  : task.estCo2Kg;
      final taskLog = _taskLogReference(task, now);
      final member = communityId == null
          ? null
          : _firestore
              .collection('communities')
              .doc(communityId)
              .collection('members')
              .doc(user!.uid);
      if (member == null || goal == null || contribution <= 0) {
        await _saveTaskStatus(task, now, TaskStatus.done);
      } else {
        final completed =
            await _firestore.runTransaction<bool>((transaction) async {
          final logSnapshot = await transaction.get(taskLog);
          final memberSnapshot = await transaction.get(member);
          if (logSnapshot.data()?['status'] == TaskStatus.done.name) {
            return false;
          }
          if (!memberSnapshot.exists) {
            throw StateError('Your community membership was not found.');
          }
          final current = (memberSnapshot.data()?['goalContribution'] as num?)
                  ?.toDouble() ??
              0;
          transaction.set(
            taskLog,
            {
              'taskId': task.id,
              'date': Timestamp.fromDate(_dayStart(now)),
              'status': TaskStatus.done.name,
            },
            SetOptions(merge: true),
          );
          transaction.update(member, {
            'goalContribution': min(goal.target, current + contribution),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          return true;
        });
        if (completed) {
          final members = await member.parent.get();
          goal.progress = members.docs.fold<double>(
            0,
            (total, document) =>
                total +
                ((document.data()['goalContribution'] as num?)?.toDouble() ??
                    0),
          );
          goal.myContribution =
              ((await member.get()).data()?['goalContribution'] as num?)
                      ?.toDouble() ??
                  goal.myContribution;
        }
      }
      taskLogs.removeWhere((log) =>
          log.taskId == task.id &&
          log.date.year == now.year &&
          log.date.month == now.month &&
          log.date.day == now.day);
      taskLogs.add(TaskLog(
        taskId: task.id,
        date: now,
        status: TaskStatus.done,
      ));
      unawaited(NotificationService.markTaskDoneToday(
          streakReminders: user!.streakReminders));
      notifyListeners();
      // Points are credited server-side (awardTaskPoints) and arrive through
      // the live profile listener; show the catalogue value optimistically.
      return TaskCompletion(
          points: task.points + (withPhoto ? config.photoBonus : 0),
          capped: false);
    }

    final u = user!;
    var points = task.points + (withPhoto ? config.photoBonus : 0);
    var capped = false;
    if (task.verification == Verification.self) {
      final remaining = config.dailySelfPointsCap - pointsTodaySelf;
      if (remaining <= 0) {
        points = 0;
        capped = true;
      } else if (points > remaining) {
        points = remaining;
        capped = true;
      }
      pointsTodaySelf += points;
    }
    final prevLevel = LevelEngine.levelFor(u.points).$1;
    taskLogs.add(TaskLog(
        taskId: task.id,
        date: DateTime.now(),
        status: TaskStatus.done,
        pointsAwarded: points,
        hasProof: withPhoto));
    if (points > 0) {
      ledger.insert(
          0,
          PointsEntry(
              delta: points,
              reason: 'Task · ${task.title}',
              createdAt: DateTime.now(),
              icon: task.theme.icon));
    }
    u.points += points;
    u.weeklyPoints += points;
    if (tasksDoneToday == 1 && u.uid != 'u_nisha') {
      u.streak += 1;
      if (u.streak > u.longestStreak) u.longestStreak = u.streak;
    }
    final newBadges = <BadgeItem>[];
    void award(String id) {
      if (!u.badges.contains(id)) {
        u.badges = [...u.badges, id];
        newBadges.add(MockData.badgeById(id));
      }
    }

    if (taskLogs.where((l) => l.status == TaskStatus.done).length == 1) {
      award('first_step');
    }
    if (task.id == 'load_shift_wm') award('peak_shifter');
    if (task.id == 'led_swap') award('led_legend');
    if (task.id == 'solar_assessment') {
      // handled in solar flow
    }
    final goal = myGoal;
    if (goal != null) {
      final add = goal.metric == 'tasks'
          ? 1.0
          : goal.metric == 'units'
              ? task.estUnitsSaved
              : task.estCo2Kg;
      goal.progress = min(goal.target, goal.progress + add);
      goal.myContribution += add;
    }
    final newLevel = LevelEngine.levelFor(u.points);
    notifyListeners();
    return TaskCompletion(
      points: points,
      capped: capped,
      leveledUp: newLevel.$1 != prevLevel ? newLevel.$2 : null,
      newBadges: newBadges,
    );
  }

  Future<void> skipTask(TaskItem task) async {
    final now = DateTime.now();
    await _saveTaskStatus(task, now, TaskStatus.skipped);
    taskLogs
        .add(TaskLog(taskId: task.id, date: now, status: TaskStatus.skipped));
    notifyListeners();
  }

  Future<void> markNotApplicable(TaskItem task) async {
    final now = DateTime.now();
<<<<<<< HEAD
    if (useSupabase) {
      await supabaseRepo.markNotApplicable(uid: user!.uid, taskId: task.id);
      notApplicable.add(task.id);
      taskLogs.add(TaskLog(
          taskId: task.id, date: now, status: TaskStatus.notApplicable));
      notifyListeners();
      return;
    }
=======
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
    if (useFirebase) {
      final batch = _firestore.batch();
      final userRef = _firestore.collection('users').doc(user!.uid);
      final day = DateTime(now.year, now.month, now.day);
      final dayId =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      batch.set(
        userRef.collection('taskLogs').doc('${dayId}_${task.id}'),
        {
          'taskId': task.id,
          'date': Timestamp.fromDate(day),
          'status': TaskStatus.notApplicable.name,
        },
        SetOptions(merge: true),
      );
      batch.set(
        userRef,
        {
          'notApplicableTaskIds': FieldValue.arrayUnion([task.id]),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      await batch.commit();
    }
    notApplicable.add(task.id);
    taskLogs.add(
        TaskLog(taskId: task.id, date: now, status: TaskStatus.notApplicable));
    notifyListeners();
  }

  void dismissNudge(String id) {
    dismissedNudges.add(id);
    notifyListeners();
  }

  Nudge? get activeNudge {
    final u = user;
    if (u == null) return null;
    for (final n in MockData.nudges) {
      if (dismissedNudges.contains(n.id)) continue;
      if (n.id == 'peak_shift' && !u.peakNudge) continue;
      if (n.id == 'heat_ac24' &&
          (!u.weatherNudge || !u.appliances.contains('ac'))) {
        continue;
      }
      if (n.id == 'goal_close' && u.communityId == null) continue;
      if (n.taskId != null && statusOf(n.taskId!) == TaskStatus.done) continue;
      return n;
    }
    return null;
  }

  // ---------- Footprint ----------
  FootprintEntry? get baseline =>
      footprints.where((f) => f.isBaseline).firstOrNull;
  FootprintEntry? get latest => footprints.isEmpty ? null : footprints.last;

  double get totalUnitsSaved => footprints.fold(0, (s, f) => s + f.unitsSaved);
  double get totalRupeesSaved =>
      footprints.fold(0, (s, f) => s + f.rupeesSaved);
  double get totalCo2Saved => footprints
      .where((f) => !f.isBaseline)
      .fold(0, (s, f) => s + max(0, (baseline?.co2Kg ?? 0) - f.co2Kg));

  /// Writes: footprints + (bill) pointsLedger/users + adminMetrics (backendschema §6.2)
  Future<int> addMonth(
      {required DateTime month,
      required double units,
<<<<<<< HEAD
      required bool fromBill,
      String? proofPath}) async {
=======
      required bool fromBill}) async {
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
    final u = user!;
    final b = baseline;
    final r = footprintCalc.calculate(FootprintInput(
      electricityUnits: units,
      lpgKg: (b?.cookingKg ?? 0) / config.factors.lpg,
      petrolL: (b?.transportKg ?? 0) / config.factors.petrol,
    ));
    final saved = max(0.0, u.baselineUnits - units);
<<<<<<< HEAD
    final points = isLiveBackend
=======
    final points = useFirebase
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
        ? 0
        : fromBill
            ? (saved * config.pointsPerUnitSaved).round()
            : 0;
    final entry = FootprintEntry(
      month: month,
      electricityUnits: units,
      electricityKg: r.electricityKg,
      cookingKg: r.cookingKg,
      transportKg: r.transportKg,
<<<<<<< HEAD
      source:
          fromBill && (proofPath != null || !isLiveBackend) ? 'bill' : 'manual',
=======
      source: !useFirebase && fromBill ? 'bill' : 'manual',
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
      unitsSaved: saved,
      rupeesSaved: saved * config.avgTariffPerUnit,
      percentChange: b == null ? 0 : (r.totalKg - b.co2Kg) / b.co2Kg * 100,
      pointsAwarded: points,
    );
<<<<<<< HEAD
    if (useSupabase) {
      var awarded = 0;
      try {
        final res = await supabaseRepo.saveMonthlyFootprint(
          uid: u.uid,
          month: month,
          units: units,
          electricityKg: entry.electricityKg,
          cookingKg: entry.cookingKg,
          transportKg: entry.transportKg,
          source: entry.source,
          unitsSaved: entry.unitsSaved,
          rupeesSaved: entry.rupeesSaved,
          percentChange: entry.percentChange,
          proofPath: proofPath,
        );
        awarded = res.$1;
      } catch (error) {
        throw StateError(SupabaseRepo.friendlyError(error));
      }
      if (awarded > 0) {
        u.points += awarded;
        u.weeklyPoints += awarded;
        ledger.insert(
            0,
            PointsEntry(
                delta: awarded,
                reason: 'Bill verified · ${saved.round()} units saved',
                createdAt: DateTime.now(),
                icon: Icons.receipt_long_rounded));
        if (!u.badges.contains('bill_verified')) {
          u.badges = [...u.badges, 'bill_verified'];
        }
      }
      footprints.removeWhere((f) =>
          f.month.year == month.year &&
          f.month.month == month.month &&
          !f.isBaseline);
      footprints.add(entry);
      footprints.sort((a, b) => a.month.compareTo(b.month));
      notifyListeners();
      return awarded;
    }
=======
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
    if (useFirebase) {
      final monthId = '${month.year}-${month.month.toString().padLeft(2, '0')}';
      await _firestore
          .collection('users')
          .doc(u.uid)
          .collection('footprints')
          .doc('entry_$monthId')
          .set({
        'month': Timestamp.fromDate(DateTime(month.year, month.month)),
        'electricityUnits': entry.electricityUnits,
        'electricityKg': entry.electricityKg,
        'cookingKg': entry.cookingKg,
        'transportKg': entry.transportKg,
        'source': entry.source,
        'isBaseline': false,
        'unitsSaved': entry.unitsSaved,
        'rupeesSaved': entry.rupeesSaved,
        'percentChange': entry.percentChange,
        'pointsAwarded': 0,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    footprints.removeWhere((f) =>
        f.month.year == month.year &&
        f.month.month == month.month &&
        !f.isBaseline);
    footprints.add(entry);
    footprints.sort((a, b) => a.month.compareTo(b.month));
    if (points > 0) {
      u.points += points;
      u.weeklyPoints += points;
      ledger.insert(
          0,
          PointsEntry(
              delta: points,
              reason: 'Bill verified · ${saved.round()} units saved',
              createdAt: DateTime.now(),
              icon: Icons.receipt_long_rounded));
      if (!u.badges.contains('bill_verified')) {
        u.badges = [...u.badges, 'bill_verified'];
      }
    }
    notifyListeners();
    return points;
  }

  // ---------- Community ----------
  Community? get myCommunity => user?.communityId == null
      ? null
<<<<<<< HEAD
      : isLiveBackend
=======
      : useFirebase
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
          ? _communities[user!.communityId]
          : MockData.communityById(user!.communityId!);
  CommunityGoal? get myGoal => user?.communityId == null
      ? null
<<<<<<< HEAD
      : isLiveBackend
=======
      : useFirebase
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
          ? _communityGoals[user!.communityId]
          : MockData.goals
              .where((g) => g.communityId == user!.communityId)
              .firstOrNull;

<<<<<<< HEAD
  CommunityGoal? goalById(String id) => isLiveBackend
=======
  CommunityGoal? goalById(String id) => useFirebase
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
      ? _communityGoals[id]
      : MockData.goals.where((goal) => goal.id == id).firstOrNull;

  Community? communityById(String id) =>
<<<<<<< HEAD
      isLiveBackend ? _communities[id] : MockData.communityById(id);

  Future<Community?> communityByJoinCode(String code) async {
    if (useSupabase) {
      final row = await supabaseRepo.communityByJoinCode(code);
      if (row == null) return null;
      final community = SupabaseRepo.communityFromRow(row);
      _communities[community.id] = community;
      final goal = SupabaseRepo.goalFromRow(row);
      if (goal != null) _communityGoals[community.id] = goal;
      notifyListeners();
      return community;
    }
    if (!isLiveBackend) {
=======
      useFirebase ? _communities[id] : MockData.communityById(id);

  Future<Community?> communityByJoinCode(String code) async {
    if (!useFirebase) {
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
      return MockData.communities
          .where((community) => community.joinCode == code)
          .firstOrNull;
    }
    final result = await _firestore
        .collection('communities')
        .where('joinCode', isEqualTo: code)
        .limit(1)
        .get();
    if (result.docs.isEmpty) return null;
    final community = _communityFromDocument(result.docs.first);
    _communities[community.id] = community;
    final goal = _goalFromCommunityDocument(result.docs.first);
    if (goal != null) _communityGoals[community.id] = goal;
    notifyListeners();
    return community;
  }

  Future<void> refreshCommunities() async {
<<<<<<< HEAD
    if (useSupabase) {
      final list = await supabaseRepo.communities();
      final goals = await supabaseRepo.goalProgressView();
      _communities
        ..clear()
        ..addEntries(list.map((c) => MapEntry(c.id, c)));
      _communityGoals.clear();
      for (final row in goals) {
        final goal = SupabaseRepo.goalFromProgressRow(row);
        if (goal != null) _communityGoals[goal.communityId] = goal;
      }
      notifyListeners();
      return;
    }
=======
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
    if (!useFirebase) return;
    final snapshot =
        await _firestore.collection('communities').limit(100).get();
    _communities
      ..clear()
      ..addEntries(snapshot.docs.map((document) => MapEntry(
            document.id,
            _communityFromDocument(document),
          )));
    _communityGoals.clear();
    for (final document in snapshot.docs) {
      final goal = _goalFromCommunityDocument(document);
      if (goal != null) _communityGoals[document.id] = goal;
    }
    notifyListeners();
  }

  Future<void> refreshCommunityProgress() async {
    final communityId = user?.communityId;
    final goal = myGoal;
<<<<<<< HEAD
    if (useSupabase && communityId != null && goal != null) {
      try {
        final rows = await supabaseRepo.goalProgressView();
        for (final row in rows) {
          if (row['community_id'] == communityId) {
            goal.progress = ((row['progress'] as num?) ?? 0).toDouble();
          }
        }
        goal.myContribution =
            await supabaseRepo.myGoalContribution(communityId, user!.uid);
        notifyListeners();
      } catch (e) {
        debugPrint('community progress refresh failed: $e');
      }
      return;
    }
    if (!isLiveBackend || communityId == null || goal == null) return;
=======
    if (!useFirebase || communityId == null || goal == null) return;
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
    final members = await _firestore
        .collection('communities')
        .doc(communityId)
        .collection('members')
        .get();
    goal.progress = members.docs.fold<double>(
      0,
      (total, document) =>
          total +
          ((document.data()['goalContribution'] as num?)?.toDouble() ?? 0),
    );
    final own =
        members.docs.where((document) => document.id == user!.uid).firstOrNull;
    goal.myContribution =
        (own?.data()['goalContribution'] as num?)?.toDouble() ?? 0;
    notifyListeners();
  }

  Future<void> joinCommunity(Community c) async {
    final currentUser = user!;
<<<<<<< HEAD
    if (useSupabase) {
      try {
        final row = await supabaseRepo.joinCommunity(c.id);
        final community = SupabaseRepo.communityFromRow(row);
        _communities[community.id] = community;
        final goal = SupabaseRepo.goalFromRow(row);
        if (goal != null) {
          _communityGoals[community.id] = goal;
          goal.progress = await supabaseRepo.goalProgressView().then((rows) =>
              rows
                  .where((r) => r['community_id'] == community.id)
                  .map((r) => ((r['progress'] as num?) ?? 0).toDouble())
                  .firstOrNull ??
              0);
          goal.myContribution = 0;
        }
        currentUser.communityId = community.id;
        notifyListeners();
      } catch (error) {
        throw StateError(SupabaseRepo.friendlyError(error));
      }
      return;
    }
=======
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
    if (useFirebase) {
      final communityRef = _firestore.collection('communities').doc(c.id);
      final memberRef = communityRef.collection('members').doc(currentUser.uid);
      final userRef = _firestore.collection('users').doc(currentUser.uid);
      await _firestore.runTransaction((transaction) async {
        final communitySnapshot = await transaction.get(communityRef);
        final memberSnapshot = await transaction.get(memberRef);
        if (!communitySnapshot.exists) {
          throw StateError('This community no longer exists.');
        }
        if (memberSnapshot.exists) {
          throw StateError('You are already a member of this community.');
        }
        transaction.set(memberRef, {
          'uid': currentUser.uid,
          'goalContribution': 0,
          'joinedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        transaction.update(communityRef, {
          'memberCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        transaction.update(userRef, {
          'communityId': c.id,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
      final data =
          (await _firestore.collection('communities').doc(c.id).get()).data();
      if (data != null) {
        _communities[c.id] = _communityFromData(c.id, data);
        final goal = _goalFromCommunityData(c.id, data);
        if (goal != null) {
          _communityGoals[c.id] = goal;
          final members = await memberRef.parent.get();
          goal.progress = members.docs.fold<double>(
            0,
            (total, document) =>
                total +
                ((document.data()['goalContribution'] as num?)?.toDouble() ??
                    0),
          );
          goal.myContribution = (members.docs
                      .where((document) => document.id == currentUser.uid)
                      .firstOrNull
                      ?.data()['goalContribution'] as num?)
                  ?.toDouble() ??
              0;
        }
      }
      currentUser.communityId = c.id;
      notifyListeners();
      return;
    }
    user!.communityId = c.id;
    c.memberCount += 1;
    notifyListeners();
  }

  Future<Community> createCommunity(
      {required String name, required String type, required String pincode}) {
<<<<<<< HEAD
    if (useSupabase) {
      return _createSupabaseCommunity(name, type, pincode);
    }
=======
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
    if (useFirebase) return _createFirestoreCommunity(name, type, pincode);
    final c = Community(
      id: 'c_${Random().nextInt(1 << 30)}',
      name: name,
      type: type,
      district: MockData.districtFromPin(pincode),
      pincode: pincode,
      memberCount: 1,
      joinCode: (name
              .replaceAll(RegExp(r'[^A-Za-z]'), '')
              .toUpperCase()
              .padRight(4, 'X')
              .substring(0, 4)) +
          pincode.substring(pincode.length - 2),
    );
    MockData.communities.insert(0, c);
    user!.communityId = c.id;
<<<<<<< HEAD
    if (!isLiveBackend && !user!.badges.contains('community_builder')) {
=======
    if (!useFirebase && !user!.badges.contains('community_builder')) {
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
      user!.badges = [...user!.badges, 'community_builder'];
      user!.points += 50;
      ledger.insert(
          0,
          PointsEntry(
              delta: 50,
              reason: 'Created community · $name',
              createdAt: DateTime.now(),
              icon: Icons.groups_rounded));
    }
    notifyListeners();
    return Future.value(c);
  }

  Future<Community> _createFirestoreCommunity(
      String name, String type, String pincode) async {
    final currentUser = user!;
    final communityRef = _firestore.collection('communities').doc();
    final userRef = _firestore.collection('users').doc(currentUser.uid);
    final now = DateTime.now();
    final goalEndDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    final joinCode = (name
            .replaceAll(RegExp(r'[^A-Za-z]'), '')
            .toUpperCase()
            .padRight(4, 'X')
            .substring(0, 4)) +
        Random()
            .nextInt(1 << 20)
            .toRadixString(36)
            .padLeft(4, '0')
            .toUpperCase();
    final batch = _firestore.batch();
    batch.set(communityRef, {
      'name': name.trim(),
      'type': type,
      'district': MockData.districtFromPin(pincode),
      'pincode': pincode,
      'joinCode': joinCode,
      'createdBy': currentUser.uid,
      'memberCount': 1,
      'totalUnitsSaved': 0,
      'goalTitle': 'Save 100 units this month',
      'goalMetric': 'units',
      'goalTarget': 100,
      'goalEndDate': Timestamp.fromDate(goalEndDate),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(communityRef.collection('members').doc(currentUser.uid), {
      'uid': currentUser.uid,
      'goalContribution': 0,
      'joinedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.update(userRef, {
      'communityId': communityRef.id,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();

    final community = Community(
      id: communityRef.id,
      name: name.trim(),
      type: type,
      district: MockData.districtFromPin(pincode),
      pincode: pincode,
      memberCount: 1,
      joinCode: joinCode,
    );
    _communities[community.id] = community;
    _communityGoals[community.id] = CommunityGoal(
      id: community.id,
      communityId: community.id,
      title: 'Save 100 units this month',
      metric: 'units',
      target: 100,
      progress: 0,
      endDate: goalEndDate,
      bonusPoints: 0,
    );
    currentUser.communityId = community.id;
    notifyListeners();
    return community;
  }

<<<<<<< HEAD
  Future<Community> _createSupabaseCommunity(
      String name, String type, String pincode) async {
    final currentUser = user!;
    final now = DateTime.now();
    final goalEndDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    final joinCode = (name
            .replaceAll(RegExp(r'[^A-Za-z]'), '')
            .toUpperCase()
            .padRight(4, 'X')
            .substring(0, 4)) +
        Random()
            .nextInt(1 << 20)
            .toRadixString(36)
            .padLeft(4, '0')
            .toUpperCase();
    Map<String, dynamic> row;
    try {
      row = await supabaseRepo.createCommunity(
        name: name,
        type: type,
        pincode: pincode,
        district: MockData.districtFromPin(pincode),
        joinCode: joinCode,
        goalEndDate: goalEndDate,
      );
    } catch (error) {
      throw StateError(SupabaseRepo.friendlyError(error));
    }
    final community = SupabaseRepo.communityFromRow(row);
    _communities[community.id] = community;
    final goal = SupabaseRepo.goalFromRow(row);
    if (goal != null) {
      goal.myContribution = 0;
      _communityGoals[community.id] = goal;
    }
    currentUser.communityId = community.id;
    if (!currentUser.badges.contains('community_builder')) {
      currentUser.badges = [...currentUser.badges, 'community_builder'];
    }
    notifyListeners();
    return community;
  }

  /// Online rankings come from the `leaderboard` table, a public projection
  /// maintained by a Postgres trigger (Supabase) or Cloud Function (Firebase).
=======
  /// Online rankings come from the `leaderboard` collection, a public
  /// projection maintained by the `syncLeaderboard` Cloud Function.
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
  final Map<String, List<(String, String, int)>> _onlineBoard = {};
  bool leaderboardLoading = false;

  Future<void> refreshLeaderboard(String scope, {bool weekly = false}) async {
<<<<<<< HEAD
    if (useSupabase && user != null) {
      final u = user!;
      leaderboardLoading = true;
      notifyListeners();
      try {
        _onlineBoard['$scope|$weekly'] = await supabaseRepo.leaderboard(
          scope: scope,
          uid: u.uid,
          district: u.district,
          communityId: u.communityId,
          weekly: weekly,
        );
      } catch (e) {
        debugPrint('leaderboard load failed: $e');
      } finally {
        leaderboardLoading = false;
        notifyListeners();
      }
      return;
    }
=======
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
    if (!useFirebase || user == null) return;
    final u = user!;
    final field = weekly ? 'weeklyPoints' : 'points';
    Query<Map<String, dynamic>> q = _firestore.collection('leaderboard');
    if (scope == 'district') {
      q = q.where('district', isEqualTo: u.district);
    } else if (scope == 'community' && u.communityId != null) {
      q = q.where('communityId', isEqualTo: u.communityId);
    }
    leaderboardLoading = true;
    notifyListeners();
    try {
      final snap = await q.orderBy(field, descending: true).limit(50).get();
      _onlineBoard['$scope|$weekly'] = [
        for (final d in snap.docs)
          if (d.id != u.uid)
            (
              d.data()['displayName'] as String? ?? 'Citizen',
              d.data()['district'] as String? ?? '',
              ((d.data()[field] as num?) ?? 0).toInt(),
            ),
      ];
    } catch (e) {
      debugPrint('leaderboard load failed: $e');
    } finally {
      leaderboardLoading = false;
      notifyListeners();
    }
  }

  List<LeaderboardEntry> leaderboard(String scope, {bool weekly = false}) {
    final u = user!;
    final myPoints = weekly ? u.weeklyPoints : u.points;
<<<<<<< HEAD
    final factor = weekly && !isLiveBackend ? 0.12 : 1.0;
    var names = isLiveBackend
        ? (_onlineBoard['$scope|$weekly'] ?? const <(String, String, int)>[])
        : MockData.leaderboardNames;
    if (!isLiveBackend && scope == 'district') {
      names = names.where((n) => n.$2 == u.district).toList();
    }
    if (!isLiveBackend && scope == 'community') names = names.take(9).toList();
=======
    final factor = weekly && !useFirebase ? 0.12 : 1.0;
    var names = useFirebase
        ? (_onlineBoard['$scope|$weekly'] ?? const <(String, String, int)>[])
        : MockData.leaderboardNames;
    if (!useFirebase && scope == 'district') {
      names = names.where((n) => n.$2 == u.district).toList();
    }
    if (!useFirebase && scope == 'community') names = names.take(9).toList();
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
    final all = [
      ...names.map((n) => (n.$1, n.$2, (n.$3 * factor).round(), false)),
      (u.displayName, u.district, myPoints, true),
    ]..sort((a, b) => b.$3.compareTo(a.$3));
    return [
      for (var i = 0; i < all.length; i++)
        LeaderboardEntry(
            rank: i + 1,
            name: all[i].$1,
            district: all[i].$2,
            points: all[i].$3,
            isMe: all[i].$4),
    ];
  }

  // ---------- Solar ----------
  Future<SolarAssessment> assess(
      {required double monthlyUnits,
      required double roofAreaM2,
      required bool scSt}) async {
    final r = solarCalc.calculate(
        monthlyUnits: monthlyUnits, roofAreaM2: roofAreaM2, scSt: scSt);
    final a = SolarAssessment(
      id: 'a_${Random().nextInt(1 << 30)}',
      monthlyUnits: monthlyUnits,
      roofAreaM2: roofAreaM2,
      category: scSt ? 'sc_st' : 'general',
      sizeKw: r.sizeKw,
      annualGenUnits: r.annualGenUnits,
      grossCost: r.grossCost,
      centralSubsidy: r.centralSubsidy,
      stateSubsidy: r.stateSubsidy,
      netCost: r.netCost,
      annualSavings: r.annualSavings,
      paybackYears: r.paybackYears,
      co2Avoided25yKg: r.co2Avoided25yKg,
      createdAt: DateTime.now(),
    );
<<<<<<< HEAD
    if (useSupabase) {
      try {
        await supabaseRepo.saveSolarAssessment(uid: user!.uid, a: a);
      } catch (error) {
        throw StateError(SupabaseRepo.friendlyError(error));
      }
      assessments.insert(0, a);
      if (statusOf('solar_assessment') != TaskStatus.done) {
        // Points are scored server-side; a failure here must not lose the
        // assessment the user just generated.
        try {
          final result = await supabaseRepo.awardTaskPoints(
            taskId: 'solar_assessment',
            points: 20,
            verification: 'self',
            estUnits: 0,
            estCo2: 0,
          );
          final awarded = ((result['points_awarded'] as num?) ?? 0).toInt();
          if (result['total_points'] is num) {
            user!.points = (result['total_points'] as num).toInt();
          }
          user!.weeklyPoints += awarded;
          taskLogs.add(TaskLog(
              taskId: 'solar_assessment',
              date: DateTime.now(),
              status: TaskStatus.done,
              pointsAwarded: awarded));
        } catch (error) {
          debugPrint('solar task points failed: $error');
        }
      }
      notifyListeners();
      return a;
    }
=======
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
    if (useFirebase) {
      await _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('solarAssessments')
          .doc(a.id)
          .set({
        'monthlyUnits': a.monthlyUnits,
        'roofAreaM2': a.roofAreaM2,
        'category': a.category,
        'sizeKw': a.sizeKw,
        'annualGenUnits': a.annualGenUnits,
        'grossCost': a.grossCost,
        'centralSubsidy': a.centralSubsidy,
        'stateSubsidy': a.stateSubsidy,
        'netCost': a.netCost,
        'annualSavings': a.annualSavings,
        'paybackYears': a.paybackYears,
        'co2Avoided25yKg': a.co2Avoided25yKg,
        'createdAt': Timestamp.fromDate(a.createdAt),
      });
    }
    assessments.insert(0, a);
    if (statusOf('solar_assessment') != TaskStatus.done && user != null) {
      final now = DateTime.now();
      if (useFirebase) {
        await _saveTaskStatus(
          MockData.taskById('solar_assessment'),
          now,
          TaskStatus.done,
        );
        taskLogs.add(TaskLog(
          taskId: 'solar_assessment',
          date: now,
          status: TaskStatus.done,
        ));
      } else {
        taskLogs.add(TaskLog(
            taskId: 'solar_assessment',
            date: now,
            status: TaskStatus.done,
            pointsAwarded: 20));
        user!.points += 20;
        ledger.insert(
            0,
            PointsEntry(
                delta: 20,
                reason: 'Solar feasibility checked',
                createdAt: now,
                icon: Icons.wb_sunny_rounded));
      }
    }
    notifyListeners();
    return a;
  }

  SolarAssessment? assessmentById(String id) =>
      assessments.where((a) => a.id == id).firstOrNull;

  /// Saves the user's survey request; online requests are not routed to vendors.
  Future<Lead> requestSurvey(
      {SolarAssessment? assessment,
      Vendor? vendor,
      required String phone,
      required String preferredSlot,
      String type = 'survey'}) {
    final u = user!;
    final lead = Lead(
      id: 'l_${Random().nextInt(1 << 30)}',
      userName: u.displayName,
      district: u.district,
      sizeKw: assessment?.sizeKw ?? 2,
      netCost: assessment?.netCost ?? 10000,
      type: type,
      createdAt: DateTime.now(),
      vendorName: vendor?.name,
      phone: phone,
      preferredSlot: preferredSlot,
    );
<<<<<<< HEAD
    if (isLiveBackend) {
=======
    if (useFirebase) {
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
      return _saveSurveyRequest(lead);
    }
    myLeads.add(lead);
    MockData.leads.insert(0, lead);
<<<<<<< HEAD
    if (!isLiveBackend && !u.badges.contains('solar_pioneer_lead')) {
=======
    if (!useFirebase && !u.badges.contains('solar_pioneer_lead')) {
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
      u.badges = [...u.badges, 'solar_pioneer_lead'];
      u.points += config.solarLeadPoints;
      u.weeklyPoints += config.solarLeadPoints;
      ledger.insert(
          0,
          PointsEntry(
              delta: config.solarLeadPoints,
              reason: 'Solar site survey requested',
              createdAt: DateTime.now(),
              icon: Icons.wb_sunny_rounded));
    }
    notifyListeners();
    return Future.value(lead);
  }

  Future<Lead> _saveSurveyRequest(Lead lead) async {
<<<<<<< HEAD
    if (useSupabase) {
      try {
        final saved =
            await supabaseRepo.saveSurveyRequest(uid: user!.uid, lead: lead);
        myLeads.insert(0, saved);
        notifyListeners();
        return saved;
      } catch (error) {
        throw StateError(SupabaseRepo.friendlyError(error));
      }
    }
=======
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
    await _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('surveyRequests')
        .doc(lead.id)
        .set({
      'userName': lead.userName,
      'district': lead.district,
      'sizeKw': lead.sizeKw,
      'netCost': lead.netCost,
      'type': lead.type,
      'createdAt': Timestamp.fromDate(lead.createdAt),
      'vendorName': lead.vendorName,
      'status': lead.status,
      'phone': lead.phone,
      'preferredSlot': lead.preferredSlot,
    });
    myLeads.insert(0, lead);
    notifyListeners();
    return lead;
  }

  // ---------- Profile / settings ----------
  Map<String, dynamic> _profileData(AppUser u) => {
        'displayName': u.displayName,
        'photoUrl': u.photoUrl,
        'language': u.language,
        'district': u.district,
        'pincode': u.pincode,
        'householdSize': u.householdSize,
        'homeType': u.homeType,
        'roofAccess': u.roofAccess,
        'appliances': List<String>.from(u.appliances),
        'travelMode': u.travelMode,
        'weeklyKm': u.weeklyKm,
        'baselineUnits': u.baselineUnits,
        'baselineCo2Kg': u.baselineCo2Kg,
        'goalPercent': u.goalPercent,
        'onboardingComplete': u.onboardingComplete,
        'communityId': u.communityId,
        'peakNudge': u.peakNudge,
        'weatherNudge': u.weatherNudge,
        'communityUpdates': u.communityUpdates,
        'streakReminders': u.streakReminders,
      };

  void _restoreProfileData(AppUser u, Map<String, dynamic> data) {
    u
      ..displayName = data['displayName'] as String
      ..photoUrl = data['photoUrl'] as String?
      ..language = data['language'] as String
      ..district = data['district'] as String
      ..pincode = data['pincode'] as String
      ..householdSize = data['householdSize'] as int
      ..homeType = data['homeType'] as String
      ..roofAccess = data['roofAccess'] as String
      ..appliances = List<String>.from(data['appliances'] as List)
      ..travelMode = data['travelMode'] as String
      ..weeklyKm = data['weeklyKm'] as double
      ..baselineUnits = data['baselineUnits'] as double
      ..baselineCo2Kg = data['baselineCo2Kg'] as double
      ..goalPercent = data['goalPercent'] as int
      ..onboardingComplete = data['onboardingComplete'] as bool
      ..communityId = data['communityId'] as String?
      ..peakNudge = data['peakNudge'] as bool
      ..weatherNudge = data['weatherNudge'] as bool
      ..communityUpdates = data['communityUpdates'] as bool
      ..streakReminders = data['streakReminders'] as bool;
  }

  Future<void> updateProfile(void Function(AppUser u) edit) async {
    final currentUser = user!;
    final previous = _profileData(currentUser);
    edit(currentUser);
<<<<<<< HEAD
    if (useSupabase) {
      try {
        await supabaseRepo.saveProfile(
            currentUser.uid, SupabaseRepo.profilePatch(currentUser));
      } catch (_) {
        _restoreProfileData(currentUser, previous);
        rethrow;
      }
      unawaited(_syncReminders(currentUser));
      unawaited(PushService.syncTopics(
          district: currentUser.district,
          communityId: currentUser.communityId,
          communityUpdates: currentUser.communityUpdates,
          peakNudge: currentUser.peakNudge));
      notifyListeners();
      return;
    }
=======
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
    if (useFirebase) {
      try {
        await _firestore.collection('users').doc(currentUser.uid).set(
          {
            ..._profileData(currentUser),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      } catch (_) {
        _restoreProfileData(currentUser, previous);
        rethrow;
      }
      unawaited(_syncReminders(currentUser));
      unawaited(PushService.syncTopics(
          district: currentUser.district,
          communityId: currentUser.communityId,
          communityUpdates: currentUser.communityUpdates,
          peakNudge: currentUser.peakNudge));
    } else {
      unawaited(_syncReminders(currentUser));
    }
    notifyListeners();
  }

  // ---------- Device services (local reminders + FCM) ----------

  void _startDeviceServices(AppUser u) {
    unawaited(_syncReminders(u));
<<<<<<< HEAD
    if (!useFirebase) return; // FCM is a Firebase-only path in this build
=======
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
    unawaited(PushService.start(
      uid: u.uid,
      district: u.district,
      communityId: u.communityId,
      communityUpdates: u.communityUpdates,
      peakNudge: u.peakNudge,
    ));
  }

  Future<void> _syncReminders(AppUser u) async {
    await NotificationService.requestPermission();
    await NotificationService.syncPreferences(
      peakNudge: u.peakNudge,
      streakReminders: u.streakReminders,
      billReminder: u.weatherNudge,
    );
  }

  /// Points, streak and badges are written by Cloud Functions
  /// (functions/src/index.ts → awardTaskPoints / awardFootprintPoints), so the
  /// client listens for those server-side changes instead of computing them.
  void _listenToProfile(String uid) {
    unawaited(_profileSubscription?.cancel());
<<<<<<< HEAD
    _profileSubscription =
        _firestore.collection('users').doc(uid).snapshots().listen((snap) {
=======
    _profileSubscription = _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((snap) {
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
      final u = user;
      final data = snap.data();
      if (u == null || u.uid != uid || data == null) return;
      var changed = false;
      void setInt(int current, String key, void Function(int) assign) {
        final v = data[key];
        if (v is num && v.toInt() != current) {
          assign(v.toInt());
          changed = true;
        }
      }

      setInt(u.points, 'points', (v) => u.points = v);
      setInt(u.weeklyPoints, 'weeklyPoints', (v) => u.weeklyPoints = v);
      setInt(u.streak, 'streak', (v) => u.streak = v);
      setInt(u.longestStreak, 'longestStreak', (v) => u.longestStreak = v);
      setInt(u.freezeTokens, 'freezeTokens', (v) => u.freezeTokens = v);
      final badges = data['badges'];
      if (badges is List) {
        final list = badges.cast<String>();
<<<<<<< HEAD
        if (list.length != u.badges.length || !list.every(u.badges.contains)) {
=======
        if (list.length != u.badges.length ||
            !list.every(u.badges.contains)) {
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
          u.badges = List<String>.from(list);
          changed = true;
        }
      }
      final role = data['role'];
      if (role is String) {
<<<<<<< HEAD
        final parsed = UserRole.values
            .firstWhere((r) => r.name == role, orElse: () => u.role);
=======
        final parsed = UserRole.values.firstWhere((r) => r.name == role,
            orElse: () => u.role);
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
        if (parsed != u.role) {
          u.role = parsed;
          changed = true;
        }
      }
      if (changed) notifyListeners();
    }, onError: (Object e) => debugPrint('profile listener: $e'));
  }

  Future<void> loadAdminLeads() async {
<<<<<<< HEAD
    if (useSupabase) {
      if (user?.isAdmin != true) {
        throw StateError('Administrator access is required.');
      }
      try {
        adminLeads
          ..clear()
          ..addAll(await supabaseRepo.adminSurveyRequests());
      } catch (error) {
        throw StateError(SupabaseRepo.friendlyError(error));
      }
      notifyListeners();
      return;
    }
    if (!isLiveBackend) {
=======
    if (!useFirebase) {
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
      adminLeads
        ..clear()
        ..addAll(MockData.leads);
      notifyListeners();
      return;
    }
    if (user?.isAdmin != true) {
      throw StateError('Administrator access is required.');
    }
    final snapshot = await _firestore
        .collectionGroup('surveyRequests')
        .orderBy('createdAt', descending: true)
        .limit(200)
        .get();
    adminLeads
      ..clear()
      ..addAll(snapshot.docs.map(_leadFromDocument));
    notifyListeners();
  }

  Future<void> updateLeadStatus(Lead lead, String status) async {
    const allowed = {
      'new',
      'contacted',
      'survey_done',
      'quoted',
      'installed',
      'dropped',
    };
    if (!allowed.contains(status)) {
      throw ArgumentError.value(status, 'status', 'Unsupported lead status');
    }
<<<<<<< HEAD
    if (useSupabase) {
      if (user?.isAdmin != true) {
        throw StateError('Administrator access is required.');
      }
      await supabaseRepo.updateLeadStatus(lead.id, status);
      lead.status = status;
      notifyListeners();
      return;
    }
=======
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
    if (useFirebase) {
      if (user?.isAdmin != true || lead.ownerUid == null) {
        throw StateError('Administrator access is required.');
      }
      await _firestore
          .collection('users')
          .doc(lead.ownerUid)
          .collection('surveyRequests')
          .doc(lead.id)
          .update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      final index = MockData.leads.indexWhere((item) => item.id == lead.id);
      if (index >= 0) MockData.leads[index].status = status;
    }
    lead.status = status;
    notifyListeners();
  }

  // ---------- Demo mode ----------
  // ---------- Cooking gas (local to this device for now) ----------
  GasConnection? gas;
<<<<<<< HEAD

=======
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
  /// Saves the LPG/PNG connection. Kept in memory; the Firestore `users`
  /// rules whitelist does not include gas fields yet (see TEAM_HANDOFF.md).
  Future<void> saveGasConnection(GasConnection g) async {
    gas = g;
<<<<<<< HEAD
    if (isLiveBackend && user != null) {
      try {
        await supabaseRepoOrFirestoreSaveGas(g);
      } catch (error, stackTrace) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'Gas connection save',
        ));
      }
    }
    if (!isLiveBackend && user != null) {
=======
    if (!useFirebase && user != null) {
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
      ledger.insert(
          0,
          PointsEntry(
              delta: 50,
              reason: 'Linked ${g.isPng ? 'PNG meter' : 'LPG connection'}',
              createdAt: DateTime.now(),
              icon: Icons.propane_tank_outlined));
      user!.points += 50;
      user!.weeklyPoints += 50;
    }
    notifyListeners();
  }

<<<<<<< HEAD
  /// Gas connections are stored as a JSON blob on the profile
  /// (`profiles.gas_connection` / `users.gasConnection`).
  Future<void> supabaseRepoOrFirestoreSaveGas(GasConnection g) async {
    final json = {
      'type': g.type,
      'provider': g.provider,
      'consumerNumber': g.consumerNumber,
      'agency': g.agency,
      'cylindersPerMonth': g.cylindersPerMonth,
      'scmPerMonth': g.scmPerMonth,
      'pmuy': g.pmuy,
      'proofAttached': g.proofAttached,
    };
    if (useSupabase) {
      await supabaseRepo.saveGasConnection(user!.uid, json);
      return;
    }
    await _firestore
        .collection('users')
        .doc(user!.uid)
        .set({'gasConnection': json}, SetOptions(merge: true));
  }

=======
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
  bool demoForceNudge = false;
  void triggerDemoNudge() {
    dismissedNudges.remove('peak_shift');
    notifyListeners();
  }
}

class TaskCompletion {
  const TaskCompletion(
      {required this.points,
      required this.capped,
      this.leveledUp,
      this.newBadges = const []});
  final int points;
  final bool capped;
  final String? leveledUp;
  final List<BadgeItem> newBadges;
}

/// Simple inherited access: `AppScope.of(context)` (rebuilds on change).
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found');
    return scope!.notifier!;
  }

  static AppState read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    return scope!.notifier!;
  }
}

/// Thrown internally when the user closes the Google account picker.
class _GoogleCancelled implements Exception {
  const _GoogleCancelled();
}
