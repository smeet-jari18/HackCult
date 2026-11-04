import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/services/push_service.dart';
import '../../core/widgets/widgets.dart';
import '../../data/app_state.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../auth/auth_screens.dart' show Validators;

// Palette tuned to the GEDA Staff Portal design (screen.png).
class _A {
  static const bgLeftTop = Color(0xFF1F6B2B);
  static const bgLeftBottom = Color(0xFF2E7D32);
  static const bgRight = Color(0xFFF7F9F7);
  static const deep = Color(0xFF0F4D1A);
  static const card = Colors.white;
  static const border = Color(0xFFE3E8E3);
  static const notice = Color(0xFFEEF2FF);
  static const noticeBorder = Color(0xFFDDE3FF);
  static const mint = Color(0xFFE2F5E3);
}

// ---------------------------------------------------------------------------
// Admin login (web)
// ---------------------------------------------------------------------------
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  bool _gLoading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final s = AppScope.read(context);
    final emailErr = Validators.email(_email.text);
    if (emailErr != null || _password.text.isEmpty) {
      setState(() => _error = emailErr ?? 'Enter your password');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final err = await s.signInWithEmail(_email.text.trim(), _password.text);
    if (!mounted) return;
    if (err != null) {
      setState(() {
        _loading = false;
        _error = err;
      });
      return;
    }
    if (!s.user!.isAdmin) {
      s.signOut();
      setState(() {
        _loading = false;
        _error = 'This account is not authorised for the staff portal.';
      });
      return;
    }
    context.go('/admin');
  }

  Future<void> _google() async {
    setState(() {
      _gLoading = true;
      _error = null;
    });
    final state = AppScope.read(context);
    final error = await state.signInWithGoogle(adminPortal: true);
    if (!mounted) return;
    setState(() => _gLoading = false);
    if (error != null) {
      if (error != 'Google sign-in was cancelled.') {
        setState(() => _error = error);
      }
      return;
    }
    if (state.user?.isAdmin != true) {
      state.signOut();
      if (!mounted) return;
      setState(() {
        _error = 'This account is not authorised for the staff portal.';
      });
      return;
    }
    context.go('/admin');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _A.bgRight,
      body: LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth >= 900;
          if (!wide) {
            return SingleChildScrollView(
              child: Column(children: [
                SizedBox(height: 420, child: _LeftPanel(compact: true)),
                Padding(
                    padding: const EdgeInsets.all(20), child: _form(context))
              ]),
            );
          }
          return Row(
            children: [
              Expanded(flex: 45, child: _LeftPanel()),
              Expanded(
                flex: 55,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 48, vertical: 40),
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: _form(context)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _form(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.verified_user_outlined,
                size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Flexible(
                child: Text('GEDA State Node: Gandhinagar',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        t.bodyMedium?.copyWith(color: AppColors.textPrimary))),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _A.border)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          color: AppColors.success, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text('Admin Console',
                      style: t.labelMedium
                          ?.copyWith(color: AppColors.textPrimary)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: _A.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _A.border),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 24,
                  offset: const Offset(0, 8))
            ],
          ),
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                          color: _A.mint,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFCDEBD0))),
                      child: const Icon(Icons.lock_outline_rounded,
                          color: AppColors.primary, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('GEDA Staff Portal',
                              style: t.headlineSmall?.copyWith(fontSize: 24)),
                          const SizedBox(height: 4),
                          Text(
                              'Authorized state officers & programme administrators only',
                              style: t.bodyMedium?.copyWith(fontSize: 15)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _Label('Official Email'),
                const SizedBox(height: 8),
                _Field(
                  controller: _email,
                  hint: 'e.g. officer.name@geda.gujarat.gov.in',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [
                    AutofillHints.username,
                    AutofillHints.email
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _Label('Password'),
                    const Spacer(),
                    InkWell(
                      onTap: () => showAppSnack(context,
                          'Reset link sent to your official email (demo)',
                          icon: Icons.mail_outline_rounded),
                      child: Text('Forgot portal credentials?',
                          style: t.labelMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _Field(
                  controller: _password,
                  hint: '••••••••••••',
                  icon: Icons.lock_clock_outlined,
                  obscure: _obscure,
                  autofillHints: const [AutofillHints.password],
                  onSubmitted: (_) => _signIn(),
                  suffix: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textSecondary),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  InfoBanner(
                      text: _error!,
                      icon: Icons.error_outline_rounded,
                      color: AppColors.error),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  height: 60,
                  child: FilledButton(
                    onPressed: _loading ? null : _signIn,
                    style: FilledButton.styleFrom(
                        backgroundColor: _A.deep,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14))),
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.4, color: Colors.white))
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                  child: Text('Sign In to Console',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: t.titleMedium?.copyWith(
                                          color: Colors.white, fontSize: 17))),
                              const SizedBox(width: 10),
                              const Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(child: Divider(color: _A.border)),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text('OR',
                            style: t.labelMedium?.copyWith(
                                color: AppColors.textTertiary,
                                letterSpacing: 1))),
                    const Expanded(child: Divider(color: _A.border)),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 60,
                  child: OutlinedButton(
                    onPressed: _gLoading ? null : _google,
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _A.border),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14))),
                    child: _gLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.4))
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const GoogleLogo(size: 22),
                              const SizedBox(width: 12),
                              Flexible(
                                  child: Text('Continue with Google Workspace',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: t.titleMedium?.copyWith(
                                          fontSize: 16,
                                          color: AppColors.textPrimary))),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                      color: _A.notice,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _A.noticeBorder)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(Icons.gpp_maybe_outlined,
                              size: 18, color: AppColors.secondary)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: t.bodySmall?.copyWith(
                                height: 1.55, color: AppColors.textPrimary),
                            children: const [
                              TextSpan(
                                  text: 'Notice: ',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w700)),
                              TextSpan(
                                  text:
                                      'Access restricted strictly to authorised GEDA staff and Gujarat Energy Department officials. Unauthorized access attempts are logged and monitored under IT Act.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        Center(
            child: Text(
                'Gujarat Energy Development Agency (GEDA) · v2.4 Admin Suite',
                style: t.bodySmall?.copyWith(color: AppColors.textSecondary))),
        const SizedBox(height: 8),
        Center(
            child: Text('Demo credentials: admin@geda.demo / Admin@1234',
                style: t.labelSmall?.copyWith(color: AppColors.textTertiary))),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 15));
}

class _Field extends StatelessWidget {
  const _Field(
      {required this.controller,
      required this.hint,
      required this.icon,
      this.obscure = false,
      this.suffix,
      this.keyboardType,
      this.autofillHints,
      this.onSubmitted});
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      onSubmitted: onSubmitted,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 15),
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _A.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.6)),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _A.border)),
      ),
    );
  }
}

class _LeftPanel extends StatelessWidget {
  const _LeftPanel({this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_A.bgLeftTop, _A.bgLeftBottom]),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -120,
            bottom: -80,
            child: Container(
              width: 420,
              height: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  Colors.white.withValues(alpha: 0.12),
                  Colors.white.withValues(alpha: 0)
                ]),
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, c) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: c.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.all(compact ? 28 : 80).copyWith(
                        top: compact ? 32 : 80, bottom: compact ? 28 : 72),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _BrandLockup(),
                        SizedBox(height: compact ? 28 : 72),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(6)),
                          child: Text('State Administration Portal',
                              style: t.labelMedium?.copyWith(
                                  color: Colors.white, fontSize: 13)),
                        ),
                        const SizedBox(height: 14),
                        Text('Mission LiFE Gujarat',
                            style: t.displaySmall?.copyWith(
                                color: Colors.white,
                                fontSize: compact ? 34 : 46,
                                height: 1.1)),
                        const SizedBox(height: 12),
                        Text(
                            'Programme Administration & Energy Telemetry Portal',
                            style: t.bodyLarge?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: compact ? 15 : 18)),
                        if (!compact) ...[
                          const SizedBox(height: 56),
                          Text('KEY TELEMETRY STREAMS',
                              style: t.labelMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  letterSpacing: 1.4)),
                          const SizedBox(height: 16),
                          const _StreamCard(
                              icon: Icons.sync_rounded,
                              title: 'Real-time Discom grid synchronization',
                              body:
                                  'Automated feed-in tariff load telemetry across all discom regions.'),
                          const SizedBox(height: 14),
                          const _StreamCard(
                              icon: Icons.bar_chart_rounded,
                              title:
                                  'Citizen carbon reduction & nudge analytics',
                              body:
                                  'Mission LiFE behavior verification and daily civic habit milestones.'),
                          const SizedBox(height: 14),
                          const _StreamCard(
                              icon: Icons.route_rounded,
                              title: 'Rooftop solar subsidy lead routing',
                              body:
                                  'Direct dispatching to empanelled vendors & DISCOM inspectors.'),
                          const Spacer(),
                          Divider(color: Colors.white.withValues(alpha: 0.2)),
                          const SizedBox(height: 22),
                          Row(
                            children: [
                              Icon(Icons.account_balance_outlined,
                                  color: Colors.white.withValues(alpha: 0.85),
                                  size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Text(
                                      'Government of Gujarat · Energy & Petrochemicals Department',
                                      style: t.bodyMedium?.copyWith(
                                          color: Colors.white
                                              .withValues(alpha: 0.85)))),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(20)),
                                child: Text('Official Access',
                                    style: t.labelMedium
                                        ?.copyWith(color: Colors.white)),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandLockup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(28)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.solar_power_outlined,
              size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Text('GEDA', style: t.titleSmall?.copyWith(fontSize: 15)),
          Container(
              width: 1,
              height: 22,
              color: _A.border,
              margin: const EdgeInsets.symmetric(horizontal: 14)),
          const Icon(Icons.eco_outlined, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Flexible(
              child: Text('Mission LiFE Gujarat',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.titleSmall?.copyWith(fontSize: 15))),
        ],
      ),
    );
  }
}

class _StreamCard extends StatelessWidget {
  const _StreamCard(
      {required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: t.titleSmall
                        ?.copyWith(color: Colors.white, fontSize: 16)),
                const SizedBox(height: 4),
                Text(body,
                    style: t.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Admin shell with sidebar
// ---------------------------------------------------------------------------
class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.child, required this.location});
  final Widget child;
  final String location;

  static const _items = [
    ('/admin', 'Overview', Icons.dashboard_outlined),
    ('/admin/leads', 'Solar leads', Icons.solar_power_outlined),
    ('/admin/content', 'Tasks & content', Icons.article_outlined),
    ('/admin/campaigns', 'Campaigns', Icons.campaign_outlined),
  ];

  int get _index {
    for (var i = _items.length - 1; i >= 0; i--) {
      if (location == _items[i].$1 ||
          (i > 0 && location.startsWith(_items[i].$1))) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final t = Theme.of(context).textTheme;
    if (!s.isSignedIn) return const Scaffold(body: SizedBox.shrink());
    final u = s.user!;
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 1000;
        final sidebar = Container(
          width: 250,
          color: _A.deep,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: BrandPill(dark: true, compact: true)),
              Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  child: Text('GEDA Admin Console',
                      style: t.labelSmall?.copyWith(color: Colors.white60))),
              for (var i = 0; i < _items.length; i++)
                _SideItem(
                    icon: _items[i].$3,
                    label: _items[i].$2,
                    selected: _index == i,
                    onTap: () => context.go(_items[i].$1)),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Avatar(
                          initials: u.initials,
                          size: 36,
                          color: AppColors.primaryLight),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(u.displayName,
                                style:
                                    t.labelLarge?.copyWith(color: Colors.white),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            Text('Programme Officer',
                                style: t.labelSmall
                                    ?.copyWith(color: Colors.white60)),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Sign out',
                        onPressed: () {
                          context.go('/admin/login');
                          s.signOut();
                        },
                        icon: const Icon(Icons.logout_rounded,
                            color: Colors.white70, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );

        return Scaffold(
          backgroundColor: _A.bgRight,
          drawer: wide ? null : Drawer(width: 250, child: sidebar),
          appBar: wide
              ? null
              : AppBar(
                  title: Text(_items[_index].$2),
                  backgroundColor: Colors.white),
          body: Row(
            children: [
              if (wide) sidebar,
              Expanded(
                child: Column(
                  children: [
                    if (wide) _TopBar(title: _items[_index].$2),
                    Expanded(child: child),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SideItem extends StatelessWidget {
  const _SideItem(
      {required this.icon,
      required this.label,
      required this.selected,
      required this.onTap});
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: selected
            ? Colors.white.withValues(alpha: 0.14)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(icon,
                    color: selected ? Colors.white : Colors.white70, size: 20),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: selected ? Colors.white : Colors.white70))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: _A.border))),
      child: Row(
        children: [
          Text(title, style: t.titleLarge),
          const Spacer(),
          const StatusTag(
              label: 'Admin Console', color: AppColors.success, dot: true),
          const SizedBox(width: 12),
          Text('GEDA State Node: Gandhinagar', style: t.labelMedium),
          const SizedBox(width: 16),
          IconButton(
              onPressed: () => showAppSnack(context, 'No new alerts',
                  icon: Icons.notifications_none_rounded),
              icon: const Icon(Icons.notifications_none_rounded)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Overview
// ---------------------------------------------------------------------------
class _LiveAdminUnavailable extends StatelessWidget {
  const _LiveAdminUnavailable({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: AppCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 44, color: AppColors.warning),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AdminOverviewScreen extends StatefulWidget {
  const AdminOverviewScreen({super.key});

  @override
  State<AdminOverviewScreen> createState() => _AdminOverviewScreenState();
}

class _AdminOverviewScreenState extends State<AdminOverviewScreen> {
  String _range = '30d';
  String _district = 'All Gujarat';

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    if (AppScope.of(context).isLiveBackend) {
=======
    if (AppScope.of(context).useFirebase) {
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
      return const _LiveAdminUnavailable(
        title: 'Live programme reporting is not connected',
        message:
            'The charts, activity feed and district totals on this page are demo data. They are hidden for Firebase accounts so they are not mistaken for real programme statistics. Review actual survey requests in Solar leads.',
      );
    }
    final t = Theme.of(context).textTheme;
    const metrics = MockData.districtMetrics;
    final users = metrics.fold<int>(0, (a, b) => a + b.users);
    final units = metrics.fold<double>(0, (a, b) => a + b.unitsSaved);
    final co2 = metrics.fold<double>(0, (a, b) => a + b.co2Kg);
    final tasks = metrics.fold<int>(0, (a, b) => a + b.tasks);
    final leads = MockData.leads.length;
    final maxUnits =
        metrics.map((m) => m.unitsSaved).reduce((a, b) => a > b ? a : b);

    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('Programme overview', style: t.headlineSmall),
            const SizedBox(width: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: '7d', label: Text('7 days')),
                ButtonSegment(value: '30d', label: Text('30 days')),
                ButtonSegment(value: 'all', label: Text('All time'))
              ],
              selected: {_range},
              onSelectionChanged: (v) => setState(() => _range = v.first),
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  selectedBackgroundColor: AppColors.primarySoft,
                  selectedForegroundColor: AppColors.primary,
                  side: const BorderSide(color: _A.border)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _A.border)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _district,
                  items: [
                    for (final d in [
                      'All Gujarat',
                      ...metrics.map((m) => m.district)
                    ])
                      DropdownMenuItem(
                          value: d, child: Text(d, style: t.labelLarge))
                  ],
                  onChanged: (v) => setState(() => _district = v!),
                ),
              ),
            ),
            OutlinedButton.icon(
                onPressed: () => showAppSnack(
                    context, 'CSV export queued — download link emailed',
                    icon: Icons.download_rounded),
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('Export CSV')),
          ],
        ),
        const SizedBox(height: 20),
        _KpiGrid(items: [
          _Kpi('Active citizens', Fmt.int(users), '+12.4% vs last month',
              Icons.people_alt_outlined, AppColors.primary),
          _Kpi(
              'Units saved',
              Fmt.compact(units),
              '≈ ${Fmt.rupees(units * 7)} saved',
              Icons.bolt_rounded,
              AppColors.secondary),
          _Kpi(
              'CO₂ avoided',
              Fmt.tonnes(co2),
              '${(co2 / 20 / 1000).toStringAsFixed(0)}k tree-years',
              Icons.co2_rounded,
              AppColors.success),
          _Kpi('Tasks verified', Fmt.compact(tasks), '38% with photo/bill',
              Icons.task_alt_rounded, AppColors.tertiary),
          _Kpi(
              'Solar leads',
              '$leads',
              '${MockData.leads.where((l) => l.status == 'new').length} new today',
              Icons.solar_power_outlined,
              AppColors.warning),
        ]),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, c) {
            final two = c.maxWidth > 820;
            final trend = _Panel(
              title: 'Units & CO₂ saved · monthly',
              child: SizedBox(height: 260, child: _TrendBars()),
            );
            final pie = _Panel(
              title: 'Task mix by theme',
              child: SizedBox(height: 260, child: _ThemePie()),
            );
            return two
                ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(flex: 3, child: trend),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: pie)
                  ])
                : Column(children: [trend, const SizedBox(height: 16), pie]);
          },
        ),
        const SizedBox(height: 20),
        _Panel(
          title: 'District leaderboard',
          trailing: TextButton(onPressed: () {}, child: const Text('View map')),
          child: Column(
            children: [
              _tableHeader(context),
              const Divider(height: 1),
              for (var i = 0; i < metrics.length; i++) ...[
                _DistrictRow(
                    rank: i + 1,
                    m: metrics[i],
                    frac: metrics[i].unitsSaved / maxUnits),
                if (i != metrics.length - 1)
                  const Divider(height: 1, color: _A.border),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        _Panel(
          title: 'Live activity',
          child: Column(
            children: [
              for (final (icon, text, ago) in const [
                (
                  Icons.receipt_long_rounded,
                  'Nisha Patel (Ahmedabad) uploaded a bill — 40 units saved, verified by OCR',
                  '2 min ago'
                ),
                (
                  Icons.solar_power_rounded,
                  'New solar survey lead — Mehul Joshi, Vadodara, 3 kW',
                  '9 min ago'
                ),
                (
                  Icons.flag_rounded,
                  'Shanti Nagar Society crossed 64% of October goal',
                  '31 min ago'
                ),
                (
                  Icons.local_fire_department_rounded,
                  '1,204 citizens completed the 5:30 pm peak-shift nudge',
                  '1 h ago'
                ),
                (
                  Icons.person_add_alt_1_rounded,
                  '86 new sign-ups in Surat via school campaign',
                  '3 h ago'
                ),
              ])
                ListTile(
                  dense: true,
                  leading: IconTile(
                      icon: icon,
                      color: AppColors.primary,
                      size: 36,
                      iconSize: 18,
                      radius: 10),
                  title: Text(text, style: t.bodyMedium),
                  trailing: Text(ago, style: t.labelSmall),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tableHeader(BuildContext context) {
    final t =
        Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 0.6);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Row(
        children: [
          SizedBox(width: 36, child: Text('#', style: t)),
          Expanded(flex: 3, child: Text('DISTRICT', style: t)),
          Expanded(flex: 2, child: Text('CITIZENS', style: t)),
          Expanded(flex: 4, child: Text('UNITS SAVED', style: t)),
          Expanded(flex: 2, child: Text('CO₂ (t)', style: t)),
          Expanded(flex: 2, child: Text('TASKS', style: t)),
        ],
      ),
    );
  }
}

class _Kpi {
  const _Kpi(this.label, this.value, this.sub, this.icon, this.color);
  final String label, value, sub;
  final IconData icon;
  final Color color;
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.items});
  final List<_Kpi> items;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth > 1100
            ? 5
            : c.maxWidth > 700
                ? 3
                : 2;
        final w = (c.maxWidth - (cols - 1) * 14) / cols;
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final k in items)
              SizedBox(
                width: w,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _A.border)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(k.label, style: t.labelMedium)),
                          IconTile(
                              icon: k.icon,
                              color: k.color,
                              size: 32,
                              iconSize: 18,
                              radius: 8),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(k.value, style: t.headlineSmall),
                      const SizedBox(height: 2),
                      Text(k.sub,
                          style:
                              t.labelSmall?.copyWith(color: AppColors.success)),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child, this.trailing});
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _A.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
                child: Text(title,
                    style: Theme.of(context).textTheme.titleMedium)),
            if (trailing != null) trailing!
          ]),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _TrendBars extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    const data = MockData.monthlyTrend;
    final maxY = data.map((d) => d.$2).reduce((a, b) => a > b ? a : b) * 1.2;
    return BarChart(
      BarChartData(
        maxY: maxY,
        gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: _A.border, strokeWidth: 1)),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.textPrimary,
            getTooltipItem: (g, gi, rod, ri) => BarTooltipItem(
                '${Fmt.compact(rod.toY)} ${ri == 0 ? 'units' : 'kg CO₂'}',
                t.labelMedium!.copyWith(color: Colors.white)),
          ),
        ),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 44,
                  interval: maxY / 4,
                  getTitlesWidget: (v, _) =>
                      Text(Fmt.compact(v), style: t.labelSmall))),
          bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, _) => Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(data[v.toInt()].$1, style: t.labelSmall)))),
        ),
        barGroups: [
          for (var i = 0; i < data.length; i++)
            BarChartGroupData(x: i, barsSpace: 4, barRods: [
              BarChartRodData(
                  toY: data[i].$2,
                  color: AppColors.primary,
                  width: 14,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(4))),
              BarChartRodData(
                  toY: data[i].$3,
                  color: AppColors.secondary,
                  width: 14,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(4))),
            ]),
        ],
      ),
    );
  }
}

class _ThemePie extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    const parts = [
      ('Save energy', 46.0, AppColors.themeEnergy),
      ('Save water', 14.0, AppColors.themeWater),
      ('Say no to plastic', 12.0, AppColors.themePlastic),
      ('Reduce waste', 11.0, AppColors.themeWaste),
      ('Healthy lifestyle', 9.0, AppColors.themeHealthy),
      ('Other', 8.0, AppColors.textTertiary)
    ];
    return Row(
      children: [
        Expanded(
          child: PieChart(PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 42,
            sections: [
              for (final p in parts)
                PieChartSectionData(
                    value: p.$2,
                    color: p.$3,
                    radius: 34,
                    title: '${p.$2.round()}%',
                    titleStyle: t.labelSmall?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w700))
            ],
          )),
        ),
        const SizedBox(width: 12),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final p in parts)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(children: [
                  Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                          color: p.$3, borderRadius: BorderRadius.circular(3))),
                  const SizedBox(width: 8),
                  Text(p.$1, style: t.labelMedium)
                ]),
              ),
          ],
        ),
      ],
    );
  }
}

class _DistrictRow extends StatelessWidget {
  const _DistrictRow({required this.rank, required this.m, required this.frac});
  final int rank;
  final DistrictMetric m;
  final double frac;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Row(
        children: [
          SizedBox(
              width: 36,
              child: Text('$rank',
                  style: t.titleSmall?.copyWith(
                      color: rank <= 3
                          ? AppColors.secondary
                          : AppColors.textSecondary))),
          Expanded(flex: 3, child: Text(m.district, style: t.titleSmall)),
          Expanded(flex: 2, child: Text(Fmt.int(m.users), style: t.bodyMedium)),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Expanded(child: GoalProgressBar(value: frac, height: 8)),
                const SizedBox(width: 10),
                SizedBox(
                    width: 60,
                    child:
                        Text(Fmt.compact(m.unitsSaved), style: t.labelLarge)),
              ],
            ),
          ),
          Expanded(
              flex: 2,
              child: Text((m.co2Kg / 1000).toStringAsFixed(1),
                  style: t.bodyMedium)),
          Expanded(
              flex: 2, child: Text(Fmt.compact(m.tasks), style: t.bodyMedium)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Leads
// ---------------------------------------------------------------------------
class AdminLeadsScreen extends StatefulWidget {
  const AdminLeadsScreen({super.key});

  @override
  State<AdminLeadsScreen> createState() => _AdminLeadsScreenState();
}

class _AdminLeadsScreenState extends State<AdminLeadsScreen> {
  String _status = 'all';
  String _q = '';
  bool _loading = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    if (AppScope.read(context).isLiveBackend) {
=======
    if (AppScope.read(context).useFirebase) {
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
      _loadLeads();
    }
  }

  Future<void> _loadLeads() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      await AppScope.read(context).loadAdminLeads();
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadError = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updateLeadStatus(Lead lead, String status) async {
    try {
      await AppScope.read(context).updateLeadStatus(lead, status);
    } catch (error) {
      if (!mounted) return;
      showAppSnack(
        context,
        'Could not update lead status: $error',
        icon: Icons.error_outline_rounded,
        color: AppColors.error,
      );
    }
  }

  static const statuses = [
    'new',
    'contacted',
    'survey_done',
    'quoted',
    'installed',
    'dropped'
  ];
  static String label(String s) => switch (s) {
        'new' => 'New',
        'contacted' => 'Contacted',
        'survey_done' => 'Survey done',
        'quoted' => 'Quoted',
        'installed' => 'Installed',
        'dropped' => 'Dropped',
        _ => s
      };
  static Color color(String s) => switch (s) {
        'new' => AppColors.tertiary,
        'contacted' => AppColors.warning,
        'survey_done' => AppColors.secondary,
        'quoted' => AppColors.primaryLight,
        'installed' => AppColors.success,
        _ => AppColors.textTertiary
      };

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final t = Theme.of(context).textTheme;
<<<<<<< HEAD
    final all = s.isLiveBackend ? s.adminLeads : MockData.leads;
=======
    final all = s.useFirebase ? s.adminLeads : MockData.leads;
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
    final list = all
        .where((l) =>
            (_status == 'all' || l.status == _status) &&
            (_q.isEmpty ||
                l.userName.toLowerCase().contains(_q) ||
                l.district.toLowerCase().contains(_q)))
        .toList();
    final kwTotal = all.fold<double>(0, (a, b) => a + b.sizeKw);

    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
<<<<<<< HEAD
        if (s.isLiveBackend) ...[
=======
        if (s.useFirebase) ...[
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
          const InfoBanner(
            text:
                'Live survey requests submitted by users. Contact details are restricted to authorised staff.',
            icon: Icons.verified_user_outlined,
          ),
          const SizedBox(height: 12),
          if (_loading) const LinearProgressIndicator(),
          if (_loadError != null)
            InfoBanner(
              text: 'Could not load live requests: $_loadError',
              icon: Icons.error_outline_rounded,
              color: AppColors.error,
            ),
          if (_loadError != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _loadLeads,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
              ),
            ),
        ],
        _KpiGrid(items: [
          _Kpi('Total leads', '${all.length}', 'This month',
              Icons.inbox_outlined, AppColors.primary),
          _Kpi(
              'Pipeline capacity',
              '${kwTotal.toStringAsFixed(1)} kW',
              '≈ ${Fmt.int(kwTotal * 4.2 * 365)} units/yr',
              Icons.solar_power_outlined,
              AppColors.secondary),
          _Kpi(
              'Awaiting contact',
              '${all.where((l) => l.status == 'new').length}',
              'SLA: 2 working days',
              Icons.phone_callback_outlined,
              AppColors.warning),
          _Kpi(
              'Installed',
              '${all.where((l) => l.status == 'installed').length}',
              'Conversion ${all.isEmpty ? 0 : (all.where((l) => l.status == 'installed').length * 100 ~/ all.length)}%',
              Icons.check_circle_outline_rounded,
              AppColors.success),
        ]),
        const SizedBox(height: 20),
        _Panel(
          title: 'Solar lead routing',
          trailing: SizedBox(
            width: 260,
            child: TextField(
              onChanged: (v) => setState(() => _q = v.trim().toLowerCase()),
              decoration: const InputDecoration(
                  hintText: 'Search name or district',
                  prefixIcon: Icon(Icons.search_rounded, size: 20),
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 12)),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                children: [
                  for (final st in ['all', ...statuses])
                    ChoiceChip(
                        label: Text(st == 'all'
                            ? 'All (${all.length})'
                            : '${label(st)} (${all.where((l) => l.status == st).length})'),
                        selected: _status == st,
                        onSelected: (_) => setState(() => _status = st)),
                ],
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 900),
                  child: DataTable(
                    headingTextStyle:
                        t.labelSmall?.copyWith(letterSpacing: 0.6),
                    columns: const [
                      DataColumn(label: Text('LEAD')),
                      DataColumn(label: Text('DISTRICT')),
                      DataColumn(label: Text('SIZE')),
                      DataColumn(label: Text('NET COST')),
                      DataColumn(label: Text('TYPE')),
                      DataColumn(label: Text('VENDOR')),
                      DataColumn(label: Text('AGE')),
                      DataColumn(label: Text('STATUS')),
                      DataColumn(label: Text('')),
                    ],
                    rows: [
                      for (final l in list)
                        DataRow(cells: [
                          DataCell(Row(children: [
                            Avatar(
                                initials: l.userName
                                    .split(' ')
                                    .map((p) => p[0])
                                    .take(2)
                                    .join(),
                                size: 30),
                            const SizedBox(width: 10),
                            Text(l.userName, style: t.labelLarge)
                          ])),
                          DataCell(Text(l.district)),
                          DataCell(Text('${l.sizeKw.toStringAsFixed(1)} kW')),
                          DataCell(Text(Fmt.rupees(l.netCost))),
                          DataCell(Pill(
                              label: l.type == 'quote' ? 'Quote' : 'Survey',
                              color: l.type == 'quote'
                                  ? AppColors.secondarySoft
                                  : AppColors.tertiarySoft,
                              textColor: l.type == 'quote'
                                  ? AppColors.warning
                                  : AppColors.tertiary)),
                          DataCell(Text(l.vendorName ?? '— unassigned',
                              style: TextStyle(
                                  color: l.vendorName == null
                                      ? AppColors.textTertiary
                                      : null))),
                          DataCell(Text(_age(l.createdAt))),
                          DataCell(StatusTag(
                              label: label(l.status),
                              color: color(l.status),
                              dot: true)),
                          DataCell(PopupMenuButton<String>(
                            tooltip: 'Update status',
                            onSelected: (v) {
                              if (v == 'assign') {
                                _assignVendor(context, l);
                              } else {
                                _updateLeadStatus(l, v);
                              }
                            },
                            itemBuilder: (_) => [
<<<<<<< HEAD
                              if (!s.isLiveBackend) ...[
=======
                              if (!s.useFirebase) ...[
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
                                const PopupMenuItem(
                                    value: 'assign',
                                    child: Text('Assign vendor…')),
                                const PopupMenuDivider(),
                              ],
                              for (final st in statuses)
                                PopupMenuItem(
                                    value: st,
                                    child: Text(
                                        'Mark ${label(st).toLowerCase()}')),
                            ],
                            icon: const Icon(Icons.more_horiz_rounded),
                          )),
                        ]),
                    ],
                  ),
                ),
              ),
              if (list.isEmpty)
                const EmptyState(
                    icon: Icons.inbox_outlined,
                    title: 'No leads match',
                    body: 'Try another status or search term',
                    compact: true),
            ],
          ),
        ),
      ],
    );
  }

  String _age(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inHours < 1) return '${diff.inMinutes} min';
    if (diff.inHours < 24) return '${diff.inHours} h';
    return '${diff.inDays} d';
  }

  void _assignVendor(BuildContext context, Lead l) {
    final vendors = MockData.vendors
        .where((v) => v.category == 'solar')
        .toList()
      ..sort((a, b) => (b.districts.contains(l.district) ? 1 : 0)
          .compareTo(a.districts.contains(l.district) ? 1 : 0));
    showDialog<void>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('Assign vendor · ${l.userName}'),
        children: [
          for (final v in vendors)
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(ctx);
                final idx = MockData.leads.indexOf(l);
                final updated = Lead(
                    id: l.id,
                    userName: l.userName,
                    district: l.district,
                    sizeKw: l.sizeKw,
                    netCost: l.netCost,
                    type: l.type,
                    createdAt: l.createdAt,
                    vendorName: v.name,
                    status: l.status == 'new' ? 'contacted' : l.status);
                MockData.leads[idx] = updated;
                AppScope.read(context)
                    .updateLeadStatus(updated, updated.status);
                showAppSnack(context, 'Assigned to ${v.name}',
                    icon: Icons.check_circle_rounded, color: AppColors.primary);
              },
              child: Row(
                children: [
                  Expanded(child: Text(v.name)),
                  if (v.districts.contains(l.district))
                    const StatusTag(
                        label: 'Serves district', color: AppColors.success),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Content (tasks)
// ---------------------------------------------------------------------------
class AdminContentScreen extends StatefulWidget {
  const AdminContentScreen({super.key});

  @override
  State<AdminContentScreen> createState() => _AdminContentScreenState();
}

class _AdminContentScreenState extends State<AdminContentScreen> {
  final Set<String> _disabled = {};
  LifeTheme? _theme;

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    if (AppScope.of(context).isLiveBackend) {
=======
    if (AppScope.of(context).useFirebase) {
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
      return const _LiveAdminUnavailable(
        title: 'Live task and scheme editing is not connected',
        message:
            'This page currently uses bundled demo content. Editing is disabled for Firebase accounts until reviewed publishing and versioned content storage are implemented.',
      );
    }
    final t = Theme.of(context).textTheme;
    final tasks = MockData.tasks
        .where((x) => _theme == null || x.theme == _theme)
        .toList();
    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
        Row(
          children: [
            Expanded(
                child: Text('Task library · ${MockData.tasks.length} tasks',
                    style: t.headlineSmall)),
            FilledButton.icon(
                onPressed: () => _editTask(context, null),
                icon: const Icon(Icons.add_rounded),
                label: const Text('New task'),
                style: FilledButton.styleFrom(minimumSize: const Size(0, 44))),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
                label: const Text('All themes'),
                selected: _theme == null,
                onSelected: (_) => setState(() => _theme = null)),
            for (final th in LifeTheme.values)
              ChoiceChip(
                  avatar: Icon(th.icon, size: 16, color: th.color),
                  label: Text(th.label),
                  selected: _theme == th,
                  onSelected: (_) => setState(() => _theme = th)),
          ],
        ),
        const SizedBox(height: 16),
        _Panel(
          title: 'Tasks',
          child: Column(
            children: [
              for (final task in tasks)
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  leading: IconTile(
                      icon: task.theme.icon,
                      color: task.theme.color,
                      size: 40,
                      iconSize: 20),
                  title: Text(task.title, style: t.titleSmall),
                  subtitle: Wrap(
                    spacing: 6,
                    children: [
                      Text(
                          '${task.points} pts · ${task.difficulty.name} · ${task.verification.label}',
                          style: t.labelSmall),
                      if (task.estUnitsSaved > 0)
                        Text(
                            '· ~${task.estUnitsSaved.toStringAsFixed(1)} units',
                            style: t.labelSmall),
                      if (task.seasonTags.first != 'all')
                        Text('· ${task.seasonTags.join(', ')}',
                            style: t.labelSmall
                                ?.copyWith(color: AppColors.warning)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                          value: !_disabled.contains(task.id),
                          onChanged: (v) => setState(() => v
                              ? _disabled.remove(task.id)
                              : _disabled.add(task.id))),
                      IconButton(
                          onPressed: () => _editTask(context, task),
                          icon: const Icon(Icons.edit_outlined, size: 20)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _Panel(
          title: 'Scheme pages',
          child: Column(
            children: [
              for (final sc in MockData.schemes)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  leading: IconTile(
                      icon: sc.icon,
                      color: AppColors.primary,
                      size: 40,
                      iconSize: 20),
                  title: Text(sc.title, style: t.titleSmall),
                  subtitle:
                      Text(sc.keyNumbers.join(' · '), style: t.labelSmall),
                  trailing: const StatusTag(
                      label: 'Published', color: AppColors.success, dot: true),
                  onTap: () => showAppSnack(
                      context, 'Scheme editor (rich text) — demo',
                      icon: Icons.edit_note_rounded),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _editTask(BuildContext context, TaskItem? task) {
    final title = TextEditingController(text: task?.title ?? '');
    final points = TextEditingController(text: '${task?.points ?? 10}');
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(task == null ? 'New task' : 'Edit task'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(label: 'Title', controller: title),
              const SizedBox(height: 12),
              AppTextField(
                  label: 'Points (5–30)',
                  controller: points,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              const InfoBanner(
                  text:
                      'Changes publish to all citizens after review by a second officer (4-eyes rule).',
                  icon: Icons.verified_outlined),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              showAppSnack(context,
                  task == null ? 'Task submitted for review' : 'Task updated',
                  icon: Icons.check_circle_rounded, color: AppColors.primary);
            },
            style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Campaigns / nudges
// ---------------------------------------------------------------------------
class AdminCampaignsScreen extends StatefulWidget {
  const AdminCampaignsScreen({super.key});

  @override
  State<AdminCampaignsScreen> createState() => _AdminCampaignsScreenState();
}

class _AdminCampaignsScreenState extends State<AdminCampaignsScreen> {
  final _title = TextEditingController(text: 'Peak hours start at 6 pm');
  final _body = TextEditingController(
      text:
          'Run your washing machine & geyser now and save up to 2 units today.');
  String _audience = 'All Gujarat';
  String _trigger = 'Scheduled · 17:30';
  final Set<String> _channels = {'push'};

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  bool _sending = false;

  String get _topic => switch (_audience) {
        'All Gujarat' => 'all_citizens',
        'Ahmedabad' => PushService.topicForDistrict('Ahmedabad'),
        'Surat' => PushService.topicForDistrict('Surat'),
        'Vadodara' => PushService.topicForDistrict('Vadodara'),
        'Rajkot' => PushService.topicForDistrict('Rajkot'),
        _ => 'all_citizens',
      };

  Future<void> _send({bool test = false}) async {
    final s = AppScope.read(context);
<<<<<<< HEAD
    if (!s.isLiveBackend) {
=======
    if (!s.useFirebase) {
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
      showAppSnack(
          context,
          test
              ? 'Test sent to your device (demo)'
              : 'Nudge scheduled for ~${_audienceSize()} citizens (demo)',
          icon: Icons.send_rounded,
          color: AppColors.primary);
      return;
    }
    if (_title.text.trim().isEmpty || _body.text.trim().isEmpty) {
      showAppSnack(context, 'Title and message are required',
          icon: Icons.error_outline_rounded, color: AppColors.error);
      return;
    }
<<<<<<< HEAD
    if (s.useSupabase) {
      showAppSnack(
          context,
          'Push campaigns run on Firebase Cloud Messaging in this build. '
          'See README_SUPABASE.md → "Push notifications" for the Supabase '
          'equivalent. Nothing was sent.',
          icon: Icons.info_outline_rounded,
          color: AppColors.warning);
      return;
    }
=======
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
    setState(() => _sending = true);
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'asia-south1')
          .httpsCallable('sendCampaign');
      await callable.call<Map<String, dynamic>>({
        'title': _title.text.trim(),
        'body': _body.text.trim(),
        'topic': _topic,
        'route': '/home',
        if (test) 'testUid': s.user!.uid,
      });
      if (!mounted) return;
      showAppSnack(
          context,
          test
              ? 'Test push sent to your device'
              : 'Campaign sent to topic $_topic',
          icon: Icons.check_circle_outline_rounded,
          color: AppColors.primary);
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      showAppSnack(context, e.message ?? 'Send failed (${e.code})',
          icon: Icons.error_outline_rounded, color: AppColors.error);
    } catch (e) {
      if (!mounted) return;
      showAppSnack(context, 'Send failed: $e',
          icon: Icons.error_outline_rounded, color: AppColors.error);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final live = AppScope.of(context).isLiveBackend;
=======
    final live = AppScope.of(context).useFirebase;
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
    final t = Theme.of(context).textTheme;
    final composer = _Panel(
      title: 'Compose nudge',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
              label: 'Title',
              controller: _title,
              maxLength: 40,
              onChanged: (_) => setState(() {})),
          const SizedBox(height: 12),
          AppTextField(
              label: 'Message',
              controller: _body,
              maxLength: 120,
              onChanged: (_) => setState(() {})),
          const SizedBox(height: 12),
          Text('Audience', style: t.titleSmall),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            for (final a in live
                ? const [
                    'All Gujarat',
                    'Ahmedabad',
                    'Surat',
                    'Vadodara',
                    'Rajkot',
                  ]
                : const [
                    'All Gujarat',
                    'Ahmedabad',
                    'Surat',
                    'AC owners',
                    'Society captains',
                    'Inactive 7 days'
                  ])
              ChoiceChip(
                  label: Text(a),
                  selected: _audience == a,
                  onSelected: (_) => setState(() => _audience = a))
          ]),
          const SizedBox(height: 12),
          Text('Trigger', style: t.titleSmall),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            for (final a in [
              'Send now',
              'Scheduled · 17:30',
              'Heatwave ≥ 40°C',
              'Goal ≥ 60%'
            ])
              ChoiceChip(
                  label: Text(a),
                  selected: _trigger == a,
                  onSelected: (_) => setState(() => _trigger = a))
          ]),
          const SizedBox(height: 12),
          Text('Channels', style: t.titleSmall),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            for (final (id, l) in [
              ('push', 'Push'),
              ('inapp', 'In-app card'),
              ('sms', 'SMS (opt-in)')
            ])
              FilterChip(
                  label: Text(l),
                  selected: _channels.contains(id),
                  onSelected: (v) => setState(
                      () => v ? _channels.add(id) : _channels.remove(id)))
          ]),
          const SizedBox(height: 16),
          const InfoBanner(
              text:
                  'Guardrails: max 2 nudges/user/day · quiet hours 22:00–07:00 · Gujarati auto-translation reviewed before send.',
              icon: Icons.shield_outlined),
          const SizedBox(height: 16),
          Row(
            children: [
              FilledButton.icon(
                onPressed: _sending ? null : () => _send(),
                icon: _sending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send_rounded, size: 18),
                label: Text(live ? 'Send push now' : 'Schedule nudge'),
                style: FilledButton.styleFrom(minimumSize: const Size(0, 46)),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                  onPressed: _sending ? null : () => _send(test: true),
                  child: const Text('Send test to me')),
            ],
          ),
        ],
      ),
    );

    final preview = _Panel(
      title: 'Preview · ${Fmt.int(_audienceSize())} recipients',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _A.border)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const IconTile(
                    icon: Icons.eco_rounded,
                    color: AppColors.primary,
                    size: 36,
                    iconSize: 18,
                    radius: 10),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text('LiFE Mitra', style: t.labelSmall),
                        const Spacer(),
                        Text('now', style: t.labelSmall)
                      ]),
                      Text(_title.text.isEmpty ? 'Title' : _title.text,
                          style: t.titleSmall),
                      Text(_body.text.isEmpty ? 'Message' : _body.text,
                          style: t.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Align(
              alignment: Alignment.centerLeft,
              child: Text('Recent campaigns', style: t.titleSmall)),
          const SizedBox(height: 6),
          for (final (name, sent, ctr, status) in const [
            ('Peak-shift · daily 17:30', '48,210', '31%', 'Running'),
            ('Diwali LED swap', '21,400', '18%', 'Scheduled'),
            ('Heatwave AC 24°C', '12,860', '27%', 'Ended'),
            ('Society goal push', '6,120', '22%', 'Ended'),
          ])
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(name, style: t.labelLarge),
              subtitle: Text('$sent sent · $ctr acted', style: t.labelSmall),
              trailing: StatusTag(
                  label: status,
                  color: status == 'Running'
                      ? AppColors.success
                      : status == 'Scheduled'
                          ? AppColors.tertiary
                          : AppColors.textTertiary,
                  dot: true),
            ),
        ],
      ),
    );

    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
        LayoutBuilder(
          builder: (context, c) => c.maxWidth > 900
              ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(flex: 3, child: composer),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: preview)
                ])
              : Column(
                  children: [composer, const SizedBox(height: 16), preview]),
        ),
      ],
    );
  }

  int _audienceSize() => switch (_audience) {
        'Ahmedabad' => 4820,
        'Surat' => 3610,
        'AC owners' => 9140,
        'Society captains' => 312,
        'Inactive 7 days' => 2260,
        _ => 19340,
      };
}
