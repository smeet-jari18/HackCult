import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/logic/calculators.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/v3.dart';
import '../../core/widgets/widgets.dart';
import '../../data/app_state.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  String _scope = 'community';
  bool _weekly = false;
  int _tab = 0; // 0 leaderboard · 1 challenges · 2 noticeboard

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBoard());
  }

  void _loadBoard() {
    if (!mounted) return;
    final s = AppScope.read(context);
    final scope =
        s.myCommunity == null && _scope == 'community' ? 'district' : _scope;
    s.refreshLeaderboard(scope, weekly: _weekly);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final t = Theme.of(context).textTheme;
    final c = s.myCommunity;
    final g = s.myGoal;
    final board = s.leaderboard(
        c == null && _scope == 'community' ? 'district' : _scope,
        weekly: _weekly);
    final ratio = g?.ratio ?? (c == null ? 0.0 : 0.42);
    final monthKg = c == null
        ? 0.0
        : c.totalUnitsSaved * s.config.factors.electricity;

    return Scaffold(
      appBar: const BrandAppBar(subtitle: '', showAvatar: false),
      body: RefreshIndicator(
        onRefresh: () async {
          try {
            await s.refreshCommunityProgress();
            _loadBoard();
          } catch (error) {
            if (!context.mounted) return;
            showAppSnack(
              context,
              'Could not refresh community goal: $error',
              icon: Icons.error_outline_rounded,
              color: AppColors.error,
            );
          }
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
          children: [
            // ---- Header card --------------------------------------------
            AppCard(
              padding: const EdgeInsets.all(18),
              onTap: c == null ? () => context.push('/community/join') : null,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const SoftChip('GEDA Citizen Hub',
                                color: AppColors.primaryLight, dense: true),
                            if (c != null)
                              Text(_wardLabel(c).replaceFirst('Ward', 'Zone'),
                                  style: t.labelMedium?.copyWith(
                                      color: AppColors.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                            c == null
                                ? 'Join your society or ward'
                                : '${_wardLabel(c)} • ${c.name}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: t.headlineSmall),
                        const SizedBox(height: 2),
                        Text(
                            c == null
                                ? 'Compete together and earn bonus credits'
                                : 'Active Civic Sustainability Mission',
                            style: t.bodyMedium
                                ?.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 56,
                    height: 56,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppShadows.level1),
                    child: Image.asset('assets/images/emblem.png'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ---- Ring gauge ---------------------------------------------
            AppCard(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 22),
              child: Column(
                children: [
                  RingGauge(
                    value: ratio,
                    size: 210,
                    stroke: 20,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${(ratio * 100).round()}%',
                            style: t.displayMedium?.copyWith(
                                color: AppColors.primary,
                                fontSize: 44,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.5)),
                        const Eyebrow('Ward clean goal'),
                        const SizedBox(height: 8),
                        SoftChip(
                            g == null
                                ? 'Set a goal'
                                : '${g.daysLeft} days left',
                            icon: Icons.trending_up_rounded,
                            color: AppColors.primaryLight,
                            dense: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_outlined,
                          size: 20, color: AppColors.primaryLight),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text.rich(
                          TextSpan(children: [
                            TextSpan(
                                text: '${Fmt.int(monthKg)} kg CO₂ ',
                                style: t.titleMedium
                                    ?.copyWith(color: AppColors.primary)),
                            TextSpan(
                                text: 'reduced this month',
                                style: t.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary)),
                          ]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (g != null) ...[
                    const SizedBox(height: 14),
                    CapsuleBar(value: g.ratio, height: 8),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(g.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: t.bodySmall),
                        ),
                        Text(
                            '${Fmt.compact(g.progress)} / ${Fmt.compact(g.target)} ${_metricLabel(g.metric)}',
                            style: t.labelMedium),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ---- Tabs -------------------------------------------------
            SegmentedChoice<int>(
              value: _tab,
              height: 46,
              onChanged: (v) => setState(() => _tab = v),
              options: const [
                (0, 'Contributors'),
                (1, 'Challenges'),
                (2, 'Noticeboard'),
              ],
            ),
            const SizedBox(height: 16),

            if (_tab == 0) ...[
              AppCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Top Ward Contributors',
                                  style: t.headlineSmall),
                              Text(
                                  '${Fmt.month(DateTime.now())} • ${_weekly ? 'This week' : 'All time'} • Verified telemetry',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: t.bodySmall),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: () {
                            setState(() => _weekly = !_weekly);
                            _loadBoard();
                          },
                          child: SoftChip(_weekly ? 'Weekly' : 'Rankings',
                              icon: Icons.emoji_events_outlined,
                              color: AppColors.warning,
                              dense: true),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      runSpacing: 6,
                      children: [
                        for (final (v, l) in const [
                          ('community', 'Society'),
                          ('district', 'District'),
                          ('state', 'Gujarat'),
                        ]) ...[
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(l),
                              selected: _scope == v,
                              onSelected: (_) {
                                setState(() => _scope = v);
                                _loadBoard();
                              },
                              labelStyle: t.labelMedium?.copyWith(
                                  color: _scope == v
                                      ? Colors.white
                                      : AppColors.textPrimary),
                              backgroundColor: AppColors.tint,
                              side: BorderSide.none,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 14),
                    for (final e in board.take(6)) _PerformerRow(entry: e),
                    if (board.length > 6 &&
                        board.indexWhere((e) => e.isMe) >= 6) ...[
                      const Divider(height: 18),
                      _PerformerRow(entry: board.firstWhere((e) => e.isMe)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (c != null && g != null)
                PrimaryButton(
                  label: g.myContribution > 0
                      ? 'View Community Challenge'
                      : 'Join Community Challenge',
                  icon: Icons.emoji_events_outlined,
                  onPressed: () => context.push('/community/goals/${g.id}'),
                )
              else
                PrimaryButton(
                  label: c == null ? 'Join a Community' : 'Create a Challenge',
                  icon: Icons.add_rounded,
                  onPressed: () => context.push(
                      c == null ? '/community/join' : '/community/create'),
                ),
              const SizedBox(height: 12),
              InfoBanner(
                  text: s.isLiveBackend
                      ? 'Rankings update live from GEDA servers · weekly points reset every Monday.'
                      : 'Points reset weekly for the challenge board. All-time points decide your level.',
                  icon: Icons.emoji_events_outlined,
                  color: AppColors.secondary),
            ],
            if (_tab == 1) ...[
              if (g != null && c != null)
                _ChallengeCard(goal: g, community: c)
              else
                EmptyState(
                    icon: Icons.flag_outlined,
                    title: 'No active challenge',
                    body: c == null
                        ? 'Join a society to take part in ward challenges.'
                        : 'Create a society goal to start a challenge.',
                    actionLabel: c == null ? 'Join community' : 'Create goal',
                    onAction: () => context.push(
                        c == null ? '/community/join' : '/community/create')),
            ],
            if (_tab == 2)
              _Noticeboard(
                  community: c,
                  onInvite: c == null ? null : () => _showInvite(context, c)),
            if (c != null) ...[
              const SizedBox(height: 16),
              Center(
                child: TextButton.icon(
                  onPressed: () => _showInvite(context, c),
                  icon: const Icon(Icons.share_outlined, size: 18),
                  label: Text('Invite neighbours · code ${c.joinCode}'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }


  String _wardLabel(Community c) {
    final n = c.pincode.isEmpty ? 9 : (int.tryParse(c.pincode) ?? 9) % 50 + 1;
    return 'Ward $n';
  }


  void _showInvite(BuildContext context, Community c) {
    final t = Theme.of(context).textTheme;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Invite neighbours', style: t.titleLarge),
            const SizedBox(height: 6),
            Text(
                'Share this code. Every member who joins and completes a task earns you +100 referral points.',
                style: t.bodyMedium),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryContainer)),
              child: Row(
                children: [
                  Expanded(
                      child: Text(c.joinCode,
                          style: t.headlineMedium?.copyWith(
                              letterSpacing: 4, color: AppColors.primary))),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(
                          text:
                              'Join ${c.name} on LiFE Mitra Gujarat! Code: ${c.joinCode}'));
                      Navigator.pop(ctx);
                      showAppSnack(context, 'Invite copied to clipboard',
                          icon: Icons.copy_rounded);
                    },
                    icon: const Icon(Icons.copy_rounded,
                        color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            PrimaryButton(
              label: 'Share on WhatsApp',
              icon: Icons.share_rounded,
              onPressed: () {
                Navigator.pop(ctx);
                showAppSnack(
                    context, 'Share sheet would open here (share_plus)',
                    icon: Icons.share_rounded);
              },
            ),
          ],
        ),
      ),
    );
  }
}

IconData _typeIcon(String type) => switch (type) {
      'Village' => Icons.holiday_village_rounded,
      'School' => Icons.school_rounded,
      'Ward' => Icons.location_city_rounded,
      'Office' => Icons.business_rounded,
      _ => Icons.apartment_rounded,
    };

String _metricLabel(String m) => switch (m) {
      'units' => 'units',
      'tasks' => 'tasks',
      'co2' => 'kg CO₂',
      _ => m
    };

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.goal, required this.community});
  final CommunityGoal goal;
  final Community community;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final g = goal;
    final joined = g.myContribution > 0;
    return AppCard(
      onTap: () => context.push('/community/goals/${g.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                flex: 3,
                child: Tag('Active Challenge',
                    icon: Icons.eco_outlined,
                    color: AppColors.primaryContainer,
                    textColor: AppColors.primaryDark),
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 2,
                child: Text(
                    g.daysLeft == 0
                        ? 'Ends today'
                        : 'Ends in ${g.daysLeft} day${g.daysLeft == 1 ? '' : 's'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: t.bodySmall),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(g.title, style: t.titleLarge),
          const SizedBox(height: 4),
          Text(
              g.metric == 'units'
                  ? '6:00 PM – 10:00 PM · Shift cooling to 26°C and heavy loads to solar hours to avoid state grid strain.'
                  : 'Every household in ${community.name} contributes. Track progress together and earn bonus credits.',
              style: t.bodyMedium?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: AppColors.tint, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Collective Goal',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.bodySmall),
                      Text(
                          '${Fmt.compact(g.target)} ${_metricLabel(g.metric)} ${g.metric == 'units' ? 'Reduction' : ''}'
                              .trim(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: t.titleSmall),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Household Reward',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.bodySmall),
                      Text('+${g.bonusPoints} Credits & Trophy',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style: t.titleSmall
                              ?.copyWith(color: AppColors.primary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          GoalProgressBar(
            value: g.ratio,
            label:
                '${Fmt.compact(g.progress)} / ${Fmt.compact(g.target)} ${_metricLabel(g.metric)}',
            trailing: '${(g.ratio * 100).round()}%',
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: joined ? 'View Challenge Progress' : 'Join Challenge',
            icon: joined ? Icons.insights_outlined : Icons.task_alt_rounded,
            height: 48,
            onPressed: () => context.push('/community/goals/${g.id}'),
          ),
        ],
      ),
    );
  }
}

class _PerformerRow extends StatelessWidget {
  const _PerformerRow({required this.entry});
  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final e = entry;
    final lvl = LevelEngine.levelFor(e.points);
    final gold = e.rank == 1;
    const roles = [
      'Solar Advocate',
      'Waste Warrior',
      'Green Commuter',
      'Energy Saver',
      'Water Guardian',
      'Compost Champion',
    ];
    final role = roles[e.name.hashCode.abs() % roles.length];
    final parts = e.name.trim().split(RegExp(r'\s+'));
    final initials = parts.length >= 2
        ? '${parts.first[0]}${parts[1][0]}'.toUpperCase()
        : e.name.substring(0, e.name.length >= 2 ? 2 : 1).toUpperCase();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: e.isMe ? AppColors.primaryContainer.withValues(alpha: 0.35) : AppColors.tint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: e.isMe ? AppColors.primaryLight : Colors.transparent),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: e.isMe ? AppColors.primary : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border)),
                child: Text(initials,
                    style: t.labelLarge?.copyWith(
                        color: e.isMe ? Colors.white : AppColors.primary)),
              ),
              Positioned(
                left: -6,
                top: -6,
                child: Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: gold
                          ? AppColors.warning
                          : (e.rank <= 3
                              ? AppColors.primaryLight
                              : AppColors.textSecondary),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2)),
                  child: Text('${e.rank}',
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(e.isMe ? 'You' : e.name,
                          style: t.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    if (e.isMe) ...[
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text('(${e.name.split(' ').first})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.bodySmall),
                      ),
                    ],
                  ],
                ),
                Text(e.isMe ? '${lvl.$2} tier' : role, style: t.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(Fmt.int(e.points),
                  style: t.titleMedium?.copyWith(
                      color: e.isMe ? AppColors.primary : AppColors.textPrimary)),
              Text(e.isMe ? 'Your rank #${e.rank}' : 'pts',
                  style: t.labelSmall?.copyWith(
                      color: e.isMe
                          ? AppColors.primaryLight
                          : AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Noticeboard extends StatelessWidget {
  const _Noticeboard({required this.community, required this.onInvite});
  final Community? community;
  final VoidCallback? onInvite;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = community;
    final posted = DateTime.now().subtract(const Duration(hours: 3));
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                    color: AppColors.tint,
                    borderRadius: BorderRadius.circular(6)),
                child: const Icon(Icons.campaign_outlined,
                    size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(
                      c == null ? 'GEDA Noticeboard' : 'Society Green Noticeboard',
                      style: t.titleMedium)),
              Text('Today, ${Fmt.dateTime(posted).split(', ').last}',
                  style: t.bodySmall),
            ],
          ),
          const Divider(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: AppColors.tint,
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.solar_power_outlined,
                    color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        c == null
                            ? 'PM Surya Ghar: Gujarat households up to 2.18 kW now pay only 10% of benchmark cost after the new state top-up subsidy.'
                            : 'Society Solar Rooftop bulk survey approved by GEDA. 12 flats scheduled for site audit on Sunday.',
                        style: t.bodyMedium),
                    const SizedBox(height: 4),
                    Text(
                        c == null
                            ? 'Posted by GEDA (Gandhinagar)'
                            : 'Posted by Management Committee (${c.name})',
                        style: t.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: onInvite ??
                        () => context.push('/community/join'),
                    icon: Icon(
                        onInvite == null
                            ? Icons.group_add_outlined
                            : Icons.person_add_alt_1_outlined,
                        size: 18),
                    label: Text(onInvite == null ? 'Join Society' : 'Invite Neighbor'),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PrimaryButton(
                  label: 'Post Update',
                  icon: Icons.edit_note_rounded,
                  height: 48,
                  onPressed: () => showAppSnack(context,
                      c == null
                          ? 'Join a society first to post updates.'
                          : 'Posting is enabled for captains in the next release.',
                      icon: Icons.info_outline_rounded),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Join / create community
// ---------------------------------------------------------------------------
class JoinCommunityScreen extends StatefulWidget {
  const JoinCommunityScreen({super.key, this.fromOnboarding = false});
  final bool fromOnboarding;

  @override
  State<JoinCommunityScreen> createState() => _JoinCommunityScreenState();
}

class _JoinCommunityScreenState extends State<JoinCommunityScreen> {
  final _search = TextEditingController();
  final _code = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    _code.dispose();
    super.dispose();
  }

  void _afterJoin(Community c) {
    showAppSnack(context, 'Welcome to ${c.name}!',
        icon: Icons.celebration_rounded, color: AppColors.primary);
    if (widget.fromOnboarding) {
      context.go('/home');
    } else {
      context.safePop('/community');
    }
  }

  Future<void> _join(Community c) async {
    final s = AppScope.read(context);
    final ok = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final t = Theme.of(ctx).textTheme;
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconTile(icon: _typeIcon(c.type), color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.name, style: t.titleLarge),
                        Text('${c.type} · ${c.district} · ${c.pincode}',
                            style: t.labelSmall)
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: _MiniStat(
                          value: Fmt.int(c.memberCount), label: 'members')),
                  Expanded(
                      child: _MiniStat(
                          value: Fmt.compact(c.totalUnitsSaved),
                          label: 'units saved')),
                  Expanded(
                      child: _MiniStat(
                          value: s.goalById(c.id) == null ? 'None' : 'Active',
                          label: 'goal')),
                ],
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                  label: 'Join ${c.type.toLowerCase()}',
                  onPressed: () => Navigator.pop(ctx, true)),
            ],
          ),
        );
      },
    );
    if (ok == true && mounted) {
      try {
        await s.joinCommunity(c);
        if (mounted) _afterJoin(c);
      } catch (error) {
        if (!mounted) return;
        showAppSnack(
          context,
          'Could not join this community: $error',
          icon: Icons.error_outline_rounded,
          color: AppColors.error,
        );
      }
    }
  }

  Future<void> _joinByCode() async {
    final code = _code.text.trim().toUpperCase();
    late final Community? c;
    try {
      c = await AppScope.read(context).communityByJoinCode(code);
    } catch (error) {
      if (!mounted) return;
      showAppSnack(
        context,
        'Could not look up that community: $error',
        icon: Icons.error_outline_rounded,
        color: AppColors.error,
      );
      return;
    }
    if (c == null) {
      showAppSnack(context, 'Code not found. Check with your society captain.',
          icon: Icons.error_outline_rounded, color: AppColors.error);
      return;
    }
    await _join(c);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final t = Theme.of(context).textTheme;
    final u = s.user!;
    final all = s.communities;
    final list = (_query.isEmpty
            ? all.where((c) => c.district == u.district).toList()
            : all
                .where((c) =>
                    c.name.toLowerCase().contains(_query) ||
                    c.pincode.contains(_query) ||
                    c.district.toLowerCase().contains(_query))
                .toList())
        .where((c) => c.id != u.communityId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        leading: const SafeBackButton(fallback: '/community'),
        title: const Text('Join a community'),
        actions: [
          if (s.isLiveBackend)
            IconButton(
              tooltip: 'Refresh communities',
              onPressed: () async {
                try {
                  await s.refreshCommunities();
                } catch (error) {
                  if (!context.mounted) return;
                  showAppSnack(
                    context,
                    'Could not load communities: $error',
                    icon: Icons.error_outline_rounded,
                    color: AppColors.error,
                  );
                }
              },
              icon: const Icon(Icons.refresh_rounded),
            ),
          if (widget.fromOnboarding)
            TextButton(
                onPressed: () => context.go('/home'),
                child: const Text('Skip')),
        ],
      ),
      body: PhoneFrame(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Save together', style: t.headlineSmall),
            const SizedBox(height: 4),
            Text(
                'Communities with shared goals save 2× more. Find yours by name or pincode.',
                style: t.bodyMedium),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Search',
              controller: _search,
              hint: 'Society, ward, village or pincode',
              prefixIcon: Icons.search_rounded,
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            ),
            const SizedBox(height: 16),
            if (_query.isEmpty)
              Text('Near you · ${u.district}', style: t.titleSmall),
            const SizedBox(height: 8),
            if (list.isEmpty)
              const EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'Nothing found',
                  body: 'Try a pincode, or create your community below',
                  compact: true)
            else
              for (final c in list)
                AppCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  onTap: () => _join(c),
                  child: Row(
                    children: [
                      IconTile(
                          icon: _typeIcon(c.type),
                          color: AppColors.primary,
                          size: 44,
                          iconSize: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.name, style: t.titleSmall),
                            Text(
                                '${c.type} · ${c.pincode} · ${Fmt.int(c.memberCount)} members',
                                style: t.labelSmall),
                          ],
                        ),
                      ),
                      TextButton(
                          onPressed: () => _join(c), child: const Text('Join')),
                    ],
                  ),
                ),
            const SizedBox(height: 10),
            Text('Have a join code?', style: t.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Join code',
                    controller: _code,
                    hint: 'e.g. SHNT15',
                    prefixIcon: Icons.qr_code_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(top: 22),
                  child: SizedBox(
                      height: 52,
                      child: FilledButton(
                          onPressed: _joinByCode, child: const Text('Go'))),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AppCard(
              color: AppColors.secondarySoft,
              border: false,
              onTap: () async {
                final created =
                    await context.push<Community>('/community/create');
                if (created != null && mounted) _afterJoin(created);
              },
              child: Row(
                children: [
                  const IconTile(
                      icon: Icons.add_home_work_rounded,
                      color: AppColors.warning),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Can't find yours? Create it",
                            style: t.titleSmall),
                        Text(
                            'Become the captain · earn the Community Builder badge',
                            style: t.labelSmall),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textSecondary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateCommunityScreen extends StatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  State<CreateCommunityScreen> createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends State<CreateCommunityScreen> {
  final _name = TextEditingController();
  late final _pin =
      TextEditingController(text: AppScope.read(context).user!.pincode);
  String _type = 'Society';
  bool _accept = false;
  bool _saving = false;
  String? _nameError;

  @override
  void dispose() {
    _name.dispose();
    _pin.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_saving) return;
    setState(() => _nameError =
        _name.text.trim().length < 3 ? 'Enter at least 3 characters' : null);
    if (_nameError != null) return;
    if (_pin.text.trim().length != 6) {
      showAppSnack(context, 'Enter a valid 6-digit pincode',
          icon: Icons.error_outline_rounded, color: AppColors.error);
      return;
    }
    setState(() => _saving = true);
    try {
      final c = await AppScope.read(context).createCommunity(
          name: _name.text.trim(), type: _type, pincode: _pin.text.trim());
      if (!mounted) return;
      if (context.canPop()) {
        context.pop(c);
      } else {
        context.go('/community');
      }
    } catch (error) {
      if (!mounted) return;
      showAppSnack(
        context,
        'Could not create community: $error',
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
          leading: const SafeBackButton(fallback: '/community/join'),
          title: const Text('Create community')),
      body: PhoneFrame(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppTextField(
                label: 'Community name',
                controller: _name,
                hint: 'e.g. Shanti Nagar Society',
                errorText: _nameError,
                prefixIcon: Icons.badge_outlined),
            const SizedBox(height: 16),
            Text('Type', style: t.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final ty in const [
                  'Society',
                  'Ward',
                  'Village',
                  'School',
                  'Office'
                ])
                  ChoiceChip(
                    label: Text(ty),
                    avatar: Icon(_typeIcon(ty),
                        size: 16,
                        color: _type == ty
                            ? AppColors.primary
                            : AppColors.textSecondary),
                    selected: _type == ty,
                    onSelected: (_) => setState(() => _type = ty),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Pincode',
              controller: _pin,
              keyboardType: TextInputType.number,
              maxLength: 6,
              prefixIcon: Icons.location_on_outlined,
              helper: 'District: ${MockData.districtFromPin(_pin.text)}',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              value: _accept,
              onChanged: (v) => setState(() => _accept = v ?? false),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                  'I agree to be the community captain and keep it respectful',
                  style: t.bodyMedium),
            ),
            const SizedBox(height: 12),
            PrimaryButton(
                label: _saving ? 'Creating...' : 'Create & become captain',
                onPressed: _accept && !_saving ? _create : null,
                icon: Icons.star_rounded),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Goal detail
// ---------------------------------------------------------------------------
class GoalDetailScreen extends StatelessWidget {
  const GoalDetailScreen({super.key, required this.goalId});
  final String goalId;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final t = Theme.of(context).textTheme;
    final g = s.goalById(goalId);
    if (g == null) {
      return Scaffold(
          appBar: AppBar(
            leading: const SafeBackButton(fallback: '/community'),
          ),
          body: const EmptyState(
              icon: Icons.flag_outlined,
              title: 'Goal not found',
              body: 'This goal may have ended'));
    }
    final c = s.communityById(g.communityId);
    if (c == null) {
      return Scaffold(
        appBar: AppBar(
          leading: const SafeBackButton(fallback: '/community'),
        ),
        body: const EmptyState(
          icon: Icons.groups_outlined,
          title: 'Community not found',
          body: 'Join or create a community to view its goal.',
        ),
      );
    }
    final perDay = g.daysLeft == 0 ? 0 : (g.target - g.progress) / g.daysLeft;
    final contributors = s.leaderboard('community').take(5).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Community goal')),
      body: PhoneFrame(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppCard(
              gradient: AppColors.heroGreen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.name,
                      style: t.labelMedium?.copyWith(color: Colors.white70)),
                  const SizedBox(height: 4),
                  Text(g.title,
                      style: t.headlineSmall?.copyWith(color: Colors.white)),
                  const SizedBox(height: 16),
                  Center(
                    child: ProgressRing(
                      value: g.ratio,
                      size: 150,
                      stroke: 14,
                      color: AppColors.secondary,
                      track: Colors.white24,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${(g.ratio * 100).round()}%',
                              style: t.headlineMedium
                                  ?.copyWith(color: Colors.white)),
                          Text(
                              '${Fmt.compact(g.progress)} / ${Fmt.compact(g.target)}',
                              style: t.labelSmall
                                  ?.copyWith(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _HeroStat(value: '${g.daysLeft}', label: 'days left'),
                      _HeroStat(
                          value: Fmt.compact(perDay),
                          label: '${_metricLabel(g.metric)} / day needed'),
                      _HeroStat(
                          value: '+${g.bonusPoints}', label: 'bonus points'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your contribution', style: t.titleSmall),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                            '${Fmt.compact(g.myContribution)} ${_metricLabel(g.metric)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.headlineSmall
                                ?.copyWith(color: AppColors.primary)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                          g.progress == 0
                              ? ''
                              : '${(g.myContribution / g.progress * 100).toStringAsFixed(1)}% of total',
                          style: t.labelSmall),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GoalProgressBar(
                      value: g.progress == 0
                          ? 0
                          : (g.myContribution / g.progress).clamp(0, 1),
                      color: AppColors.secondary,
                      height: 8),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const SectionHeader(title: 'Top contributors'),
            AppCard(
              padding: const EdgeInsets.all(6),
              child: Column(children: [
                for (final e in contributors)
                  LeaderboardTile(entry: e, dense: true)
              ]),
            ),
            const SizedBox(height: 16),
            const SectionHeader(title: 'Quick ways to help'),
            for (final id in const ['load_shift_wm', 'ac_24', 'led_swap'])
              Builder(builder: (context) {
                final task = MockData.taskById(id);
                return AppCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  onTap: () => context.go('/home'),
                  child: Row(
                    children: [
                      IconTile(
                          icon: task.theme.icon,
                          color: task.theme.color,
                          size: 42,
                          iconSize: 22),
                      const SizedBox(width: 12),
                      Expanded(child: Text(task.title, style: t.titleSmall)),
                      Pill(
                          label: '+${task.points}',
                          color: AppColors.primarySoft,
                          textColor: AppColors.primary),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 8),
            SecondaryButton(
                label: 'Invite neighbours',
                icon: Icons.person_add_alt_1_rounded,
                onPressed: () => showAppSnack(
                    context, 'Join code: ${c.joinCode}',
                    icon: Icons.qr_code_rounded)),
          ],
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: t.titleLarge?.copyWith(color: Colors.white)),
          Text(label, style: t.labelSmall?.copyWith(color: Colors.white70))
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: t.titleMedium?.copyWith(color: AppColors.primary)),
        Text(label, style: t.labelSmall)
      ],
    );
  }
}
