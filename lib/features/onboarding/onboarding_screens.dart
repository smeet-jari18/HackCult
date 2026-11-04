import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/logic/calculators.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../data/app_state.dart';
import '../../data/mock_data.dart';

/// Holds the 5-step onboarding answers (survives back/forward navigation).
class OnboardingData {
  static final instance = OnboardingData();

  String pincode = '';
  String district = 'Ahmedabad';
  int householdSize = 4;
  String homeType = 'flat';
  String roofAccess = 'yes';
  String electricityMethod = 'units'; // units | bill | quiz
  double units = 0;
  double billAmount = 0;
  Map<String, (int, double)> quiz = {
    'ac': (1, 6),
    'fridge': (1, 24),
    'geyser': (1, 0.5),
    'fan': (3, 10),
    'led': (6, 5)
  };
  double lpgCylinders = 1;
  String travelMode = 'two_wheeler';
  double weeklyKm = 70;
  Set<String> appliances = {'ac', 'fridge', 'washing_machine', 'geyser'};
  int goalPercent = 15;

  double resolvedUnits(AppState s) => switch (electricityMethod) {
        'bill' => s.footprintCalc.unitsFromBill(billAmount),
        'quiz' => s.footprintCalc.unitsFromAppliances(quiz),
        _ => units,
      };

  void reset() {
    final fresh = OnboardingData();
    pincode = fresh.pincode;
    district = fresh.district;
    householdSize = fresh.householdSize;
    homeType = fresh.homeType;
    roofAccess = fresh.roofAccess;
    electricityMethod = fresh.electricityMethod;
    units = 0;
    billAmount = 0;
    quiz = fresh.quiz;
    lpgCylinders = fresh.lpgCylinders;
    travelMode = fresh.travelMode;
    weeklyKm = fresh.weeklyKm;
    appliances = fresh.appliances;
    goalPercent = fresh.goalPercent;
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.step});
  final int step;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final d = OnboardingData.instance;
  late final _pin = TextEditingController(text: d.pincode);
  late final _units = TextEditingController(
      text: d.units > 0 ? d.units.round().toString() : '');
  late final _bill = TextEditingController(
      text: d.billAmount > 0 ? d.billAmount.round().toString() : '');

  @override
  void dispose() {
    _pin.dispose();
    _units.dispose();
    _bill.dispose();
    super.dispose();
  }

  bool get _valid => switch (widget.step) {
        1 => d.pincode.length == 6,
        3 => d.electricityMethod == 'quiz' ||
            (d.electricityMethod == 'units' ? d.units > 0 : d.billAmount > 0),
        _ => true,
      };

  void _next() {
    if (widget.step < 5) {
      context.push('/onboarding/${widget.step + 1}');
    } else {
      context.push('/onboarding/result');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    const stepNames = [
      'Your Location',
      'Your Home Profile',
      'Electricity Use',
      'Cooking Fuel',
      'Daily Travel',
    ];
    final titles = [
      'Where do you live?',
      'Set up your home footprint',
      'Your electricity',
      'Cooking fuel',
      'How do you travel?'
    ];
    final subtitles = [
      'We use this to find your DISCOM, community and solar potential.',
      'Helps GEDA calculate accurate baseline energy & CO₂ metrics for your household in Gujarat.',
      'Pick whichever is easiest — you can refine it later.',
      'Cooking fuel is the second-largest home emission source.',
      'Last step! Then we reveal your footprint.',
    ];
    return Scaffold(
      body: PhoneFrame(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('MISSION LIFE GUJARAT',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: t.labelMedium?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8)),
                        ),
                        Text('Step ${widget.step} of 5',
                            style: t.labelMedium
                                ?.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        for (var i = 1; i <= 5; i++) ...[
                          Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              height: 6,
                              decoration: BoxDecoration(
                                color: i < widget.step
                                    ? AppColors.primary
                                    : i == widget.step
                                        ? AppColors.primaryDark
                                        : AppColors.border,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                          if (i < 5) const SizedBox(width: 6),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(stepNames[widget.step - 1],
                          style: t.labelLarge
                              ?.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Text(titles[widget.step - 1], style: t.headlineMedium),
                      const SizedBox(height: 6),
                      Text(subtitles[widget.step - 1],
                          style: t.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 20),
                      _buildStep(),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () => widget.step == 1
                              ? context.go('/login')
                              : context
                                  .safePop('/onboarding/${widget.step - 1}'),
                          icon: const Icon(Icons.arrow_back_rounded, size: 18),
                          label: const Text('Back'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: PrimaryButton(
                        label: widget.step == 5
                            ? 'Reveal my footprint'
                            : 'Continue to Step ${widget.step + 1}',
                        trailingIcon: Icons.arrow_forward_rounded,
                        height: 48,
                        onPressed: _valid ? _next : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (widget.step) {
      case 1:
        return _stepLocation();
      case 2:
        return _stepHome();
      case 3:
        return _stepElectricity();
      case 4:
        return _stepCooking();
      default:
        return _stepTravel();
    }
  }

  // Step 1 -------------------------------------------------------------
  Widget _stepLocation() {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: 'PIN code',
          controller: _pin,
          hint: 'e.g. 380015',
          keyboardType: TextInputType.number,
          maxLength: 6,
          prefixIcon: Icons.location_on_outlined,
          onChanged: (v) => setState(() {
            d.pincode = v;
            if (v.length == 6) d.district = MockData.districtFromPin(v);
          }),
        ),
        const SizedBox(height: 12),
        if (d.pincode.length == 6)
          Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 18),
              const SizedBox(width: 6),
              Text('Detected district: ', style: t.bodySmall),
              Pill(
                  label: d.district,
                  color: AppColors.primarySoft,
                  textColor: AppColors.primary,
                  icon: Icons.map_outlined),
            ],
          ),
        const SizedBox(height: 16),
        SecondaryButton(
          label: 'Use my location',
          icon: Icons.my_location_rounded,
          onPressed: () => setState(() {
            d.pincode = '380015';
            _pin.text = d.pincode;
            d.district = 'Ahmedabad';
          }),
        ),
        const SizedBox(height: 24),
        Text('Or pick your district', style: t.titleSmall),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          key: ValueKey(d.district),
          initialValue: d.district,
          isExpanded: true,
          items: MockData.gujaratDistricts
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => setState(() => d.district = v ?? d.district),
          decoration: const InputDecoration(
              prefixIcon: Icon(Icons.map_outlined, size: 20)),
        ),
      ],
    );
  }

  // Step 2 -------------------------------------------------------------
  Widget _stepHome() {
    final t = Theme.of(context).textTheme;
    const applianceMeta = <String, (String, String, IconData)>{
      'ac': ('AC (1.5 Ton)', '~1.6 kWh', Icons.ac_unit_rounded),
      'geyser': ('Water heater', '~2.0 kWh', Icons.hot_tub_rounded),
      'fridge': ('Refrigerator', '24/7 Base', Icons.kitchen_rounded),
      'washing_machine': (
        'Washing machine',
        '~0.8 kWh',
        Icons.local_laundry_service_rounded
      ),
      'pump': ('Water pump', '~0.7 kWh', Icons.water_rounded),
      'inverter': (
        'Solar Inverter',
        'Hybrid setup',
        Icons.battery_charging_full_rounded
      ),
      'ev': ('Electric vehicle', 'Home charging', Icons.electric_car_rounded),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // District + PIN (prefilled from step 1, editable here too)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FieldLabel('District', required: true),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    key: ValueKey('d2-${d.district}'),
                    initialValue: d.district,
                    isExpanded: true,
                    items: MockData.gujaratDistricts
                        .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e, overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => d.district = v ?? d.district),
                  ),
                  const HelperText('Admin division'),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                label: 'PIN Code',
                required: true,
                controller: _pin,
                hint: '380015',
                keyboardType: TextInputType.number,
                maxLength: 6,
                helper: '6-digit postal',
                onChanged: (v) => setState(() {
                  d.pincode = v;
                  if (v.length == 6) d.district = MockData.districtFromPin(v);
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        FieldLabel('Household size',
            required: true,
            trailing: Text('Primary residents', style: t.bodySmall)),
        const SizedBox(height: 8),
        SegmentedChoice<int>(
          value: d.householdSize.clamp(1, 5),
          height: 56,
          onChanged: (v) => setState(() => d.householdSize = v),
          options: const [(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5+')],
        ),
        const SizedBox(height: 22),
        const FieldLabel('Home type', required: true),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
                child: _RadioTile(
                    label: 'Apartment',
                    selected: d.homeType == 'flat',
                    onTap: () => setState(() => d.homeType = 'flat'))),
            const SizedBox(width: 12),
            Expanded(
                child: _RadioTile(
                    label: 'House',
                    selected: d.homeType == 'house',
                    onTap: () => setState(() => d.homeType = 'house'))),
          ],
        ),
        const SizedBox(height: 22),
        FieldLabel('Rooftop solar access',
            required: true,
            trailing: d.roofAccess == 'no'
                ? null
                : const Tag('Surya Gujarat Eligible',
                    color: AppColors.primary, textColor: Colors.white)),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final (v, l, ic) in [
              ('yes', 'Own roof', Icons.solar_power_outlined),
              ('shared', 'Shared roof', Icons.roofing_outlined),
              ('no', 'No access', Icons.block_rounded)
            ]) ...[
              Expanded(
                child: _IconTile(
                    label: l,
                    icon: ic,
                    selected: d.roofAccess == v,
                    onTap: () => setState(() => d.roofAccess = v)),
              ),
              if (v != 'no') const SizedBox(width: 10),
            ],
          ],
        ),
        const SizedBox(height: 22),
        FieldLabel('Major appliances at home',
            trailing: Text('Select all running', style: t.bodySmall)),
        const SizedBox(height: 8),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          // Fixed tile height (not aspect-ratio based) so two text lines
          // always fit regardless of screen width / font scale.
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            mainAxisExtent: 68,
          ),
          children: [
            for (final (id, _, fallbackIcon) in MockData.appliances)
              _ApplianceCheck(
                title: applianceMeta[id]?.$1 ?? id,
                subtitle: applianceMeta[id]?.$2 ?? '',
                icon: applianceMeta[id]?.$3 ?? fallbackIcon,
                selected: d.appliances.contains(id),
                onTap: () => setState(() => d.appliances.contains(id)
                    ? d.appliances.remove(id)
                    : d.appliances.add(id)),
              ),
          ],
        ),
        const SizedBox(height: 20),
        const InfoBanner(
          icon: Icons.verified_user_outlined,
          color: AppColors.primary,
          text:
              'Data collected strictly under GEDA LiFE Baseline Standard 2024. Used exclusively to compute state carbon credits and subsidy tiers.',
          bold: 'GEDA LiFE Baseline Standard 2024',
        ),
      ],
    );
  }

  // Step 3 -------------------------------------------------------------
  Widget _stepElectricity() {
    final t = Theme.of(context).textTheme;
    final s = AppScope.read(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
                value: 'units',
                label: Text('Units'),
                icon: Icon(Icons.bolt_rounded, size: 16)),
            ButtonSegment(
                value: 'bill',
                label: Text('Bill ₹'),
                icon: Icon(Icons.receipt_long_rounded, size: 16)),
            ButtonSegment(
                value: 'quiz',
                label: Text('Estimate'),
                icon: Icon(Icons.calculate_rounded, size: 16)),
          ],
          selected: {d.electricityMethod},
          onSelectionChanged: (v) =>
              setState(() => d.electricityMethod = v.first),
          style: SegmentedButton.styleFrom(
            selectedBackgroundColor: AppColors.primarySoft,
            selectedForegroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.border),
            textStyle: t.labelMedium,
          ),
        ),
        const SizedBox(height: 20),
        if (d.electricityMethod == 'units')
          AppTextField(
            label: 'Units (kWh) on last month\'s bill',
            controller: _units,
            hint: 'e.g. 250',
            keyboardType: TextInputType.number,
            prefixIcon: Icons.bolt_rounded,
            helper:
                'Look for "Units consumed" on your DGVCL / MGVCL / PGVCL / UGVCL / Torrent bill',
            onChanged: (v) => setState(() => d.units = double.tryParse(v) ?? 0),
          )
        else if (d.electricityMethod == 'bill')
          AppTextField(
            label: 'Last month\'s bill amount (₹)',
            controller: _bill,
            hint: 'e.g. 1800',
            keyboardType: TextInputType.number,
            prefixIcon: Icons.currency_rupee_rounded,
            helper: 'We estimate units at an average ₹6 per unit',
            onChanged: (v) =>
                setState(() => d.billAmount = double.tryParse(v) ?? 0),
          )
        else
          _ApplianceQuiz(data: d, onChanged: () => setState(() {})),
        const SizedBox(height: 20),
        if (_valid)
          AppCard(
            color: AppColors.primarySoft,
            border: false,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.insights_rounded, color: AppColors.primary),
                const SizedBox(width: 10),
                Text('≈ ${d.resolvedUnits(s).round()} units / month',
                    style: t.titleMedium?.copyWith(color: AppColors.primary)),
              ],
            ),
          ),
      ],
    );
  }

  // Step 4 -------------------------------------------------------------
  Widget _stepCooking() {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('LPG cylinders per month', style: t.titleSmall),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final v in [0.0, 0.5, 1.0, 1.5, 2.0])
              ChoiceChip(
                label: Text(v == 0 ? 'None / PNG' : v.toString()),
                selected: d.lpgCylinders == v,
                onSelected: (_) => setState(() => d.lpgCylinders = v),
                labelStyle: t.labelLarge?.copyWith(
                    color: d.lpgCylinders == v
                        ? AppColors.primary
                        : AppColors.textPrimary),
                selectedColor: AppColors.primarySoft,
                side: BorderSide(
                    color: d.lpgCylinders == v
                        ? AppColors.primary
                        : AppColors.border),
              ),
          ],
        ),
        const SizedBox(height: 20),
        const InfoBanner(
          bold: 'Did you know?',
          text:
              'One 14.2 kg LPG cylinder releases about 42 kg CO₂. Pressure cooking and covering pans can cut usage by 20%.',
          icon: Icons.lightbulb_outline_rounded,
        ),
      ],
    );
  }

  // Step 5 -------------------------------------------------------------
  Widget _stepTravel() {
    final t = Theme.of(context).textTheme;
    const modes = [
      ('none', 'None', Icons.directions_walk_rounded),
      ('two_wheeler', 'Two-wheeler', Icons.two_wheeler_rounded),
      ('car', 'Car', Icons.directions_car_rounded),
      ('bus_metro', 'Bus / Metro', Icons.directions_bus_rounded),
      ('ev', 'EV', Icons.electric_bolt_rounded),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Primary travel mode', style: t.titleSmall),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.6,
          children: [
            for (final (v, l, i) in modes)
              SelectableTile(
                  label: l,
                  icon: i,
                  compact: true,
                  selected: d.travelMode == v,
                  onTap: () => setState(() => d.travelMode = v)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: Text('Weekly distance', style: t.titleSmall)),
            Text('${d.weeklyKm.round()} km',
                style: t.titleSmall?.copyWith(color: AppColors.primary)),
          ],
        ),
        Slider(
            value: d.weeklyKm,
            min: 0,
            max: 300,
            divisions: 30,
            onChanged: d.travelMode == 'none'
                ? null
                : (v) => setState(() => d.weeklyKm = v)),
        const SizedBox(height: 16),
        Text('Appliances at home', style: t.titleSmall),
        const SizedBox(height: 4),
        Text('Used to personalise your daily nudges', style: t.bodySmall),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (id, label, icon) in MockData.appliances)
              FilterChip(
                avatar: Icon(icon,
                    size: 16,
                    color: d.appliances.contains(id)
                        ? AppColors.primary
                        : AppColors.textSecondary),
                label: Text(label),
                selected: d.appliances.contains(id),
                onSelected: (v) => setState(
                    () => v ? d.appliances.add(id) : d.appliances.remove(id)),
                selectedColor: AppColors.primarySoft,
                side: BorderSide(
                    color: d.appliances.contains(id)
                        ? AppColors.primary
                        : AppColors.border),
              ),
          ],
        ),
      ],
    );
  }
}

class _ApplianceQuiz extends StatelessWidget {
  const _ApplianceQuiz({required this.data, required this.onChanged});
  final OnboardingData data;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    const rows = [
      ('ac', 'AC', Icons.ac_unit_rounded),
      ('geyser', 'Geyser', Icons.hot_tub_rounded),
      ('fridge', 'Fridge', Icons.kitchen_rounded),
      ('fan', 'Fans', Icons.mode_fan_off_rounded),
      ('led', 'Lights', Icons.lightbulb_outline_rounded),
      ('tv', 'TV', Icons.tv_rounded)
    ];
    return Column(
      children: [
        for (final (id, label, icon) in rows)
          AppCard(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(icon, size: 20, color: AppColors.textSecondary),
                    const SizedBox(width: 10),
                    Expanded(child: Text(label, style: t.titleSmall)),
                    _MiniStepper(
                      value: data.quiz[id]?.$1 ?? 0,
                      onChanged: (v) {
                        data.quiz[id] = (v, data.quiz[id]?.$2 ?? 4);
                        onChanged();
                      },
                    ),
                  ],
                ),
                if ((data.quiz[id]?.$1 ?? 0) > 0)
                  Row(
                    children: [
                      Text(
                          '${(data.quiz[id]!.$2).toStringAsFixed(data.quiz[id]!.$2 < 1 ? 1 : 0)} h/day',
                          style: t.labelSmall),
                      Expanded(
                        child: Slider(
                          value: data.quiz[id]!.$2,
                          min: 0.5,
                          max: 24,
                          divisions: 47,
                          onChanged: (v) {
                            data.quiz[id] = (data.quiz[id]!.$1, v);
                            onChanged();
                          },
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _MiniStepper extends StatelessWidget {
  const _MiniStepper({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: value > 0 ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_circle_outline_rounded)),
        SizedBox(
            width: 22,
            child: Text('$value',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall)),
        IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: value < 9 ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add_circle_outline_rounded,
                color: AppColors.primary)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Baseline result
// ---------------------------------------------------------------------------
class BaselineResultScreen extends StatefulWidget {
  const BaselineResultScreen({super.key});

  @override
  State<BaselineResultScreen> createState() => _BaselineResultScreenState();
}

class _BaselineResultScreenState extends State<BaselineResultScreen> {
  final d = OnboardingData.instance;
  bool _saving = false;

  Future<void> _start(AppState s, double units) async {
    setState(() => _saving = true);
    try {
      await s.completeOnboarding(
        pincode: d.pincode.isEmpty ? '380015' : d.pincode,
        district: d.district,
        householdSize: d.householdSize,
        homeType: d.homeType,
        roofAccess: d.roofAccess,
        electricityUnits: units,
        lpgCylinders: d.lpgCylinders,
        travelMode: d.travelMode,
        weeklyKm: d.weeklyKm,
        appliances: d.appliances.toList(),
        goalPercent: d.goalPercent,
        source: d.electricityMethod == 'quiz' ? 'quiz' : 'manual',
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'Saving onboarding profile',
      ));
      if (mounted) {
        setState(() => _saving = false);
        showAppSnack(
          context,
          'Could not save your profile. Check your connection and try again.',
          icon: Icons.error_outline_rounded,
          color: AppColors.error,
        );
      }
      return;
    }
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    context.go('/community/join?onboarding=1');
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final s = AppScope.of(context);
    final units = d.resolvedUnits(s);
    final calc = s.footprintCalc;
    final r = calc.calculate(FootprintInput(
      electricityUnits: units,
      lpgKg: d.lpgCylinders * 14.2,
      petrolL: calc.petrolLitresFromKm(d.travelMode, d.weeklyKm),
      busKm: d.travelMode == 'bus_metro' ? d.weeklyKm * 4.33 : 0,
    ));
    final avg = s.config.gujaratAvgHouseholdCo2Kg;
    final pctOfAvg = avg == 0 ? 100 : (r.totalKg / avg * 100).round();
    final total = r.totalKg <= 0 ? 1.0 : r.totalKg;
    final tariff = s.config.avgTariffPerUnit;
    final now = DateTime.now();
    final fyStart = now.month >= 4 ? now.year : now.year - 1;
    final fy = 'FY $fyStart-${(fyStart + 1) % 100}';
    final travelLabel = switch (d.travelMode) {
      'car' => 'car',
      'bus_metro' => 'bus / metro',
      'cycle_walk' => 'cycle / walk',
      _ => 'two-wheeler',
    };

    String rupees(int g) =>
        Fmt.rupees(units * (g / 100) * tariff).replaceAll('.00', '');

    return Scaffold(
      body: PhoneFrame(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                                color: AppColors.tint,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.border)),
                            padding: const EdgeInsets.all(6),
                            child: Image.asset('assets/images/emblem.png',
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.eco_outlined,
                                    color: AppColors.primary)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('LiFE Mitra Gujarat',
                                    style: t.titleSmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                Text('GEDA · Govt. of Gujarat',
                                    style: t.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Tag('Verified',
                              icon: Icons.verified_outlined,
                              color: AppColors.tintStrong,
                              textColor: AppColors.textPrimary),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text('Your household footprint',
                          style: t.headlineMedium),
                      const SizedBox(height: 4),
                      Text('Standardized carbon baseline for $fy',
                          style: t.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 16),
                      // ---- Headline number -------------------------------
                      AppCard(
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                CountUpText(
                                    value: r.totalKg,
                                    decimals: 0,
                                    style: t.displayMedium?.copyWith(
                                        color: AppColors.primary,
                                        fontSize: 52,
                                        height: 1)),
                                const SizedBox(width: 6),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Text('kg CO₂',
                                      style: t.titleMedium?.copyWith(
                                          color: AppColors.primary)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('/ month baseline emissions',
                                style: t.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary)),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: AppColors.tint,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.location_city_rounded,
                                          size: 18, color: AppColors.primary),
                                      const SizedBox(width: 8),
                                      Expanded(
                                          child: Text('Gujarat Urban Average',
                                              style: t.titleSmall)),
                                      Tag('$pctOfAvg% of benchmark',
                                          color: AppColors.tintStrong,
                                          textColor: AppColors.textPrimary),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    r.totalKg <= avg
                                        ? 'Urban household benchmark: ${avg.round()} kg CO₂. You are below the Gandhinagar & Ahmedabad metro baseline.'
                                        : pctOfAvg <= 105
                                            ? 'Urban household benchmark: ${avg.round()} kg CO₂. You match the Gandhinagar & Ahmedabad metro baseline.'
                                            : 'Urban household benchmark: ${avg.round()} kg CO₂. You are ${pctOfAvg - 100}% above the metro baseline — easy wins ahead.',
                                    style: t.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // ---- Breakdown -------------------------------------
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: AppColors.tint,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Text('Monthly emission breakdown',
                                          style: t.titleMedium)),
                                  Text('3 verified\nsources',
                                      style: t.labelLarge?.copyWith(
                                          color: AppColors.primary),
                                      textAlign: TextAlign.right),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            _BreakdownRow(
                                icon: Icons.bolt_rounded,
                                label: 'Electricity',
                                detail: '(${units.round()} kWh)',
                                kg: r.electricityKg,
                                share: r.electricityKg / total),
                            _BreakdownRow(
                                icon: Icons.propane_tank_outlined,
                                label: 'Cooking (LPG)',
                                detail:
                                    '(${d.lpgCylinders % 1 == 0 ? d.lpgCylinders.round() : d.lpgCylinders} cylinder${d.lpgCylinders == 1 ? '' : 's'})',
                                kg: r.cookingKg,
                                share: r.cookingKg / total),
                            _BreakdownRow(
                                icon: Icons.two_wheeler_rounded,
                                label: 'Transport',
                                detail:
                                    '(${d.weeklyKm.round()} km $travelLabel)',
                                kg: r.transportKg,
                                share: r.transportKg / total,
                                last: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // ---- Target --------------------------------------
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Choose your LiFE conservation target',
                                style: t.titleMedium),
                            const SizedBox(height: 2),
                            Text(
                                'Recommended reduction aligned with Gujarat Clean Energy Mission',
                                style: t.bodySmall),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                  color: AppColors.tint,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.border)),
                              child: Row(
                                children: [
                                  for (final g in [5, 10, 15])
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () =>
                                            setState(() => d.goalPercent = g),
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 160),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          decoration: BoxDecoration(
                                            color: d.goalPercent == g
                                                ? AppColors.surface
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                                color: d.goalPercent == g
                                                    ? AppColors.border
                                                    : Colors.transparent),
                                          ),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  if (d.goalPercent == g)
                                                    const Padding(
                                                      padding: EdgeInsets.only(
                                                          right: 6),
                                                      child: Icon(Icons.circle,
                                                          size: 7,
                                                          color: AppColors
                                                              .primary),
                                                    ),
                                                  Text('Save $g%',
                                                      style: t.titleSmall
                                                          ?.copyWith(
                                                              color: d.goalPercent ==
                                                                      g
                                                                  ? AppColors
                                                                      .primary
                                                                  : AppColors
                                                                      .textPrimary)),
                                                ],
                                              ),
                                              Text('${rupees(g)}/mo',
                                                  style: t.bodySmall),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: AppColors.tint,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.border)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.park_outlined,
                                          size: 18, color: AppColors.primary),
                                      const SizedBox(width: 8),
                                      Text('Impact Projection',
                                          style: t.titleSmall?.copyWith(
                                              color: AppColors.primary)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  RichText(
                                    text: TextSpan(
                                      style: t.bodyMedium,
                                      children: [
                                        const TextSpan(text: 'Saving '),
                                        TextSpan(
                                            text: '${d.goalPercent}%',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.primary)),
                                        const TextSpan(text: ' reduces '),
                                        TextSpan(
                                            text:
                                                '${(r.totalKg * d.goalPercent / 100).round()} kg CO₂/mo',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.primary)),
                                        const TextSpan(text: ' and earns '),
                                        TextSpan(
                                            text:
                                                '${d.goalPercent >= 15 ? 400 : d.goalPercent >= 10 ? 250 : 100} bonus GEDA civic credits.',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.primary)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: 'Start saving · Go to Home',
                        trailingIcon: Icons.arrow_forward_rounded,
                        height: 52,
                        loading: _saving,
                        onPressed: _saving ? null : () => _start(s, units),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () => context.safePop('/onboarding/5'),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Recalculate inputs'),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Center(
                        child: HelperText(
                            'Public Service Record · Mission LiFE Gujarat',
                            icon: Icons.shield_outlined),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.icon,
    required this.label,
    required this.detail,
    required this.kg,
    required this.share,
    this.last = false,
  });
  final IconData icon;
  final String label;
  final String detail;
  final double kg;
  final double share;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: t.titleSmall),
                    Text(detail,
                        style: t.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${kg.round()} kg CO₂',
                      style:
                          t.titleSmall?.copyWith(color: AppColors.primary)),
                  Text('${(share * 100).round()}% of total',
                      style: t.bodySmall),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
                value: share.clamp(0, 1),
                minHeight: 8,
                color: AppColors.primary,
                backgroundColor: AppColors.tintStrong),
          ),
        ],
      ),
    );
  }
}

class _RadioTile extends StatelessWidget {
  const _RadioTile(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.5 : 1)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AppColors.surface : AppColors.tintStrong,
                  border: Border.all(
                      color: selected ? AppColors.primary : AppColors.border,
                      width: selected ? 2 : 1),
                ),
                child: selected
                    ? Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                            color: AppColors.primary, shape: BoxShape.circle))
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(label,
                    style: t.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile(
      {required this.label,
      required this.icon,
      required this.selected,
      required this.onTap});
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Material(
      color: selected ? AppColors.surface : AppColors.tint,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.5 : 1)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 24,
                  color: selected ? AppColors.primary : AppColors.textSecondary),
              const SizedBox(height: 8),
              Text(label,
                  style: t.labelLarge?.copyWith(
                      color: selected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApplianceCheck extends StatelessWidget {
  const _ApplianceCheck(
      {required this.title,
      required this.subtitle,
      required this.icon,
      required this.selected,
      required this.onTap});
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
              color: selected ? AppColors.primary : AppColors.border)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.tintStrong,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: selected
                    ? const Icon(Icons.check_rounded,
                        size: 18, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: t.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    if (subtitle.isNotEmpty)
                      Text(subtitle,
                          style: t.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
