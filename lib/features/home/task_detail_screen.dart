import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/v3.dart';
import '../../core/widgets/widgets.dart';
import '../../data/app_state.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';
import 'home_screens.dart' show completeTaskFlow;

/// Full-page task detail (DESIGN-3 "Task Details").
class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key, required this.taskId});
  final String taskId;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final s = AppScope.of(context);
    final task = MockData.taskById(taskId);
    final status = s.statusOf(task.id);
    final done = status == TaskStatus.done;
    final energy = task.theme == LifeTheme.saveEnergy;

    return Scaffold(
      appBar: PageAppBar(
        title: 'Task Details',
        leading: const SafeBackButton(fallback: '/home'),
        actions: [
          IconButton(
              tooltip: 'Share',
              onPressed: () => showAppSnack(context, 'Share link copied',
                  icon: Icons.link_rounded),
              icon: const Icon(Icons.ios_share_rounded, size: 21)),
          IconButton(
              tooltip: 'Save',
              onPressed: () => showAppSnack(context, 'Saved to your tasks',
                  icon: Icons.bookmark_added_outlined),
              icon: const Icon(Icons.bookmark_border_rounded, size: 22)),
        ],
      ),
      body: PhoneFrame(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
          children: [
            // ---- Hero --------------------------------------------------
            AppCard(
              color: AppColors.surfaceLow,
              border: false,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconBubble(task.theme.icon,
                          size: 56,
                          color: task.theme.color,
                          background: Colors.white,
                          circle: true),
                      const Spacer(),
                      Flexible(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.end,
                          children: [
                            SoftChip('+${task.points} Points',
                                icon: Icons.local_fire_department_rounded,
                                color: AppColors.warning),
                            SoftChip(task.verification.label,
                                color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(task.title,
                      style: t.headlineMedium?.copyWith(
                          color: AppColors.primary, fontSize: 25)),
                  const SizedBox(height: 8),
                  Text(task.description,
                      style: t.bodyMedium
                          ?.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _HeroStat(
                            icon: Icons.eco_outlined,
                            label: 'CO₂ avoided',
                            value:
                                '${task.estCo2Kg.toStringAsFixed(2)} kg CO₂e'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _HeroStat(
                            icon: Icons.savings_outlined,
                            label: 'Monthly saving',
                            value: task.estRupees > 0
                                ? Fmt.rupees(task.estRupees)
                                : '${task.estUnitsSaved.toStringAsFixed(1)} units'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ---- Telemetry / why it matters -------------------------------
            if (energy) const _DemandCurveCard() else _WhyCard(task: task),
            const SizedBox(height: 16),

            // ---- Checklist -------------------------------------------------
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Eyebrow('Action checklist'),
                  const SizedBox(height: 4),
                  Text('How to complete it', style: t.headlineSmall),
                  const SizedBox(height: 16),
                  for (var i = 0; i < task.steps.length; i++)
                    _StepRow(
                      index: i + 1,
                      text: task.steps[i],
                      state: done
                          ? _StepState.done
                          : i == 0
                              ? _StepState.ready
                              : i == 1
                                  ? _StepState.active
                                  : _StepState.pending,
                      last: i == task.steps.length - 1,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Callout(
              icon: task.verification.icon,
              title: switch (task.verification) {
                Verification.self => 'Self-verified action',
                Verification.photo => 'Photo proof required',
                Verification.bill => 'Verified from your bill',
                Verification.vendor => 'Vendor confirmation',
              },
              text: switch (task.verification) {
                Verification.self =>
                  'No upload needed. Points are credited instantly and count '
                      'towards your daily self-verified cap.',
                Verification.photo =>
                  'Attach one photo when you commit. GEDA moderators spot-check '
                      'uploads; verified photos earn the full reward.',
                Verification.bill =>
                  'Log your monthly DISCOM bill in Impact → Add month entry. '
                      'The saving is computed from meter units automatically.',
                Verification.vendor =>
                  'Completed when an empanelled vendor confirms installation '
                      'through the GEDA portal.',
              },
            ),
            const SizedBox(height: 24),

            // ---- Actions ---------------------------------------------------
            Center(
              child: TextButton.icon(
                onPressed: () => context.push('/profile/notifications'),
                icon: const Icon(Icons.notifications_none_rounded, size: 18),
                label: const Text('Set a reminder'),
              ),
            ),
            const SizedBox(height: 6),
            PrimaryButton(
              label: done
                  ? 'Completed today'
                  : task.verification == Verification.bill
                      ? 'Log this month\'s bill'
                      : 'Commit to Task',
              icon: done
                  ? Icons.check_circle_rounded
                  : Icons.check_circle_outline_rounded,
              onPressed: done ? null : () => completeTaskFlow(context, task),
            ),
            if (!done) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        await s.skipTask(task);
                        if (context.mounted) context.safePop('/home');
                      },
                      child: const Text('Skip today'),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSecondary),
                      onPressed: () async {
                        await s.markNotApplicable(task);
                        if (context.mounted) context.safePop('/home');
                      },
                      child: const Text('Not applicable'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primaryLight),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.labelMedium
                      ?.copyWith(color: AppColors.textSecondary)),
              Text(value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.titleSmall?.copyWith(fontSize: 15)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Illustrative Gujarat 24-hour demand curve with the evening peak window.
class _DemandCurveCard extends StatelessWidget {
  const _DemandCurveCard();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    const values = <double>[52, 60, 74, 70, 78, 100, 56];
    const labels = ['00:00', '04:00', '08:00', '12:00', '16:00', '18–22', '24:00'];
    final colors = [
      const Color(0xFFB9E4B4),
      const Color(0xFFA5DCA0),
      const Color(0xFF9BE59A),
      const Color(0xFF9BE59A),
      const Color(0xFF9BE59A),
      AppColors.secondary,
      AppColors.primary,
    ];
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('GUVNL live telemetry'),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Text('Gujarat 24-Hour Demand Curve',
                      style: t.headlineSmall)),
              const SizedBox(width: 8),
              const SoftChip('Sync 2m ago',
                  icon: Icons.circle, color: AppColors.primaryLight, dense: true),
            ],
          ),
          const SizedBox(height: 14),
          const Callout(
            icon: Icons.warning_amber_rounded,
            color: AppColors.warning,
            title: 'Peak Load Window (18:00 – 22:00)',
            text:
                'High grid thermal strain. Running heavy loads during this '
                'period incurs penalty factors.',
          ),
          const SizedBox(height: 18),
          Stack(
            clipBehavior: Clip.none,
            children: [
              DemandBars(
                  values: values,
                  labels: labels,
                  colors: colors,
                  boldLabels: const {5, 6}),
              Positioned(
                right: 44,
                top: -14,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: const Color(0xFF8A5A00),
                      borderRadius: BorderRadius.circular(999)),
                  child: Text('Peak Stress Zone',
                      style: t.labelSmall?.copyWith(
                          color: Colors.white, letterSpacing: 0)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const _LegendDot(AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                  child: Text('Recommended window (10 PM – 6 AM)',
                      maxLines: 2, style: t.bodySmall)),
              const SizedBox(width: 10),
              const _LegendDot(AppColors.secondary),
              const SizedBox(width: 6),
              Expanded(
                  child: Text('Heavy load penalty',
                      maxLines: 2, style: t.bodySmall)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot(this.color);
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}

class _WhyCard extends StatelessWidget {
  const _WhyCard({required this.task});
  final TaskItem task;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('Why it matters'),
          const SizedBox(height: 4),
          Text(task.theme.label, style: t.headlineSmall),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: MetricTile(
                    label: 'CO₂ avoided',
                    value: task.estCo2Kg.toStringAsFixed(1),
                    unit: 'kg',
                    color: AppColors.surfaceLow),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MetricTile(
                    label: 'Green credits',
                    value: '+${task.points}',
                    unit: 'pts',
                    color: AppColors.surfaceLow),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
              'Mission LiFE counts every household action. Repeating this '
              'task weekly adds up to about ${(task.estCo2Kg * 52).toStringAsFixed(0)} kg CO₂ a year '
              '— roughly ${(task.estCo2Kg * 52 / 21).clamp(1, 999).toStringAsFixed(0)} tree(s) worth of absorption.',
              style: t.bodyMedium?.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

enum _StepState { ready, active, pending, done }

class _StepRow extends StatelessWidget {
  const _StepRow(
      {required this.index,
      required this.text,
      required this.state,
      required this.last});
  final int index;
  final String text;
  final _StepState state;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final (chipLabel, chipColor) = switch (state) {
      _StepState.ready => ('Ready', AppColors.primaryLight),
      _StepState.active => ('In progress', AppColors.success),
      _StepState.pending => ('Pending', AppColors.textTertiary),
      _StepState.done => ('Done', AppColors.primaryLight),
    };
    final marker = switch (state) {
      _StepState.ready || _StepState.done => Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
              color: AppColors.primary, shape: BoxShape.circle),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
        ),
      _StepState.active => Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2)),
          child: Center(
            child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle)),
          ),
        ),
      _StepState.pending => Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
              color: AppColors.tint, shape: BoxShape.circle),
          child: const Icon(Icons.hourglass_bottom_rounded,
              size: 18, color: AppColors.textSecondary),
        ),
    };
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              marker,
              if (!last)
                Expanded(
                    child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: AppColors.tintStrong)),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text('Step $index',
                            style: t.titleSmall?.copyWith(fontSize: 15)),
                      ),
                      const SizedBox(width: 8),
                      SoftChip(chipLabel, color: chipColor, dense: true),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(text,
                      style: t.bodyMedium
                          ?.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
