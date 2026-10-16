import 'package:flutter/material.dart';

import '../components/controls.dart';
import '../components/page.dart';
import '../components/quiet_text.dart';
import '../companion.dart';
import '../notification_service.dart';
import '../theme.dart';

/// Settings — ported from `src/app/settings.tsx`.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.controller});

  final CompanionController controller;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _reminderPending = false;

  Future<void> _changeReminder(bool next) async {
    if (!next) {
      widget.controller.setGentleReminder(false);
      return;
    }
    setState(() => _reminderPending = true);
    try {
      final allowed = await NotificationService.instance.requestPermission();
      if (allowed) widget.controller.setGentleReminder(true);
    } finally {
      if (mounted) setState(() => _reminderPending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;
    return QuietPage(
      title: 'Settings',
      subtitle: 'there is nothing here that counts you.',
      children: [
        Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.hairline, width: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              QuietToggle(
                label: 'Ambient sound',
                value: state.ambientOn,
                onChange: widget.controller.setAmbient,
              ),
              QuietToggle(
                label: _reminderPending ? 'Gentle reminder · checking' : 'Gentle reminder',
                value: state.gentleReminderOn,
                onChange: (next) {
                  _changeReminder(next);
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: const Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.md),
                  child: Tiny(
                    'off by default · one quiet reminder after four days away',
                    style: TextStyle(fontSize: 11, height: 17 / 11),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: AppSpacing.sm),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.hairline, width: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListRow(
                first: true,
                title: 'How it works',
                note: 'presence, fading, and passing.',
                onPressed: () => Navigator.of(context).pushNamed('/settings/how-it-works'),
              ),
              ListRow(
                title: 'Developer support',
                note: 'a message is always welcome.',
                onPressed: () =>
                    Navigator.of(context).pushNamed('/settings/developer-support'),
              ),
              ListRow(
                title: 'The Quiet Archive',
                note: 'companions remembered.',
                onPressed: () => Navigator.of(context).pushNamed('/archive'),
              ),
              ListRow(
                title: 'Terms and conditions',
                onPressed: () => Navigator.of(context).pushNamed('/settings/terms'),
              ),
              ListRow(
                title: 'Privacy policy',
                onPressed: () => Navigator.of(context).pushNamed('/settings/privacy'),
              ),
              ListRow(
                title: 'About',
                onPressed: () => Navigator.of(context).pushNamed('/settings/about'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
