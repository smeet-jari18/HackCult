import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/proof_picker.dart';
import '../theme/app_theme.dart';
import 'widgets.dart';

/// Bottom sheet that captures a real photo (camera or gallery) and returns the
/// bytes. Returns `null` when the user cancels.
///
/// Used by both the eco-task photo proof flow and the monthly bill proof flow.
Future<PickedProof?> showProofPickerSheet(
  BuildContext context, {
  String title = 'Add a photo as proof',
  String subtitle =
      'GEDA moderators spot-check uploads. Verified photos earn the full reward.',
  String confirmLabel = 'Use this photo',
}) {
  return showModalBottomSheet<PickedProof>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _ProofPickerSheet(
      title: title,
      subtitle: subtitle,
      confirmLabel: confirmLabel,
    ),
  );
}

class _ProofPickerSheet extends StatefulWidget {
  const _ProofPickerSheet({
    required this.title,
    required this.subtitle,
    required this.confirmLabel,
  });

  final String title;
  final String subtitle;
  final String confirmLabel;

  @override
  State<_ProofPickerSheet> createState() => _ProofPickerSheetState();
}

class _ProofPickerSheetState extends State<_ProofPickerSheet> {
  final _picker = ProofPicker();
  PickedProof? _proof;
  bool _busy = false;
  String? _error;

  Future<void> _pick(ImageSource source) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final picked = await _picker.pick(source);
      if (!mounted) return;
      setState(() {
        if (picked != null) _proof = picked;
        _busy = false;
      });
    } on ProofPickerException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final proof = _proof;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            20, 16, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(widget.title, style: t.headlineSmall),
            const SizedBox(height: 6),
            Text(widget.subtitle, style: t.bodySmall),
            const SizedBox(height: 18),
            if (_error != null) ...[
              InfoBanner(
                text: _error!,
                icon: Icons.error_outline_rounded,
                color: AppColors.error,
              ),
              const SizedBox(height: 14),
            ],
            if (proof != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Image.memory(
                      proof.bytes,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: StatusTag(
                        label: '${(proof.sizeBytes / 1024).round()} KB · ready',
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      proof.fileName,
                      style: t.labelSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton.icon(
                    onPressed:
                        _busy ? null : () => setState(() => _proof = null),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Retake'),
                  ),
                ],
              ),
            ] else
              Row(
                children: [
                  Expanded(
                    child: _PickTile(
                      icon: Icons.photo_camera_rounded,
                      label: 'Camera',
                      onTap: _busy ? null : () => _pick(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PickTile(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      onTap: _busy ? null : () => _pick(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 18),
            PrimaryButton(
              label:
                  proof == null ? 'Choose a photo first' : widget.confirmLabel,
              loading: _busy,
              onPressed: proof == null || _busy
                  ? null
                  : () => Navigator.pop(context, proof),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickTile extends StatelessWidget {
  const _PickTile({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 30),
            const SizedBox(height: 8),
            Text(label,
                style: t.labelLarge?.copyWith(color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}
