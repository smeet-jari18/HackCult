import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

/// Thin wrapper around url_launcher with user feedback.
class Links {
  Links._();

  static const gedaHelpline = '1800-233-0122';

  static Future<void> call(BuildContext context, String number) =>
      _open(context, Uri(scheme: 'tel', path: number.replaceAll(' ', '')),
          failMessage: 'Could not open the dialer. Call $number');

  static Future<void> web(BuildContext context, String url) =>
      _open(context, Uri.parse(url),
          mode: LaunchMode.externalApplication,
          failMessage: 'Could not open $url');

  static Future<void> email(BuildContext context,
          {required String to, String subject = '', String body = ''}) =>
      _open(
          context,
          Uri(
              scheme: 'mailto',
              path: to,
              query: _encodeQuery({'subject': subject, 'body': body})),
          failMessage: 'No email app found');

  static String _encodeQuery(Map<String, String> params) => params.entries
      .where((e) => e.value.isNotEmpty)
      .map((e) =>
          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');

  static Future<void> _open(BuildContext context, Uri uri,
      {LaunchMode mode = LaunchMode.platformDefault,
      required String failMessage}) async {
    var ok = false;
    try {
      ok = await launchUrl(uri, mode: mode);
    } catch (_) {
      ok = false;
    }
    if (!ok && context.mounted) {
      showAppSnack(context, failMessage,
          icon: Icons.error_outline_rounded, color: AppColors.error);
    }
  }
}
