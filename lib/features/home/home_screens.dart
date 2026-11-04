import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/logic/calculators.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/v3.dart';
import '../../core/services/notification_service.dart';
<<<<<<< HEAD
import '../../core/widgets/proof_picker_sheet.dart';
=======
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
import '../../core/widgets/widgets.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';

// ---------------------------------------------------------------------------
// Main shell with bottom navigation
// ---------------------------------------------------------------------------
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child, required this.location});
  final Widget child;
  final String location;

  static const _tabs = ['/home', '/impact', '/community', '/hub', '/profile'];

  int get _index {
    for (var i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i])) return i;
    }
    return 0;
  }

  static const _destinations = [
    (Icons.home_outlined, Icons.home_rounded, 'Home'),
    (Icons.show_chart_rounded, Icons.show_chart_rounded, 'Impact'),
    (Icons.groups_outlined, Icons.groups_rounded, 'Community'),
    (Icons.grid_view_outlined, Icons.grid_view_rounded, 'Hub'),
    (Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    // During sign-out the router is about to redirect; never build tab
    // screens (which assume a signed-in user) in that intermediate frame.
    if (!s.isSignedIn) {
      return const Scaffold(body: SizedBox.shrink());
    }
    final width = MediaQuery.sizeOf(context).width;
    final onHome = _index == 0;

    // ---- Phone (< 600 dp): bottom navigation, full width ----
    if (width < 600) {
      // Hardware / gesture back: tabs are switched with `go` (no history),
      // so without this the system back would close the app from any tab.
      // Behaviour: any tab -> Home; Home -> leave app (default behaviour).
      return PopScope(
        canPop: onHome,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && !onHome) context.go('/home');
        },
        child: Scaffold(
<<<<<<< HEAD
          body: child,
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border))),
            child: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => context.go(_tabs[i]),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: [
                for (final d in _destinations)
                  NavigationDestination(
                      icon: Icon(d.$1), selectedIcon: Icon(d.$2), label: d.$3),
              ],
            ),
          ),
        ),
=======
        body: child,
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border))),
          child: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => context.go(_tabs[i]),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              for (final d in _destinations)
                NavigationDestination(
                    icon: Icon(d.$1), selectedIcon: Icon(d.$2), label: d.$3),
            ],
          ),
        ),
        ),
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
      );
    }

    // ---- Tablet / desktop / web (>= 600 dp): side rail + centred content ----
    final extended = width >= 1100;
    final contentMax = width >= 900 ? 760.0 : 600.0;
    return PopScope(
      canPop: onHome,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !onHome) context.go('/home');
      },
      child: Scaffold(
<<<<<<< HEAD
        backgroundColor: AppColors.surfaceLow,
        body: Row(
          children: [
            NavigationRail(
              extended: extended,
              minExtendedWidth: 210,
              backgroundColor: Colors.white,
              selectedIndex: _index,
              onDestinationSelected: (i) => context.go(_tabs[i]),
              labelType: extended
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              indicatorColor: AppColors.tint,
              selectedIconTheme: const IconThemeData(color: AppColors.primary),
              selectedLabelTextStyle: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.w700),
              leading: Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 8, 20),
                child: Image.asset('assets/images/emblem.png',
                    width: extended ? 64 : 40, height: extended ? 64 : 40),
              ),
              destinations: [
                for (final d in _destinations)
                  NavigationRailDestination(
                      icon: Icon(d.$1),
                      selectedIcon: Icon(d.$2),
                      label: Text(d.$3)),
              ],
            ),
            const VerticalDivider(
                width: 1, thickness: 1, color: AppColors.border),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentMax),
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      border: Border.symmetric(
                          vertical: BorderSide(color: AppColors.border)),
                    ),
                    child: child,
                  ),
                ),
              ),
            ),
          ],
        ),
=======
      backgroundColor: AppColors.surfaceLow,
      body: Row(
        children: [
          NavigationRail(
            extended: extended,
            minExtendedWidth: 210,
            backgroundColor: Colors.white,
            selectedIndex: _index,
            onDestinationSelected: (i) => context.go(_tabs[i]),
            labelType: extended
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            indicatorColor: AppColors.tint,
            selectedIconTheme: const IconThemeData(color: AppColors.primary),
            selectedLabelTextStyle: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w700),
            leading: Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 8, 20),
              child: Image.asset('assets/images/emblem.png',
                  width: extended ? 64 : 40, height: extended ? 64 : 40),
            ),
            destinations: [
              for (final d in _destinations)
                NavigationRailDestination(
                    icon: Icon(d.$1),
                    selectedIcon: Icon(d.$2),
                    label: Text(d.$3)),
            ],
          ),
          const VerticalDivider(
              width: 1, thickness: 1, color: AppColors.border),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentMax),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    border: Border.symmetric(
                        vertical: BorderSide(color: AppColors.border)),
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Home — Today
// ---------------------------------------------------------------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500),
        () => mounted ? setState(() => _loading = false) : null);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final u = s.user!;
    final t = Theme.of(context).textTheme;
    final tasks = s.todayTasks;
    final done = s.tasksDoneToday;
    final pending = tasks.length - done;
    final nudge = s.activeNudge;
    final goal = s.myGoal;
    final community = s.myCommunity;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';
    final co2 = s.totalCo2Saved;
    final latest = s.latest;
    final trend = latest == null || latest.percentChange == 0
        ? null
        : latest.percentChange;

    return Scaffold(
      appBar: const BrandAppBar(subtitle: '', showAvatar: false),
      body: _loading
          ? const _HomeSkeleton()
          : RefreshIndicator(
              onRefresh: () async => setState(() {}),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                children: [
                  // ---- Greeting -------------------------------------------
                  Row(
                    children: [
                      Avatar(initials: u.initials, size: 52),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Eyebrow('Citizen Dashboard'),
                            const SizedBox(height: 2),
                            Text('$greeting, ${u.displayName.split(' ').first}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: t.headlineSmall
                                    ?.copyWith(color: AppColors.primary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // ---- Hero metric ----------------------------------------
                  AppCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: SoftChip('${u.streak}-day streak',
                                  icon: Icons.local_fire_department_rounded,
                                  color: AppColors.warning),
                            ),
                            const SizedBox(width: 8),
                            if (trend != null)
                              Flexible(
                                child: SoftChip(
                                    '${trend > 0 ? '+' : ''}${trend.abs().toStringAsFixed(0)}% this month',
                                    icon: trend < 0
                                        ? Icons.trending_down_rounded
                                        : Icons.trending_up_rounded,
                                    color: AppColors.primaryLight),
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Eyebrow('Carbon offset metric'),
                        const SizedBox(height: 6),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text.rich(
                            TextSpan(children: [
                              TextSpan(
                                  text: Fmt.int(co2),
                                  style: t.displayMedium?.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 40,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -1.2)),
                              TextSpan(
                                  text: ' kg CO₂ saved',
                                  style: t.headlineSmall?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700)),
                            ]),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Divider(),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.verified_outlined,
                                size: 18, color: AppColors.primaryLight),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                  '${u.district.isEmpty ? 'Gujarat' : u.district} Smart Grid Verified',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
<<<<<<< HEAD
                                  style: t.bodySmall
                                      ?.copyWith(fontWeight: FontWeight.w600)),
=======
                                  style: t.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600)),
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
                            ),
                            InkWell(
                              onTap: () => context.go('/impact'),
                              child: Text('View Analytics',
                                  style: t.labelLarge
                                      ?.copyWith(color: AppColors.primary)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ---- Peak nudge -----------------------------------------
                  if (nudge != null) ...[
                    _PeakNudgeCard(
                      nudge: nudge,
                      onDoIt: () {
                        if (nudge.taskId != null) {
                          context.push('/tasks/${nudge.taskId}');
                        } else {
                          context.go('/community');
                        }
                      },
                      onReminder: () => _setPeakReminder(context, s),
                      onDismiss: () => s.dismissNudge(nudge.id),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ---- Today's tasks --------------------------------------
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 6, 4, 12),
                    child: Row(
                      children: [
                        Text("Today's tasks", style: t.headlineSmall),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: SoftChip(
                                pending == 0 ? 'all done' : '$pending pending',
                                color: pending == 0
                                    ? AppColors.primaryLight
                                    : AppColors.textSecondary,
                                dense: true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => context.push('/tasks'),
                          child: Text('History',
                              style: t.labelLarge
                                  ?.copyWith(color: AppColors.primary)),
                        ),
                      ],
                    ),
                  ),
                  for (var i = 0; i < tasks.length; i++) ...[
                    _TaskCardV3(
                      task: tasks[i],
                      status: s.statusOf(tasks[i].id),
                      onOpen: () => context.push('/tasks/${tasks[i].id}'),
                      onToggle: () => completeTaskFlow(context, tasks[i]),
                    ),
                    if (i < tasks.length - 1) const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 20),

                  // ---- This month + gas -----------------------------------
                  _ThisMonthCard(state: s),
                  const SizedBox(height: 16),
                  _GasCard(state: s),
                  const SizedBox(height: 16),

                  // ---- Society --------------------------------------------
                  if (community != null && goal != null)
                    _SocietyCard(community: community, goal: goal, user: u)
                  else
                    AppCard(
                      onTap: () => context.push('/community/join'),
                      child: Row(
                        children: [
                          const IconBubble(Icons.groups_outlined,
                              color: AppColors.primaryLight),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
<<<<<<< HEAD
                                Text('Join your society', style: t.titleMedium),
=======
                                Text('Join your society',
                                    style: t.titleMedium),
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
                                Text(
                                    'Compete on the ward leaderboard and earn bonus credits',
                                    style: t.bodySmall),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded,
                              color: AppColors.outline),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),

                  // ---- Quick actions --------------------------------------
                  Row(
                    children: [
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.receipt_long_outlined,
                          title: 'Log bill',
                          subtitle: 'Add month entry',
                          onTap: () => context.push('/impact/add-month'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.solar_power_outlined,
                          title: 'Solar check',
                          subtitle: 'Rooftop estimate',
                          onTap: () => context.push('/hub/solar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
<<<<<<< HEAD
=======


>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
}

class _ThisMonthCard extends StatelessWidget {
  const _ThisMonthCard({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final u = state.user!;
    final base = state.baseline;
    final latest = state.latest;
    final units = latest?.electricityUnits ?? u.baselineUnits;
    final baseUnits = base?.electricityUnits ?? u.baselineUnits;
    final pct = baseUnits > 0 ? ((baseUnits - units) / baseUnits * 100) : 0.0;
    final co2Saved = state.totalCo2Saved;
    final goalPct = u.goalPercent <= 0 ? 10 : u.goalPercent;
    final ratio = (pct / goalPct).clamp(0.0, 1.0);
    final trees = (co2Saved / 20).round();
    final rupees = (units * goalPct / 100 * state.config.avgTariffPerUnit);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardTitle(
            icon: Icons.calendar_month_outlined,
            title: 'This month',
            trailing: const Tag('UGVCL Smart Meter',
                color: AppColors.tintStrong, textColor: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatBlock(
                  label: 'Units used',
                  value: Fmt.int(units),
                  unit: 'kWh',
                  caption: pct >= 0
                      ? '−${pct.toStringAsFixed(0)}% vs base'
                      : '+${(-pct).toStringAsFixed(0)}% vs base',
                  captionIcon: pct >= 0
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  captionColor: pct >= 0 ? AppColors.success : AppColors.error,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatBlock(
                  label: 'CO₂ avoided',
                  value: Fmt.int(co2Saved),
                  unit: 'kg CO₂',
                  caption: '~$trees trees saved',
                  captionIcon: Icons.park_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LabelledProgress(
            value: ratio,
            leading: 'Goal: save $goalPct%',
            trailing: '${(ratio * 100).round()}% done',
            caption:
                'Keep current rate to save approx. ${Fmt.rupees(rupees)} on upcoming power invoice.',
          ),
        ],
      ),
    );
  }
}

class _GasCard extends StatelessWidget {
  const _GasCard({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final gas = state.gas;
    final cylinders = gas?.cylindersPerMonth ?? 1;
    final kg = (cylinders * 14.2 * state.config.factors.lpg);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardTitle(
            icon: Icons.propane_tank_outlined,
            title: 'Cooking Gas',
            trailing: Tag(
                gas == null
                    ? 'Not linked'
                    : '${gas.providerShort} · ${gas.isPng ? 'PNG' : '14.2 kg'}',
                color: AppColors.tintStrong,
                textColor: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                    label: gas?.isPng == true ? 'SCM / month' : 'Cylinders',
                    value: gas?.isPng == true
                        ? '${gas!.scmPerMonth} / month'
                        : '$cylinders / month'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniStat(
<<<<<<< HEAD
                    label: 'CO₂', value: '${kg.toStringAsFixed(0)} kg'),
=======
                    label: 'CO₂',
                    value: '${kg.toStringAsFixed(0)} kg'),
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniStat(
                    label: 'Subsidy',
                    value: gas?.pmuy == true ? 'PMUY' : 'Standard'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Flexible(
                child: Tag('+15 pts per refill logged',
                    icon: Icons.stars_outlined),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => context.push('/home/gas'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(gas == null ? '+ Add gas' : 'Update',
                          style:
                              t.labelLarge?.copyWith(color: AppColors.primary)),
                      const Icon(Icons.arrow_forward_rounded,
                          size: 16, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: AppColors.tint, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: t.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(value,
              style: t.labelLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _PeakNudgeCard extends StatelessWidget {
  const _PeakNudgeCard(
      {required this.nudge,
      required this.onDoIt,
      required this.onReminder,
      required this.onDismiss});
  final Nudge nudge;
  final VoidCallback onDoIt;
  final VoidCallback onReminder;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.secondarySoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: AppColors.secondary),
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                    onTap: onDoIt,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 10, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(nudge.icon,
                                  color: AppColors.warning, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                  child:
                                      Text(nudge.title, style: t.titleMedium)),
                              const SizedBox(width: 8),
                              const Tag('GUJARAT GRID',
                                  color: Color(0xFFFFE08A),
                                  textColor: Color(0xFF6B4A00)),
                              InkWell(
                                onTap: onDismiss,
                                borderRadius: BorderRadius.circular(12),
                                child: const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(Icons.close_rounded,
                                      size: 16, color: AppColors.textSecondary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(nudge.message,
                              style: t.bodyMedium
                                  ?.copyWith(color: AppColors.warning)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Flexible(
                                child: Tag(nudge.impact,
                                    icon: Icons.stars_outlined,
                                    color: const Color(0xFFFFE08A),
                                    textColor: const Color(0xFF6B4A00)),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: onReminder,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('Set reminder',
                                          style: t.labelLarge?.copyWith(
                                              color: AppColors.primary)),
                                      const Icon(Icons.arrow_forward_rounded,
                                          size: 16, color: AppColors.primary),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact task row used on Home and the Tasks tab.
class TaskRow extends StatelessWidget {
  const TaskRow(
      {super.key,
      required this.task,
      required this.status,
      required this.onTap,
      required this.onToggle,
      this.showMeta = true});
  final TaskItem task;
  final TaskStatus status;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final bool showMeta;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final done = status == TaskStatus.done;
    final na = status == TaskStatus.notApplicable;
    final skipped = status == TaskStatus.skipped;
    final muted = done || na || skipped;
    final photo = task.verification == Verification.photo;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              button: true,
              label: done ? 'Completed' : 'Mark done',
              child: InkWell(
                onTap: muted ? null : onToggle,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(top: 1),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                        color: done ? AppColors.primary : AppColors.outline,
                        width: 1.5),
                  ),
                  child: done
                      ? const Icon(Icons.check_rounded,
                          size: 16, color: Colors.white)
                      : photo
                          ? const Icon(Icons.photo_camera_outlined,
                              size: 14, color: AppColors.textSecondary)
                          : null,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title,
                      style: t.bodyLarge?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: muted
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                          decoration:
                              done ? TextDecoration.lineThrough : null)),
                  if (showMeta)
                    Text(
                        done
                            ? 'Logged today · ${task.theme.label}'
                            : na
                                ? 'Marked not applicable'
                                : skipped
                                    ? 'Skipped for today'
                                    : task.description,
                        style: t.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Tag('+${task.points} pts',
                color: muted ? AppColors.tintStrong : AppColors.tint,
                textColor: muted ? AppColors.textSecondary : AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _SocietyCard extends StatelessWidget {
  const _SocietyCard(
      {required this.community, required this.goal, required this.user});
  final Community community;
  final CommunityGoal goal;
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final rank = 1 + (user.points ~/ 500) % 5;
    return AppCard(
      onTap: () => context.go('/community'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardTitle(
            icon: Icons.apartment_outlined,
            title: 'Your society',
            subtitle: '${community.type} · ${community.district}',
            trailing: Tag('Rank #$rank',
                color: AppColors.tintStrong, textColor: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: AppColors.tint, borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text(community.name,
                            style: t.titleSmall,
                            overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 8),
                    Text('${community.memberCount} members',
                        style: t.bodySmall),
                  ],
                ),
                const SizedBox(height: 8),
                LabelledProgress(
                  value: goal.ratio,
                  leading: 'Society target',
                  trailing:
                      '${Fmt.int(goal.progress)}/${Fmt.int(goal.target)} ${goal.metric == 'co2' ? 'kg CO₂' : goal.metric} saved',
                  height: 6,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              SizedBox(
                width: 72,
                height: 28,
                child: Stack(
                  children: [
                    for (var i = 0; i < 3; i++)
                      Positioned(
                        left: i * 20.0,
                        child: Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: [
                              AppColors.primary,
                              AppColors.primaryDark,
                              AppColors.success
                            ][i],
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Text(['PK', 'RD', 'NS'][i],
                              style: t.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 9)),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Text(
                    '+${(community.memberCount - 3).clamp(0, 9999)} others',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.bodySmall),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text('View details',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.labelLarge?.copyWith(color: AppColors.primary)),
              ),
              const SizedBox(width: 2),
              const Icon(Icons.arrow_forward_rounded,
                  size: 16, color: AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: AppColors.tint, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: t.labelLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                Text(subtitle,
                    style: t.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      children: const [
        SkeletonBox(height: 44, width: 220),
        SizedBox(height: 12),
        SkeletonBox(height: 36),
        SizedBox(height: 16),
        SkeletonBox(height: 190),
        SizedBox(height: 12),
        SkeletonBox(height: 150),
        SizedBox(height: 12),
        SkeletonBox(height: 220),
      ],
    );
  }
}

Future<void> completeTaskFlow(BuildContext context, TaskItem task,
    {bool fromSheet = false}) async {
  final s = AppScope.read(context);
  if (task.verification == Verification.bill) {
    context.push('/impact/add-month');
    return;
  }
<<<<<<< HEAD
  var withPhoto = false;
  String? proofPath;
  if (task.verification == Verification.photo) {
    final picked = await showProofPickerSheet(
      context,
      title: 'Add a photo as proof',
      subtitle: 'GEDA moderators spot-check uploads. A verified photo earns '
          '+${s.config.photoBonus} bonus points.',
      confirmLabel: 'Complete task',
    );
    if (picked == null) return;

    if (s.isLiveBackend) {
      // Upload first — the DB function verifies the object really exists
      // before it awards any photo bonus.
      if (!context.mounted) return;
      showAppSnack(context, 'Uploading proof…',
          icon: Icons.cloud_upload_outlined, color: AppColors.tertiary);
      try {
        proofPath = await s.uploadBillProof(
          bytes: picked.bytes,
          contentType: picked.contentType,
        );
      } catch (error) {
        if (!context.mounted) return;
        showAppSnack(
          context,
          'Proof upload failed: $error',
          icon: Icons.error_outline_rounded,
          color: AppColors.error,
        );
        return;
      }
    }
=======
  if (s.useFirebase && task.verification == Verification.photo) {
    showAppSnack(
      context,
      'Photo verification is not available for online accounts yet.',
      icon: Icons.info_outline_rounded,
      color: AppColors.warning,
    );
    return;
  }
  var withPhoto = false;
  if (task.verification == Verification.photo) {
    final picked = await showModalBottomSheet<bool>(
      context: context,
      builder: (_) => const _PhotoPickerSheet(),
    );
    if (picked != true) return;
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
    withPhoto = true;
  }
  late final TaskCompletion result;
  try {
<<<<<<< HEAD
    result =
        await s.completeTask(task, withPhoto: withPhoto, proofPath: proofPath);
=======
    result = await s.completeTask(task, withPhoto: withPhoto);
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
  } catch (error) {
    if (!context.mounted) return;
    showAppSnack(
      context,
      'Could not save task progress: $error',
      icon: Icons.error_outline_rounded,
      color: AppColors.error,
    );
    return;
  }
  if (!context.mounted) return;
  HapticFeedback.lightImpact();
  if (result.points > 0) showConfetti(context);
  showAppSnack(
    context,
    result.points > 0
        ? '+${result.points} Green Points'
<<<<<<< HEAD
        : 'Logged! Daily points cap reached — verify with your bill for more.',
=======
        : s.useFirebase
            ? 'Task progress saved. Online rewards are not enabled yet.'
            : 'Logged! Daily cap reached — verify with your bill for more.',
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
    icon: Icons.stars_rounded,
    color: AppColors.primary,
  );
  if (result.leveledUp != null) {
    await showDialog<void>(
        context: context,
        builder: (_) =>
            _LevelUpDialog(level: result.leveledUp!, points: s.user!.points));
  }
  for (final b in result.newBadges) {
    if (!context.mounted) return;
    await showDialog<void>(
        context: context, builder: (_) => _BadgeDialog(badge: b));
  }
}

Future<void> _saveTaskAction(
  BuildContext context,
  Future<void> Function() save, {
  String? successMessage,
  IconData successIcon = Icons.check_circle_outline_rounded,
}) async {
  try {
    await save();
    if (!context.mounted || successMessage == null) return;
    showAppSnack(context, successMessage, icon: successIcon);
  } catch (error) {
    if (!context.mounted) return;
    showAppSnack(
      context,
      'Could not save task progress: $error',
      icon: Icons.error_outline_rounded,
      color: AppColors.error,
    );
  }
}

<<<<<<< HEAD
=======
class _PhotoPickerSheet extends StatefulWidget {
  const _PhotoPickerSheet();

  @override
  State<_PhotoPickerSheet> createState() => _PhotoPickerSheetState();
}

class _PhotoPickerSheetState extends State<_PhotoPickerSheet> {
  bool _picked = false;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add a photo as proof', style: t.headlineSmall),
          const SizedBox(height: 4),
          Text(
              'Our AI checks the image, then your points are credited instantly. +5 bonus for photo proof.',
              style: t.bodySmall),
          const SizedBox(height: 20),
          if (_picked)
            Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                    colors: [Color(0xFFDDE7DD), Color(0xFFC6D8C7)]),
              ),
              child: Stack(
                children: [
                  const Center(
                      child: Icon(Icons.image_rounded,
                          size: 56, color: Colors.white)),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: StatusTag(
                        label: 'Looks good ✓', color: AppColors.success),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                Expanded(
                    child: _PickTile(
                        icon: Icons.photo_camera_rounded,
                        label: 'Camera',
                        onTap: () => setState(() => _picked = true))),
                const SizedBox(width: 12),
                Expanded(
                    child: _PickTile(
                        icon: Icons.photo_library_rounded,
                        label: 'Gallery',
                        onTap: () => setState(() => _picked = true))),
              ],
            ),
          const SizedBox(height: 20),
          PrimaryButton(
              label: _picked ? 'Complete task' : 'Choose a photo first',
              onPressed: _picked ? () => Navigator.pop(context, true) : null),
        ],
      ),
    );
  }
}

class _PickTile extends StatelessWidget {
  const _PickTile(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.border,
              width: 1.5,
              strokeAlign: BorderSide.strokeAlignInside),
          color: AppColors.background,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(label, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}

>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
Future<void> showTaskSheet(BuildContext context, TaskItem task) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => TaskDetailSheet(task: task),
  );
}

class TaskDetailSheet extends StatelessWidget {
  const TaskDetailSheet({super.key, required this.task});
  final TaskItem task;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final s = AppScope.of(context);
    final status = s.statusOf(task.id);
    final done = status == TaskStatus.done;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconTile(
                    icon: task.theme.icon,
                    color: task.theme.color,
                    size: 44,
                    iconSize: 22),
                const SizedBox(width: 12),
                Pill(
                    label: task.theme.label,
                    color: task.theme.color.withValues(alpha: 0.12),
                    textColor: task.theme.color),
                const Spacer(),
                Pill(
                    label: '+${task.points} pts',
                    color: AppColors.secondarySoft,
                    textColor: const Color(0xFF694300),
                    icon: Icons.stars_rounded),
              ],
            ),
            const SizedBox(height: 14),
            Text(task.title, style: t.headlineSmall),
            const SizedBox(height: 8),
            Text('Why it matters', style: t.labelMedium),
            const SizedBox(height: 2),
            Text(task.description, style: t.bodyMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                _ImpactStat(
                    value: task.estUnitsSaved > 0
                        ? '${task.estUnitsSaved} units'
                        : '—',
                    label: 'Energy'),
                _ImpactStat(
                    value:
                        task.estRupees > 0 ? Fmt.rupees(task.estRupees) : '—',
                    label: 'Saving'),
                _ImpactStat(
                    value: task.estCo2Kg > 0 ? Fmt.kg(task.estCo2Kg) : '—',
                    label: 'CO₂'),
              ],
            ),
            if (task.steps.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('How to do it', style: t.titleSmall),
              const SizedBox(height: 8),
              for (var i = 0; i < task.steps.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                            color: AppColors.primarySoft,
                            shape: BoxShape.circle),
                        child: Text('${i + 1}',
                            style: t.labelSmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(task.steps[i], style: t.bodyMedium)),
                    ],
                  ),
                ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(task.verification.icon,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(task.verification.label, style: t.labelMedium),
                if (task.verification == Verification.photo)
                  Text(' · +${s.config.photoBonus} bonus',
                      style: t.labelMedium?.copyWith(color: AppColors.success)),
              ],
            ),
            const SizedBox(height: 18),
            if (done)
              const SecondaryButton(label: 'Completed today ✓')
            else
              PrimaryButton(
                label: switch (task.verification) {
                  Verification.photo => 'Add photo & complete',
                  Verification.bill => 'Upload bill',
                  Verification.vendor => 'Book with a vendor',
                  _ => 'Mark as done',
                },
                icon: task.verification == Verification.photo
                    ? Icons.photo_camera_rounded
                    : Icons.check_rounded,
                onPressed: () async {
                  Navigator.pop(context);
                  if (task.verification == Verification.vendor) {
                    context.push('/hub/vendors');
                    return;
                  }
                  await completeTaskFlow(context, task);
                },
              ),
            if (!done)
              Center(
                child: TextButton(
                  onPressed: () {
                    _saveTaskAction(
                      context,
                      () => s.markNotApplicable(task),
                      successMessage: "Got it — we won't suggest this again.",
                      successIcon: Icons.thumb_up_alt_outlined,
                    ).then((_) {
                      if (context.mounted) Navigator.pop(context);
                    });
                  },
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary),
                  child: const Text('Not applicable to me'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ImpactStat extends StatelessWidget {
  const _ImpactStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border)),
        child: Column(
          children: [
            FittedBox(
                child: Text(value,
                    style: t.titleSmall?.copyWith(color: AppColors.primary))),
            Text(label, style: t.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _LevelUpDialog extends StatelessWidget {
  const _LevelUpDialog({required this.level, required this.points});
  final String level;
  final int points;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final l = LevelEngine.levelFor(points);
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            gradient: AppColors.heroGreen,
            borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.$4, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 8),
            Text('Level up!',
                style: t.headlineSmall?.copyWith(color: Colors.white)),
            Text("You're now a $level",
                style: t.bodyMedium?.copyWith(color: Colors.white70),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            PrimaryButton(
                label: 'Continue',
                color: Colors.white,
                foreground: AppColors.primary,
                onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}

class _BadgeDialog extends StatelessWidget {
  const _BadgeDialog({required this.badge});
  final BadgeItem badge;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                  color: badge.color.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                  border: Border.all(color: badge.color, width: 3)),
              child: Icon(badge.icon, color: badge.color, size: 40),
            ),
            const SizedBox(height: 16),
            Text('Badge earned!', style: t.labelMedium),
            Text(badge.name, style: t.headlineSmall),
            const SizedBox(height: 4),
            Text(badge.description,
                style: t.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            PrimaryButton(
                label: 'Awesome', onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}

<<<<<<< HEAD
=======

>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
/// DESIGN-3 task card: icon tile · title/subtitle · circular check · chevron.
class _TaskCardV3 extends StatelessWidget {
  const _TaskCardV3(
      {required this.task,
      required this.status,
      required this.onOpen,
      required this.onToggle});
  final TaskItem task;
  final TaskStatus status;
  final VoidCallback onOpen;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final done = status == TaskStatus.done;
    final sub = done
        ? 'Completed today · +${task.points} Green Credits'
        : '${task.theme.label} · Saves ${task.estCo2Kg.toStringAsFixed(1)} kg CO₂';
    return AppCard(
      onTap: onOpen,
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
      child: Row(
        children: [
          IconBubble(task.theme.icon,
<<<<<<< HEAD
              size: 48,
              color: done ? AppColors.primaryLight : task.theme.color),
=======
              size: 48, color: done ? AppColors.primaryLight : task.theme.color),
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: t.titleMedium?.copyWith(
                        decoration: done ? TextDecoration.lineThrough : null,
                        color: done ? AppColors.textSecondary : null)),
                const SizedBox(height: 3),
                Row(
                  children: [
                    if (done) ...[
                      const Icon(Icons.check_circle_rounded,
                          size: 14, color: AppColors.primaryLight),
                      const SizedBox(width: 4),
                    ],
                    Expanded(
                      child: Text(sub,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.bodySmall?.copyWith(
                              color: done
                                  ? AppColors.primaryLight
                                  : AppColors.textSecondary,
                              fontWeight:
                                  done ? FontWeight.w600 : FontWeight.w500)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: done ? null : onToggle,
            customBorder: const CircleBorder(),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? AppColors.primaryLight : Colors.transparent,
                border: Border.all(
                    color: done ? AppColors.primaryLight : AppColors.outline,
                    width: 1.6),
              ),
              child: done
                  ? const Icon(Icons.check_rounded,
                      size: 20, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded,
              size: 20, color: AppColors.outline),
        ],
      ),
    );
  }
}

Future<void> _setPeakReminder(BuildContext context, AppState s) async {
  final granted = await NotificationService.requestPermission();
  if (!context.mounted) return;
  if (!granted) {
<<<<<<< HEAD
    showAppSnack(
        context, 'Allow notifications in system settings to get reminders',
=======
    showAppSnack(context, 'Allow notifications in system settings to get reminders',
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
        icon: Icons.notifications_off_outlined, color: AppColors.warning);
    return;
  }
  if (!s.user!.peakNudge) {
    await s.updateProfile((u) => u.peakNudge = true);
  } else {
    await NotificationService.schedulePeakNudge(enabled: true);
  }
  if (!context.mounted) return;
  showAppSnack(context, 'Reminder set · every day at 5:30 pm before peak hours',
      icon: Icons.alarm_on_rounded);
}
