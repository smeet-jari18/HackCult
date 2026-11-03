import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/v3.dart';
import '../../core/services/links.dart';
import '../../core/widgets/widgets.dart';
import '../../data/app_state.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';

class HubScreen extends StatelessWidget {
  const HubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final t = Theme.of(context).textTheme;
    final last = s.assessments.firstOrNull;
    final solarVendors = MockData.vendors
        .where((v) =>
            v.category == 'solar' && v.districts.contains(s.user!.district))
        .toList();
    final gasLinked = s.gas != null;

    return Scaffold(
      appBar: const BrandAppBar(subtitle: '', showAvatar: false),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          // ---- Intro card -----------------------------------------------
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: Opacity(
                    opacity: 0.08,
                    child: Image.asset('assets/images/logo.png', width: 120),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SoftChip('GEDA approved green utilities',
                        icon: Icons.circle,
                        color: AppColors.primaryLight,
                        dense: true),
                    const SizedBox(height: 12),
                    Text('Civic Services Hub', style: t.headlineMedium),
                    const SizedBox(height: 6),
                    Text(
                        'Streamline home telemetry, verified clean energy transition programs, and municipal solar subsidies across Gujarat state.',
                        style: t.bodyMedium
                            ?.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                          color: AppColors.tint,
                          borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_user_outlined,
                              color: AppColors.primary, size: 22),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Eyebrow('Portal authority'),
                              Text('Govt. of Gujarat',
                                  style: t.titleSmall
                                      ?.copyWith(color: AppColors.primary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ---- Solar calculator -----------------------------------------
          _HubFeatureCard(
            icon: Icons.wb_sunny_outlined,
            iconColor: AppColors.primaryLight,
            eyebrow: 'Telemetry & sizing',
            title: 'Solar Calculator',
            body:
                'Calculate your rooftop PV potential, monthly DISCOM savings, and direct subsidy transfer under PM Surya Ghar Yojana.',
            badge: 'Up to ₹78,000 subsidy',
            badgeColor: AppColors.warning,
            badgeIcon: Icons.currency_rupee_rounded,
            action: last == null
                ? 'Calculate Potential'
                : 'Last estimate: ${last.sizeKw.toStringAsFixed(1)} kW',
            highlighted: true,
            onTap: () => context.push(last == null
                ? '/hub/solar'
                : '/hub/solar/result/${last.id}'),
            onSecondary: last == null ? null : () => context.push('/hub/solar'),
          ),
          const SizedBox(height: 16),

          // ---- Gas connection -------------------------------------------
          _HubFeatureCard(
            icon: Icons.local_fire_department_outlined,
            iconColor: AppColors.textSecondary,
            eyebrow: 'Utility sync',
            title: 'Link Gas Connection',
            body:
                'Connect Adani Total Gas, Gujarat Gas, or Sabarmati Gas smart IDs for integrated domestic carbon-offset credit logs.',
            badge: gasLinked ? 'Linked' : 'PNG / LPG meter sync',
            badgeColor:
                gasLinked ? AppColors.primaryLight : AppColors.textSecondary,
            action: gasLinked ? 'Manage Account' : 'Configure Account',
            onTap: () => context.push('/home/gas'),
          ),
          const SizedBox(height: 16),

          // ---- Departmental services ------------------------------------
          AppCard(
            padding: const EdgeInsets.all(18),
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
                          const Eyebrow('Gujarat energy desk'),
                          const SizedBox(height: 4),
                          Text('Departmental Services & Guidelines',
                              style: t.headlineSmall),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const SoftChip('Active Registry',
                        color: AppColors.primary, dense: true),
                  ],
                ),
                const SizedBox(height: 14),
                _ServiceRow(
                  icon: Icons.storefront_outlined,
                  title: 'Empanelled Solar Vendors',
                  subtitle:
                      '${solarVendors.isEmpty ? MockData.vendors.length : solarVendors.length} GEDA-certified installers in ${s.user!.district}',
                  onTap: () => context.push('/hub/vendors'),
                ),
                _ServiceRow(
                  icon: Icons.account_balance_outlined,
                  title: 'State & Central Subsidies',
                  subtitle: 'PM Surya Ghar & Gujarat Solar Policy',
                  onTap: () => _showAllSchemes(context),
                ),
                _ServiceRow(
                  icon: Icons.menu_book_outlined,
                  title: 'Green Living Handbook',
                  subtitle: 'Official Mission LiFE practice modules',
                  onTap: () => context.push('/hub/schemes/read_your_bill'),
                ),
                _ServiceRow(
                  icon: Icons.receipt_long_outlined,
                  title: 'Tariff Slabs & TOU Telemetry',
                  subtitle: 'Smart meter peak & off-peak tariff guide',
                  onTap: () => context.push('/hub/schemes/tod_tariff'),
                  last: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ---- Helpline -----------------------------------------------
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const IconBubble(Icons.support_agent_rounded,
                        size: 40, circle: true),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Need technical verification for your rooftop?',
                              style: t.titleSmall),
                          const SizedBox(height: 2),
                          Text(
                              'Toll-free GEDA Mitra helpline available 9 AM – 6 PM',
                              style: t.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                PrimaryButton(
                  label: 'Call 1800-233-0122',
                  icon: Icons.call_outlined,
                  onPressed: () => Links.call(context, Links.gedaHelpline),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAllSchemes(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
        children: [
          for (final sc in MockData.schemes)
            ListTile(
              leading: IconTile(
                  icon: sc.icon,
                  color: AppColors.primary,
                  size: 40,
                  iconSize: 20),
              title: Text(sc.title),
              subtitle: Text(sc.keyNumbers.first),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/hub/schemes/${sc.id}');
              },
            ),
        ],
      ),
    );
  }
}

class _HubFeatureCard extends StatelessWidget {
  const _HubFeatureCard({
    required this.icon,
    required this.iconColor,
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.badge,
    required this.badgeColor,
    required this.action,
    required this.onTap,
    this.badgeIcon,
    this.highlighted = false,
    this.onSecondary,
  });
  final IconData icon;
  final Color iconColor;
  final String eyebrow;
  final String title;
  final String body;
  final String badge;
  final Color badgeColor;
  final IconData? badgeIcon;
  final String action;
  final bool highlighted;
  final VoidCallback onTap;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final card = AppCard(
      padding: const EdgeInsets.all(18),
      onTap: onTap,
      border: !highlighted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconBubble(icon,
                  size: 48,
                  color: iconColor,
                  background: AppColors.tint),
              const SizedBox(width: 12),
              Expanded(
                child: Align(
                  alignment: Alignment.topRight,
                  child: SoftChip(badge,
                      icon: badgeIcon, color: badgeColor, dense: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Eyebrow(eyebrow,
              color: highlighted ? AppColors.primaryLight : AppColors.textSecondary),
          const SizedBox(height: 4),
          Text(title, style: t.headlineSmall),
          const SizedBox(height: 6),
          Text(body,
              style: t.bodyMedium?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(children: [
                    TextSpan(text: action),
                    const WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(Icons.arrow_forward_rounded, size: 18),
                        )),
                  ]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.titleSmall,
                ),
              ),
              if (onSecondary != null)
                TextButton(
                    onPressed: onSecondary, child: const Text('New estimate'))
              else
                Icon(highlighted ? Icons.circle : Icons.sync_rounded,
                    size: highlighted ? 10 : 18,
                    color: highlighted
                        ? AppColors.primary
                        : AppColors.textSecondary.withValues(alpha: 0.5)),
            ],
          ),
        ],
      ),
    );
    if (!highlighted) return card;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.primary, width: 1.4),
      ),
      child: card,
    );
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.last = false,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                IconBubble(icon, size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: t.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(subtitle,
                          style: t.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
        if (!last) const Divider(height: 1),
      ],
    );
  }
}

class VendorCard extends StatelessWidget {
  const VendorCard(
      {super.key, required this.vendor, this.compact = false, this.onRequest});
  final Vendor vendor;
  final bool compact;
  final VoidCallback? onRequest;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cat = MockData.vendorCategories
        .firstWhere((c) => c.$1 == vendor.category, orElse: () => ('', 'Other'))
        .$2;
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconTile(
                  icon: _catIcon(vendor.category),
                  color: AppColors.primary,
                  size: 44,
                  iconSize: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vendor.name,
                        style: t.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 14, color: AppColors.secondary),
                        Expanded(
                          child: Text(
                              ' ${vendor.rating}  ·  $cat  ·  ${vendor.districts.join(', ')}',
                              style: t.labelSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              StatusTag(
                  label: vendor.empanelledBy,
                  color: AppColors.tertiary,
                  icon: Icons.verified_rounded),
            ],
          ),
          if (!compact) ...[
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              runSpacing: 4,
              children: [
                if (vendor.pricePerKw != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text('~${Fmt.rupees(vendor.pricePerKw!)}/kW',
                        style:
                            t.labelLarge?.copyWith(color: AppColors.primary)),
                  ),
                TextButton.icon(
                  onPressed: () => Links.call(context, vendor.phone),
                  icon: const Icon(Icons.call_rounded, size: 18),
                  label: const Text('Call'),
                ),
                FilledButton(
                  onPressed: onRequest,
                  style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 14)),
                  child: const Text('Request quote'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  IconData _catIcon(String c) => switch (c) {
        'solar' => Icons.solar_power_rounded,
        'led' => Icons.lightbulb_rounded,
        'solar_water_heater' => Icons.hot_tub_rounded,
        'ev_charging' => Icons.ev_station_rounded,
        'ewaste' => Icons.recycling_rounded,
        _ => Icons.store_rounded,
      };
}

// ---------------------------------------------------------------------------
// Solar calculator
// ---------------------------------------------------------------------------
class SolarCalculatorScreen extends StatefulWidget {
  const SolarCalculatorScreen({super.key});

  @override
  State<SolarCalculatorScreen> createState() => _SolarCalculatorScreenState();
}

class _SolarCalculatorScreenState extends State<SolarCalculatorScreen> {
  late final TextEditingController _units;
  double _roof = 30;
  bool _ownRoof = true;
  bool _scSt = false;
  bool _shadeFree = true;

  @override
  void initState() {
    super.initState();
    final u = AppScope.read(context).user!;
    _units = TextEditingController(
        text: u.baselineUnits > 0 ? u.baselineUnits.round().toString() : '');
    if (u.roofAccess == 'shared') _ownRoof = false;
  }

  @override
  void dispose() {
    _units.dispose();
    super.dispose();
  }

  Future<void> _calc() async {
    final units = double.tryParse(_units.text) ?? 0;
    if (units <= 0) {
      showAppSnack(context, 'Enter your monthly units',
          icon: Icons.error_outline_rounded, color: AppColors.error);
      return;
    }
    late final SolarAssessment a;
    try {
      a = await AppScope.read(context)
          .assess(monthlyUnits: units, roofAreaM2: _roof, scSt: _scSt);
    } catch (error) {
      if (!mounted) return;
      showAppSnack(
        context,
        'Could not save your task progress: $error',
        icon: Icons.error_outline_rounded,
        color: AppColors.error,
      );
      return;
    }
    if (!mounted) return;
    context.push('/hub/solar/result/${a.id}');
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final s = AppScope.of(context);
    final units = double.tryParse(_units.text) ?? 0;
    final liveKw =
        units > 0 ? (units / 30 / s.config.solar.specificYield) : 0.0;
    final maxKw = _roof / s.config.solar.areaPerKw;

    return Scaffold(
      appBar: PageAppBar(
        title: 'Solar Feasibility Calculator',
        subtitle: 'Mission LiFE Gujarat',
        leading: const SafeBackButton(fallback: '/hub'),
        actions: [
          IconButton(
            tooltip: 'How it works',
            onPressed: () => context.push('/hub/schemes/pm_surya_ghar'),
            icon: const Icon(Icons.help_outline_rounded),
          ),
        ],
      ),
      body: PhoneFrame(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _SolarStepper(step: units > 0 ? 2 : 1),
            const SizedBox(height: 16),
            Text(
                'Estimates use PM Surya Ghar + Gujarat state subsidy rules (Oct 2026).',
                style: t.bodyMedium),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Monthly electricity units',
              controller: _units,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.bolt_rounded,
              hint: 'e.g. 250',
              helper: units > 0
                  ? 'Suggested system ≈ ${liveKw.toStringAsFixed(1)} kW'
                  : 'From your latest bill',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Text('Usable roof area', style: t.titleSmall)),
                Text(
                    '${_roof.round()} m² · fits ${maxKw.toStringAsFixed(1)} kW',
                    style: t.labelMedium?.copyWith(color: AppColors.primary)),
              ],
            ),
            Slider(
                value: _roof,
                min: 5,
                max: 120,
                divisions: 23,
                label: '${_roof.round()} m²',
                onChanged: (v) => setState(() => _roof = v)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                    child: Text('5 m² (balcony)',
                        style: t.labelSmall, overflow: TextOverflow.ellipsis)),
                Flexible(
                    child: Text('120 m² (bungalow)',
                        style: t.labelSmall, overflow: TextOverflow.ellipsis))
              ],
            ),
            const SizedBox(height: 16),
            Text('Roof details', style: t.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                    child: SelectableTile(
                        label: 'Own roof',
                        icon: Icons.home_rounded,
                        selected: _ownRoof,
                        onTap: () => setState(() => _ownRoof = true),
                        compact: true)),
                const SizedBox(width: 10),
                Expanded(
                    child: SelectableTile(
                        label: 'Shared / society',
                        icon: Icons.apartment_rounded,
                        selected: !_ownRoof,
                        onTap: () => setState(() => _ownRoof = false),
                        compact: true)),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Roof is mostly shade-free'),
              subtitle:
                  const Text('No tall buildings/trees blocking south side'),
              value: _shadeFree,
              onChanged: (v) => setState(() => _shadeFree = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('SC / ST household'),
              subtitle:
                  const Text('Higher Gujarat state subsidy (consumer pays 5%)'),
              value: _scSt,
              onChanged: (v) => setState(() => _scSt = v),
            ),
            if (!_ownRoof) ...[
              const SizedBox(height: 8),
              const InfoBanner(
                  text:
                      'Shared roofs qualify under the Group Housing Society route — common-area loads up to 500 kW. Your society captain can apply.',
                  icon: Icons.groups_rounded),
            ],
            if (!_shadeFree) ...[
              const SizedBox(height: 8),
              const InfoBanner(
                  text:
                      'Shading can cut generation by 20–40%. A vendor site survey will confirm the exact yield.',
                  icon: Icons.wb_shade_rounded,
                  color: AppColors.warning),
            ],
            const SizedBox(height: 24),
            PrimaryButton(
                label: 'Calculate savings',
                icon: Icons.calculate_rounded,
                onPressed: _calc),
            const SizedBox(height: 10),
            Center(
                child: Text(
                    'Indicative only · final figures from vendor & DISCOM',
                    style: t.labelSmall)),
          ],
        ),
      ),
    );
  }
}

class SolarResultScreen extends StatelessWidget {
  const SolarResultScreen({super.key, required this.assessmentId});
  final String assessmentId;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final t = Theme.of(context).textTheme;
    final a = s.assessmentById(assessmentId);
    if (a == null) {
      return Scaffold(
          appBar: AppBar(
            leading: const SafeBackButton(fallback: '/hub'),
          ),
          body: EmptyState(
              icon: Icons.solar_power_outlined,
              title: 'Estimate not found',
              body: 'Run the calculator again',
              actionLabel: 'Open calculator',
              onAction: () => context.go('/hub/solar')));
    }
    final subsidy = a.centralSubsidy + a.stateSubsidy;
    final subsidyPct =
        a.grossCost == 0 ? 0.0 : subsidy / a.grossCost * 100;
    final hasLead = s.myLeads.isNotEmpty;
    final roofSqFt = a.roofAreaM2 * 10.764;
    final co2PerYearT = a.co2Avoided25yKg / 25 / 1000;

    return Scaffold(
      appBar: PageAppBar(
        title: 'Solar Feasibility Calculator',
        subtitle: 'Mission LiFE Gujarat',
        leading: const SafeBackButton(fallback: '/hub'),
        actions: [
          IconButton(
            tooltip: 'How the subsidy works',
            onPressed: () => context.push('/hub/schemes/pm_surya_ghar'),
            icon: const Icon(Icons.help_outline_rounded),
          ),
        ],
      ),
      body: PhoneFrame(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            const _SolarStepper(step: 3),
            const SizedBox(height: 16),

            // ---- inputs recap -----------------------------------------
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Expanded(child: Eyebrow('Monthly usage')),
                            Icon(Icons.bolt_rounded,
                                size: 18, color: AppColors.primaryLight),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text.rich(
                          TextSpan(children: [
                            TextSpan(
                                text: Fmt.int(a.monthlyUnits),
                                style: t.headlineMedium
                                    ?.copyWith(color: AppColors.primary)),
                            TextSpan(text: ' kWh/mo', style: t.labelMedium),
                          ]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        CapsuleBar(
                            value: (a.monthlyUnits / 500).clamp(0.05, 1.0),
                            height: 6),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppCard(
                    padding: const EdgeInsets.all(16),
                    onTap: () => context.push('/hub/solar'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Expanded(child: Eyebrow('Rooftop area')),
                            Icon(Icons.roofing_rounded,
                                size: 18, color: AppColors.primaryLight),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text.rich(
                          TextSpan(children: [
                            TextSpan(
                                text: Fmt.int(roofSqFt),
                                style: t.headlineMedium
                                    ?.copyWith(color: AppColors.primary)),
                            TextSpan(text: ' sq.ft', style: t.labelMedium),
                          ]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text('${a.roofAreaM2.round()} m² · tap to edit',
                            style: t.labelSmall
                                ?.copyWith(color: AppColors.primaryLight)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ---- headline -----------------------------------------------
            AppCard(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
              child: Column(
                children: [
                  const SoftChip('Government subsidised estimate',
                      icon: Icons.verified_outlined,
                      color: AppColors.primaryLight,
                      dense: true),
                  const SizedBox(height: 10),
                  const Eyebrow('Estimated net investment'),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 14, right: 2),
                          child: Text('₹',
                              style: t.titleLarge
                                  ?.copyWith(color: AppColors.primary)),
                        ),
                        Text(
                            Fmt.int(a.netCost),
                            style: t.displayLarge!.copyWith(
                                color: AppColors.primary,
                                fontSize: 56,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -2)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                      'Recommended ${a.sizeKw.toStringAsFixed(1)} kW Rooftop Solar System',
                      textAlign: TextAlign.center,
                      style: t.titleMedium),
                  const SizedBox(height: 18),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _ResultStat(
                            label: 'Generation / yr',
                            value: '${Fmt.int(a.annualGenUnits)} kWh'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ResultStat(
                            label: 'CO₂ offset / yr',
                            value:
                                '${co2PerYearT.toStringAsFixed(1)} Tonnes'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ---- breakdown ---------------------------------------------
            AppCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Text('Subsidy & Cost Breakdown',
                              style: t.headlineSmall)),
                      const Icon(Icons.account_balance_outlined,
                          color: AppColors.textSecondary),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: Text('Gross system installation cost',
                              style: t.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary))),
                      Text(Fmt.rupees(a.grossCost), style: t.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _SubsidyRow(
                    icon: Icons.flag_outlined,
                    title: 'PM Surya Ghar Central Subsidy',
                    subtitle: 'Direct DBT transfer from MNRE',
                    amount: a.centralSubsidy,
                  ),
                  const SizedBox(height: 10),
                  _SubsidyRow(
                    icon: Icons.eco_outlined,
                    title: 'Gujarat State Renewable Incentive',
                    subtitle: a.stateSubsidy == 0
                        ? 'Applies to systems ≤ 2.18 kW only'
                        : 'GEDA additional state subsidy',
                    amount: a.stateSubsidy,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: Text('Net subsidies availed',
                              style: t.bodySmall)),
                      Flexible(
                        child: Text(
                            '${Fmt.rupees(subsidy)} (${subsidyPct.toStringAsFixed(1)}% covered)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.labelLarge
                                ?.copyWith(color: AppColors.primaryLight)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      children: [
                        const Icon(Icons.savings_outlined,
                            size: 20, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                              a.paybackYears == null
                                  ? 'Payback not applicable'
                                  : 'Payback in ${a.paybackYears!.toStringAsFixed(1)} Years',
                              style: t.titleSmall
                                  ?.copyWith(color: AppColors.primary)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.trending_down_rounded,
                          size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text('Estimated Savings:', style: t.bodySmall),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                            '${Fmt.rupees(a.annualSavings / 12)} / month',
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.titleMedium),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Callout(
              icon: Icons.shield_outlined,
              title: 'DISCOM Net-Metering Assured',
              text:
                  'Automatic bi-directional meter setup approved by UGVCL / DGVCL / PGVCL / MGVCL with 25-year panel warranty. Assumes 4.2 units/kW/day and ₹${s.config.avgTariffPerUnit.toStringAsFixed(1)}/unit tariff.',
            ),
            const SizedBox(height: 20),

            Center(
              child: TextButton.icon(
                onPressed: () => Links.email(
                  context,
                  to: s.user!.email,
                  subject:
                      'LiFE Mitra solar estimate · ${a.sizeKw.toStringAsFixed(1)} kW',
                  body: [
                    'Solar feasibility estimate (PM Surya Ghar + Gujarat state subsidy)',
                    '',
                    'Monthly usage: ${Fmt.int(a.monthlyUnits)} units',
                    'Roof area: ${a.roofAreaM2.round()} m²',
                    'Recommended system: ${a.sizeKw.toStringAsFixed(1)} kW',
                    'Gross cost: ${Fmt.rupees(a.grossCost)}',
                    'Central subsidy: ${Fmt.rupees(a.centralSubsidy)}',
                    'State subsidy: ${Fmt.rupees(a.stateSubsidy)}',
                    'Net investment: ${Fmt.rupees(a.netCost)}',
                    'Annual generation: ${Fmt.int(a.annualGenUnits)} units',
                    'Annual savings: ${Fmt.rupees(a.annualSavings)}',
                    'Payback: ${a.paybackYears?.toStringAsFixed(1) ?? '—'} years',
                    '',
                    'Indicative only — final figures from the empanelled vendor & DISCOM.',
                    'GEDA helpline ${Links.gedaHelpline}',
                  ].join('\n'),
                ),
                icon: const Icon(Icons.mail_outline_rounded, size: 18),
                label: const Text('Email me this estimate'),
              ),
            ),
            const SizedBox(height: 4),
            PrimaryButton(
              label: hasLead ? 'Survey requested ✓' : 'Request Free GEDA Survey',
              icon: Icons.arrow_forward_rounded,
              onPressed: hasLead
                  ? null
                  : () => showRequestSurveySheet(context, assessment: a),
            ),
            const SizedBox(height: 8),
            Center(
                child: Text('Free on-site roof technical feasibility evaluation',
                    style: t.labelSmall)),
            const SizedBox(height: 12),
            SecondaryButton(
                label: 'Compare empanelled vendors',
                icon: Icons.storefront_rounded,
                onPressed: () => context.push('/hub/vendors')),
          ],
        ),
      ),
    );
  }
}

class _SolarStepper extends StatelessWidget {
  const _SolarStepper({required this.step});
  final int step; // 1..3 (current)

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    const labels = ['1 Usage', '2 Roof', '3 Result'];
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        children: [
          Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                _StepDot(index: i + 1, current: step),
                if (i < 2)
                  Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: i + 1 < step
                            ? AppColors.primary
                            : AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < 3; i++)
                Text(labels[i],
                    style: t.labelMedium?.copyWith(
                        color: i + 1 == step
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontWeight: i + 1 == step
                            ? FontWeight.w700
                            : FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.index, required this.current});
  final int index;
  final int current;

  @override
  Widget build(BuildContext context) {
    final done = index < current;
    final active = index == current;
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: done || active ? AppColors.primary : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
            color: active ? AppColors.primaryContainer : AppColors.primary,
            width: active ? 3 : 1.5),
      ),
      child: done
          ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
          : Text('$index',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: active ? Colors.white : AppColors.primary)),
    );
  }
}

class _ResultStat extends StatelessWidget {
  const _ResultStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
          color: AppColors.tint, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: t.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(value,
              style: t.titleMedium?.copyWith(color: AppColors.primary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _SubsidyRow extends StatelessWidget {
  const _SubsidyRow(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.amount});
  final IconData icon;
  final String title;
  final String subtitle;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.tint, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryLight),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: t.titleSmall?.copyWith(color: AppColors.primary)),
                const SizedBox(height: 2),
                Text(subtitle, style: t.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(amount == 0 ? '—' : '− ${Fmt.rupees(amount)}',
              style: t.titleMedium?.copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }
}

Future<void> showRequestSurveySheet(BuildContext context,
    {SolarAssessment? assessment, Vendor? vendor}) async {
  final s = AppScope.read(context);
  final phone = TextEditingController();
  var consent = false;
  var slot = 'Weekday morning';
  var submitting = false;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSt) {
        final t = Theme.of(ctx).textTheme;
        return Padding(
          padding: EdgeInsets.fromLTRB(
              24, 0, 24, 24 + MediaQuery.of(ctx).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  vendor == null
                      ? 'Request free site survey'
                      : 'Request quote from ${vendor.name}',
                  style: t.titleLarge),
              const SizedBox(height: 6),
              Text(
                  s.useFirebase
                      ? 'Your request will be saved to your account. Vendor contact is not connected yet; your details will not be sent automatically.'
                      : 'A GEDA-empanelled vendor will visit, verify roof & shading, and share a final quote. No obligation.',
                  style: t.bodyMedium),
              const SizedBox(height: 16),
              AppTextField(
                  label: 'Contact number',
                  controller: phone,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.call_outlined,
                  hint: '10-digit mobile',
                  maxLength: 10),
              const SizedBox(height: 12),
              Text('Preferred visit slot', style: t.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final sl in const [
                    'Weekday morning',
                    'Weekday evening',
                    'Weekend'
                  ])
                    ChoiceChip(
                        label: Text(sl),
                        selected: slot == sl,
                        onSelected: (_) => setSt(() => slot = sl)),
                ],
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                value: consent,
                onChanged: (v) => setSt(() => consent = v ?? false),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                    s.useFirebase
                        ? 'Save my contact number, preferred time and estimate with this account'
                        : 'Share my name, district & estimate with GEDA and the vendor',
                    style: t.bodySmall),
              ),
              const SizedBox(height: 8),
              PrimaryButton(
                label: submitting
                    ? 'Saving...'
                    : s.useFirebase
                        ? 'Save request'
                        : 'Submit request  · +${s.config.solarLeadPoints} pts',
                onPressed:
                    consent && phone.text.trim().length == 10 && !submitting
                        ? () async {
                            setSt(() => submitting = true);
                            try {
                              await s.requestSurvey(
                                  assessment: assessment,
                                  vendor: vendor,
                                  phone: phone.text.trim(),
                                  preferredSlot: slot,
                                  type: vendor == null ? 'survey' : 'quote');
                              if (!ctx.mounted) return;
                              Navigator.pop(ctx);
                              if (s.useFirebase) {
                                showAppSnack(
                                  context,
                                  'Request saved to your account. Vendor contact is not connected yet.',
                                  icon: Icons.check_circle_rounded,
                                  color: AppColors.primary,
                                );
                              } else {
                                showConfetti(context);
                                showAppSnack(context,
                                    'Request sent! Vendor will call within 2 working days.',
                                    icon: Icons.check_circle_rounded,
                                    color: AppColors.primary);
                              }
                            } catch (error) {
                              if (!context.mounted) return;
                              showAppSnack(
                                context,
                                'Could not save your request: $error',
                                icon: Icons.error_outline_rounded,
                                color: AppColors.error,
                              );
                            } finally {
                              if (ctx.mounted) setSt(() => submitting = false);
                            }
                          }
                        : null,
              ),
              const SizedBox(height: 4),
              Center(
                  child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Maybe later'))),
            ],
          ),
        );
      },
    ),
  );
  phone.dispose();
}

// ---------------------------------------------------------------------------
// Vendors
// ---------------------------------------------------------------------------
class VendorsScreen extends StatefulWidget {
  const VendorsScreen({super.key});

  @override
  State<VendorsScreen> createState() => _VendorsScreenState();
}

class _VendorsScreenState extends State<VendorsScreen> {
  String _cat = 'solar';
  late String _district = AppScope.read(context).user!.district;
  bool _allDistricts = false;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final list = MockData.vendors
        .where((v) =>
            v.category == _cat &&
            (_allDistricts || v.districts.contains(_district)))
        .toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));

    return Scaffold(
      appBar: AppBar(
          leading: const SafeBackButton(fallback: '/hub'),
          title: const Text('Empanelled vendors')),
      body: PhoneFrame(
        child: Column(
          children: [
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  for (final c in MockData.vendorCategories)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                          label: Text(c.$2),
                          selected: _cat == c.$1,
                          onSelected: (_) => setState(() => _cat = c.$1)),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _district,
                        isDense: true,
                        isExpanded: true,
                        style: t.labelLarge
                            ?.copyWith(color: AppColors.textPrimary),
                        items: [
                          for (final d in MockData.gujaratDistricts)
                            DropdownMenuItem(value: d, child: Text(d))
                        ],
                        onChanged: _allDistricts
                            ? null
                            : (v) => setState(() => _district = v!),
                      ),
                    ),
                  ),
                  FilterChip(
                      label: const Text('All Gujarat'),
                      selected: _allDistricts,
                      onSelected: (v) => setState(() => _allDistricts = v)),
                ],
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? EmptyState(
                      icon: Icons.storefront_outlined,
                      title: 'No vendors here yet',
                      body: 'Try "All Gujarat" or another category',
                      actionLabel: 'Show all Gujarat',
                      onAction: () => setState(() => _allDistricts = true))
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      children: [
                        const InfoBanner(
                            text:
                                'All vendors are empanelled by GEDA / MNRE / DISCOM. Prices are indicative; pay only after a written quote.',
                            icon: Icons.verified_user_outlined),
                        const SizedBox(height: 12),
                        for (final v in list)
                          VendorCard(
                              vendor: v,
                              onRequest: () => showRequestSurveySheet(context,
                                  vendor: v,
                                  assessment: AppScope.read(context)
                                      .assessments
                                      .firstOrNull)),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Scheme detail
// ---------------------------------------------------------------------------
class SchemeDetailScreen extends StatelessWidget {
  const SchemeDetailScreen({super.key, required this.schemeId});
  final String schemeId;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final sc = MockData.schemeById(schemeId);
    return Scaffold(
      appBar: AppBar(
          leading: const SafeBackButton(fallback: '/hub'),
          title: Text(sc.title, overflow: TextOverflow.ellipsis)),
      body: PhoneFrame(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                IconTile(
                    icon: sc.icon,
                    color: AppColors.primary,
                    size: 56,
                    iconSize: 28),
                const SizedBox(width: 14),
                Expanded(child: Text(sc.title, style: t.headlineSmall)),
              ],
            ),
            const SizedBox(height: 12),
            Text(sc.summary, style: t.bodyLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final k in sc.keyNumbers)
                  Pill(
                      label: k,
                      color: AppColors.primarySoft,
                      textColor: AppColors.primary,
                      icon: Icons.check_circle_rounded)
              ],
            ),
            const SizedBox(height: 20),
            _Section(
                title: 'Who is eligible',
                icon: Icons.how_to_reg_rounded,
                items: sc.eligibility,
                numbered: false),
            const SizedBox(height: 16),
            _Section(
                title: 'How to apply',
                icon: Icons.format_list_numbered_rounded,
                items: sc.steps,
                numbered: true),
            const SizedBox(height: 20),
            PrimaryButton(
                label: 'Open official site',
                icon: Icons.open_in_new_rounded,
                onPressed: () => Links.web(context, sc.officialUrl)),
            if (schemeId == 'pm_surya_ghar' ||
                schemeId == 'gujarat_state_subsidy') ...[
              const SizedBox(height: 10),
              SecondaryButton(
                  label: 'Check my eligibility & savings',
                  icon: Icons.calculate_rounded,
                  onPressed: () => context.push('/hub/solar')),
            ],
            const SizedBox(height: 16),
            Text(
                'Source: GEDA / MNRE notifications. Figures as of Oct 2026 — verify on the official portal before applying.',
                style: t.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(
      {required this.title,
      required this.icon,
      required this.items,
      required this.numbered});
  final String title;
  final IconData icon;
  final List<String> items;
  final bool numbered;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(title, style: t.titleMedium)
          ]),
          const SizedBox(height: 10),
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  numbered
                      ? Container(
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
                        )
                      : const Padding(
                          padding: EdgeInsets.only(top: 3),
                          child: Icon(Icons.check_rounded,
                              size: 16, color: AppColors.success)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(items[i], style: t.bodyMedium)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
