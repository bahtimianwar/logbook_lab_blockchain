import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> bukaUrl(BuildContext context, String url) async {
  final messenger = ScaffoldMessenger.of(context);
  var ok = false;
  try {
    ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } catch (_) {}
  if (!ok) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Tidak bisa membuka tautan.')),
    );
  }
}
