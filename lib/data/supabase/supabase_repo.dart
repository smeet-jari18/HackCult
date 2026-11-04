import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/logic/calculators.dart';
import '../models.dart';
import 'supabase_config.dart';

/// Thin, typed data-access layer over Supabase (Postgres + RLS + RPC).
///
/// Everything the app needs from the backend lives here so the UI layer never
/// touches SQL or JSON keys. Errors are converted into friendly strings by
/// [SupabaseAuthApi.friendlyError].
class SupabaseRepo {
  SupabaseRepo(this.calc);

  final FootprintCalculator calc;
  SupabaseClient get _db => SupabaseConfig.client;
  GoTrueClient get _auth => _db.auth;

  String? get currentUid => _auth.currentUser?.id;
  User? get authUser => _auth.currentUser;

  // ---------------------------------------------------------------- auth ----

  Stream<AuthState> get onAuthStateChange => _auth.onAuthStateChange;

  Future<User> signInWithEmail(String email, String password) async {
    final res = await _auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    final user = res.user;
    if (user == null) throw const AuthException('Sign-in failed.');
    return user;
  }

  Future<User> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await _auth.signUp(
      email: email.trim(),
      password: password,
      data: {'full_name': name.trim()},
    );
    final user = res.user;
    if (user == null) throw const AuthException('Sign-up failed.');
    if (res.session == null) {
      // Confirmation email enabled in the project → tell the user to confirm.
      throw const AuthException(
        'Account created. Please confirm your email, then sign in.',
      );
    }
    return user;
  }

  Future<void> signInWithGoogle({bool adminPortal = false}) async {
    // Supabase performs the OAuth round-trip and restores the session when the
    // browser/app returns to this URL. For web the current origin is used.
    final String? redirect = kIsWeb ? null : 'io.lifemitra://login-callback';
    await _auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: redirect,
      authScreenLaunchMode:
          kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
      queryParams: const {'prompt': 'select_account'},
    );
  }

  Future<void> sendPasswordReset(String email) =>
      _auth.resetPasswordForEmail(email.trim());

  Future<void> signOut() => _auth.signOut();

  // ------------------------------------------------------------- profiles ---

  static AppUser userFromProfile(
    Map<String, dynamic> p, {
    String? emailOverride,
    AuthProvider provider = AuthProvider.password,
  }) {
    return AppUser(
      uid: p['id'] as String,
      email: (p['email'] as String?) ?? emailOverride ?? '',
      displayName: (p['display_name'] as String?) ?? 'Citizen',
      role: switch (p['role'] as String?) {
        'admin' => UserRole.admin,
        'captain' => UserRole.captain,
        _ => UserRole.citizen,
      },
      authProvider: provider,
      photoUrl: p['photo_url'] as String?,
      language: (p['language'] as String?) ?? 'en',
      district: (p['district'] as String?) ?? 'Ahmedabad',
      pincode: (p['pincode'] as String?) ?? '380015',
      householdSize: _int(p['household_size'], 4),
      homeType: (p['home_type'] as String?) ?? 'flat',
      roofAccess: (p['roof_access'] as String?) ?? 'yes',
      appliances: _strings(p['appliances'],
          const ['ac', 'fridge', 'washing_machine', 'geyser']),
      travelMode: (p['travel_mode'] as String?) ?? 'two_wheeler',
      weeklyKm: _dbl(p['weekly_km'], 70),
      baselineUnits: _dbl(p['baseline_units'], 250),
      baselineCo2Kg: _dbl(p['baseline_co2_kg'], 226.9),
      goalPercent: _int(p['goal_percent'], 15),
      onboardingComplete: p['onboarding_complete'] == true,
      communityId: p['community_id'] as String?,
      points: _int(p['points'], 0),
      weeklyPoints: _int(p['weekly_points'], 0),
      streak: _int(p['streak'], 0),
      longestStreak: _int(p['longest_streak'], 0),
      freezeTokens: _int(p['freeze_tokens'], 1),
      badges: _strings(p['badges'], const []),
      peakNudge: p['peak_nudge'] != false,
      weatherNudge: p['weather_nudge'] != false,
      communityUpdates: p['community_updates'] != false,
      streakReminders: p['streak_reminders'] != false,
    );
  }

  /// Profile columns the *client* is allowed to write (server-owned gamification
  /// columns are stripped by the DB guard trigger anyway).
  static Map<String, dynamic> profilePatch(AppUser u) => {
        'display_name': u.displayName,
        'photo_url': u.photoUrl,
        'language': u.language,
        'district': u.district,
        'pincode': u.pincode,
        'household_size': u.householdSize,
        'home_type': u.homeType,
        'roof_access': u.roofAccess,
        'appliances': u.appliances,
        'travel_mode': u.travelMode,
        'weekly_km': u.weeklyKm,
        'baseline_units': u.baselineUnits,
        'baseline_co2_kg': u.baselineCo2Kg,
        'goal_percent': u.goalPercent,
        'onboarding_complete': u.onboardingComplete,
        'community_id': u.communityId,
        'peak_nudge': u.peakNudge,
        'weather_nudge': u.weatherNudge,
        'community_updates': u.communityUpdates,
        'streak_reminders': u.streakReminders,
      };

  /// Creates the profile row if the sign-up trigger has not run yet, then
  /// returns the row (avoids the classic "profile missing after Google OAuth").
  Future<Map<String, dynamic>> ensureProfile(User user) async {
    final existing = await _db
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    if (existing != null) return existing;

    final meta = user.userMetadata ?? {};
    await _db.from('profiles').upsert({
      'id': user.id,
      'email': user.email ?? '',
      'display_name': (meta['full_name'] ?? meta['name'] ??
          (user.email ?? 'Citizen').split('@').first),
      'photo_url': meta['avatar_url'],
    });
    final created =
        await _db.from('profiles').select().eq('id', user.id).single();
    return created;
  }

  Stream<Map<String, dynamic>> profileStream(String uid) => _db
      .from('profiles')
      .stream(primaryKey: ['id'])
      .eq('id', uid)
      .map((rows) => rows.isEmpty ? <String, dynamic>{} : rows.first);

  Future<Map<String, dynamic>> fetchProfile(String uid) async {
    final row =
        await _db.from('profiles').select().eq('id', uid).maybeSingle();
    return row ?? <String, dynamic>{};
  }

  Future<void> saveProfile(String uid, Map<String, dynamic> patch) async {
    await _db.from('profiles').update(patch).eq('id', uid);
  }

  // ------------------------------------------------------------ snapshots ---

  Future<List<TaskLog>> todayTaskLogs(String uid) async {
    final today = _istDayStart();
    final rows = await _db
        .from('task_logs')
        .select()
        .eq('user_id', uid)
        .eq('log_date', _dateOnly(today));
    return rows
        .map((r) => TaskLog(
              taskId: r['task_id'] as String,
              date: DateTime.parse(r['log_date'] as String),
              status: TaskStatus.values.firstWhere(
                (s) => s.name == _statusName(r['status'] as String),
                orElse: () => TaskStatus.pending,
              ),
            ))
        .toList();
  }

  Future<List<FootprintEntry>> footprints(String uid) async {
    final rows = await _db
        .from('footprints')
        .select()
        .eq('user_id', uid)
        .order('month', ascending: true);
    return rows
        .map((r) => FootprintEntry(
              month: DateTime.parse(r['month'] as String),
              electricityUnits: _dbl(r['electricity_units'], 0),
              electricityKg: _dbl(r['electricity_kg'], 0),
              cookingKg: _dbl(r['cooking_kg'], 0),
              transportKg: _dbl(r['transport_kg'], 0),
              source: (r['source'] as String?) ?? 'manual',
              isBaseline: r['is_baseline'] == true,
              unitsSaved: _dbl(r['units_saved'], 0),
              rupeesSaved: _dbl(r['rupees_saved'], 0),
              percentChange: _dbl(r['percent_change'], 0),
              pointsAwarded: _int(r['points_awarded'], 0),
            ))
        .toList();
  }

  Future<List<PointsEntry>> ledger(String uid, {int limit = 100}) async {
    final rows = await _db
        .from('points_ledger')
        .select()
        .eq('user_id', uid)
        .order('created_at', ascending: false)
        .limit(limit);
    return rows.map((r) {
      final taskId = r['task_id'] as String?;
      final task = taskId == null
          ? null
          : mockTaskById(taskId);
      return PointsEntry(
        delta: _int(r['delta'], 0),
        reason: task != null
            ? 'Task · ${task.title}'
            : ((r['reason'] as String?) ?? 'Points'),
        createdAt:
            DateTime.tryParse((r['created_at'] as String?) ?? '')?.toLocal() ??
                DateTime.now(),
        icon: task?.theme.icon ?? Icons.stars_rounded,
      );
    }).toList();
  }

  Future<List<SolarAssessment>> solarAssessments(String uid) async {
    final rows = await _db
        .from('solar_assessments')
        .select()
        .eq('user_id', uid)
        .order('created_at', ascending: false)
        .limit(20);
    return rows
        .map((r) => SolarAssessment(
              id: r['id'] as String,
              monthlyUnits: _dbl(r['monthly_units'], 0),
              roofAreaM2: _dbl(r['roof_area_m2'], 0),
              category: (r['category'] as String?) ?? 'general',
              sizeKw: _dbl(r['size_kw'], 0),
              annualGenUnits: _dbl(r['annual_gen_units'], 0),
              grossCost: _dbl(r['gross_cost'], 0),
              centralSubsidy: _dbl(r['central_subsidy'], 0),
              stateSubsidy: _dbl(r['state_subsidy'], 0),
              netCost: _dbl(r['net_cost'], 0),
              annualSavings: _dbl(r['annual_savings'], 0),
              paybackYears: _dbl(r['payback_years'], 0),
              co2Avoided25yKg: _dbl(r['co2_avoided_25y_kg'], 0),
              createdAt: DateTime.tryParse(
                      (r['created_at'] as String?) ?? '')?.toLocal() ??
                  DateTime.now(),
            ))
        .toList();
  }

  Future<List<Lead>> surveyRequests(String uid) async {
    final rows = await _db
        .from('survey_requests')
        .select()
        .eq('user_id', uid)
        .order('created_at', ascending: false)
        .limit(20);
    return rows.map(leadFromRow).toList();
  }

  Future<List<Lead>> adminSurveyRequests({int limit = 200}) async {
    final rows = await _db.rpc('admin_survey_requests', params: {'p_limit': limit});
    return (rows as List).map((r) => leadFromRow(r as Map<String, dynamic>)).toList();
  }

  static Lead leadFromRow(Map<String, dynamic> r) => Lead(
        id: r['id'] as String,
        userName: (r['user_name'] as String?) ?? '',
        district: (r['district'] as String?) ?? '',
        sizeKw: _dbl(r['size_kw'], 2),
        netCost: _dbl(r['net_cost'], 0),
        type: (r['type'] as String?) ?? 'survey',
        createdAt:
            DateTime.tryParse((r['created_at'] as String?) ?? '')?.toLocal() ??
                DateTime.now(),
        vendorName: r['vendor_name'] as String?,
        status: (r['status'] as String?) ?? 'new',
        phone: r['phone'] as String?,
        preferredSlot: r['preferred_slot'] as String?,
        ownerUid: r['user_id'] as String?,
      );

  // ----------------------------------------------------------- communities --

  Future<List<Community>> communities() async {
    final rows =
        await _db.from('communities').select().limit(100).order('member_count', ascending: false);
    return rows.map(communityFromRow).toList();
  }

  static Community communityFromRow(Map<String, dynamic> r) => Community(
        id: r['id'] as String,
        name: (r['name'] as String?) ?? 'Community',
        type: (r['type'] as String?) ?? 'Society',
        district: (r['district'] as String?) ?? '',
        pincode: (r['pincode'] as String?) ?? '',
        memberCount: _int(r['member_count'], 1),
        joinCode: (r['join_code'] as String?) ?? '',
        totalUnitsSaved: _dbl(r['total_units_saved'], 0),
      );

  /// Row of the `community_goal_progress` view.
  static CommunityGoal? goalFromProgressRow(Map<String, dynamic> r) {
    final id = r['community_id'] as String?;
    if (id == null || r['goal_title'] == null) return null;
    return CommunityGoal(
      id: id,
      communityId: id,
      title: r['goal_title'] as String,
      metric: (r['goal_metric'] as String?) ?? 'units',
      target: _dbl(r['goal_target'], 100),
      progress: _dbl(r['progress'], 0),
      endDate:
          DateTime.tryParse((r['goal_end_date'] as String?) ?? '')?.toLocal() ??
              DateTime.now().add(const Duration(days: 30)),
      bonusPoints: 0,
    );
  }

  static CommunityGoal? goalFromRow(Map<String, dynamic> r) {
    if (r['goal_title'] == null) return null;
    return CommunityGoal(
      id: r['id'] as String,
      communityId: r['id'] as String,
      title: r['goal_title'] as String,
      metric: (r['goal_metric'] as String?) ?? 'units',
      target: _dbl(r['goal_target'], 100),
      progress: _dbl(r['progress'], 0),
      endDate: DateTime.tryParse((r['goal_end_date'] as String?) ?? '')
              ?.toLocal() ??
          DateTime.now().add(const Duration(days: 30)),
      bonusPoints: 0,
    );
  }

  Future<Map<String, dynamic>?> communityByJoinCode(String code) async {
    final row = await _db
        .from('communities')
        .select()
        .eq('join_code', code.trim().toUpperCase())
        .maybeSingle();
    return row;
  }

  Future<List<Map<String, dynamic>>> goalProgressView() async {
    final rows = await _db.from('community_goal_progress').select();
    return List<Map<String, dynamic>>.from(rows);
  }

  Future<double> myGoalContribution(String communityId, String uid) async {
    final row = await _db
        .from('community_members')
        .select('goal_contribution')
        .eq('community_id', communityId)
        .eq('user_id', uid)
        .maybeSingle();
    return _dbl(row?['goal_contribution'], 0);
  }

  Future<Map<String, dynamic>> joinCommunity(String communityId) async {
    final res = await _db.rpc('join_community', params: {'p_community_id': communityId});
    final row = res is List
        ? Map<String, dynamic>.from((res).first as Map)
        : Map<String, dynamic>.from(res as Map);
    return row;
  }

  Future<Map<String, dynamic>> createCommunity({
    required String name,
    required String type,
    required String pincode,
    required String district,
    required String joinCode,
    required DateTime goalEndDate,
  }) async {
    final row = await _db
        .from('communities')
        .insert({
          'name': name.trim(),
          'type': type,
          'pincode': pincode,
          'district': district,
          'join_code': joinCode,
          'created_by': currentUid,
          'member_count': 1,
          'goal_end_date': goalEndDate.toUtc().toIso8601String(),
        })
        .select()
        .single();
    final communityId = row['id'] as String;
    try {
      await _db.from('community_members').insert({
        'community_id': communityId,
        'user_id': currentUid,
      });
    } on PostgrestException catch (e) {
      if (e.code != '23505') rethrow; // already a member is fine
    }
    await _db
        .from('profiles')
        .update({'community_id': communityId}).eq('id', currentUid!);
    return row;
  }

  // ----------------------------------------------------------- leaderboard --

  Future<List<(String, String, int)>> leaderboard({
    required String scope,
    required String uid,
    required String district,
    String? communityId,
    bool weekly = false,
  }) async {
    final field = weekly ? 'weekly_points' : 'points';
    var query = _db.from('leaderboard').select();
    if (scope == 'district') {
      query = query.eq('district', district);
    } else if (scope == 'community' && communityId != null) {
      query = query.eq('community_id', communityId);
    }
    final rows =
        await query.order(field, ascending: false).limit(50);
    return [
      for (final r in rows)
        if (r['user_id'] != uid)
          (
            (r['display_name'] as String?) ?? 'Citizen',
            (r['district'] as String?) ?? '',
            _int(r[field], 0),
          ),
    ];
  }

  // ---------------------------------------------------------------- writes --

  /// Server-side scoring: daily cap, streak, badges, total, ledger, goal.
  Future<Map<String, dynamic>> awardTaskPoints({
    required String taskId,
    required int points,
    required String verification,
    required double estUnits,
    required double estCo2,
    bool withPhoto = false,
  }) async {
    final res = await _db.rpc('award_task_points', params: {
      'p_task_id': taskId,
      'p_points': points,
      'p_verification': verification,
      'p_est_units': estUnits,
      'p_est_co2': estCo2,
      'p_with_photo': withPhoto,
    });
    final row = res is List
        ? Map<String, dynamic>.from((res).first as Map)
        : Map<String, dynamic>.from(res as Map);
    return row;
  }

  Future<void> saveTaskStatus({
    required String uid,
    required String taskId,
    required DateTime date,
    required TaskStatus status,
  }) async {
    await _db.from('task_logs').upsert(
      {
        'user_id': uid,
        'task_id': taskId,
        'log_date': _dateOnly(date),
        'status': _statusColumn(status),
      },
      onConflict: 'user_id,task_id,log_date',
      ignoreDuplicates: false,
    );
  }

  Future<void> markNotApplicable({
    required String uid,
    required String taskId,
  }) async {
    await saveTaskStatus(
      uid: uid,
      taskId: taskId,
      date: DateTime.now(),
      status: TaskStatus.notApplicable,
    );
    final current = await fetchProfile(uid);
    final list = _strings(current['not_applicable_task_ids'], const []);
    if (!list.contains(taskId)) {
      await _db.from('profiles').update({
        'not_applicable_task_ids': [...list, taskId],
      }).eq('id', uid);
    }
  }

  Future<Set<String>> notApplicableTaskIds(String uid) async {
    final p = await fetchProfile(uid);
    return _strings(p['not_applicable_task_ids'], const []).toSet();
  }

  Future<int> saveBaseline({
    required String uid,
    required DateTime month,
    required double units,
    required double electricityKg,
    required double cookingKg,
    required double transportKg,
    required String source,
    required double lpgCylinders,
  }) async {
    await _db.from('footprints').upsert(
      {
        'user_id': uid,
        'month': _dateOnly(month),
        'electricity_units': units,
        'electricity_kg': electricityKg,
        'cooking_kg': cookingKg,
        'transport_kg': transportKg,
        'source': source,
        'is_baseline': true,
        'lpg_cylinders': lpgCylinders,
      },
      onConflict: 'user_id,month,is_baseline',
    );
    return 0;
  }

  /// Upserts the month entry and (for non-baseline rows) asks the server to
  /// award points. Returns the points awarded.
  Future<(int, int)> saveMonthlyFootprint({
    required String uid,
    required DateTime month,
    required double units,
    required double electricityKg,
    required double cookingKg,
    required double transportKg,
    required String source,
    required double unitsSaved,
    required double rupeesSaved,
    required double percentChange,
  }) async {
    final row = await _db
        .from('footprints')
        .upsert(
          {
            'user_id': uid,
            'month': _dateOnly(month),
            'electricity_units': units,
            'electricity_kg': electricityKg,
            'cooking_kg': cookingKg,
            'transport_kg': transportKg,
            'source': source,
            'is_baseline': false,
            'units_saved': unitsSaved,
            'rupees_saved': rupeesSaved,
            'percent_change': percentChange,
          },
          onConflict: 'user_id,month,is_baseline',
        )
        .select()
        .single();
    final id = _int(row['id'], 0);
    var points = 0;
    if (id > 0) {
      final res = await _db.rpc('award_footprint_points', params: {'p_footprint_id': id});
      points = (res is int) ? res : _int(res, 0);
    }
    return (points, id);
  }

  Future<void> saveSolarAssessment({
    required String uid,
    required SolarAssessment a,
  }) async {
    await _db.from('solar_assessments').insert({
      'id': a.id,
      'user_id': uid,
      'monthly_units': a.monthlyUnits,
      'roof_area_m2': a.roofAreaM2,
      'category': a.category,
      'size_kw': a.sizeKw,
      'annual_gen_units': a.annualGenUnits,
      'gross_cost': a.grossCost,
      'central_subsidy': a.centralSubsidy,
      'state_subsidy': a.stateSubsidy,
      'net_cost': a.netCost,
      'annual_savings': a.annualSavings,
      'payback_years': a.paybackYears,
      'co2_avoided_25y_kg': a.co2Avoided25yKg,
    });
  }

  Future<Lead> saveSurveyRequest({required String uid, required Lead lead}) async {
    final row = await _db
        .from('survey_requests')
        .insert({
          'id': lead.id,
          'user_id': uid,
          'user_name': lead.userName,
          'district': lead.district,
          'size_kw': lead.sizeKw,
          'net_cost': lead.netCost,
          'type': lead.type,
          'vendor_name': lead.vendorName,
          'status': lead.status,
          'phone': lead.phone,
          'preferred_slot': lead.preferredSlot,
        })
        .select()
        .single();
    return leadFromRow(row);
  }

  Future<void> updateLeadStatus(String leadId, String status) async {
    await _db.from('survey_requests').update({'status': status}).eq('id', leadId);
  }

  /// Bill-proof upload → Supabase Storage bucket `bill-proofs`.
  Future<String> uploadBillProof({
    required Uint8List bytes,
    required String contentType,
  }) async {
    final uid = currentUid;
    if (uid == null) throw StateError('Sign in before uploading bill proof.');
    if (bytes.isEmpty || bytes.length > 10 * 1024 * 1024) {
      throw ArgumentError('Bill proof must be between 1 byte and 10 MB.');
    }
    if (!const {'image/jpeg', 'image/png', 'image/webp'}.contains(contentType)) {
      throw ArgumentError('Bill proof must be a JPEG, PNG, or WebP image.');
    }
    final ext = switch (contentType) {
      'image/jpeg' => 'jpg',
      'image/png' => 'png',
      _ => 'webp',
    };
    final path =
        '$uid/${DateTime.now().microsecondsSinceEpoch}.$ext';
    await _db.storage.from('bill-proofs').uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType, upsert: true),
        );
    // Bucket is private: hand back a short-lived signed URL (the UI only needs
    // a stable reference to attach to the entry).
    return _db.storage.from('bill-proofs').createSignedUrl(path, 3600);
  }

  Future<void> saveGasConnection(String uid, Map<String, dynamic> json) async {
    await _db.from('profiles').update({'gas_connection': json}).eq('id', uid);
  }

  Future<void> savePushToken({
    required String uid,
    required String token,
    required String platform,
  }) async {
    await _db.from('push_tokens').upsert({
      'token': token,
      'user_id': uid,
      'platform': platform,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<void> deletePushToken(String token) async {
    await _db.from('push_tokens').delete().eq('token', token);
  }

  // --------------------------------------------------------------- helpers --

  static DateTime _istDayStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static String _dateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String _statusColumn(TaskStatus s) => switch (s) {
        TaskStatus.done => 'done',
        TaskStatus.skipped => 'skipped',
        TaskStatus.notApplicable => 'not_applicable',
        TaskStatus.pending => 'pending',
      };

  static String _statusName(String dbValue) => switch (dbValue) {
        'not_applicable' => 'notApplicable',
        _ => dbValue,
      };

  static int _int(Object? v, int fallback) =>
      v is num ? v.toInt() : int.tryParse('$v') ?? fallback;

  static double _dbl(Object? v, double fallback) =>
      v is num ? v.toDouble() : double.tryParse('$v') ?? fallback;

  static List<String> _strings(Object? v, List<String> fallback) {
    if (v is List) return v.map((e) => '$e').toList();
    return List<String>.from(fallback);
  }

  static TaskItem? mockTaskById(String id) {
    // Injected by app_state to avoid a dependency cycle; set at startup.
    return _taskResolver?.call(id);
  }

  static TaskItem? Function(String id)? _taskResolver;
  static set taskResolver(TaskItem? Function(String id)? fn) =>
      _taskResolver = fn;

  /// Maps Supabase / network errors to messages the UI can show directly.
  static String friendlyError(Object error) {
    if (error is AuthException) {
      final msg = error.message.toLowerCase();
      if (msg.contains('invalid login credentials')) {
        return 'Email or password is incorrect.';
      }
      if (msg.contains('email not confirmed')) {
        return 'Please confirm your email address, then sign in.';
      }
      if (msg.contains('user already registered')) return 'email-already-in-use';
      if (msg.contains('password should be at least')) {
        return 'Choose a stronger password (6+ characters).';
      }
      if (msg.contains('rate limit') || msg.contains('too many')) {
        return 'Too many attempts. Please try again later.';
      }
      if (msg.contains('provider is not enabled')) {
        return 'Google sign-in is not enabled for this Supabase project yet.';
      }
      return error.message;
    }
    if (error is PostgrestException) {
      switch (error.code) {
        case '42P01':
          return 'Database table missing — run supabase/migrations/0001_init.sql.';
        case '42501':
          return 'Permission denied. Check the Row Level Security policies.';
        case '23505':
          return 'That record already exists.';
        default:
          return error.message;
      }
    }
    if (error is StorageException) return error.message;
    final text = error.toString();
    if (text.contains('SocketException') || text.contains('Failed host lookup')) {
      return 'Network error. Check your connection and try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}
