import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/app_state.dart';
import '../../data/models.dart';
import '../logic/calculators.dart';
import '../theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Buttons
// ---------------------------------------------------------------------------

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.icon,
    this.trailingIcon,
    this.color,
    this.foreground,
    this.height = 52,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final IconData? trailingIcon;
  final Color? color;
  final Color? foreground;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color ?? AppColors.primary,
          foregroundColor: foreground ?? Colors.white,
          disabledBackgroundColor:
              (color ?? AppColors.primary).withValues(alpha: 0.38),
          disabledForegroundColor: Colors.white,
          minimumSize: Size.fromHeight(height),
        ),
        child: loading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.4, color: Colors.white))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8)
                  ],
                  Flexible(
                      child: Text(label,
                          maxLines: 1, overflow: TextOverflow.ellipsis)),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 8),
                    Icon(trailingIcon, size: 20)
                  ],
                ],
              ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton(
      {super.key,
      required this.label,
      this.onPressed,
      this.icon,
      this.height = 52});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
            minimumSize: Size.fromHeight(height),
            side: const BorderSide(color: AppColors.primary)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8)
            ],
            Text(label),
          ],
        ),
      ),
    );
  }
}

class GoogleButton extends StatelessWidget {
  const GoogleButton(
      {super.key,
      required this.onPressed,
      this.label = 'Continue with Google',
      this.loading = false});
  final VoidCallback? onPressed;
  final String label;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border),
        ),
        child: loading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const GoogleLogo(size: 20),
                  const SizedBox(width: 12),
                  Flexible(
                      child: Text(label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(fontSize: 15))),
                ],
              ),
      ),
    );
  }
}

/// Vector "G" logo drawn with canvas (no asset needed).
class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key, this.size = 20});
  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _GooglePainter());
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final stroke = size.width * 0.2;
    final r = rect.deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;
    void arc(Color c, double start, double sweep) {
      paint.color = c;
      canvas.drawArc(r, start, sweep, false, paint);
    }

    const d = math.pi / 180;
    arc(const Color(0xFFEA4335), 200 * d, 110 * d); // red (top-left)
    arc(const Color(0xFFFBBC05), 130 * d, 70 * d); // yellow (left-bottom)
    arc(const Color(0xFF34A853), 45 * d, 85 * d); // green (bottom)
    arc(const Color(0xFF4285F4), -5 * d, 50 * d); // blue (right)
    // blue bar
    final barPaint = Paint()..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(size.width / 2, size.height / 2 - stroke / 2,
          size.width / 2 - stroke * 0.1, stroke),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Inputs
// ---------------------------------------------------------------------------

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.obscure = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffix,
    this.validator,
    this.onChanged,
    this.helper,
    this.errorText,
    this.maxLength,
    this.enabled = true,
    this.textInputAction,
    this.autofillHints,
    this.labelTrailing,
    this.required = false,
    this.tinted = false,
    this.readOnly = false,
    this.onTap,
    this.initialValue,
  });

  final String label;
  final bool required;
  final bool tinted;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? initialValue;
  final TextEditingController? controller;
  final String? hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final String? helper;
  final String? errorText;
  final int? maxLength;
  final bool enabled;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final Widget? labelTrailing;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: FieldLabel(label, required: required),
              ),
              if (labelTrailing != null) labelTrailing!,
            ],
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          readOnly: readOnly,
          onTap: onTap,
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          maxLength: maxLength,
          enabled: enabled,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          style: t.bodyLarge?.copyWith(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            helperText: helper,
            errorText: errorText,
            counterText: '',
            fillColor: tinted ? AppColors.tint : AppColors.surface,
            enabledBorder: tinted
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    borderSide: const BorderSide(color: AppColors.tintStrong))
                : null,
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, size: 20, color: AppColors.textSecondary),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}

class SelectableTile extends StatelessWidget {
  const SelectableTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.subtitle,
    this.compact = false,
  });
  final String label;
  final String? subtitle;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: selected ? AppColors.primarySoft : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(compact ? 12 : 16),
            child: Row(
              children: [
                if (icon != null) ...[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color:
                          selected ? AppColors.primary : AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon,
                        color:
                            selected ? Colors.white : AppColors.textSecondary,
                        size: 22),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (compact)
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(label, style: t.titleSmall, maxLines: 1),
                        )
                      else
                        Text(label,
                            style: t.titleSmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      if (subtitle != null)
                        Text(subtitle!,
                            style: t.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                if (selected)
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.primary, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StepperField extends StatelessWidget {
  const StepperField(
      {super.key,
      required this.value,
      required this.onChanged,
      this.min = 0,
      this.max = 10,
      this.label});
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          if (label != null)
            Expanded(
                child: Text(label!,
                    style: Theme.of(context).textTheme.titleSmall)),
          _RoundIconButton(
              icon: Icons.remove_rounded,
              onTap: value > min ? () => onChanged(value - 1) : null),
          SizedBox(
            width: 44,
            child: Text('$value',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge),
          ),
          _RoundIconButton(
              icon: Icons.add_rounded,
              onTap: value < max ? () => onChanged(value + 1) : null),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: enabled ? AppColors.primarySoft : AppColors.background,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon,
              color: enabled ? AppColors.primary : AppColors.textTertiary),
        ),
      ),
    );
  }
}

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher(
      {super.key,
      required this.value,
      required this.onChanged,
      this.light = false});
  final String value;
  final ValueChanged<String> onChanged;
  final bool light;

  @override
  Widget build(BuildContext context) {
    const items = [('en', 'EN'), ('gu', 'ગુ'), ('hi', 'हि')];
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color:
            light ? Colors.white.withValues(alpha: 0.18) : AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color:
                light ? Colors.white.withValues(alpha: 0.3) : AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (code, label) in items)
            GestureDetector(
              onTap: () => onChanged(code),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: value == code
                      ? (light ? Colors.white : AppColors.primary)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: value == code
                            ? (light ? AppColors.primary : Colors.white)
                            : (light ? Colors.white : AppColors.textSecondary),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Containers & cards
// ---------------------------------------------------------------------------

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color,
    this.gradient,
    this.onTap,
    this.border = true,
    this.radius = AppRadius.card,
    this.margin,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final bool border;
  final double radius;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    // Decoration lives on an outer box; an inner transparent Material hosts
    // ink splashes for ListTiles/InkWells placed inside the card.
    // DESIGN-3: hard borders avoided — faint tinted hairline + soft
    // double shadow give the card its edge.
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    );
    final white = (color ?? AppColors.surface) == AppColors.surface;
    final content = Container(
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? AppColors.surface) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: border && gradient == null
            ? Border.all(color: const Color(0x0F1B5E20))
            : null,
        boxShadow: gradient == null && white ? AppShadows.level1 : null,
      ),
      child: Material(
        color: Colors.transparent,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: onTap == null
            ? Padding(padding: padding, child: child)
            : InkWell(
                onTap: onTap,
                child: Padding(padding: padding, child: child),
              ),
      ),
    );
    return margin == null ? content : Padding(padding: margin!, child: content);
  }
}

class BrandPill extends StatelessWidget {
  const BrandPill({super.key, this.dark = false, this.compact = false});
  final bool dark;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final fg = dark ? AppColors.textPrimary : AppColors.textPrimary;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 16, vertical: compact ? 8 : 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.button),
        border: Border.all(color: AppColors.border),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_balance_rounded,
                size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text('GEDA', style: t.labelLarge?.copyWith(color: fg)),
            Container(
                width: 1,
                height: 18,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                color: AppColors.border),
            const Icon(Icons.eco_rounded, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Flexible(
                child: Text('Mission LiFE Gujarat',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.labelLarge?.copyWith(color: fg))),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(
      {super.key,
      required this.title,
      this.subtitle,
      this.actionLabel,
      this.onAction,
      this.padding});
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: t.titleMedium),
                if (subtitle != null) Text(subtitle!, style: t.bodySmall),
              ],
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 36)),
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.iconColor = AppColors.primary,
    this.delta,
    this.deltaPositive = true,
    this.strike,
    this.dense = false,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
  final String? delta;
  final bool deltaPositive;
  final String? strike;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return AppCard(
      padding: EdgeInsets.all(dense ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle),
                child: Icon(icon, size: 19, color: iconColor),
              ),
              const Spacer(),
              if (delta != null)
                DeltaChip(label: delta!, positive: deltaPositive),
            ],
          ),
          SizedBox(height: dense ? 10 : 14),
          if (strike != null)
            Text(strike!,
                style: t.bodySmall?.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: AppColors.textTertiary)),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                style: dense
                    ? t.titleLarge
                    : t.headlineSmall?.copyWith(fontSize: 22)),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: t.labelMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class DeltaChip extends StatelessWidget {
  const DeltaChip({super.key, required this.label, this.positive = true});
  final String label;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final color = positive ? AppColors.success : AppColors.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
              positive
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              size: 12,
              color: color),
          const SizedBox(width: 2),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class StatusTag extends StatelessWidget {
  const StatusTag(
      {super.key,
      required this.label,
      this.color = AppColors.success,
      this.icon,
      this.dot = false});
  final String label;
  final Color color;
  final IconData? icon;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
                width: 7,
                height: 7,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
          ],
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4)
          ],
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class Pill extends StatelessWidget {
  const Pill(
      {super.key,
      required this.label,
      this.icon,
      this.color,
      this.textColor,
      this.onTap});
  final String label;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = color ?? Colors.white.withValues(alpha: 0.2);
    final fg = textColor ?? Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: fg),
              const SizedBox(width: 4)
            ],
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: fg, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class IconTile extends StatelessWidget {
  const IconTile(
      {super.key,
      required this.icon,
      required this.color,
      this.size = 48,
      this.iconSize = 24,
      this.radius = 16});
  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(radius)),
      child: Icon(icon, color: color, size: iconSize),
    );
  }
}

class Avatar extends StatelessWidget {
  const Avatar(
      {super.key,
      required this.initials,
      this.size = 40,
      this.color = AppColors.primary,
      this.photoUrl});
  final String initials;
  final double size;
  final Color color;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14), shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(color: color, fontSize: size * 0.38),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Progress
// ---------------------------------------------------------------------------

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    this.size = 72,
    this.stroke = 8,
    this.color = AppColors.primary,
    this.track = AppColors.border,
    this.child,
  });
  final double value;
  final double size;
  final double stroke;
  final Color color;
  final Color track;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value.clamp(0, 1)),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, v, _) => CustomPaint(
          painter: _RingPainter(v, stroke, color, track),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value, this.stroke, this.color, this.track);
  final double value;
  final double stroke;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, p..color = track);
    canvas.drawArc(
        rect, -math.pi / 2, math.pi * 2 * value, false, p..color = color);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.value != value || old.color != color;
}

class GoalProgressBar extends StatelessWidget {
  const GoalProgressBar(
      {super.key,
      required this.value,
      this.label,
      this.trailing,
      this.color = AppColors.primary,
      this.height = 10});
  final double value;
  final String? label;
  final String? trailing;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null || trailing != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                if (label != null)
                  Expanded(child: Text(label!, style: t.bodySmall)),
                if (trailing != null)
                  Text(trailing!,
                      style: t.labelMedium?.copyWith(
                          color: color, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(height),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value.clamp(0, 1)),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (_, v, __) => LinearProgressIndicator(
                value: v,
                minHeight: height,
                color: color,
                backgroundColor: color.withValues(alpha: 0.15)),
          ),
        ),
      ],
    );
  }
}

class SolarHoursGauge extends StatelessWidget {
  const SolarHoursGauge({super.key, this.hour});
  final int? hour;

  @override
  Widget build(BuildContext context) {
    final h = hour ?? DateTime.now().hour;
    final (label, color, pos) = switch (h) {
      >= 11 && < 15 => (
          'Grid is greenest now — run heavy loads',
          AppColors.success,
          0.17
        ),
      >= 18 && < 23 => (
          'Peak hours — avoid heavy appliances',
          AppColors.error,
          0.84
        ),
      >= 15 && < 18 => (
          'Peak starts at 6 pm — finish heavy loads',
          AppColors.warning,
          0.5
        ),
      _ => (
          'Off-peak — good time for pumps & EV charging',
          AppColors.success,
          0.17
        ),
    };
    final t = Theme.of(context).textTheme;
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.solar_power_rounded,
                  size: 18, color: AppColors.secondary),
              const SizedBox(width: 8),
              Text('Solar Hours', style: t.titleSmall),
              const Spacer(),
              StatusTag(
                  label: color == AppColors.success
                      ? 'Green'
                      : color == AppColors.warning
                          ? 'Amber'
                          : 'Peak',
                  color: color,
                  dot: true),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, c) => SizedBox(
              height: 22,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    top: 7,
                    bottom: 7,
                    child: Row(
                      children: [
                        Expanded(
                            flex: 34,
                            child: Container(
                                decoration: const BoxDecoration(
                                    color: AppColors.success,
                                    borderRadius: BorderRadius.horizontal(
                                        left: Radius.circular(8))))),
                        const SizedBox(width: 2),
                        Expanded(
                            flex: 32,
                            child: Container(color: AppColors.secondary)),
                        const SizedBox(width: 2),
                        Expanded(
                            flex: 34,
                            child: Container(
                                decoration: const BoxDecoration(
                                    color: AppColors.error,
                                    borderRadius: BorderRadius.horizontal(
                                        right: Radius.circular(8))))),
                      ],
                    ),
                  ),
                  Positioned(
                    left: c.maxWidth * pos - 11,
                    top: 0,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: color, width: 3),
                          boxShadow: AppShadows.level2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text('Solar 11–3', style: t.labelSmall),
              const Spacer(),
              Text('Peak 6–11 pm', style: t.labelSmall),
            ],
          ),
          const SizedBox(height: 8),
          Text(label,
              style: t.bodySmall?.copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Domain widgets
// ---------------------------------------------------------------------------

class TaskCard extends StatelessWidget {
  const TaskCard(
      {super.key,
      required this.task,
      required this.status,
      this.onDone,
      this.onTap,
      this.onSkip,
      this.onNotApplicable});
  final TaskItem task;
  final TaskStatus status;
  final VoidCallback? onDone;
  final VoidCallback? onTap;
  final VoidCallback? onSkip;
  final VoidCallback? onNotApplicable;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final done = status == TaskStatus.done;
    final skipped = status == TaskStatus.skipped;
    return Opacity(
      opacity: skipped ? 0.55 : 1,
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            IconTile(icon: task.theme.icon, color: task.theme.color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title,
                      style: t.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: AppColors.secondarySoft,
                            borderRadius: BorderRadius.circular(10)),
                        child: Text('+${task.points}',
                            style: t.labelSmall?.copyWith(
                                color: const Color(0xFF694300),
                                fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 8),
                      Icon(task.verification.icon,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Flexible(
                          child: Text(task.verification.label,
                              style: t.labelSmall,
                              overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (done)
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, color: Colors.white),
              )
            else if (skipped)
              Text('Skipped', style: t.labelSmall)
            else
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 36,
                    child: FilledButton(
                      onPressed: onDone,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(72, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        textStyle: t.labelMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      child: const Text('Done'),
                    ),
                  ),
                  if (onSkip != null || onNotApplicable != null)
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      iconSize: 18,
                      icon: const Icon(Icons.more_horiz_rounded,
                          color: AppColors.textTertiary),
                      onSelected: (v) => v == 'skip'
                          ? onSkip?.call()
                          : onNotApplicable?.call(),
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                            value: 'skip', child: Text('Skip for today')),
                        PopupMenuItem(
                            value: 'na', child: Text('Not applicable to me')),
                      ],
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class NudgeCard extends StatelessWidget {
  const NudgeCard(
      {super.key,
      required this.nudge,
      this.onDoIt,
      this.onLater,
      this.onNotForMe});
  final Nudge nudge;
  final VoidCallback? onDoIt;
  final VoidCallback? onLater;
  final VoidCallback? onNotForMe;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: nudge.softColor,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border(left: BorderSide(color: nudge.color, width: 4)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: nudge.color.withValues(alpha: 0.15),
                    shape: BoxShape.circle),
                child: Icon(nudge.icon, color: nudge.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nudge.title, style: t.titleSmall),
                    const SizedBox(height: 2),
                    Text(nudge.message,
                        style: t.bodySmall
                            ?.copyWith(color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.eco_rounded, size: 14, color: nudge.color),
                        const SizedBox(width: 4),
                        Text(nudge.impact,
                            style: t.labelSmall?.copyWith(
                                color: nudge.color,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            children: [
              TextButton(
                  onPressed: onDoIt,
                  style: TextButton.styleFrom(foregroundColor: nudge.color),
                  child: const Text('Do it')),
              TextButton(
                  onPressed: onLater,
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary),
                  child: const Text('Later')),
              TextButton(
                  onPressed: onNotForMe,
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary),
                  child: const Text('Not for me')),
            ],
          ),
        ],
      ),
    );
  }
}

class LeaderboardTile extends StatelessWidget {
  const LeaderboardTile({super.key, required this.entry, this.dense = false});
  final LeaderboardEntry entry;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final medal = switch (entry.rank) {
      1 => const Color(0xFFF9A825),
      2 => const Color(0xFF9E9E9E),
      3 => const Color(0xFFBF8970),
      _ => null
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: dense ? 8 : 12),
      decoration: BoxDecoration(
        color: entry.isMe ? AppColors.primarySoft : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border:
            entry.isMe ? Border.all(color: AppColors.primaryContainer) : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: medal != null
                ? Icon(Icons.workspace_premium_rounded, color: medal, size: 24)
                : Text('#${entry.rank}',
                    style:
                        t.labelLarge?.copyWith(color: AppColors.textSecondary)),
          ),
          const SizedBox(width: 8),
          Avatar(
              initials: entry.name.split(' ').map((e) => e[0]).take(2).join(),
              size: 36,
              color: entry.isMe ? AppColors.primary : AppColors.tertiary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.isMe ? '${entry.name} (You)' : entry.name,
                    style: t.titleSmall, overflow: TextOverflow.ellipsis),
                Text(entry.district, style: t.labelSmall),
              ],
            ),
          ),
          Text('${entry.points}',
              style: t.titleSmall?.copyWith(color: AppColors.primary)),
          const SizedBox(width: 4),
          Text('pts', style: t.labelSmall),
        ],
      ),
    );
  }
}

class BadgeTile extends StatelessWidget {
  const BadgeTile(
      {super.key, required this.badge, required this.earned, this.onTap});
  final BadgeItem badge;
  final bool earned;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final color = earned ? badge.color : AppColors.textTertiary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: earned
                      ? color.withValues(alpha: 0.14)
                      : AppColors.background,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: earned
                          ? color.withValues(alpha: 0.4)
                          : AppColors.border,
                      width: 2),
                ),
                child: Icon(badge.icon, color: color, size: 30),
              ),
              if (!earned)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.lock_rounded,
                        size: 12, color: AppColors.textSecondary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(badge.name,
              style: t.labelMedium?.copyWith(
                  color:
                      earned ? AppColors.textPrimary : AppColors.textSecondary),
              textAlign: TextAlign.center,
              maxLines: 2),
        ],
      ),
    );
  }
}

class LevelChip extends StatelessWidget {
  const LevelChip({super.key, required this.points, this.light = false});
  final int points;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final l = LevelEngine.levelFor(points);
    return Pill(
      label: '${l.$4} ${l.$2}',
      color:
          light ? Colors.white.withValues(alpha: 0.2) : AppColors.primarySoft,
      textColor: light ? Colors.white : AppColors.primary,
    );
  }
}

// ---------------------------------------------------------------------------
// States
// ---------------------------------------------------------------------------

class EmptyState extends StatelessWidget {
  const EmptyState(
      {super.key,
      required this.icon,
      required this.title,
      required this.body,
      this.actionLabel,
      this.onAction,
      this.compact = false});
  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? 16 : 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: compact ? 64 : 88,
              height: compact ? 64 : 88,
              decoration: const BoxDecoration(
                  color: AppColors.primarySoft, shape: BoxShape.circle),
              child:
                  Icon(icon, size: compact ? 30 : 40, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(title, style: t.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(body,
                style: t.bodyMedium?.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center),
            if (actionLabel != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                  width: 220,
                  child: PrimaryButton(
                      label: actionLabel!, onPressed: onAction, height: 46)),
            ],
          ],
        ),
      ),
    );
  }
}

class SkeletonBox extends StatefulWidget {
  const SkeletonBox(
      {super.key,
      this.height = 16,
      this.width = double.infinity,
      this.radius = 8});
  final double height;
  final double width;
  final double radius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1100))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: Color.lerp(
              const Color(0xFFE9EDE9), const Color(0xFFF4F7F4), _c.value),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.warningSoft,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded,
              size: 16, color: AppColors.warning),
          const SizedBox(width: 8),
          Text("You're offline — actions will sync later",
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: AppColors.warning)),
        ],
      ),
    );
  }
}

class InfoBanner extends StatelessWidget {
  const InfoBanner(
      {super.key,
      required this.text,
      this.icon = Icons.info_outline_rounded,
      this.color = AppColors.tertiary,
      this.bold});
  final String text;
  final String? bold;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color == AppColors.tertiary
            ? AppColors.noticeSoft
            : color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              size: 18,
              color: color == AppColors.tertiary ? AppColors.secondary : color),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: t.bodySmall
                    ?.copyWith(color: AppColors.textPrimary, height: 1.5),
                children: _spans(text, bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

List<InlineSpan> _spans(String text, String? bold) {
  if (bold == null || bold.isEmpty || !text.contains(bold)) {
    return [
      if (bold != null && bold.isNotEmpty)
        TextSpan(
            text: '$bold ',
            style: const TextStyle(fontWeight: FontWeight.w700)),
      TextSpan(text: text),
    ];
  }
  final i = text.indexOf(bold);
  return [
    TextSpan(text: text.substring(0, i)),
    TextSpan(
        text: bold, style: const TextStyle(fontWeight: FontWeight.w700)),
    TextSpan(text: text.substring(i + bold.length)),
  ];
}

/// Plain page app bar for tab screens: one title, optional subtitle, actions.
/// (The brand bar with logo is used on Home only — avoids a double header.)
class PageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PageAppBar(
      {super.key,
      required this.title,
      this.subtitle,
      this.actions = const [],
      this.leading});
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget? leading;

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return AppBar(
      toolbarHeight: 60,
      titleSpacing: leading == null ? 16 : 0,
      leading: leading,
      automaticallyImplyLeading: leading != null,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: t.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
          if (subtitle != null)
            Text(subtitle!,
                style: t.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
        ],
      ),
      actions: [...actions, const SizedBox(width: 8)],
    );
  }
}

/// Animated count-up text for hero numbers.
class CountUpText extends StatelessWidget {
  const CountUpText(
      {super.key,
      required this.value,
      required this.style,
      this.decimals = 0,
      this.prefix = '',
      this.suffix = '',
      this.duration = const Duration(milliseconds: 1100)});
  final double value;
  final TextStyle? style;
  final int decimals;
  final String prefix;
  final String suffix;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (_, v, __) =>
          Text('$prefix${v.toStringAsFixed(decimals)}$suffix', style: style),
    );
  }
}

/// Lightweight confetti burst painted with canvas (no package).
class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst(
      {super.key, this.duration = const Duration(milliseconds: 1500)});
  final Duration duration;

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: widget.duration)
    ..forward();
  final _rnd = math.Random();
  late final _parts = List.generate(70, (_) => _Particle(_rnd));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => CustomPaint(
            painter: _ConfettiPainter(_parts, _c.value), size: Size.infinite),
      ),
    );
  }
}

class _Particle {
  _Particle(math.Random r)
      : x = r.nextDouble(),
        vx = (r.nextDouble() - 0.5) * 0.6,
        vy = 0.6 + r.nextDouble() * 1.2,
        size = 5 + r.nextDouble() * 6,
        rot = r.nextDouble() * math.pi,
        color = [
          AppColors.primary,
          AppColors.secondary,
          AppColors.tertiary,
          AppColors.primaryLight,
          const Color(0xFFE91E63)
        ][r.nextInt(5)];
  final double x, vx, vy, size, rot;
  final Color color;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.parts, this.t);
  final List<_Particle> parts;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in parts) {
      final x = (p.x + p.vx * t) * size.width;
      final y = (-0.05 + p.vy * t * t) * size.height;
      paint.color = p.color.withValues(alpha: (1 - t).clamp(0, 1));
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rot + t * 6);
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromCenter(
                  center: Offset.zero, width: p.size, height: p.size * 0.6),
              const Radius.circular(1.5)),
          paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.t != t;
}

/// Shows a confetti overlay on top of the current route for [duration].
void showConfetti(BuildContext context,
    {Duration duration = const Duration(milliseconds: 1600)}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(builder: (_) => ConfettiBurst(duration: duration));
  overlay.insert(entry);
  Future.delayed(duration, entry.remove);
}

void showAppSnack(BuildContext context, String message,
    {IconData? icon,
    Color? color,
    String? actionLabel,
    VoidCallback? onAction}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      backgroundColor: color ?? AppColors.textPrimary,
      content: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 10)
          ],
          Expanded(child: Text(message)),
        ],
      ),
      action: actionLabel == null
          ? null
          : SnackBarAction(
              label: actionLabel,
              textColor: AppColors.secondaryLight,
              onPressed: onAction ?? () {}),
    ));
}

/// Constrains content to a phone-like width when running on wide screens (web).
class PhoneFrame extends StatelessWidget {
  const PhoneFrame({super.key, required this.child, this.maxWidth = 600});
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w <= maxWidth + 40) return child;
    // Wide screens: centre the phone-width column on a soft canvas.
    return ColoredBox(
      color: const Color(0xFFEEF4EE),
      child: Center(
        child: Container(
          width: maxWidth,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border.symmetric(
                vertical:
                    BorderSide(color: AppColors.border.withValues(alpha: 0.8))),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Back navigation that never leaves a black screen: pops if there is a page
/// underneath, otherwise jumps to [fallback] (e.g. after a deep link / `go`).
extension SafeNav on BuildContext {
  void safePop([String fallback = '/home']) {
    if (canPop()) {
      pop();
    } else {
      go(fallback);
    }
  }
}

/// Always-visible back button (also on web after a deep link / refresh).
class SafeBackButton extends StatelessWidget {
  const SafeBackButton({super.key, this.fallback = '/home', this.color});
  final String fallback;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      icon: Icon(Icons.arrow_back_rounded, color: color),
      onPressed: () => context.safePop(fallback),
    );
  }
}


// ---------------------------------------------------------------------------
// Design-system v2 (Institutional Flat Utility) helpers
// ---------------------------------------------------------------------------

/// Form label placed above an input. Required fields get a red asterisk.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key, this.required = false, this.trailing});
  final String text;
  final bool required;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      children: [
        Flexible(
          child: RichText(
            text: TextSpan(
              text: text,
              style: t.labelLarge?.copyWith(color: AppColors.textPrimary),
              children: [
                if (required)
                  const TextSpan(
                      text: ' *', style: TextStyle(color: AppColors.error)),
              ],
            ),
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );
  }
}

/// Small helper text under a field (12px, secondary).
class HelperText extends StatelessWidget {
  const HelperText(this.text, {super.key, this.icon, this.color});
  final String text;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = color ?? AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(icon, size: 14, color: c),
            ),
            const SizedBox(width: 4),
          ],
          Expanded(child: Text(text, style: t.bodySmall?.copyWith(color: c))),
        ],
      ),
    );
  }
}

/// Two-or-more option segmented control (full width), e.g. Citizen | Admin.
class SegmentedChoice<T> extends StatelessWidget {
  const SegmentedChoice({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.height = 44,
  });
  final List<(T, String)> options;
  final T value;
  final ValueChanged<T> onChanged;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      height: height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.tint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          for (final o in options)
            Expanded(
              child: Semantics(
                button: true,
                selected: o.$1 == value,
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => onChanged(o.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: o.$1 == value
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      o.$2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.labelLarge?.copyWith(
                          color: o.$1 == value
                              ? Colors.white
                              : AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Flat tinted stat block used inside cards ("Units used 212 kWh").
class StatBlock extends StatelessWidget {
  const StatBlock({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.caption,
    this.captionIcon,
    this.captionColor,
    this.color = AppColors.tint,
    this.valueColor = AppColors.primary,
  });
  final String label;
  final String value;
  final String? unit;
  final String? caption;
  final IconData? captionIcon;
  final Color? captionColor;
  final Color color;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: t.bodySmall, maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              text: value,
              style: t.headlineSmall?.copyWith(
                  color: valueColor, fontWeight: FontWeight.w700),
              children: [
                if (unit != null)
                  TextSpan(
                      text: ' $unit',
                      style: t.labelMedium?.copyWith(color: valueColor)),
              ],
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                if (captionIcon != null) ...[
                  Icon(captionIcon,
                      size: 14, color: captionColor ?? AppColors.success),
                  const SizedBox(width: 3),
                ],
                Flexible(
                  child: Text(caption!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.labelMedium?.copyWith(
                          color: captionColor ?? AppColors.success)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Card title row: icon tile + title + optional trailing tag.
class CardTitle extends StatelessWidget {
  const CardTitle({
    super.key,
    required this.title,
    this.icon,
    this.subtitle,
    this.trailing,
    this.iconColor = AppColors.primary,
  });
  final String title;
  final IconData? icon;
  final String? subtitle;
  final Widget? trailing;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: AppColors.tint, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: t.titleMedium,
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              if (subtitle != null)
                Text(subtitle!, style: t.bodySmall,
                    maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          // Cap the trailing tag so long labels / wide fonts can never push
          // the row past its bounds (the tag itself ellipsises its text).
          ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 150),
              child: trailing!),
        ],
      ],
    );
  }
}

/// Square-corner status tag (6px radius) e.g. "GEDA Verified".
class Tag extends StatelessWidget {
  const Tag(this.text,
      {super.key,
      this.icon,
      this.color = AppColors.tint,
      this.textColor = AppColors.primary});
  final String text;
  final IconData? icon;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.labelMedium
                    ?.copyWith(color: textColor, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

/// Labelled linear progress ("Goal: save 10%  68% done").
class LabelledProgress extends StatelessWidget {
  const LabelledProgress({
    super.key,
    required this.value,
    this.leading,
    this.trailing,
    this.caption,
    this.height = 8,
    this.color = AppColors.primary,
  });
  final double value;
  final String? leading;
  final String? trailing;
  final String? caption;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leading != null || trailing != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                if (leading != null)
                  Expanded(
                      child: Text(leading!,
                          style: t.labelLarge, overflow: TextOverflow.ellipsis)),
                if (trailing != null)
                  Text(trailing!,
                      style: t.labelLarge?.copyWith(color: color)),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
              value: value.clamp(0, 1).toDouble(),
              minHeight: height,
              color: color,
              backgroundColor: AppColors.tintStrong),
        ),
        if (caption != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(caption!, style: t.bodySmall),
          ),
      ],
    );
  }
}

/// Top app bar used on all citizen tabs: emblem + app name + bell + avatar.
class BrandAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BrandAppBar({super.key, this.subtitle = 'Home', this.showAvatar = true});
  final String subtitle;
  final bool showAvatar;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final s = AppScope.of(context);
    final u = s.user;
    return AppBar(
      titleSpacing: 12,
      title: Row(
        children: [
          Image.asset('assets/images/emblem.png', width: 30, height: 30),
          const SizedBox(width: 10),
          Expanded(
            child: subtitle.isEmpty
                ? Text('LiFE Mitra Gujarat',
                    style: t.titleLarge?.copyWith(color: AppColors.primary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('LiFE Mitra Gujarat',
                          style:
                              t.titleMedium?.copyWith(color: AppColors.primary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text(subtitle,
                          style: t.labelSmall
                              ?.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Notifications',
          onPressed: () => context.push('/profile/notifications'),
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        if (showAvatar && u != null)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => context.go('/profile'),
              child: Avatar(initials: u.initials, size: 34),
            ),
          ),
      ],
    );
  }
}

/// Footer line used on auth screens.
class GedaFooter extends StatelessWidget {
  const GedaFooter({super.key, this.extra});
  final String? extra;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_balance_outlined,
                size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Flexible(
              child: Text('A GEDA · Government of Gujarat initiative',
                  style: t.bodySmall, textAlign: TextAlign.center),
            ),
          ],
        ),
        if (extra != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(extra!, style: t.bodySmall, textAlign: TextAlign.center),
          ),
      ],
    );
  }
}
