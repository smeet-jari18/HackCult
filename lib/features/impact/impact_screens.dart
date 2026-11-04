import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/v3.dart';
import '../../core/widgets/widgets.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';

class ImpactScreen extends StatefulWidget {
  const ImpactScreen({super.key});

  @override
  State<ImpactScreen> createState() => _ImpactScreenState();
}


class _ImpactScreenState extends State<ImpactScreen> {
  int _tab = 0;
  bool _breakdownOpen = true;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final u = s.user!;
    final t = Theme.of(context).textTheme;
    final baseline = s.baseline;
    final entries = s.footprints.where((f) => !f.isBaseline).toList();
    final latest = entries.isEmpty ? baseline : entries.last;

    return Scaffold(
      appBar: const BrandAppBar(subtitle: '', showAvatar: false),
      body: baseline == null || latest == null
          ? EmptyState(
              icon: Icons.insights_rounded,
              title: 'Your journey starts here',
              body: "Add this month's units to see your progress",
              actionLabel: 'Add month',
              onAction: () => context.push('/impact/add-month'))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
              children: [
                // ---- Title row ----------------------------------------
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Eyebrow('Citizen Dashboard'),
                          const SizedBox(height: 2),
                          Text('Impact Analytics', style: t.headlineMedium),
                        ],
                      ),
                    ),
                    const SoftChip('GEDA Verified',
                        icon: Icons.verified_rounded,
                        color: AppColors.primaryLight),
                  ],
                ),
                const SizedBox(height: 16),
                SegmentedChoice<int>(
                  value: _tab,
                  height: 46,
                  onChanged: (v) => setState(() => _tab = v),
                  options: const [
                    (0, 'Overview'),
                    (1, 'Credits'),
                    (2, 'Rewards'),
                  ],
                ),
                const SizedBox(height: 16),
                if (_tab == 0) ...[
                  _NetOffsetCard(
                      baseline: baseline,
                      latest: latest,
                      entries: entries,
                      goalPercent: u.goalPercent),
                  const SizedBox(height: 22),
                  // ---- Cumulative benefits carousel ---------------------
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text('Cumulative Benefits',
                                style: t.headlineSmall)),
                        Text('Swipe to see more',
                            style: t.bodySmall
                                ?.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 168,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      children: [
                        _BenefitCard(
                          label: 'Carbon budget',
                          value: '${Fmt.int(s.totalCo2Saved)} kg CO₂',
                          body: 'Emissions avoided this season',
                          icon: Icons.cloud_outlined,
                          progress: (s.totalCo2Saved / 250).clamp(0.05, 1),
                        ),
                        const SizedBox(width: 12),
                        _BenefitCard(
                          label: 'Bill savings',
                          value: Fmt.rupees(s.totalRupeesSaved),
                          body: 'Saved on DISCOM bills so far',
                          icon: Icons.savings_outlined,
                          color: AppColors.warning,
                          progress: (s.totalRupeesSaved / 2000).clamp(0.05, 1),
                        ),
                        const SizedBox(width: 12),
                        _BenefitCard(
                          label: 'Units saved',
                          value: '${Fmt.int(s.totalUnitsSaved)} kWh',
                          body: 'Grid electricity conserved',
                          icon: Icons.bolt_rounded,
                          color: AppColors.tertiary,
                          progress: (s.totalUnitsSaved / 300).clamp(0.05, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ---- Emission breakdown --------------------------------
                  AppCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () => setState(
                              () => _breakdownOpen = !_breakdownOpen),
                          child: Row(
                            children: [
                              const IconBubble(Icons.pie_chart_outline_rounded,
                                  size: 40,
                                  color: AppColors.primary,
                                  circle: true),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Emission breakdown',
                                        style: t.titleMedium
                                            ?.copyWith(fontSize: 17)),
                                    Text('Savings segregated by utility pillar',
                                        style: t.bodySmall),
                                  ],
                                ),
                              ),
                              Icon(
                                  _breakdownOpen
                                      ? Icons.expand_less_rounded
                                      : Icons.expand_more_rounded,
                                  color: AppColors.textSecondary),
                            ],
                          ),
                        ),
                        if (_breakdownOpen) ...[
                          const SizedBox(height: 18),
                          _BreakdownRow(
                            icon: Icons.solar_power_outlined,
                            title: 'Rooftop Solar & Power',
                            kg: latest.electricityKg,
                            total: latest.co2Kg,
                            detail:
                                '${Fmt.int(latest.electricityUnits)} kWh metered',
                            color: AppColors.primaryLight,
                          ),
                          const SizedBox(height: 16),
                          _BreakdownRow(
                            icon: Icons.local_fire_department_outlined,
                            title: 'PNG / LPG Cooking',
                            kg: latest.cookingKg,
                            total: latest.co2Kg,
                            detail: 'Cooking fuel · ${s.gas?.isPng == true ? 'PNG' : 'LPG'}',
                            color: const Color(0xFF8A5A00),
                          ),
                          const SizedBox(height: 16),
                          _BreakdownRow(
                            icon: Icons.directions_bus_outlined,
                            title: 'Commute & Transit',
                            kg: latest.transportKg,
                            total: latest.co2Kg,
                            detail:
                                '${Fmt.int(u.weeklyKm)} km / week · ${u.travelMode}',
                            color: const Color(0xFF7BC67E),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Callout(
                    icon: Icons.shield_outlined,
                    text:
                        'Telemetry authenticated by Gujarat Energy Development '
                        'Agency under LiFE Mission parameters.',
                  ),
                  const SizedBox(height: 18),
                  PrimaryButton(
                    label: 'Add month entry',
                    icon: Icons.add_circle_outline_rounded,
                    onPressed: () => context.push('/impact/add-month'),
                  ),
                  const SizedBox(height: 24),
                  // ---- Monthly entries ----------------------------------
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        Expanded(
                            child:
                                Text('Monthly ledger', style: t.headlineSmall)),
                        Text('${entries.length + 1} months',
                            style: t.bodySmall),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final e in entries.reversed) _EntryTile(entry: e),
                  _EntryTile(entry: baseline),
                ] else if (_tab == 1) ...[
                  _CreditsCard(points: u.points, ledger: s.ledger),
                ] else ...[
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: Text('Redeemable State Benefits',
                                    style: t.titleMedium)),
                            SoftChip(
                                u.points >= 1000 ? 'Eligible now' : 'Locked',
                                color: u.points >= 1000
                                    ? AppColors.primaryLight
                                    : AppColors.textTertiary,
                                dense: true),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _BenefitTile(
                          icon: Icons.apartment_rounded,
                          title: '5% Municipal Property Tax Rebate',
                          body:
                              'Applicable for Ahmedabad (AMC) & Surat (SMC) wards for LiFE Diamond Tier.',
                          action: 'Apply Voucher to Property ID',
                          onTap: () => showAppSnack(context,
                              'Voucher application opens in the ULB portal (coming soon).',
                              icon: Icons.open_in_new_rounded),
                        ),
                        const SizedBox(height: 10),
                        _BenefitTile(
                          icon: Icons.wb_sunny_outlined,
                          title: 'GEDA Solar Equipment Voucher',
                          body:
                              'Additional ₹3,000 state subsidy for certified hybrid inverters or rooftop arrays.',
                          action: 'Claim Subsidy Code',
                          onTap: () => context.push('/hub/solar'),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

/// Net carbon offset hero: eyebrow, big number, trend chip, line chart.
class _NetOffsetCard extends StatelessWidget {
  const _NetOffsetCard({
    required this.baseline,
    required this.latest,
    required this.entries,
    required this.goalPercent,
  });
  final FootprintEntry baseline;
  final FootprintEntry latest;
  final List<FootprintEntry> entries;
  final int goalPercent;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final series = [baseline, ...entries];
    // Show at most the last 5 points; pad with a gentle synthetic lead-in so
    // the chart reads as a trend even for brand-new accounts.
    var values = series.map((e) => e.co2Kg).toList();
    var labels = series.map((e) => Fmt.monthShort(e.month)).toList();
    if (values.length < 3) {
      final first = series.first.month;
      final pad = 3 - values.length;
      values = [
        for (var i = pad; i >= 1; i--) baseline.co2Kg * (1 + 0.04 * i),
        ...values
      ];
      labels = [
        for (var i = pad; i >= 1; i--)
          Fmt.monthShort(DateTime(first.year, first.month - i)),
        ...labels
      ];
    }
    if (values.length > 5) {
      values = values.sublist(values.length - 5);
      labels = labels.sublist(labels.length - 5);
    }
    final target = baseline.co2Kg * (1 - goalPercent / 100);
    final pct = latest.percentChange;
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Eyebrow('Net carbon offset'),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text.rich(TextSpan(children: [
                        TextSpan(
                            text: Fmt.int(latest.co2Kg),
                            style: t.displayMedium?.copyWith(
                                color: AppColors.primary,
                                fontSize: 38,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1)),
                        TextSpan(
                            text: ' kg CO₂',
                            style: t.titleMedium
                                ?.copyWith(color: AppColors.primary)),
                      ])),
                    ),
                  ],
                ),
              ),
              if (pct != 0)
                SoftChip('${pct > 0 ? '+' : ''}${pct.toStringAsFixed(1)}%',
                    icon: pct < 0
                        ? Icons.trending_down_rounded
                        : Icons.trending_up_rounded,
                    color: pct < 0 ? AppColors.primaryLight : AppColors.error),
            ],
          ),
          const SizedBox(height: 8),
          TrendLineChart(
            labels: labels,
            values: values,
            target: (baseline.co2Kg, target),
            height: 230,
            lastLabel: '${labels.last}: ${Fmt.int(values.last)} kg CO₂',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(width: 18, height: 3, color: AppColors.primary),
              const SizedBox(width: 6),
              Flexible(
                  child: Text('Actual trajectory',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.bodySmall)),
              const SizedBox(width: 16),
              Container(
                  width: 18,
                  height: 0,
                  decoration: const BoxDecoration(
                      border: Border(
                          top: BorderSide(
                              color: AppColors.secondary,
                              width: 2,
                              style: BorderStyle.solid)))),
              const SizedBox(width: 6),
              Flexible(
                  child: Text('LiFE state target (−$goalPercent%)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.bodySmall)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Horizontal carousel card ("CARBON BUDGET  150 kg CO₂").
class _BenefitCard extends StatelessWidget {
  const _BenefitCard(
      {required this.label,
      required this.value,
      required this.body,
      required this.icon,
      required this.progress,
      this.color = AppColors.primaryLight});
  final String label;
  final String value;
  final String body;
  final IconData icon;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SizedBox(
      width: 272,
      child: AppCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Eyebrow(label)),
                IconBubble(icon, size: 36, color: color, circle: true),
              ],
            ),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value,
                  style: t.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6)),
            ),
            const SizedBox(height: 2),
            Text(body,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.bodySmall),
            const SizedBox(height: 12),
            CapsuleBar(value: progress, height: 8, color: color),
          ],
        ),
      ),
    );
  }
}

/// Breakdown row: icon · title · kg CO₂, capsule bar, % of total · detail.
class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow(
      {required this.icon,
      required this.title,
      required this.kg,
      required this.total,
      required this.detail,
      required this.color});
  final IconData icon;
  final String title;
  final double kg;
  final double total;
  final String detail;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final share = total <= 0 ? 0.0 : (kg / total).clamp(0, 1).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
                child: Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.titleSmall?.copyWith(fontSize: 15))),
            const SizedBox(width: 8),
            Text('${Fmt.int(kg)} kg CO₂',
                style: t.titleSmall?.copyWith(fontSize: 15)),
          ],
        ),
        const SizedBox(height: 8),
        CapsuleBar(value: share, height: 8, color: color),
        const SizedBox(height: 6),
        Row(
          children: [
            Text('${(share * 100).toStringAsFixed(1)}% of total',
                style: t.bodySmall),
            const Spacer(),
            Flexible(
                child: Text(detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.bodySmall)),
          ],
        ),
      ],
    );
  }
}


class _CreditsCard extends StatelessWidget {
  const _CreditsCard({required this.points, required this.ledger});
  final int points;
  final List<PointsEntry> ledger;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    // Group ledger into the three official buckets.
    int meter = 0, tasks = 0, peak = 0;
    for (final e in ledger) {
      if (e.delta <= 0) continue;
      final r = e.reason.toLowerCase();
      if (r.contains('bill') || r.contains('meter') || r.contains('verified') || r.contains('saved')) {
        meter += e.delta;
      } else if (r.contains('peak') || r.contains('solar hours') || r.contains('shift')) {
        peak += e.delta;
      } else {
        tasks += e.delta;
      }
    }
    final rows = <(IconData, String, int)>[
      (Icons.electric_meter_outlined, 'Smart Meter Auto-Verified', meter),
      (Icons.checklist_rounded, 'Daily Mission LiFE Tasks', tasks),
      (Icons.swap_horiz_rounded, 'Peak Load Shifting (Afternoon)', peak),
    ];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.account_balance_wallet_outlined,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('GEDA Green Credits', style: t.titleMedium),
                    Text('Official Citizen Ledger', style: t.bodySmall),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(Fmt.int(points),
                      style: t.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  Text('Total Credits', style: t.bodySmall),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final (ic, label, pts) in rows)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                  color: AppColors.tint,
                  borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Icon(ic, size: 18, color: AppColors.textPrimary),
                  const SizedBox(width: 10),
                  Expanded(child: Text(label, style: t.titleSmall)),
                  Text('+$pts pts',
                      style: t.labelLarge?.copyWith(color: AppColors.primary)),
                ],
              ),
            ),
          const SizedBox(height: 4),
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => showAppSnack(context, 'Official PDF certificate will be issued after GEDA verification. Your ledger is in Profile → Points history.', icon: Icons.picture_as_pdf_outlined),
              icon: const Icon(Icons.download_outlined, size: 18),
              label: const Text('Download Official Carbon Offset Certificate (PDF)',
                  textAlign: TextAlign.center),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitTile extends StatelessWidget {
  const _BenefitTile(
      {required this.icon,
      required this.title,
      required this.body,
      required this.action,
      required this.onTap});
  final IconData icon;
  final String title;
  final String body;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppColors.tint, borderRadius: BorderRadius.circular(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textPrimary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: t.titleSmall),
                const SizedBox(height: 2),
                Text(body, style: t.bodySmall),
                const SizedBox(height: 6),
                InkWell(
                  onTap: onTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(action,
                          style: t.labelLarge
                              ?.copyWith(color: AppColors.textPrimary)),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry});
  final FootprintEntry entry;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final bill = entry.source == 'bill';
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          IconTile(
              icon: bill ? Icons.receipt_long_rounded : Icons.edit_note_rounded,
              color: bill ? AppColors.tertiary : AppColors.textSecondary,
              size: 42,
              iconSize: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(Fmt.month(entry.month), style: t.titleSmall),
                Text(
                    '${Fmt.units(entry.electricityUnits)} · ${bill ? 'Bill verified' : 'Manual entry'}',
                    style: t.labelSmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(Fmt.kg(entry.co2Kg, decimals: 0), style: t.titleSmall),
              if (entry.unitsSaved > 0)
                DeltaChip(
                    label: '${Fmt.int(entry.unitsSaved)} units',
                    positive: true),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add month
// ---------------------------------------------------------------------------
class AddMonthScreen extends StatefulWidget {
  const AddMonthScreen({super.key});

  @override
  State<AddMonthScreen> createState() => _AddMonthScreenState();
}

class _AddMonthScreenState extends State<AddMonthScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  bool _byBill = false;
  final _value = TextEditingController();
  bool _photo = false;
  bool _sameCooking = true;
  bool _sameTravel = true;
  bool _saving = false;

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final s = AppScope.read(context);
    final raw = double.tryParse(_value.text) ?? 0;
    if (raw <= 0) {
      showAppSnack(context, 'Enter units or bill amount',
          icon: Icons.error_outline_rounded, color: AppColors.error);
      return;
    }
    final units = _byBill ? s.footprintCalc.unitsFromBill(raw) : raw;
    final exists = s.footprints.any((f) =>
        !f.isBaseline &&
        f.month.year == _month.year &&
        f.month.month == _month.month);
    if (exists) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Update existing entry?'),
          content: Text(
              'You already added ${Fmt.month(_month)}. Replace it with the new value?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
                child: const Text('Replace')),
          ],
        ),
      );
      if (ok != true) return;
    }
    setState(() => _saving = true);
    late final int points;
    try {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      points = await s.addMonth(
        month: _month,
        units: units,
        fromBill: _photo,
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'Saving monthly impact entry',
      ));
      if (!mounted) return;
      setState(() => _saving = false);
      showAppSnack(
        context,
        'Could not save your impact entry: $error',
        icon: Icons.error_outline_rounded,
        color: AppColors.error,
      );
      return;
    }
    if (!mounted) return;
    final saved = math.max(0.0, s.user!.baselineUnits - units);
    if (points > 0) showConfetti(context);
    showAppSnack(
      context,
      points > 0
          ? 'Saved ${saved.round()} units vs baseline · +$points points (bill verified)'
          : s.isLiveBackend
              ? 'Entry saved. Reward points are unavailable until secure verification is deployed.'
              : saved > 0
                  ? 'Saved ${saved.round()} units vs baseline. Add a bill photo next time to earn points!'
                  : 'Entry saved. Check today\'s nudges for quick wins.',
      icon: Icons.check_circle_rounded,
      color: AppColors.primary,
    );
    context.safePop('/impact');
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final s = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(
          leading: const SafeBackButton(fallback: '/impact'),
          title: const Text('Add month')),
      body: PhoneFrame(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Billing month', style: t.titleSmall),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () => setState(() =>
                          _month = DateTime(_month.year, _month.month - 1)),
                      icon: const Icon(Icons.chevron_left_rounded)),
                  Expanded(
                      child: Text(Fmt.month(_month),
                          textAlign: TextAlign.center, style: t.titleMedium)),
                  IconButton(
                    onPressed: _month.isBefore(
                            DateTime(DateTime.now().year, DateTime.now().month))
                        ? () => setState(() =>
                            _month = DateTime(_month.year, _month.month + 1))
                        : null,
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                    value: false,
                    label: Text('Units (kWh)'),
                    icon: Icon(Icons.bolt_rounded, size: 16)),
                ButtonSegment(
                    value: true,
                    label: Text('Bill amount ₹'),
                    icon: Icon(Icons.currency_rupee_rounded, size: 16)),
              ],
              selected: {_byBill},
              onSelectionChanged: (v) => setState(() => _byBill = v.first),
              style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: AppColors.primarySoft,
                  selectedForegroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.border)),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: _byBill ? 'Bill amount' : 'Units consumed',
              controller: _value,
              hint: _byBill ? 'e.g. 1,500' : 'e.g. 210',
              keyboardType: TextInputType.number,
              prefixIcon:
                  _byBill ? Icons.currency_rupee_rounded : Icons.bolt_rounded,
              helper:
                  'Your baseline is ${Fmt.int(s.user!.baselineUnits)} units / month',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),
            if (s.isLiveBackend) ...[
              const InfoBanner(
                text:
                    'Bill photo verification is not configured yet. You can save the monthly units now; rewards will be available after secure verification is deployed.',
                icon: Icons.info_outline_rounded,
              ),
            ] else ...[
              Text('Bill photo (for verified points)', style: t.titleSmall),
              const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => setState(() => _photo = !_photo),
                child: Container(
                  height: 130,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: _photo ? AppColors.primarySoft : AppColors.surface,
                    border: Border.all(
                        color: _photo ? AppColors.primary : AppColors.border,
                        width: 1.5),
                  ),
                  child: _photo
                      ? Row(
                          children: [
                            Container(
                              width: 110,
                              margin: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFDDE7DD),
                                  borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.receipt_long_rounded,
                                  size: 40, color: Colors.white),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'bill_${_month.year}${_month.month.toString().padLeft(2, '0')}.jpg',
                                      style: t.titleSmall),
                                  const SizedBox(height: 4),
                                  const StatusTag(
                                      label: 'OCR: units detected ✓',
                                      color: AppColors.success),
                                  const SizedBox(height: 6),
                                  Text('Tap to remove', style: t.labelSmall),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_a_photo_outlined,
                                color: AppColors.primary, size: 30),
                            const SizedBox(height: 8),
                            Text('Add bill photo',
                                style: t.labelLarge
                                    ?.copyWith(color: AppColors.primary)),
                            Text(
                                'Earn ${s.config.pointsPerUnitSaved} points per unit saved',
                                style: t.labelSmall),
                          ],
                        ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Text('Other sources', style: t.titleSmall),
            const SizedBox(height: 4),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Cooking fuel same as before'),
              subtitle: const Text('LPG / PNG usage unchanged'),
              value: _sameCooking,
              onChanged: (v) => setState(() => _sameCooking = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Travel same as before'),
              subtitle: const Text('Weekly km unchanged'),
              value: _sameTravel,
              onChanged: (v) => setState(() => _sameTravel = v),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
                label: 'Save entry',
                onPressed: _save,
                loading: _saving,
                icon: Icons.check_rounded),
          ],
        ),
      ),
    );
  }
}
