// DESIGN-3 ("Civic Ecological Utility") building blocks.
//
// Soft white cards (20 px radius, diffused shadow), pill chips/buttons,
// uppercase eyebrow labels and simple telemetry charts. Everything here is
// pure Flutter – no extra packages.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Small uppercase tracking label ("CARBON OFFSET METRIC").
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text,
      {super.key, this.color = AppColors.textSecondary, this.maxLines = 1});
  final String text;
  final Color color;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(),
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: color, letterSpacing: 0.8));
  }
}

/// Pill chip with tinted background (streak amber, trend green, water blue…).
class SoftChip extends StatelessWidget {
  const SoftChip(this.text,
      {super.key,
      this.icon,
      this.color = AppColors.primaryLight,
      this.filled = false,
      this.dense = false});
  final String text;
  final IconData? icon;
  final Color color;
  final bool filled;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? Colors.white : color;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: dense ? 10 : 12, vertical: dense ? 4 : 7),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dense ? 13 : 15, color: fg),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: fg, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

/// Circular / squircle icon bubble.
class IconBubble extends StatelessWidget {
  const IconBubble(this.icon,
      {super.key,
      this.size = 44,
      this.color = AppColors.primary,
      this.background,
      this.circle = false,
      this.iconSize});
  final IconData icon;
  final double size;
  final Color color;
  final Color? background;
  final bool circle;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background ?? color.withValues(alpha: 0.12),
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(size * 0.36),
      ),
      child: Icon(icon, size: iconSize ?? size * 0.5, color: color),
    );
  }
}

/// Compact metric tile: eyebrow + big value + unit + optional footnote.
class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.foot,
    this.footColor = AppColors.primaryLight,
    this.footIcon,
    this.icon,
    this.iconColor = AppColors.primaryLight,
    this.color,
  });
  final String label;
  final String value;
  final String? unit;
  final String? foot;
  final Color footColor;
  final IconData? footIcon;
  final IconData? icon;
  final Color iconColor;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x0F1B5E20)),
        boxShadow: color == null ? AppShadows.level1 : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Eyebrow(label, maxLines: 2)),
              if (icon != null) Icon(icon, size: 16, color: iconColor),
            ],
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(children: [
              TextSpan(
                  text: value,
                  style: t.headlineSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5)),
              if (unit != null)
                TextSpan(
                    text: ' $unit',
                    style: t.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
            ]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (foot != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                if (footIcon != null) ...[
                  Icon(footIcon, size: 12, color: footColor),
                  const SizedBox(width: 3),
                ],
                Expanded(
                  child: Text(foot!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.labelSmall?.copyWith(
                          color: footColor, letterSpacing: 0)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Rounded settings / navigation row used in grouped cards.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.subtitleColor,
    this.trailing,
    this.onTap,
    this.iconColor = AppColors.primary,
    this.danger = false,
    this.chevron = true,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? subtitleColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color iconColor;
  final bool danger;
  final bool chevron;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final fg = danger ? AppColors.error : iconColor;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            IconBubble(icon, size: 40, color: fg, iconSize: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.titleSmall?.copyWith(
                          color: danger ? AppColors.error : null,
                          fontSize: 15)),
                  if (subtitle != null)
                    Text(subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.bodySmall?.copyWith(
                            color: subtitleColor ?? AppColors.textSecondary)),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            if (chevron && onTap != null) ...[
              const SizedBox(width: 6),
              Icon(
                  danger
                      ? Icons.arrow_forward_rounded
                      : Icons.chevron_right_rounded,
                  size: 20,
                  color: danger ? AppColors.error : AppColors.outline),
            ],
          ],
        ),
      ),
    );
  }
}

/// White grouped card that stacks [SettingsRow]s with hairline dividers.
class GroupCard extends StatelessWidget {
  const GroupCard({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x0F1B5E20)),
        boxShadow: AppShadows.level1,
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0)
                const Divider(height: 1, indent: 70, color: AppColors.border),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// Section label above a group ("APP SETTINGS & TELEMETRY").
class GroupLabel extends StatelessWidget {
  const GroupLabel(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
      child: Row(
        children: [
          Expanded(child: Eyebrow(text)),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Capsule progress track (8–12 px).
class CapsuleBar extends StatelessWidget {
  const CapsuleBar(
      {super.key,
      required this.value,
      this.height = 10,
      this.color = AppColors.primaryLight,
      this.track = AppColors.tintStrong});
  final double value;
  final double height;
  final Color color;
  final Color track;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
          value: value.clamp(0, 1).toDouble(),
          minHeight: height,
          color: color,
          backgroundColor: track),
    );
  }
}

/// Thick ring gauge with a centred child (ward goal 74 %).
class RingGauge extends StatelessWidget {
  const RingGauge(
      {super.key,
      required this.value,
      this.size = 200,
      this.stroke = 18,
      this.color = AppColors.primaryLight,
      this.track = AppColors.tintStrong,
      required this.child});
  final double value;
  final double size;
  final double stroke;
  final Color color;
  final Color track;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value.clamp(0, 1).toDouble()),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (_, v, __) => CustomPaint(
          painter: _RingPainter(v, stroke, color, track),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value, this.stroke, this.color, this.track);
  final double value, stroke;
  final Color color, track;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = rect.deflate(stroke / 2);
    final bg = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    final fg = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(r, -math.pi / 2, math.pi * 2, false, bg);
    canvas.drawArc(r, -math.pi / 2, math.pi * 2 * value, false, fg);
  }

  @override
  bool shouldRepaint(_RingPainter o) =>
      o.value != value || o.color != color || o.stroke != stroke;
}

/// Smooth line chart with soft area fill, dots and a dashed target line.
class TrendLineChart extends StatelessWidget {
  const TrendLineChart({
    super.key,
    required this.labels,
    required this.values,
    this.target,
    this.height = 220,
    this.color = AppColors.primary,
    this.targetColor = AppColors.secondary,
    this.highlightLast = true,
    this.lastLabel,
  });
  final List<String> labels;
  final List<double> values;

  /// Target line as (start, end) values across the x-range.
  final (double, double)? target;
  final double height;
  final Color color;
  final Color targetColor;
  final bool highlightLast;
  final String? lastLabel;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SizedBox(
      height: height,
      child: Column(
        children: [
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (_, p, __) => CustomPaint(
                size: Size.infinite,
                painter: _LinePainter(
                    values, target, color, targetColor, p, lastLabel,
                    t.labelMedium?.copyWith(color: Colors.white)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < labels.length; i++)
                Expanded(
                  child: Text(labels[i],
                      textAlign: i == 0
                          ? TextAlign.start
                          : i == labels.length - 1
                              ? TextAlign.end
                              : TextAlign.center,
                      style: t.labelMedium?.copyWith(
                          color: highlightLast && i == labels.length - 1
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontWeight: highlightLast && i == labels.length - 1
                              ? FontWeight.w700
                              : FontWeight.w500)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter(this.values, this.target, this.color, this.targetColor,
      this.progress, this.lastLabel, this.labelStyle);
  final List<double> values;
  final (double, double)? target;
  final Color color, targetColor;
  final double progress;
  final String? lastLabel;
  final TextStyle? labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    const top = 34.0, bottom = 6.0;
    final all = [...values, if (target != null) target!.$1, target!.$2];
    var lo = all.reduce(math.min), hi = all.reduce(math.max);
    if (hi - lo < 1e-6) hi = lo + 1;
    final pad = (hi - lo) * 0.18;
    lo -= pad;
    hi += pad;
    double x(int i) => i * size.width / (values.length - 1);
    double y(double v) =>
        top + (size.height - top - bottom) * (1 - (v - lo) / (hi - lo));

    // grid
    final grid = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    for (var g = 0; g < 3; g++) {
      final gy = top + (size.height - top - bottom) * g / 2;
      _dash(canvas, Offset(0, gy), Offset(size.width, gy), grid, 4, 5);
    }
    // target
    if (target != null) {
      final tp = Paint()
        ..color = targetColor
        ..strokeWidth = 2;
      _dash(canvas, Offset(0, y(target!.$1)),
          Offset(size.width, y(target!.$2)), tp, 7, 6);
    }
    // path
    final pts = [for (var i = 0; i < values.length; i++) Offset(x(i), y(values[i]))];
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      final p0 = pts[i - 1], p1 = pts[i];
      final cx = (p0.dx + p1.dx) / 2;
      path.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }
    final metrics = path.computeMetrics().first;
    final drawn = metrics.extractPath(0, metrics.length * progress);
    final area = Path.from(drawn)
      ..lineTo(math.min(size.width, pts.last.dx * progress + 0.01),
          size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0)],
          ).createShader(Offset.zero & size));
    canvas.drawPath(
        drawn,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round);
    // dots
    final n = (pts.length * progress).ceil().clamp(0, pts.length);
    for (var i = 0; i < n; i++) {
      canvas.drawCircle(pts[i], 6, Paint()..color = Colors.white);
      canvas.drawCircle(
          pts[i],
          6,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5);
    }
    // last point: vertical guide + label bubble
    if (progress >= 1 && lastLabel != null) {
      final lp = pts.last;
      _dash(canvas, Offset(lp.dx, lp.dy), Offset(lp.dx, size.height),
          Paint()..color = AppColors.outline..strokeWidth = 1, 3, 4);
      final tp = TextPainter(
          text: TextSpan(text: lastLabel, style: labelStyle),
          textDirection: TextDirection.ltr)
        ..layout();
      final w = tp.width + 26, h = tp.height + 12;
      var left = lp.dx - w + 10;
      if (left < 0) left = 0;
      final r = RRect.fromRectAndRadius(
          Rect.fromLTWH(left, lp.dy - h - 14, w, h), const Radius.circular(999));
      canvas.drawRRect(r, Paint()..color = color);
      canvas.drawCircle(
          Offset(left + 11, lp.dy - h / 2 - 14), 3.5, Paint()..color = AppColors.primaryContainer);
      tp.paint(canvas, Offset(left + 19, lp.dy - h - 14 + 6));
    }
  }

  void _dash(Canvas c, Offset a, Offset b, Paint p, double on, double off) {
    final total = (b - a).distance;
    final dir = (b - a) / total;
    var d = 0.0;
    while (d < total) {
      final e = math.min(d + on, total);
      c.drawLine(a + dir * d, a + dir * e, p);
      d += on + off;
    }
  }

  @override
  bool shouldRepaint(_LinePainter o) =>
      o.progress != progress || o.values != values;
}

/// Simple rounded bar chart (24-hour demand curve).
class DemandBars extends StatelessWidget {
  const DemandBars(
      {super.key,
      required this.values,
      required this.labels,
      this.colors,
      this.height = 150,
      this.boldLabels = const {}});
  final List<double> values;
  final List<String> labels;
  final List<Color>? colors;
  final double height;
  final Set<int> boldLabels;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final max = values.reduce(math.max);
    return Column(
      children: [
        SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < values.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: values[i] / max),
                    duration: Duration(milliseconds: 500 + i * 60),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => FractionallySizedBox(
                      heightFactor: v.clamp(0.04, 1),
                      child: Container(
                        decoration: BoxDecoration(
                          color: colors?[i] ?? AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var i = 0; i < labels.length; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(
                child: Text(labels[i],
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                    softWrap: false,
                    style: t.labelSmall?.copyWith(
                        letterSpacing: 0,
                        color: boldLabels.contains(i)
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontWeight: boldLabels.contains(i)
                            ? FontWeight.w800
                            : FontWeight.w500)),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Numbered section used by Terms / Privacy pages.
class LegalSection extends StatelessWidget {
  const LegalSection({
    super.key,
    required this.index,
    required this.title,
    this.tag,
    this.tagColor = AppColors.primaryLight,
    required this.children,
  });
  final int index;
  final String title;
  final String? tag;
  final Color tagColor;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x0F1B5E20)),
        boxShadow: AppShadows.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    color: AppColors.tint, shape: BoxShape.circle),
                child: Text('$index',
                    style: t.labelLarge?.copyWith(color: AppColors.primary)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: t.titleMedium?.copyWith(fontSize: 17)),
                    if (tag != null) ...[
                      const SizedBox(height: 6),
                      SoftChip(tag!, color: tagColor, dense: true),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

/// Bullet with a check / block icon used inside legal sections.
class LegalPoint extends StatelessWidget {
  const LegalPoint(this.text,
      {super.key, this.icon = Icons.check_circle_outline_rounded,
      this.color = AppColors.primaryLight});
  final String text;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Text(text,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textSecondary))),
        ],
      ),
    );
  }
}

/// Tinted callout box (info / warning).
class Callout extends StatelessWidget {
  const Callout(
      {super.key,
      required this.text,
      this.title,
      this.icon = Icons.info_outline_rounded,
      this.color = AppColors.primaryLight});
  final String text;
  final String? title;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(title!,
                        style: t.labelLarge?.copyWith(color: color)),
                  ),
                Text(text,
                    style: t.bodySmall?.copyWith(
                        color: AppColors.textPrimary, height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Soft green canvas used behind splash / hero areas (the one allowed
/// gradient: barely-there mint mist).
class MistBackground extends StatelessWidget {
  const MistBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF1FDEF), Color(0xFFE4F3E2), Color(0xFFF1FDEF)],
        ),
      ),
      child: child,
    );
  }
}
