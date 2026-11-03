import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/logic/calculators.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/v3.dart';
import '../../core/services/links.dart';
import '../../core/services/notification_service.dart';
import '../../core/widgets/widgets.dart';
import '../../data/app_state.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';

Future<void> _updateProfileWithFeedback(
  BuildContext context,
  AppState state,
  void Function(AppUser) edit,
) async {
  try {
    await state.updateProfile(edit);
  } catch (error) {
    if (!context.mounted) return;
    showAppSnack(
      context,
      'Could not save your changes: $error',
      icon: Icons.error_outline_rounded,
      color: AppColors.error,
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final t = Theme.of(context).textTheme;
    final u = s.user!;
    final level = LevelEngine.levelFor(u.points);
    final next = LevelEngine.nextLevel(u.points);
    final levelIndex =
        LevelEngine.levels.indexWhere((l) => l.$1 == level.$1) + 1;
    final tierProgress = next == null
        ? 1.0
        : ((u.points - level.$3) / (next.$3 - level.$3)).clamp(0.0, 1.0);
    final gas = s.gas;
    final solar = s.assessments.firstOrNull;
    final discom = _discomFor(u.district);
    final citizenId = Fmt.consumerId(u.uid);
    final tasksDone = s.ledger.where((e) => e.delta > 0).length;
    final co2Kg = s.totalCo2Saved;
    final rupees = s.totalRupeesSaved;
    final months = s.footprints.length;

    return Scaffold(
      appBar: const BrandAppBar(subtitle: '', showAvatar: false),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          // ---- Identity card -------------------------------------------
          AppCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Avatar(
                            initials: u.initials,
                            size: 72,
                            photoUrl: u.photoUrl),
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2)),
                            child: const Icon(Icons.check_rounded,
                                size: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(u.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: t.headlineSmall),
                          const SizedBox(height: 2),
                          Text('ID: $citizenId', style: t.bodySmall),
                          const SizedBox(height: 8),
                          SoftChip(
                              u.authProvider == AuthProvider.google
                                  ? 'Google verified citizen'
                                  : 'GEDA Verified Citizen',
                              color: AppColors.primaryLight,
                              dense: true),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Edit profile',
                      onPressed: () => context.push('/profile/edit'),
                      icon: const Icon(Icons.edit_outlined,
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    SoftChip('Level $levelIndex: ${level.$2}',
                        icon: Icons.park_rounded,
                        color: AppColors.primary,
                        dense: true),
                    SoftChip('${u.streak}-day streak',
                        icon: Icons.local_fire_department_rounded,
                        color: AppColors.warning,
                        dense: true),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(children: [
                          TextSpan(
                              text: Fmt.int(u.points),
                              style: t.titleMedium),
                          TextSpan(
                              text: next == null
                                  ? ' Green Credits'
                                  : ' / ${Fmt.int(next.$3)} Green Credits',
                              style: t.bodySmall),
                        ]),
                      ),
                    ),
                    Flexible(
                      child: Text(
                          next == null
                              ? 'Top tier reached'
                              : '+${Fmt.int(next.$3 - u.points)} pts to ${next.$2}',
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.labelMedium
                              ?.copyWith(color: AppColors.primaryLight)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CapsuleBar(value: tierProgress, height: 8),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ---- Stat tiles ----------------------------------------------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: MetricTile(
                  label: 'CO₂ offset',
                  value: Fmt.int(co2Kg),
                  unit: 'kg',
                  icon: Icons.eco_outlined,
                  foot: months > 1 ? 'Lifetime' : 'This month',
                  footIcon: Icons.arrow_upward_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MetricTile(
                  label: 'Bill saved',
                  value: Fmt.rupees(rupees),
                  icon: Icons.savings_outlined,
                  iconColor: AppColors.warning,
                  foot: months > 0
                      ? 'Avg ${Fmt.rupees(rupees / months)}/mo'
                      : 'Add a bill',
                  footColor: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MetricTile(
                  label: 'LiFE tasks',
                  value: '$tasksDone',
                  unit: 'Done',
                  icon: Icons.check_circle_outline_rounded,
                  foot: '${s.tasksDoneToday} today',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ---- App settings --------------------------------------------
          const GroupLabel('App settings & telemetry'),
          GroupCard(children: [
            SettingsRow(
              icon: Icons.sync_rounded,
              title: 'Smart Meter Live Sync',
              subtitle: '$discom consumer ${citizenId.split('-')[1]}',
              chevron: false,
              trailing: Switch(
                  value: u.peakNudge,
                  onChanged: (v) => _updateProfileWithFeedback(
                      context, s, (x) => x.peakNudge = v)),
            ),
            SettingsRow(
              icon: Icons.notifications_active_outlined,
              title: 'Push Notifications',
              subtitle: 'Peak hour nudges, streak alerts',
              chevron: false,
              trailing: Switch(
                  value: u.streakReminders,
                  onChanged: (v) => _updateProfileWithFeedback(
                      context, s, (x) => x.streakReminders = v)),
              onTap: () => context.push('/profile/notifications'),
            ),
            SettingsRow(
              icon: Icons.translate_rounded,
              title: 'App Language',
              subtitle: u.language == 'gu' ? 'ગુજરાતી' : 'English (Default)',
              trailing: Text('Change',
                  style: t.labelLarge?.copyWith(color: AppColors.primary)),
              onTap: () => _languageSheet(context, s),
            ),
          ]),
          const SizedBox(height: 20),

          // ---- Utilities -----------------------------------------------
          const GroupLabel('Utilities & linked accounts'),
          GroupCard(children: [
            SettingsRow(
              icon: Icons.bolt_rounded,
              title: 'Electricity ($discom Smart Meter)',
              subtitle: u.baselineUnits > 0 ? 'Linked (Active)' : 'Add your bill',
              subtitleColor:
                  u.baselineUnits > 0 ? AppColors.primaryLight : null,
              onTap: () => context.push('/impact/add-month'),
            ),
            SettingsRow(
              icon: Icons.local_fire_department_outlined,
              title: gas == null
                  ? 'Cooking Gas (PNG / LPG)'
                  : 'Cooking Gas (${gas.provider})',
              subtitle: gas == null ? 'Not linked · tap to connect' : '1 meter linked',
              onTap: () => context.push('/home/gas'),
            ),
            SettingsRow(
              icon: Icons.solar_power_outlined,
              title: 'Solar Rooftop Telemetry',
              subtitle: solar == null
                  ? 'Run the solar calculator'
                  : '${solar.sizeKw.toStringAsFixed(1)} kW setup (estimate)',
              iconColor: AppColors.warning,
              onTap: () => context.push(solar == null
                  ? '/hub/solar'
                  : '/hub/solar/result/${solar.id}'),
            ),
          ]),
          const SizedBox(height: 20),

          // ---- Privacy -------------------------------------------------
          const GroupLabel('Privacy, legal & governance'),
          GroupCard(children: [
            SettingsRow(
              icon: Icons.shield_outlined,
              title: 'Privacy Policy',
              subtitle: 'DPDP Act 2023 compliant',
              subtitleColor: AppColors.primaryLight,
              onTap: () => context.push('/legal/privacy'),
            ),
            SettingsRow(
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              subtitle: 'User agreement v2.4',
              onTap: () => context.push('/legal/terms'),
            ),
            SettingsRow(
              icon: Icons.folder_shared_outlined,
              title: 'Data Export & Consent Management',
              subtitle: 'Manage your citizen telemetry logs',
              onTap: () => _privacySheet(context),
            ),
          ]),
          const SizedBox(height: 20),

          // ---- Support -------------------------------------------------
          const GroupLabel('Support & account'),
          GroupCard(children: [
            SettingsRow(
              icon: Icons.support_agent_rounded,
              title: 'Helpline & Grievance',
              subtitle: 'Toll free 1800-233-0122',
              trailing: const SoftChip('24x7',
                  color: AppColors.primary, dense: true),
              onTap: () => Links.call(context, Links.gedaHelpline),
            ),
            SettingsRow(
              icon: Icons.emoji_events_outlined,
              title: 'Badges & points history',
              subtitle: '${u.badges.length} badges earned',
              onTap: () => context.push('/profile/badges'),
            ),
            SettingsRow(
              icon: Icons.logout_rounded,
              title: 'Sign Out',
              subtitle: citizenId,
              danger: true,
              onTap: () => _confirmSignOut(context, s),
            ),
          ]),
          const SizedBox(height: 28),
          const GedaFooter(
              extra: 'LiFE Mitra mobile build v2.4.1 (State Mission Eco-Grid)'),
        ],
      ),
    );
  }

  void _languageSheet(BuildContext context, AppState s) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (code, label, note) in const [
              ('en', 'English', 'Default'),
              ('gu', 'ગુજરાતી', 'Gujarati · translations in progress'),
            ])
              ListTile(
                leading: Icon(
                    s.user!.language == code
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: AppColors.primary),
                title: Text(label),
                subtitle: Text(note),
                onTap: () {
                  Navigator.pop(ctx);
                  _updateProfileWithFeedback(
                      context, s, (x) => x.language = code);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, AppState s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
            'Your streak is safe — it continues when you sign back in today.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  minimumSize: const Size(0, 40)),
              child: const Text('Sign out')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.go('/login');
      s.signOut();
    }
  }

  static String _discomFor(String district) {
    const south = {'Surat', 'Navsari', 'Valsad', 'Bharuch', 'Narmada', 'Tapi', 'Dang'};
    const west = {'Rajkot', 'Jamnagar', 'Bhavnagar', 'Junagadh', 'Kutch', 'Amreli', 'Porbandar', 'Morbi', 'Surendranagar', 'Botad', 'Gir Somnath', 'Devbhumi Dwarka'};
    const central = {'Vadodara', 'Panchmahal', 'Dahod', 'Chhota Udaipur', 'Mahisagar'};
    if (south.contains(district)) return 'DGVCL';
    if (west.contains(district)) return 'PGVCL';
    if (central.contains(district)) return 'MGVCL';
    return 'UGVCL';
  }

  void _privacySheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
                leading: const Icon(Icons.download_rounded),
                title: const Text('Export my data (JSON)'),
                subtitle: const Text(
                    'Footprint, tasks, points — emailed within 24 h'),
                onTap: () {
                  Navigator.pop(ctx);
                  showAppSnack(context, 'Export requested',
                      icon: Icons.download_rounded);
                }),
            ListTile(
                leading: const Icon(Icons.policy_outlined),
                title: const Text('Privacy policy'),
                subtitle: const Text(
                    'DPDP Act 2023 compliant · data stored in India'),
                onTap: () => Navigator.pop(ctx)),
            ListTile(
                leading: const Icon(Icons.delete_forever_rounded,
                    color: AppColors.error),
                title: const Text('Delete account',
                    style: TextStyle(color: AppColors.error)),
                subtitle:
                    const Text('Removes all personal data within 30 days'),
                onTap: () {
                  Navigator.pop(ctx);
                  showAppSnack(
                      context, 'Deletion flow (confirm by email) — demo',
                      icon: Icons.delete_outline_rounded,
                      color: AppColors.error);
                }),
          ],
        ),
      ),
    );
  }
}

class _LedgerTile extends StatelessWidget {
  const _LedgerTile(this.e);
  final PointsEntry e;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final pos = e.delta >= 0;
    return ListTile(
      dense: true,
      leading: IconTile(
          icon: e.icon ?? Icons.stars_rounded,
          color: pos ? AppColors.primary : AppColors.error,
          size: 38,
          iconSize: 20,
          radius: 10),
      title: Text(e.reason, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(Fmt.dateTime(e.createdAt)),
      trailing: Text('${pos ? '+' : ''}${e.delta}',
          style: t.titleSmall
              ?.copyWith(color: pos ? AppColors.success : AppColors.error)),
    );
  }
}

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final u = AppScope.of(context).user!;
    return Scaffold(
      appBar: AppBar(
          leading: const SafeBackButton(fallback: '/profile'),
          title: const Text('Badges')),
      body: PhoneFrame(
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 130,
              mainAxisExtent: 124,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10),
          itemCount: MockData.badges.length,
          itemBuilder: (_, i) {
            final b = MockData.badges[i];
            return BadgeTile(
                badge: b,
                earned: u.badges.contains(b.id),
                onTap: () => showAppSnack(
                    context, '${b.name}: ${b.description}',
                    icon: b.icon));
          },
        ),
      ),
    );
  }
}

class PointsHistoryScreen extends StatelessWidget {
  const PointsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(
          leading: const SafeBackButton(fallback: '/profile'),
          title: const Text('Points history')),
      body: PhoneFrame(
        child: s.ledger.isEmpty
            ? const EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'Nothing yet',
                body: 'Complete tasks and upload bills to see entries here')
            : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: s.ledger.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, indent: 64),
                itemBuilder: (_, i) => _LedgerTile(s.ledger[i]),
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Edit profile
// ---------------------------------------------------------------------------
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final AppUser u = AppScope.read(context).user!;
  late final _name = TextEditingController(text: u.displayName);
  late final _pin = TextEditingController(text: u.pincode);
  late int _household = u.householdSize;
  late String _homeType = u.homeType;
  late final Set<String> _appl = {...u.appliances};
  late String _travel = u.travelMode;
  late double _km = u.weeklyKm;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _pin.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    if (_name.text.trim().length < 2) {
      showAppSnack(context, 'Enter your name',
          icon: Icons.error_outline_rounded, color: AppColors.error);
      return;
    }
    setState(() => _saving = true);
    try {
      await AppScope.read(context).updateProfile((x) => x
        ..displayName = _name.text.trim()
        ..pincode = _pin.text.trim()
        ..district = MockData.districtFromPin(_pin.text.trim())
        ..householdSize = _household
        ..homeType = _homeType
        ..appliances = _appl.toList()
        ..travelMode = _travel
        ..weeklyKm = _km);
      if (!mounted) return;
      showAppSnack(context, 'Profile updated',
          icon: Icons.check_circle_rounded, color: AppColors.primary);
      context.safePop('/profile');
    } catch (error) {
      if (!mounted) return;
      showAppSnack(
        context,
        'Could not save your profile: $error',
        icon: Icons.error_outline_rounded,
        color: AppColors.error,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
          leading: const SafeBackButton(fallback: '/profile'),
          title: const Text('Edit profile'),
          actions: [
            TextButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Saving' : 'Save'))
          ]),
      body: PhoneFrame(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
                child: Avatar(
                    initials: u.initials, size: 80, photoUrl: u.photoUrl)),
            const SizedBox(height: 8),
            Center(
                child: TextButton(
                    onPressed: () => showAppSnack(
                        context, 'Photo picker (image_picker) opens here',
                        icon: Icons.photo_camera_outlined),
                    child: const Text('Change photo'))),
            const SizedBox(height: 8),
            AppTextField(
                label: 'Full name',
                controller: _name,
                prefixIcon: Icons.person_outline_rounded),
            const SizedBox(height: 14),
            AppTextField(
                label: 'Pincode',
                controller: _pin,
                keyboardType: TextInputType.number,
                maxLength: 6,
                prefixIcon: Icons.location_on_outlined,
                helper: 'District: ${MockData.districtFromPin(_pin.text)}',
                onChanged: (_) => setState(() {})),
            const SizedBox(height: 14),
            StepperField(
                label: 'People at home',
                value: _household,
                min: 1,
                max: 15,
                onChanged: (v) => setState(() => _household = v)),
            const SizedBox(height: 16),
            Text('Home type', style: t.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (id, label) in const [
                  ('flat', 'Flat'),
                  ('bungalow', 'Bungalow'),
                  ('row_house', 'Row house'),
                  ('rented', 'Rented')
                ])
                  ChoiceChip(
                      label: Text(label),
                      selected: _homeType == id,
                      onSelected: (_) => setState(() => _homeType = id)),
              ],
            ),
            const SizedBox(height: 16),
            Text('Appliances', style: t.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final a in MockData.appliances)
                  FilterChip(
                    label: Text(a.$2),
                    avatar: Icon(a.$3, size: 16),
                    selected: _appl.contains(a.$1),
                    onSelected: (v) => setState(
                        () => v ? _appl.add(a.$1) : _appl.remove(a.$1)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Daily travel', style: t.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (id, label) in const [
                  ('two_wheeler', 'Two-wheeler'),
                  ('car', 'Car'),
                  ('bus_metro', 'Bus / Metro'),
                  ('walk_cycle', 'Walk / Cycle'),
                  ('ev', 'EV')
                ])
                  ChoiceChip(
                      label: Text(label),
                      selected: _travel == id,
                      onSelected: (_) => setState(() => _travel = id)),
              ],
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: Text('Weekly km', style: t.titleSmall)),
              Text('${_km.round()} km',
                  style: t.labelLarge?.copyWith(color: AppColors.primary))
            ]),
            Slider(
                value: _km,
                min: 0,
                max: 300,
                divisions: 30,
                onChanged: (v) => setState(() => _km = v)),
            const SizedBox(height: 12),
            const InfoBanner(
                text:
                    'Changing appliances or travel updates your task recommendations, not your baseline footprint.',
                icon: Icons.info_outline_rounded),
            const SizedBox(height: 20),
            PrimaryButton(
                label: _saving ? 'Saving...' : 'Save changes',
                onPressed: _saving ? null : _save),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Notification settings
// ---------------------------------------------------------------------------
class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final u = s.user!;
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
          leading: const SafeBackButton(fallback: '/profile'),
          title: const Text('Notifications & nudges')),
      body: PhoneFrame(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const InfoBanner(
                text:
                    'Max 2 nudges a day · quiet hours 10 pm – 7 am · you can switch any off.',
                icon: Icons.do_not_disturb_on_outlined),
            const SizedBox(height: 12),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.schedule_rounded,
                        color: AppColors.warning),
                    title: const Text('Peak-hour reminder'),
                    subtitle:
                        const Text('5:30 pm · shift heavy loads before 6 pm'),
                    value: u.peakNudge,
                    onChanged: (v) => _updateProfileWithFeedback(
                        context, s, (x) => x.peakNudge = v),
                  ),
                  const Divider(height: 1, indent: 60),
                  SwitchListTile(
                    secondary: const Icon(Icons.thermostat_rounded,
                        color: AppColors.error),
                    title: const Text('Bill & weather reminders'),
                    subtitle: const Text(
                        '1st of month bill reminder · heatwave cooling tips'),
                    value: u.weatherNudge,
                    onChanged: (v) => _updateProfileWithFeedback(
                        context, s, (x) => x.weatherNudge = v),
                  ),
                  const Divider(height: 1, indent: 60),
                  SwitchListTile(
                    secondary: const Icon(Icons.groups_rounded,
                        color: AppColors.primary),
                    title: const Text('Community updates'),
                    subtitle: const Text(
                        'Goal milestones, rank changes, captain posts'),
                    value: u.communityUpdates,
                    onChanged: (v) => _updateProfileWithFeedback(
                        context, s, (x) => x.communityUpdates = v),
                  ),
                  const Divider(height: 1, indent: 60),
                  SwitchListTile(
                    secondary: const Icon(Icons.local_fire_department_rounded,
                        color: AppColors.secondary),
                    title: const Text('Streak reminders'),
                    subtitle: const Text('8:30 pm if no task done yet today'),
                    value: u.streakReminders,
                    onChanged: (v) => _updateProfileWithFeedback(
                        context, s, (x) => x.streakReminders = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Test & tools', style: t.titleSmall),
            const SizedBox(height: 8),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.notifications_active_outlined,
                        color: AppColors.primary),
                    title: const Text('Send a test notification'),
                    subtitle: const Text(
                        'Checks device permission & the LiFE nudges channel'),
                    trailing: const Icon(Icons.send_rounded),
                    onTap: () async {
                      final ok = await NotificationService.requestPermission();
                      await NotificationService.showNow(
                          title: 'LiFE Mitra is set up ✅',
                          body:
                              'You will get the 5:30 pm peak-hour nudge and streak reminders here.');
                      if (!context.mounted) return;
                      showAppSnack(
                          context,
                          ok
                              ? 'Test notification sent'
                              : 'Notifications are blocked — enable them in system settings',
                          icon: ok
                              ? Icons.check_circle_outline_rounded
                              : Icons.notifications_off_outlined,
                          color: ok ? null : AppColors.warning);
                    },
                  ),
                  const Divider(height: 1, indent: 60),
                  ListTile(
                    leading: const Icon(Icons.bolt_rounded,
                        color: AppColors.warning),
                    title: const Text('Preview peak-hour nudge on Home'),
                    subtitle: const Text('Shows the 5:30 pm nudge card now'),
                    trailing: const Icon(Icons.play_arrow_rounded),
                    onTap: () {
                      s.triggerDemoNudge();
                      showAppSnack(context, 'Nudge queued — check Home',
                          icon: Icons.notifications_active_rounded);
                      context.go('/home');
                    },
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
