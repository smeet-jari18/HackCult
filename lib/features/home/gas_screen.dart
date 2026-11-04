import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';

/// "Add Gas Connection" — link an LPG cylinder subscription or a PNG meter so
/// cooking-fuel emissions and refill points can be tracked.
class GasConnectionScreen extends StatefulWidget {
  const GasConnectionScreen({super.key});

  @override
  State<GasConnectionScreen> createState() => _GasConnectionScreenState();
}

class _GasConnectionScreenState extends State<GasConnectionScreen> {
  static const lpgProviders = [
    'Indane (IOCL) - Indian Oil',
    'HP Gas (HPCL)',
    'Bharatgas (BPCL)',
  ];
  static const pngProviders = [
    'Gujarat Gas Ltd',
    'Adani Total Gas',
    'Sabarmati Gas',
    'Vadodara Gas Ltd',
  ];

  final _form = GlobalKey<FormState>();
  String _type = 'lpg';
  String? _provider;
  final _consumer = TextEditingController();
  final _agency = TextEditingController();
  int _cylinders = 1;
  int _scm = 15;
  bool _pmuy = false;
  bool _proof = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final g = AppScope.read(context).gas;
    if (g != null) {
      _type = g.type;
      _provider = g.provider;
      _consumer.text = g.consumerNumber;
      _agency.text = g.agency;
      _cylinders = g.cylindersPerMonth;
      _scm = g.scmPerMonth;
      _pmuy = g.pmuy;
      _proof = g.proofAttached;
    }
  }

  @override
  void dispose() {
    _consumer.dispose();
    _agency.dispose();
    super.dispose();
  }

  bool get _png => _type == 'png';
  List<String> get _providers => _png ? pngProviders : lpgProviders;

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (_provider == null) {
      showAppSnack(context, 'Select your gas provider',
          icon: Icons.error_outline_rounded, color: AppColors.error);
      return;
    }
    setState(() => _saving = true);
    final s = AppScope.read(context);
    await s.saveGasConnection(GasConnection(
      type: _type,
      provider: _provider!,
      consumerNumber: _consumer.text.trim(),
      agency: _agency.text.trim(),
      cylindersPerMonth: _cylinders,
      scmPerMonth: _scm,
      pmuy: _pmuy,
      proofAttached: _proof,
    ));
    if (!mounted) return;
    setState(() => _saving = false);
    HapticFeedback.lightImpact();
    showAppSnack(
        context,
<<<<<<< HEAD
        s.isLiveBackend
=======
        s.useFirebase
>>>>>>> 3925557e47509db90e39ef76831483fc9ae78a47
            ? 'Gas connection saved on this device.'
            : 'Gas connection linked · +50 Green Credits',
        icon: Icons.check_circle_outline_rounded,
        color: AppColors.primary);
    context.safePop('/home');
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final s = AppScope.of(context);
    final kgPerUnit = _png ? s.config.factors.png : 14.2 * s.config.factors.lpg;
    final monthlyKg = _png ? _scm * kgPerUnit : _cylinders * kgPerUnit;
    return Scaffold(
      appBar: const PageAppBar(
        title: 'Add Gas Connection',
        subtitle: 'Mission LiFE · Cooking Fuel Tracking',
        leading: SafeBackButton(fallback: '/home'),
      ),
      body: PhoneFrame(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CardTitle(
                        icon: Icons.propane_tank_outlined,
                        title: 'Link LPG Cylinder or PNG Meter'),
                    const SizedBox(height: 8),
                    Text(
                        'Track clean cooking fuel consumption, monitor CO₂ offset, and earn GEDA civic credits under Gujarat Clean Cooking Energy mission.',
                        style: t.bodyMedium
                            ?.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 10),
                    const Tag('+50 Green Credits on linking',
                        icon: Icons.verified_outlined),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SegmentedChoice<String>(
                value: _type,
                height: 48,
                onChanged: (v) => setState(() {
                  _type = v;
                  _provider = null;
                }),
                options: const [
                  ('lpg', 'LPG Cylinder'),
                  ('png', 'PNG Meter'),
                ],
              ),
              const SizedBox(height: 24),
              const FieldLabel('Gas Provider / Company', required: true),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _provider,
                isExpanded: true,
                hint: const Text('Select provider'),
                items: [
                  for (final p in _providers)
                    DropdownMenuItem(value: p, child: Text(p)),
                ],
                onChanged: (v) => setState(() => _provider = v),
                validator: (v) => v == null ? 'Select a provider' : null,
              ),
              const HelperText(
                  'Select state-recognised oil marketing company or piped utility'),
              const SizedBox(height: 14),
              AppTextField(
                label: _png ? 'Customer / Meter Number' : 'Consumer Number / SV Number',
                required: true,
                controller: _consumer,
                hint: _png ? '1023456789' : '2847192048',
                keyboardType: TextInputType.number,
                maxLength: 17,
                validator: (v) {
                  final x = (v ?? '').trim();
                  if (x.length < 6) return 'Enter a valid number';
                  if (!RegExp(r'^[0-9A-Za-z]+$').hasMatch(x)) {
                    return 'Only letters and digits';
                  }
                  return null;
                },
                suffix: Tooltip(
                  message: _png
                      ? 'Printed on your PNG bill'
                      : 'Found on LPG subscription voucher (SV) or domestic blue book',
                  triggerMode: TooltipTriggerMode.tap,
                  child: const Icon(Icons.help_outline_rounded, size: 20),
                ),
              ),
              HelperText(
                  _png
                      ? 'Found on the top of your monthly PNG bill.'
                      : 'Found on LPG subscription voucher (SV) or domestic blue book',
                  icon: Icons.info_outline_rounded),
              const SizedBox(height: 14),
              AppTextField(
                label: _png ? 'Service Area / Zone' : 'LPG Agency / Distributor',
                required: !_png,
                controller: _agency,
                hint: _png
                    ? 'Ahmedabad City Gas Zone 4'
                    : 'Sabarmati Indane Gas Agency, Ahmedabad',
                validator: (v) =>
                    !_png && (v ?? '').trim().length < 3 ? 'Enter agency' : null,
                suffix: const Icon(Icons.check_circle_outline_rounded,
                    size: 20, color: AppColors.primary),
              ),
              HelperText(
                  _png
                      ? 'Verified with the city gas distribution licence.'
                      : 'Verified with Food, Civil Supplies & Consumer Affairs Dept.'),
              const SizedBox(height: 14),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: FieldLabel(
                              _png
                                  ? 'Estimated Monthly Consumption'
                                  : 'Estimated Monthly Cylinders',
                              required: true),
                        ),
                        Tag(_png
                            ? 'Metered'
                            : _cylinders <= 1
                                ? 'Standard Household'
                                : 'Large Household'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: AppColors.tint,
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          _StepBtn(
                              icon: Icons.remove_rounded,
                              onTap: () => setState(() {
                                    if (_png) {
                                      _scm = (_scm - 5).clamp(5, 200);
                                    } else {
                                      _cylinders =
                                          (_cylinders - 1).clamp(1, 6);
                                    }
                                  })),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                    _png
                                        ? '$_scm SCM'
                                        : '$_cylinders Cylinder${_cylinders > 1 ? 's' : ''} (14.2 kg)',
                                    style: t.titleMedium),
                                Text(
                                    _png
                                        ? 'Per monthly bill'
                                        : '~${(45 ~/ _cylinders).clamp(8, 60)}–${(60 ~/ _cylinders).clamp(10, 60)} Days Burn Cycle',
                                    style: t.bodySmall),
                              ],
                            ),
                          ),
                          _StepBtn(
                              icon: Icons.add_rounded,
                              onTap: () => setState(() {
                                    if (_png) {
                                      _scm = (_scm + 5).clamp(5, 200);
                                    } else {
                                      _cylinders =
                                          (_cylinders + 1).clamp(1, 6);
                                    }
                                  })),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    HelperText(
                        'Baseline emission: ~${monthlyKg.toStringAsFixed(1)} kg CO₂ equivalent per ${_png ? 'month' : 'refill cycle'}',
                        icon: Icons.co2_rounded),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: Text(
                                _png
                                    ? 'Latest PNG Bill'
                                    : 'Gas Passbook or Last Booking Slip',
                                style: t.titleSmall)),
                        const Tag('Optional',
                            color: AppColors.tintStrong,
                            textColor: AppColors.textPrimary),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.tint,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle),
                            child: Icon(
                                _proof
                                    ? Icons.task_outlined
                                    : Icons.menu_book_outlined,
                                color: AppColors.primary),
                          ),
                          const SizedBox(height: 8),
                          Text(
                              _proof
                                  ? 'Document attached'
                                  : 'Verify Consumption Baseline',
                              style: t.titleSmall),
                          const SizedBox(height: 2),
                          Text(
                              _proof
                                  ? 'GEDA verification badge will be issued after review.'
                                  : 'Upload recent refill voucher or consumer slip to unlock instant GEDA verification badge (+20 pts).',
                              style: t.bodySmall,
                              textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _attach('camera'),
                                  icon: const Icon(Icons.photo_camera_outlined,
                                      size: 18),
                                  label: const Text('Take Photo'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _attach('file'),
                                  icon: const Icon(Icons.upload_file_outlined,
                                      size: 18),
                                  label: const Text('Upload File'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              AppCard(
                padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
                onTap: () => setState(() => _pmuy = !_pmuy),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                          value: _pmuy,
                          onChanged: (v) =>
                              setState(() => _pmuy = v ?? false)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Enrolled in PM Ujjwala Yojana (PMUY) or Gujarat Piped Gas Subsidy',
                              style: t.labelLarge),
                          const SizedBox(height: 2),
                          Text(
                              'Auto-validates state cooking fuel energy credits and low-emission household incentives.',
                              style: t.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const HelperText(
                  'Protected under Digital Personal Data Protection (DPDP) Act 2023 · GEDA Energy Audit Certified',
                  icon: Icons.shield_outlined),
              const SizedBox(height: 16),
              PrimaryButton(
                  label: 'Save & Link Gas Connection',
                  icon: Icons.link_rounded,
                  loading: _saving,
                  onPressed: _save,
                  height: 48),
            ],
          ),
        ),
      ),
    );
  }

  void _attach(String how) {
    setState(() => _proof = true);
    showAppSnack(
        context,
        how == 'camera'
            ? 'Photo captured (demo) — attached to your gas record.'
            : 'File attached (demo) — attached to your gas record.',
        icon: Icons.attach_file_rounded);
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.border)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: SizedBox(
            width: 44, height: 44, child: Icon(icon, color: AppColors.primary)),
      ),
    );
  }
}
