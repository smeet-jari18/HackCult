import 'package:flutter_test/flutter_test.dart';
import 'package:life_mitra/data/models.dart';
import 'package:life_mitra/data/supabase/supabase_repo.dart';

/// Pure row → model mapping tests for the Supabase data layer.
/// These run offline (no Supabase project needed).
void main() {
  group('profiles row → AppUser', () {
    test('maps every column the app relies on', () {
      final user = SupabaseRepo.userFromProfile({
        'id': '11111111-1111-1111-1111-111111111111',
        'email': 'nisha@demo.com',
        'display_name': 'Nisha Patel',
        'role': 'admin',
        'photo_url': null,
        'language': 'gu',
        'district': 'Ahmedabad',
        'pincode': '380015',
        'household_size': 5,
        'home_type': 'flat',
        'roof_access': 'yes',
        'appliances': ['ac', 'fridge'],
        'travel_mode': 'bus_metro',
        'weekly_km': 42.5,
        'baseline_units': 210,
        'baseline_co2_kg': 190.4,
        'goal_percent': 20,
        'onboarding_complete': true,
        'community_id': '22222222-2222-2222-2222-222222222222',
        'points': 1240,
        'weekly_points': 180,
        'streak': 5,
        'longest_streak': 12,
        'freeze_tokens': 2,
        'badges': ['first_step', 'streak_7'],
        'peak_nudge': false,
        'weather_nudge': true,
        'community_updates': false,
        'streak_reminders': true,
      });

      expect(user.displayName, 'Nisha Patel');
      expect(user.role, UserRole.admin);
      expect(user.isAdmin, isTrue);
      expect(user.householdSize, 5);
      expect(user.appliances, ['ac', 'fridge']);
      expect(user.weeklyKm, 42.5);
      expect(user.goalPercent, 20);
      expect(user.onboardingComplete, isTrue);
      expect(user.points, 1240);
      expect(user.weeklyPoints, 180);
      expect(user.streak, 5);
      expect(user.badges, ['first_step', 'streak_7']);
      expect(user.peakNudge, isFalse);
      expect(user.communityUpdates, isFalse);
      expect(user.initials, 'NP');
    });

    test('tolerates missing / null columns with sane defaults', () {
      final user = SupabaseRepo.userFromProfile({
        'id': '33333333-3333-3333-3333-333333333333',
        'email': 'new@user.com',
        'display_name': 'New User',
        'appliances': null,
        'badges': null,
        'points': null,
        'household_size': null,
      });
      expect(user.role, UserRole.citizen);
      expect(user.householdSize, 4);
      expect(user.points, 0);
      expect(user.badges, isEmpty);
      expect(user.appliances, isNotEmpty);
      expect(user.onboardingComplete, isFalse);
    });

    test('profile patch never sends server-owned scoring columns', () {
      final user = SupabaseRepo.userFromProfile({
        'id': '44444444-4444-4444-4444-444444444444',
        'email': 'a@b.com',
        'display_name': 'A',
        'points': 999,
      });
      final patch = SupabaseRepo.profilePatch(user);
      expect(patch.containsKey('points'), isFalse);
      expect(patch.containsKey('badges'), isFalse);
      expect(patch.containsKey('streak'), isFalse);
      expect(patch['display_name'], 'A');
    });
  });

  group('leads, communities, goals', () {
    test('lead row → Lead', () {
      final lead = SupabaseRepo.leadFromRow({
        'id': '55555555-5555-5555-5555-555555555555',
        'user_id': '66666666-6666-6666-6666-666666666666',
        'user_name': 'Nisha Patel',
        'district': 'Surat',
        'size_kw': 3,
        'net_cost': 145000,
        'type': 'quote',
        'status': 'contacted',
        'phone': '9876543210',
        'preferred_slot': 'Weekend',
        'created_at': '2026-11-01T10:00:00+00:00',
      });
      expect(lead.district, 'Surat');
      expect(lead.sizeKw, 3);
      expect(lead.status, 'contacted');
      expect(lead.phone, '9876543210');
      expect(lead.ownerUid, '66666666-6666-6666-6666-666666666666');
    });

    test('community row → Community', () {
      final c = SupabaseRepo.communityFromRow({
        'id': '77777777-7777-7777-7777-777777777777',
        'name': 'Shanti Nagar Society',
        'type': 'Society',
        'district': 'Ahmedabad',
        'pincode': '380015',
        'member_count': 128,
        'join_code': 'SHNT15',
        'total_units_saved': 3200,
      });
      expect(c.name, 'Shanti Nagar Society');
      expect(c.memberCount, 128);
      expect(c.joinCode, 'SHNT15');
      expect(c.totalUnitsSaved, 3200);
    });

    test('goal progress view row → CommunityGoal', () {
      final goal = SupabaseRepo.goalFromProgressRow({
        'community_id': '77777777-7777-7777-7777-777777777777',
        'goal_title': 'Save 100 units this month',
        'goal_metric': 'units',
        'goal_target': 100,
        'goal_end_date': '2026-12-01T00:00:00+00:00',
        'progress': 42.5,
        'member_total': 7,
      });
      expect(goal, isNotNull);
      expect(goal!.target, 100);
      expect(goal.progress, 42.5);
      expect(goal.ratio, closeTo(0.425, 1e-9));
    });
  });

  group('friendly errors', () {
    test('maps Postgres / network failures to readable text', () {
      expect(
        SupabaseRepo.friendlyError(Exception('SocketException: failed')),
        contains('Network error'),
      );
      expect(
        SupabaseRepo.friendlyError(Exception('random')),
        contains('Something went wrong'),
      );
    });
  });
}
