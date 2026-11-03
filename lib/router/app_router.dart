import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/app_state.dart';
import '../features/admin/admin_screens.dart';
import '../features/auth/auth_screens.dart';
import '../features/community/community_screens.dart';
import '../features/home/gas_screen.dart';
import '../features/home/home_screens.dart';
import '../features/home/task_detail_screen.dart';
import '../features/home/tasks_screen.dart';
import '../features/legal/legal_screens.dart';
import '../features/hub/hub_screens.dart';
import '../features/impact/impact_screens.dart';
import '../features/onboarding/onboarding_screens.dart';
import '../features/profile/profile_screens.dart';

/// Builds the GoRouter. Redirect rules:
///  * not signed in  -> /login (or /admin/login for /admin/* paths)
///  * signed in, onboarding incomplete -> /onboarding/1
///  * admin users land on /admin; citizens can never open /admin/*
GoRouter buildRouter(AppState state) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: state.authChanges,
    debugLogDiagnostics: false,
    redirect: (context, st) {
      final loc = st.matchedLocation;
      final signedIn = state.isSignedIn;
      final isAdminPath = loc.startsWith('/admin');
      final isAuthPath = loc == '/login' ||
          loc == '/signup' ||
          loc == '/forgot' ||
          loc == '/admin/login';
      if (loc == '/splash') return null;
      // Legal pages are public (linked from login / sign-up).
      if (loc.startsWith('/legal/')) return null;

      if (!signedIn) {
        if (isAuthPath) return null;
        return isAdminPath ? '/admin/login' : '/login';
      }
      final u = state.user!;
      if (u.isAdmin) {
        if (!isAdminPath || loc == '/admin/login') return '/admin';
        return null;
      }
      // Citizen
      if (isAdminPath) return '/home';
      if (isAuthPath) return u.onboardingComplete ? '/home' : '/onboarding/1';
      if (!u.onboardingComplete &&
          !loc.startsWith('/onboarding') &&
          !loc.startsWith('/legal/') &&
          !loc.startsWith('/community/join')) {
        return '/onboarding/1';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignUpScreen()),
      GoRoute(
          path: '/forgot', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(
        path: '/onboarding/result',
        builder: (_, __) => const BaselineResultScreen(),
      ),
      GoRoute(
        path: '/onboarding/:step',
        builder: (_, st) => OnboardingScreen(
            step: int.tryParse(st.pathParameters['step'] ?? '1') ?? 1),
      ),

      // ---- Citizen app (bottom-nav shell) ----
      ShellRoute(
        builder: (context, st, child) =>
            MainShell(location: st.matchedLocation, child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/impact', builder: (_, __) => const ImpactScreen()),
          GoRoute(
              path: '/community', builder: (_, __) => const CommunityScreen()),
          GoRoute(path: '/hub', builder: (_, __) => const HubScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),

      // ---- Full-screen citizen pages (pushed above the shell) ----
      GoRoute(path: '/tasks', builder: (_, __) => const TasksScreen()),
      GoRoute(
          path: '/tasks/:id',
          builder: (_, st) =>
              TaskDetailScreen(taskId: st.pathParameters['id']!)),
      GoRoute(
          path: '/legal/privacy',
          builder: (_, __) => const PrivacyPolicyScreen()),
      GoRoute(path: '/legal/terms', builder: (_, __) => const TermsScreen()),
      GoRoute(
          path: '/home/gas', builder: (_, __) => const GasConnectionScreen()),
      GoRoute(
          path: '/impact/add-month',
          builder: (_, __) => const AddMonthScreen()),
      GoRoute(
        path: '/community/join',
        builder: (_, st) => JoinCommunityScreen(
            fromOnboarding: st.uri.queryParameters['onboarding'] == '1'),
      ),
      GoRoute(
          path: '/community/goals/:id',
          builder: (_, st) =>
              GoalDetailScreen(goalId: st.pathParameters['id']!)),
      GoRoute(
          path: '/hub/solar',
          builder: (_, __) => const SolarCalculatorScreen()),
      GoRoute(
          path: '/hub/solar/result/:id',
          builder: (_, st) =>
              SolarResultScreen(assessmentId: st.pathParameters['id']!)),
      GoRoute(path: '/hub/vendors', builder: (_, __) => const VendorsScreen()),
      GoRoute(
          path: '/hub/schemes/:id',
          builder: (_, st) =>
              SchemeDetailScreen(schemeId: st.pathParameters['id']!)),
      GoRoute(
          path: '/profile/edit', builder: (_, __) => const EditProfileScreen()),
      GoRoute(
          path: '/profile/badges', builder: (_, __) => const BadgesScreen()),
      GoRoute(
          path: '/profile/points',
          builder: (_, __) => const PointsHistoryScreen()),
      GoRoute(
          path: '/community/create',
          builder: (_, __) => const CreateCommunityScreen()),
      GoRoute(
          path: '/profile/notifications',
          builder: (_, __) => const NotificationSettingsScreen()),

      // ---- Admin web portal ----
      GoRoute(
          path: '/admin/login', builder: (_, __) => const AdminLoginScreen()),
      ShellRoute(
        builder: (context, st, child) =>
            AdminShell(location: st.matchedLocation, child: child),
        routes: [
          GoRoute(
              path: '/admin', builder: (_, __) => const AdminOverviewScreen()),
          GoRoute(
              path: '/admin/leads',
              builder: (_, __) => const AdminLeadsScreen()),
          GoRoute(
              path: '/admin/content',
              builder: (_, __) => const AdminContentScreen()),
          GoRoute(
              path: '/admin/campaigns',
              builder: (_, __) => const AdminCampaignsScreen()),
        ],
      ),
    ],
    errorBuilder: (context, st) => Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(st.uri.toString()),
            const SizedBox(height: 12),
            FilledButton(
                onPressed: () => context.go('/splash'),
                child: const Text('Go home')),
          ],
        ),
      ),
    ),
  );
}
