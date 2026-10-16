import 'package:flutter/material.dart';

import '../archive.dart';
import '../components/controls.dart';
import '../components/page.dart';
import '../components/quiet_text.dart';
import '../format.dart';
import '../theme.dart';

String _stayText(int? ms) {
  if (ms == null || ms == 0) return 'no long stay recorded';
  final minutes = (ms / 60000).round();
  if (minutes < 1) return 'under a minute';
  return 'about $minutes minute${minutes == 1 ? '' : 's'}';
}

/// The Quiet Archive — ported from `src/app/archive.tsx`.
///
/// Post-death list of passed companions; no counts, no achievements,
/// respectful only.
class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  List<CertificateEntry> _list = const [];

  @override
  void initState() {
    super.initState();
    loadArchive().then((list) {
      if (mounted) setState(() => _list = list);
    });
  }

  @override
  Widget build(BuildContext context) {
    return QuietPage(
      title: 'The Quiet Archive',
      subtitle: 'A still record of companions past.',
      children: [
        const Prose(children: [
          P('Each is kept quietly. There is no count, no order of importance — only presence, remembered.'),
        ]),
        Container(
          margin: const EdgeInsets.only(top: AppSpacing.sm),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.hairline, width: 0.5)),
          ),
          child: _list.isEmpty
              ? const Padding(
                  padding: EdgeInsets.only(top: AppSpacing.lg),
                  child: P(
                    'Nothing has been kept here yet. When a companion passes, you may choose to keep it.',
                    style: TextStyle(color: AppColors.inkDim),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final entry in _list) _ArchiveCard(entry: entry),
                  ],
                ),
        ),
      ],
    );
  }
}

class _ArchiveCard extends StatelessWidget {
  const _ArchiveCard({required this.entry});

  final CertificateEntry entry;

  @override
  Widget build(BuildContext context) {
    return QuietPressable(
      onPressed: () => Navigator.of(context).pushNamed(
        '/certificate',
        arguments: entry.id,
      ),
      label: 'Open certificate for companion lived ${entry.lifespanDays} days',
      style: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.sm,
      ),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.hairline, width: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            P(
              'Lived for ${entry.lifespanDays} days',
              style: const TextStyle(
                fontSize: 22,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SerifItalic(
              entry.cause,
              tone: Tone.dim,
              style: const TextStyle(fontSize: 15, height: 25 / 15),
            ),
            const SizedBox(height: AppSpacing.sm),
            Tiny('planted · ${formatStamp(entry.plantedAt ?? entry.passedAt)}'),
            Tiny('passed quietly · ${formatStamp(entry.passedAt)}'),
            Tiny(
              '${entry.realVisits ?? 0} real visit${entry.realVisits == 1 ? '' : 's'} · longest stay ${_stayText(entry.longestVisitMs)}',
            ),
            const SizedBox(height: AppSpacing.xs),
            const Tiny(
              'open certificate',
              style: TextStyle(letterSpacing: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
