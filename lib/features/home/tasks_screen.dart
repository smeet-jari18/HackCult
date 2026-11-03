import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/widgets.dart';
import '../../data/app_state.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';
import 'home_screens.dart';

/// Tasks tab — "Eco-Tasks": daily cap progress, theme filters and the
/// full Mission LiFE task library grouped into Today / More tasks.
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  LifeTheme? _theme;
  String _query = '';
  bool _searching = false;
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final u = s.user!;
    final t = Theme.of(context).textTheme;
    final today = s.todayTasks;
    final todayIds = today.map((e) => e.id).toSet();
    final all = MockData.tasks
        .where((x) =>
            x.verification != Verification.vendor &&
            !todayIds.contains(x.id) &&
            !s.notApplicable.contains(x.id))
        .toList();

    bool matches(TaskItem x) {
      if (_theme != null && x.theme != _theme) return false;
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return x.title.toLowerCase().contains(q) ||
          x.description.toLowerCase().contains(q);
    }

    final todayList = today.where(matches).toList();
    final moreList = all.where(matches).toList();
    final cap = s.config.dailySelfPointsCap;
    final used = s.pointsTodaySelf.clamp(0, cap);

    final counts = <LifeTheme, int>{};
    for (final x in [...today, ...all]) {
      counts[x.theme] = (counts[x.theme] ?? 0) + 1;
    }
    final themes = counts.keys.toList()
      ..sort((a, b) => (counts[b] ?? 0).compareTo(counts[a] ?? 0));

    return Scaffold(
      appBar: PageAppBar(
        title: 'Eco-Tasks',
        subtitle: 'Mission LiFE Gujarat Action Log',
        leading: const SafeBackButton(fallback: '/home'),
        actions: [
          _SquareIconButton(
            icon: _searching ? Icons.close_rounded : Icons.search_rounded,
            onTap: () => setState(() {
              _searching = !_searching;
              if (!_searching) {
                _query = '';
                _search.clear();
              }
            }),
          ),
          const SizedBox(width: 8),
          _SquareIconButton(
            icon: Icons.tune_rounded,
            dot: _theme != null,
            onTap: () => _openFilter(themes, counts),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          if (_searching) ...[
            const SizedBox(height: 4),
            TextField(
              controller: _search,
              autofocus: true,
              onChanged: (v) => setState(() => _query = v.trim()),
              decoration: const InputDecoration(
                hintText: 'Search tasks (e.g. AC, geyser, LED)',
                prefixIcon: Icon(Icons.search_rounded, size: 20),
              ),
            ),
          ],
          const SizedBox(height: 4),
          // ---- Daily cap -------------------------------------------------
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.tint,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text('Daily Cap Progress',
                            style: t.labelLarge
                                ?.copyWith(color: AppColors.primary))),
                    Text('$used / $cap pts',
                        style:
                            t.labelLarge?.copyWith(color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                      value: cap == 0 ? 0 : used / cap,
                      minHeight: 8,
                      backgroundColor: Colors.white),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                        child: Text(
                            'Self-verified cap: ${cap - used} pts remaining',
                            style: t.bodySmall)),
                    Text('${u.district.isEmpty ? 'Gujarat' : u.district} Grid',
                        style: t.labelMedium
                            ?.copyWith(color: AppColors.primary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // ---- Theme chips ---------------------------------------------
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                    label: 'All (${today.length + all.length})',
                    selected: _theme == null,
                    onTap: () => setState(() => _theme = null)),
                for (final th in themes) ...[
                  const SizedBox(width: 8),
                  _FilterChip(
                      label: '${th.label} (${counts[th]})',
                      selected: _theme == th,
                      onTap: () => setState(() => _theme = th)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          // ---- Today's priority ----------------------------------------
          _GroupHeader(title: "Today's Priority", count: todayList.length),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: todayList.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text('No tasks match this filter.',
                        style: t.bodySmall),
                  )
                : Column(
                    children: [
                      for (var i = 0; i < todayList.length; i++) ...[
                        _TaskListRow(task: todayList[i]),
                        if (i < todayList.length - 1) const Divider(),
                      ],
                    ],
                  ),
          ),
          const SizedBox(height: 24),
          _GroupHeader(title: 'More Mission LiFE tasks', count: moreList.length),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: moreList.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text('Nothing here — try another filter.',
                        style: t.bodySmall),
                  )
                : Column(
                    children: [
                      for (var i = 0; i < moreList.length; i++) ...[
                        _TaskListRow(task: moreList[i]),
                        if (i < moreList.length - 1) const Divider(),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _openFilter(
      List<LifeTheme> themes, Map<LifeTheme, int> counts) async {
    final picked = await showModalBottomSheet<LifeTheme?>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Filter by Mission LiFE theme',
                    style: Theme.of(ctx).textTheme.titleMedium),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.all_inclusive_rounded),
              title: const Text('All themes'),
              trailing: _theme == null
                  ? const Icon(Icons.check_rounded, color: AppColors.primary)
                  : null,
              onTap: () => Navigator.pop(ctx, null),
            ),
            for (final th in themes)
              ListTile(
                leading: Icon(th.icon, color: th.color),
                title: Text(th.label),
                subtitle: Text('${counts[th]} tasks'),
                trailing: _theme == th
                    ? const Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.pop(ctx, th),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (!mounted) return;
    setState(() => _theme = picked);
  }
}

class _TaskListRow extends StatelessWidget {
  const _TaskListRow({required this.task});
  final TaskItem task;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final status = s.statusOf(task.id);
    return TaskRow(
      task: task,
      status: status,
      onTap: () => showTaskSheet(context, task),
      onToggle: () => completeTaskFlow(context, task),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.title, required this.count});
  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(title, style: t.titleMedium)),
          Text('$count ${count == 1 ? 'Task' : 'Tasks'}', style: t.bodySmall),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Material(
      color: selected ? AppColors.primary : AppColors.tint,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
              color: selected ? AppColors.primary : AppColors.border)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(selected ? Icons.circle : Icons.circle_outlined,
                  size: 8, color: selected ? Colors.white : AppColors.outline),
              const SizedBox(width: 8),
              Text(label,
                  style: t.labelLarge?.copyWith(
                      color: selected ? Colors.white : AppColors.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton(
      {required this.icon, required this.onTap, this.dot = false});
  final IconData icon;
  final VoidCallback onTap;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.tint,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.border)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, size: 20, color: AppColors.textPrimary),
              if (dot)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
