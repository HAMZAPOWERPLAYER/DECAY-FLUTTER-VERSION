import 'package:flutter/material.dart';

import '../theme.dart';
import 'controls.dart';
import 'quiet_text.dart';
import 'screen.dart';

/// Long-form page scaffold — ported from `src/components/page.tsx`.

class BackLink extends StatelessWidget {
  const BackLink({super.key, this.label = 'back', this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return QuietPressable(
      onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
      label: 'Go back',
      style: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.xs),
      child: Opacity(
        opacity: 0.7,
        child: Tiny(label),
      ),
    );
  }
}

class QuietPage extends StatelessWidget {
  const QuietPage({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    this.scroll = true,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final bool scroll;

  @override
  Widget build(BuildContext context) {
    final padding = useScreenPadding(context);
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Heading(title, style: const TextStyle(fontSize: 30, height: 40 / 30)),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Tiny(subtitle!, style: const TextStyle(fontSize: 12, height: 18 / 12)),
                ),
            ],
          ),
        ),
        ...children,
      ],
    );

    return Screen(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: padding.top,
          bottom: padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const BackLink(),
            Expanded(
              child: scroll
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: AppSpacing.huge),
                      child: body,
                    )
                  : body,
            ),
          ],
        ),
      ),
    );
  }
}

/// Long-form reading: terms, privacy, the letter from the developer.
class Prose extends StatelessWidget {
  const Prose({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final child in children)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: child,
          ),
      ],
    );
  }
}

class P extends StatelessWidget {
  const P(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Serif(
      text,
      tone: Tone.dim,
      style: const TextStyle(fontSize: 16, height: 29 / 16).merge(style),
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Heading(text, style: const TextStyle(fontSize: 19, height: 28 / 19)),
    );
  }
}
