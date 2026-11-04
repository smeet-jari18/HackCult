import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/v3.dart';
import '../../core/widgets/widgets.dart';

/// Shared frame for the long-form legal pages.
class _LegalPage extends StatelessWidget {
  const _LegalPage({
    required this.title,
    required this.subtitle,
    required this.statusTag,
    required this.heading,
    required this.intro,
    required this.sections,
    required this.ctaLabel,
    this.trust,
    this.officer = false,
  });
  final String title;
  final String subtitle;
  final String statusTag;
  final String heading;
  final String intro;
  final List<Widget> sections;
  final String ctaLabel;
  final Widget? trust;
  final bool officer;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: PageAppBar(
        title: title,
        subtitle: subtitle,
        leading: const SafeBackButton(fallback: '/profile'),
        actions: [
          IconButton(
              tooltip: 'Share',
              onPressed: () => showAppSnack(context, 'Link copied',
                  icon: Icons.link_rounded),
              icon: const Icon(Icons.ios_share_rounded, size: 21)),
        ],
      ),
      body: PhoneFrame(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: SoftChip(statusTag,
                            icon: Icons.verified_rounded,
                            color: AppColors.primaryLight),
                      ),
                      const SizedBox(width: 8),
                      Text('GEDA Reg. Auth',
                          maxLines: 1,
                          style: t.labelMedium
                              ?.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined,
                                size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text('Effective: May 2025 • Version 2.4',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: t.labelMedium?.copyWith(
                                      color: AppColors.textSecondary)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(heading,
                            style: t.headlineMedium?.copyWith(fontSize: 23)),
                        const SizedBox(height: 10),
                        Text(intro,
                            style: t.bodyMedium?.copyWith(
                                color: AppColors.textSecondary, height: 1.55)),
                        if (trust != null) ...[
                          const SizedBox(height: 14),
                          trust!,
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final w in sections) ...[w, const SizedBox(height: 16)],
                  if (officer) const _OfficerCard(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_outline_rounded,
                          size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                            'Encrypted & certified by National Informatics Centre (NIC) Gujarat',
                            textAlign: TextAlign.center,
                            style: t.labelSmall?.copyWith(
                                color: AppColors.textTertiary,
                                letterSpacing: 0)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // sticky action
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: OutlinedButton.icon(
                        onPressed: () => showAppSnack(
                            context, 'PDF download will start shortly',
                            icon: Icons.download_rounded),
                        icon: const Icon(Icons.download_rounded, size: 18),
                        label: const FittedBox(
                            fit: BoxFit.scaleDown, child: Text('Download PDF')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: PrimaryButton(
                        label: ctaLabel,
                        icon: Icons.check_rounded,
                        onPressed: () => context.safePop('/profile'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfficerCard extends StatelessWidget {
  const _OfficerCard();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: Eyebrow('Statutory officer')),
              Icon(Icons.badge_outlined,
                  size: 18, color: AppColors.primaryLight),
            ],
          ),
          const SizedBox(height: 6),
          Text('Data Protection & Grievance Officer',
              style: t.titleMedium?.copyWith(fontSize: 17)),
          const SizedBox(height: 2),
          Text('Gujarat Energy Development Agency (GEDA)',
              style: t.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
          Text('4th Floor, Block No. 11 & 12, Udyog Bhavan, Gandhinagar – 382010',
              style: t.bodySmall),
          const SizedBox(height: 12),
          _ContactRow(
              icon: Icons.mail_outline_rounded,
              text: 'dpo.geda@gujarat.gov.in',
              trailing: Icons.arrow_forward_rounded),
          const SizedBox(height: 8),
          _ContactRow(
              icon: Icons.call_outlined,
              text: '1800-233-0122 (Toll Free)',
              trailing: Icons.call_rounded),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow(
      {required this.icon, required this.text, required this.trailing});
  final IconData icon;
  final String text;
  final IconData trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
          color: AppColors.surfaceLow, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
              child: Text(text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: AppColors.primary))),
          Icon(trailing, size: 16, color: AppColors.primary),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Privacy policy
// ---------------------------------------------------------------------------
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    Widget sub(String s) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(s,
            style: t.bodyMedium
                ?.copyWith(color: AppColors.textSecondary, height: 1.5)));
    Widget dataRow(IconData i, String title, String body) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(14)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(i, size: 18, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: t.labelLarge),
                    const SizedBox(height: 2),
                    Text(body,
                        style: t.bodySmall
                            ?.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        );

    return _LegalPage(
      title: 'Privacy Policy',
      subtitle: 'LiFE Mitra Gujarat • GEDA',
      statusTag: 'DPDP Act 2023 compliant',
      heading: 'Your Data Rights & Environmental Telemetry',
      intro:
          'The Gujarat Energy Development Agency (GEDA) collects civic utility '
          'and environmental telemetry strictly to evaluate domestic carbon '
          'abatement. Your personal data is sovereign, protected by national '
          'statutory mandates, and strictly safeguarded.',
      trust: const Callout(
        icon: Icons.shield_outlined,
        title: 'End-to-End Civic Confidentiality',
        text:
            'Consumer power, solar generation and piped-gas telemetry are '
            'encrypted at rest and in transit. Information is never monetised '
            'or sold to third parties.',
      ),
      ctaLabel: 'I Understand',
      officer: true,
      sections: [
        LegalSection(index: 1, title: 'Scope & Legislative Framework', children: [
          sub('This Policy governs all users of the LiFE Mitra platform '
              'administered under the Gujarat Energy Development Agency '
              '(GEDA), Department of Energy and Petrochemicals, Government of '
              'Gujarat.'),
          const Callout(
              icon: Icons.gavel_rounded,
              text:
                  'Framed in strict accordance with the Digital Personal Data '
                  'Protection Act, 2023 (DPDP Act), and cybersecurity norms '
                  'issued by Gujarat Informatics Limited (GIL).'),
        ]),
        LegalSection(index: 2, title: 'Data We Collect', children: [
          sub('We collect the minimum telemetry parameters required for '
              'computing authentic household energy savings:'),
          dataRow(Icons.bolt_rounded, 'DISCOM Consumer Numbers',
              'Validated customer account numbers for UGVCL, MGVCL, PGVCL and DGVCL to fetch net power tariffs.'),
          dataRow(Icons.solar_power_outlined, 'Telemetry & Fuels',
              'PNG / LPG consumption units, rooftop solar inverter generation (Surya Gujarat) and smart-meter telemetry.'),
          dataRow(Icons.groups_outlined, 'Voluntary Community Action',
              'Ward / society conservation leaderboards, civic tree-plantation logs and LiFE pledge commitments.'),
        ]),
        LegalSection(index: 3, title: 'Purpose of Processing', children: [
          sub('Energy and conservation logs are analysed strictly for verified '
              'ecological calculations:'),
          const LegalPoint('Baseline establishment and seasonal power conservation ratios.'),
          const LegalPoint('Automated Green Credit issuance and institutional incentives.'),
          const LegalPoint('Aggregated, anonymised carbon audit for Gujarat Net-Zero targets.'),
          const LegalPoint('Zero commercial advertisement profiling or broker transfers.',
              icon: Icons.block_rounded, color: AppColors.error),
        ]),
        LegalSection(index: 4, title: 'Citizen Consent & Revocation', children: [
          sub('You maintain unalienable autonomy over your data under Section '
              '6(1) of the DPDP Act 2023.'),
          const Callout(
              icon: Icons.toggle_off_outlined,
              text:
                  'You may revoke data-fetching permissions for DISCOM consumer '
                  'IDs at any time via Settings → Connected Utilities. '
                  'Revocation immediately ceases external meter synchronisation '
                  'and removes active participation from ward leaderboards '
                  'within 7 business days.'),
        ]),
        LegalSection(index: 5, title: 'Data Storage & Security', children: [
          sub('In accordance with sovereign data-localisation rules, no '
              'consumer data ever leaves state jurisdiction:'),
          Row(
            children: [
              Expanded(
                  child: MetricTile(
                      label: 'Location',
                      value: 'GSDC',
                      foot: 'Gandhinagar, Gujarat',
                      footColor: AppColors.textSecondary,
                      icon: Icons.location_on_outlined,
                      color: AppColors.surfaceLow)),
              const SizedBox(width: 10),
              Expanded(
                  child: MetricTile(
                      label: 'Encryption',
                      value: 'AES-256',
                      foot: 'at rest · TLS 1.3 transit',
                      footColor: AppColors.textSecondary,
                      icon: Icons.lock_outline_rounded,
                      color: AppColors.surfaceLow)),
            ],
          ),
        ]),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Terms of service
// ---------------------------------------------------------------------------
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    Widget sub(String s) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(s,
            style: t.bodyMedium
                ?.copyWith(color: AppColors.textSecondary, height: 1.5)));

    return _LegalPage(
      title: 'Terms of Service',
      subtitle: 'GEDA • Climate Change Dept',
      statusTag: 'Official framework',
      heading: 'Mission LiFE Gujarat Citizen Terms',
      intro:
          'Welcome to the civic cooperative platform empowering citizens across '
          'Gujarat to adopt sustainable lifestyles for environmental '
          'stewardship (Mission LiFE) in accordance with the Gujarat Energy '
          'Development Agency (GEDA).',
      trust: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user_outlined,
                  size: 16, color: AppColors.primaryLight),
              const SizedBox(width: 6),
              Expanded(
                child: Text('Citizen Trust & Transparent Telemetry Guarantee',
                    style: t.labelMedium
                        ?.copyWith(color: AppColors.primaryLight)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.eco_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Commitment to Clean Energy',
                          style: t.titleSmall?.copyWith(color: Colors.white)),
                      const SizedBox(height: 2),
                      Text(
                          'Governed by Gujarat State Policy on Decentralized '
                          'Renewable Energy & rooftop solar conservation protocols.',
                          style: t.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.85))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ctaLabel: 'Accept & Acknowledge',
      sections: [
        LegalSection(
            index: 1,
            title: 'Acceptance of Terms',
            tag: 'Civic Protocol Standard',
            children: [
              sub('By accessing LiFE Mitra, citizens agree to authentic '
                  'telemetry reporting and civic energy conservation '
                  'guidelines. Participation constitutes voluntary alignment '
                  "with Gujarat's net-zero transition goals, ensuring "
                  'responsible reporting of residential solar generation and '
                  'energy conservation indices.'),
            ]),
        LegalSection(
            index: 2,
            title: 'Green Credits & Incentive Mechanism',
            tag: 'Non-Monetary Credits',
            tagColor: AppColors.warning,
            children: [
              sub('Rules governing earned credits, non-monetary transferable '
                  'incentives, municipal benefits and verification via DISCOM '
                  'meters:'),
              const LegalPoint('Credits are awarded solely for validated reductions against ward baselines.'),
              const LegalPoint('Municipal rebates (e.g. civic tax relief, EV charging credits) remain contingent upon DISCOM confirmation.'),
              const LegalPoint('Green Credits hold zero direct cash liquidity and are restricted to state-approved ecological benefits.'),
            ]),
        LegalSection(
            index: 3,
            title: 'Smart Meter & Utility Sync',
            tag: 'UGVCL • DGVCL • MGVCL • PGVCL',
            children: [
              sub('Accurate linking of state electricity / gas connections is '
                  'required. Prohibition of falsified meter logs:'),
              const Callout(
                  icon: Icons.warning_amber_rounded,
                  color: AppColors.error,
                  text:
                      'Any attempted spoofing of smart-meter telemetry or '
                      'duplicate consumer numbers results in immediate account '
                      'de-registration and clawback of associated civic '
                      'incentives.'),
            ]),
        LegalSection(
            index: 4,
            title: 'Community Conduct & Ward Challenges',
            tag: 'Decentralized Civic Honor',
            children: [
              sub('Respectful civic collaboration and anti-tampering rules on '
                  'community leaderboard entries are strictly enforced. '
                  'Ward-level green rankings are designed to celebrate '
                  'cooperative neighbourhood savings without harassment, '
                  'false-flag reporting, or non-verified claims.'),
            ]),
        LegalSection(
            index: 5,
            title: 'Service Modifications & Governance',
            tag: 'Regulatory Oversight',
            children: [
              sub('The Department of Climate Change and GEDA reserve the '
                  'express right to update emission benchmark indices, credit '
                  'computation ratios and solar net-metering telemetry '
                  'algorithms based on annual climate policy directives.'),
            ]),
      ],
    );
  }
}
