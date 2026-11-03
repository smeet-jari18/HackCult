import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/v3.dart';
import '../../core/widgets/widgets.dart';
import '../../data/app_state.dart';

// ---------------------------------------------------------------------------
// Validators (shared with admin login)
// ---------------------------------------------------------------------------
class Validators {
  Validators._();
  static final _email = RegExp(r'^[\w\.\-+]+@[\w\-]+(\.[\w\-]+)+$');

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    if (!_email.hasMatch(v.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Use at least 8 characters';
    if (!RegExp(r'[A-Za-z]').hasMatch(v) || !RegExp(r'\d').hasMatch(v)) {
      return 'Include a letter and a number';
    }
    return null;
  }

  static String? name(String? v) {
    if (v == null || v.trim().length < 2) return 'Enter your full name';
    return null;
  }

  static int strength(String v) {
    var s = 0;
    if (v.length >= 8) s++;
    if (RegExp(r'[A-Za-z]').hasMatch(v) && RegExp(r'\d').hasMatch(v)) s++;
    if (v.length >= 12 || RegExp(r'[^A-Za-z0-9]').hasMatch(v)) s++;
    return s;
  }
}

/// Which portal the person wants to enter from the login form.
enum LoginRole { citizen, admin }

// ---------------------------------------------------------------------------
// Splash
// ---------------------------------------------------------------------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      final s = AppScope.read(context);
      if (!s.isSignedIn) {
        context.go('/login');
      } else if (!s.user!.onboardingComplete) {
        context.go('/onboarding/1');
      } else {
        context.go(s.user!.isAdmin ? '/admin' : '/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      body: MistBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              children: [
                // top strip
                Row(
                  children: [
                    Image.asset('assets/images/emblem.png',
                        width: 22, height: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('MISSION LIFE',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.labelMedium?.copyWith(
                              color: AppColors.textSecondary,
                              letterSpacing: 1.2)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: AppShadows.level1),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                  color: AppColors.primaryLight,
                                  shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text('Gujarat Node',
                              style: t.labelMedium
                                  ?.copyWith(color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                  ],
                ),
                // centre block
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 180,
                          height: 180,
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: AppShadows.level2,
                          ),
                          child: Image.asset('assets/images/emblem.png',
                              filterQuality: FilterQuality.high),
                        ),
                        const SizedBox(height: 28),
                        Text('LiFE Mitra Gujarat',
                            style: t.headlineMedium
                                ?.copyWith(color: AppColors.primary)),
                        const SizedBox(height: 6),
                        Text('SMALL HABITS  •  BIG IMPACT',
                            style: t.labelMedium?.copyWith(
                                color: AppColors.textSecondary,
                                letterSpacing: 1.6)),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 9),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: AppShadows.level1),
                          child: Text('Climate Action for Citizens',
                              style: t.labelLarge
                                  ?.copyWith(color: AppColors.textPrimary)),
                        ),
                      ],
                    ),
                  ),
                ),
                // bottom status
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: AppColors.primaryLight,
                            shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text('Connecting to GEDA Green Telemetry…',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.bodySmall
                              ?.copyWith(color: AppColors.textSecondary)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const CapsuleBar(value: 0.6, height: 3),
                const SizedBox(height: 14),
                Text('Government of Gujarat  •  GEDA  •  v2.5 Civic Secure',
                    textAlign: TextAlign.center,
                    style: t.labelSmall?.copyWith(
                        color: AppColors.textTertiary, letterSpacing: 0.2)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared auth page frame: mist canvas, brand strip, logo tile, white card
// ---------------------------------------------------------------------------
class _AuthPage extends StatelessWidget {
  const _AuthPage({
    required this.form,
    required this.title,
    required this.subtitle,
    this.showBack = false,
    this.badge = 'Secure Portal',
    this.below,
  });
  final Widget form;
  final String title;
  final String subtitle;
  final bool showBack;
  final String badge;
  final Widget? below;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PhoneFrame(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
                20, 12, 20, 24 + MediaQuery.viewInsetsOf(context).bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ---- brand strip ------------------------------------------
                Row(
                  children: [
                    if (showBack) ...[
                      const DecoratedBox(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: AppShadows.level1),
                        child: SafeBackButton(fallback: '/login'),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                            color: AppColors.tint,
                            borderRadius: BorderRadius.circular(999)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/emblem.png',
                                width: 16, height: 16),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text('LiFE Mission • Gujarat',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: t.labelMedium
                                      ?.copyWith(color: AppColors.primary)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Row(
                      children: [
                        Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                                color: AppColors.primaryLight,
                                shape: BoxShape.circle)),
                        const SizedBox(width: 5),
                        Text(badge,
                            style: t.labelMedium
                                ?.copyWith(color: AppColors.primary)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                // ---- logo tile + headline ----------------------------------
                Center(
                  child: Container(
                    width: 84,
                    height: 84,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: AppShadows.level2),
                    child: Image.asset('assets/images/emblem.png'),
                  ),
                ),
                const SizedBox(height: 18),
                Text(title,
                    textAlign: TextAlign.center,
                    style: t.headlineMedium?.copyWith(
                        color: AppColors.primary, fontSize: 26)),
                const SizedBox(height: 6),
                Text(subtitle,
                    textAlign: TextAlign.center,
                    style: t.bodyMedium
                        ?.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 22),
                AppCard(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                    child: form),
                if (below != null) ...[const SizedBox(height: 20), below!],
                const SizedBox(height: 26),
                const _LegalFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LegalFooter extends StatelessWidget {
  const _LegalFooter();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final link = t.labelMedium?.copyWith(
        color: AppColors.textSecondary,
        decoration: TextDecoration.underline);
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 4,
          children: [
            const Icon(Icons.verified_user_outlined,
                size: 14, color: AppColors.textSecondary),
            Text('Protected by DPDP Act 2023  •',
                style: t.labelMedium
                    ?.copyWith(color: AppColors.textSecondary)),
            InkWell(
                onTap: () => context.push('/legal/privacy'),
                child: Text('Privacy Policy', style: link)),
            Text('•',
                style: t.labelMedium
                    ?.copyWith(color: AppColors.textSecondary)),
            InkWell(
                onTap: () => context.push('/legal/terms'),
                child: Text('Terms of Service', style: link)),
          ],
        ),
        const SizedBox(height: 8),
        Text('CLIMATE ACTION TELEMETRY  •  GEDA, GANDHINAGAR',
            textAlign: TextAlign.center,
            style: t.labelSmall?.copyWith(
                color: AppColors.textTertiary, letterSpacing: 0.8)),
      ],
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider({this.label = 'OR CONTINUE WITH'});
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label,
              style: t.labelSmall?.copyWith(
                  color: AppColors.textTertiary, letterSpacing: 1)),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

/// Eye toggle used as a password suffix.
class _EyeButton extends StatelessWidget {
  const _EyeButton({required this.shown, required this.onTap});
  final bool shown;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: shown ? 'Hide password' : 'Show password',
      onPressed: onTap,
      icon: Icon(
          shown ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20,
          color: AppColors.textSecondary),
    );
  }
}

// ---------------------------------------------------------------------------
// Login
// ---------------------------------------------------------------------------

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _show = false;
  bool _loading = false;
  bool _googleLoading = false;
  String? _error;
  bool _remember = true;
  LoginRole _role = LoginRole.citizen;

  bool get _admin => _role == LoginRole.admin;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    final s = AppScope.read(context);
    final err = await s.signInWithEmail(_email.text, _password.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    _route();
  }

  Future<void> _google() async {
    setState(() {
      _googleLoading = true;
      _error = null;
    });
    final s = AppScope.read(context);
    final err = await s.signInWithGoogle(adminPortal: _admin);
    if (!mounted) return;
    setState(() => _googleLoading = false);
    if (err != null) {
      if (err != AppState.googleCancelled) {
        setState(() => _error = err);
      }
      return;
    }
    _route();
  }

  void _route() {
    final s = AppScope.read(context);
    final u = s.user!;
    if (_admin && !u.isAdmin) {
      // Signed in fine, but this account has no GEDA admin role.
      s.signOut();
      setState(() => _error =
          'This account is not a GEDA admin. Select "Citizen" to continue.');
      return;
    }
    if (u.isAdmin) {
      context.go('/admin');
    } else if (!u.onboardingComplete) {
      context.go('/onboarding/1');
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final s = AppScope.of(context);
    return _AuthPage(
      title: 'Welcome back',
      subtitle: 'Sign in to continue your LiFE journey',
      form: Form(
        key: _form,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_error != null) ...[
                InfoBanner(
                    text: _error!,
                    icon: Icons.error_outline_rounded,
                    color: AppColors.error),
                const SizedBox(height: 14),
              ],
              SegmentedChoice<LoginRole>(
                value: _role,
                height: 42,
                onChanged: (v) => setState(() {
                  _role = v;
                  _error = null;
                }),
                options: const [
                  (LoginRole.citizen, 'Citizen'),
                  (LoginRole.admin, 'Admin (GEDA)'),
                ],
              ),
              const SizedBox(height: 18),
              AppTextField(
                label: 'Email address',
                controller: _email,
                hint: _admin
                    ? 'officer@geda.gujarat.gov.in'
                    : 'citizen.ahmedabad@gujarat.gov.in',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Password',
                controller: _password,
                hint: '••••••••••••',
                prefixIcon: Icons.lock_outline_rounded,
                obscure: !_show,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Password is required' : null,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                suffix: _EyeButton(
                    shown: _show,
                    onTap: () => setState(() => _show = !_show)),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: Checkbox(
                      value: _remember,
                      onChanged: (v) =>
                          setState(() => _remember = v ?? true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Remember me',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.bodyMedium),
                  ),
                  InkWell(
                    onTap: () => context.push('/forgot'),
                    child: Text('Forgot password?',
                        maxLines: 1,
                        style: t.labelLarge
                            ?.copyWith(color: AppColors.primaryLight)),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              PrimaryButton(
                  label: 'Sign In',
                  trailingIcon: Icons.arrow_forward_rounded,
                  onPressed: _submit,
                  loading: _loading),
              const SizedBox(height: 18),
              const _OrDivider(),
              const SizedBox(height: 16),
              GoogleButton(
                onPressed: _google,
                loading: _googleLoading,
                label: _admin
                    ? 'Continue with GEDA Google account'
                    : 'Continue with Google',
              ),
              if (_admin) ...[
                const SizedBox(height: 12),
                Text('Authorised GEDA personnel only. Citizens: select Citizen.',
                    textAlign: TextAlign.center,
                    style: t.bodySmall
                        ?.copyWith(color: AppColors.textSecondary)),
              ],
              if (!s.useFirebase) ...[
                const SizedBox(height: 12),
                Text(
                    'Demo: nisha@demo.com / Demo@1234 · admin@geda.demo / Admin@1234',
                    style: t.bodySmall?.copyWith(color: AppColors.textTertiary),
                    textAlign: TextAlign.center),
              ],
            ],
          ),
        ),
      ),
      below: _admin
          ? null
          : Center(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('New to LiFE Mitra?  ',
                      style: t.bodyMedium
                          ?.copyWith(color: AppColors.textSecondary)),
                  InkWell(
                    onTap: () => context.push('/signup'),
                    child: Text('Create account',
                        style:
                            t.labelLarge?.copyWith(color: AppColors.primary)),
                  ),
                ],
              ),
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sign up
// ---------------------------------------------------------------------------


// ---------------------------------------------------------------------------
// Sign up
// ---------------------------------------------------------------------------
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _show = false;
  bool _consent = false;
  bool _consentError = false;
  bool _loading = false;
  bool _googleLoading = false;
  int _strength = 0;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _openPrivacy() async {
    final agreed = await showPrivacyConsentSheet(context);
    if (agreed == true && mounted) {
      setState(() {
        _consent = true;
        _consentError = false;
      });
    }
  }

  Future<void> _submit() async {
    final valid = _form.currentState!.validate();
    if (!_consent) {
      setState(() => _consentError = true);
      if (valid) await _openPrivacy();
      if (!_consent) return;
    }
    if (!valid) return;
    setState(() => _loading = true);
    final err = await AppScope.read(context).signUpWithEmail(
        name: _name.text, email: _email.text, password: _password.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (err == 'email-already-in-use') {
      showAppSnack(context, 'Account exists with this email',
          icon: Icons.info_outline_rounded,
          actionLabel: 'Login',
          onAction: () => context.go('/login'));
      return;
    }
    if (err != null) {
      showAppSnack(context, err, icon: Icons.error_outline_rounded);
      return;
    }
    final u = AppScope.read(context).user!;
    context.go(u.isAdmin ? '/admin' : '/onboarding/1');
  }

  Future<void> _google() async {
    setState(() => _googleLoading = true);
    final err = await AppScope.read(context).signInWithGoogle();
    if (!mounted) return;
    setState(() => _googleLoading = false);
    if (err != null) {
      if (err != AppState.googleCancelled) {
        showAppSnack(context, err, icon: Icons.error_outline_rounded);
      }
      return;
    }
    final u = AppScope.read(context).user!;
    context.go(u.onboardingComplete ? '/home' : '/onboarding/1');
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return _AuthPage(
      title: 'Create your account',
      subtitle: "Join Gujarat's Mission LiFE clean energy movement",
      badge: 'Secure Onboarding',
      showBack: true,
      form: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
                label: 'Full Name',
                controller: _name,
                hint: 'Nisha Patel',
                prefixIcon: Icons.person_outline_rounded,
                validator: Validators.name,
                textInputAction: TextInputAction.next),
            const SizedBox(height: 14),
            AppTextField(
                label: 'Email address',
                controller: _email,
                hint: 'citizen@gujarat.gov.in',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
                textInputAction: TextInputAction.next),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Create password',
              controller: _password,
              hint: 'At least 8 characters',
              prefixIcon: Icons.lock_outline_rounded,
              obscure: !_show,
              validator: Validators.password,
              onChanged: (v) =>
                  setState(() => _strength = Validators.strength(v)),
              textInputAction: TextInputAction.next,
              suffix: _EyeButton(
                  shown: _show, onTap: () => setState(() => _show = !_show)),
            ),
            if (_strength > 0) ...[
              const SizedBox(height: 8),
              _StrengthMeter(strength: _strength),
            ],
            const SizedBox(height: 14),
            AppTextField(
              label: 'Confirm password',
              controller: _confirm,
              hint: 'Re-enter password',
              prefixIcon: Icons.lock_reset_rounded,
              obscure: !_show,
              validator: (v) =>
                  v != _password.text ? 'Passwords do not match' : null,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 12),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => setState(() {
                _consent = !_consent;
                _consentError = false;
              }),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _consent,
                        isError: _consentError,
                        onChanged: (v) => setState(() {
                          _consent = v ?? false;
                          _consentError = false;
                        }),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          style: t.bodySmall?.copyWith(
                              color: _consentError
                                  ? AppColors.error
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              height: 1.4),
                          children: [
                            const TextSpan(text: 'I agree to Mission LiFE '),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.baseline,
                              baseline: TextBaseline.alphabetic,
                              child: InkWell(
                                onTap: _openPrivacy,
                                child: Text('Community Guidelines',
                                    style: t.bodySmall?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                        decoration:
                                            TextDecoration.underline)),
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.baseline,
                              baseline: TextBaseline.alphabetic,
                              child: InkWell(
                                onTap: () => context.push('/legal/privacy'),
                                child: Text('DPDP Act 2023 data usage policy',
                                    style: t.bodySmall?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                        decoration:
                                            TextDecoration.underline)),
                              ),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_consentError)
              const HelperText('Please accept to continue',
                  color: AppColors.error),
            const SizedBox(height: 18),
            PrimaryButton(
                label: 'Create Account',
                trailingIcon: Icons.arrow_forward_rounded,
                onPressed: _submit,
                loading: _loading),
            const SizedBox(height: 18),
            const _OrDivider(label: 'OR REGISTER WITH'),
            const SizedBox(height: 16),
            GoogleButton(
                onPressed: _google,
                loading: _googleLoading,
                label: 'Sign up with Google'),
          ],
        ),
      ),
      below: Center(
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('Already have an account?  ',
                style:
                    t.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            InkWell(
              onTap: () => context.safePop('/login'),
              child: Text('Sign in',
                  style: t.labelLarge?.copyWith(color: AppColors.primary)),
            ),
          ],
        ),
      ),
    );
  }
}


class _StrengthMeter extends StatelessWidget {
  const _StrengthMeter({required this.strength});
  final int strength;

  @override
  Widget build(BuildContext context) {
    final colors = [AppColors.error, AppColors.warning, AppColors.success];
    final labels = ['Too short', 'Weak', 'Good', 'Strong'];
    return Row(
      children: [
        for (var i = 0; i < 3; i++) ...[
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 4,
              decoration: BoxDecoration(
                color: i < strength
                    ? colors[strength - 1]
                    : AppColors.tintStrong,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (i < 2) const SizedBox(width: 4),
        ],
        const SizedBox(width: 10),
        Text(labels[strength], style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Privacy / DPDP consent sheet
// ---------------------------------------------------------------------------
Future<bool?> showPrivacyConsentSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x991F2A24),
    builder: (ctx) => const _PrivacyConsentSheet(),
  );
}

class _PrivacyConsentSheet extends StatefulWidget {
  const _PrivacyConsentSheet();

  @override
  State<_PrivacyConsentSheet> createState() => _PrivacyConsentSheetState();
}

class _PrivacyConsentSheetState extends State<_PrivacyConsentSheet> {
  bool _agree = false;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final maxH = MediaQuery.sizeOf(context).height * 0.88;
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        constraints: BoxConstraints(maxHeight: maxH),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                              color: AppColors.tint, shape: BoxShape.circle),
                          child: const Icon(Icons.policy_outlined,
                              color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Data privacy & consent',
                                  style: t.titleLarge),
                              Text('GEDA · Mission LiFE Gujarat',
                                  style: t.bodySmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                        'Your household electricity consumption, solar PV generation, and civic action logs are used strictly for:',
                        style: t.bodyMedium),
                    const SizedBox(height: 12),
                    const _ConsentPoint(
                        icon: Icons.co2_rounded,
                        title: '1. Carbon Evaluation:',
                        text:
                            'Baseline footprint evaluation and LiFE sustainability tier calculation.'),
                    const _ConsentPoint(
                        icon: Icons.bolt_outlined,
                        title: '2. DISCOM Integration:',
                        text:
                            'Smart meter validation with state utilities (UGVCL, DGVCL, MGVCL, PGVCL, Torrent).'),
                    const _ConsentPoint(
                        icon: Icons.solar_power_outlined,
                        title: '3. Solar Subsidy Routing:',
                        text:
                            'Sharing your estimate and district with GEDA-empanelled vendors only when you request a survey.'),
                    const _ConsentPoint(
                        icon: Icons.bar_chart_rounded,
                        title: '4. Programme Reporting:',
                        text:
                            'Anonymised, district-level aggregates for Mission LiFE progress dashboards.'),
                    const SizedBox(height: 8),
                    Text(
                        'We never sell personal data. You can export or delete your account data from Profile at any time.',
                        style: t.bodySmall),
                    const SizedBox(height: 16),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => setState(() => _agree = !_agree),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                                value: _agree,
                                onChanged: (v) =>
                                    setState(() => _agree = v ?? false)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: t.bodyMedium,
                                children: const [
                                  TextSpan(text: 'I have read and agree to the '),
                                  TextSpan(
                                      text: 'GEDA Data Privacy Policy',
                                      style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                          decoration:
                                              TextDecoration.underline)),
                                  TextSpan(text: ' and '),
                                  TextSpan(
                                      text: 'Terms of Use',
                                      style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                          decoration:
                                              TextDecoration.underline)),
                                  TextSpan(text: '.'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PrimaryButton(
                      label: 'Agree & Continue',
                      trailingIcon: Icons.arrow_forward_rounded,
                      onPressed:
                          _agree ? () => Navigator.pop(context, true) : null,
                      height: 48),
                  const SizedBox(height: 4),
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSecondary),
                      child: const Text('Cancel / Decline')),
                  Row(
                    children: [
                      const Icon(Icons.lock_outline_rounded,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                            'Digital Personal Data Protection (DPDP) Act 2023 Compliant',
                            style: t.bodySmall),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsentPoint extends StatelessWidget {
  const _ConsentPoint(
      {required this.icon, required this.title, required this.text});
  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: t.bodyMedium?.copyWith(color: AppColors.textSecondary),
                children: [
                  TextSpan(
                      text: '$title ',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  TextSpan(text: text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Forgot password
// ---------------------------------------------------------------------------
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    final err = await AppScope.read(context).sendPasswordReset(_email.text);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _sent = err == null;
    });
    if (err != null) {
      showAppSnack(context, err, icon: Icons.error_outline_rounded);
    }
  }

  String get _masked {
    final e = _email.text.trim();
    final at = e.indexOf('@');
    if (at <= 1) return e;
    return '${e[0]}***${e.substring(at)}';
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return _AuthPage(
      title: 'Forgot password?',
      subtitle: 'Enter your registered email to receive a secure reset link',
      badge: 'HELP',
      showBack: true,
      form: _sent
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: IconBubble(Icons.mark_email_read_outlined,
                      size: 64, color: AppColors.primaryLight, circle: true),
                ),
                const SizedBox(height: 16),
                Text('Check your inbox',
                    textAlign: TextAlign.center, style: t.headlineSmall),
                const SizedBox(height: 6),
                Text(
                    'A password reset link was sent to $_masked. The link is '
                    'valid for 1 hour.',
                    textAlign: TextAlign.center,
                    style: t.bodyMedium
                        ?.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 20),
                PrimaryButton(
                    label: 'Back to Sign in',
                    icon: Icons.arrow_back_rounded,
                    onPressed: () => context.safePop('/login')),
                const SizedBox(height: 10),
                TextButton(
                    onPressed: () => setState(() => _sent = false),
                    child: const Text('Resend link')),
              ],
            )
          : Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    label: 'Registered Email',
                    labelTrailing: Text('GEDA DISCOM Linked',
                        style: t.labelMedium
                            ?.copyWith(color: AppColors.primaryLight)),
                    controller: _email,
                    hint: 'citizen.ahmedabad@gujarat.gov.in',
                    prefixIcon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 16),
                  const Callout(
                    icon: Icons.verified_user_outlined,
                    text:
                        'A secure reset link will be dispatched to the email '
                        'linked with your citizen profile. No OTP or phone '
                        'number is needed.',
                  ),
                  const SizedBox(height: 18),
                  PrimaryButton(
                      label: 'Send Reset Link',
                      trailingIcon: Icons.arrow_forward_rounded,
                      onPressed: _send,
                      loading: _loading),
                ],
              ),
            ),
      below: Center(
        child: InkWell(
          onTap: () => context.safePop('/login'),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.arrow_back_rounded,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text('Back to Sign in',
                  style: t.labelLarge?.copyWith(color: AppColors.primary)),
            ],
          ),
        ),
      ),
    );
  }
}
