import 'package:flutter/material.dart';

import '../theme.dart';

/// Quiet text styles — ported from `src/components/text.tsx`.
enum Tone { ink, dim, faint, ghost, gold }

Color _toneColor(Tone tone) {
  switch (tone) {
    case Tone.ink:
      return AppColors.ink;
    case Tone.dim:
      return AppColors.inkDim;
    case Tone.faint:
      return AppColors.inkFaint;
    case Tone.ghost:
      return AppColors.inkGhost;
    case Tone.gold:
      return AppColors.gold;
  }
}

class QuietText extends StatelessWidget {
  const QuietText(
    this.data, {
    super.key,
    required this.family,
    required this.fontSize,
    required this.lineHeight,
    this.letterSpacing = 0,
    this.tone = Tone.ink,
    this.style,
    this.textAlign,
  });

  final String data;
  final String family;
  final double fontSize;
  final double lineHeight;
  final double letterSpacing;
  final Tone tone;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      textAlign: textAlign,
      style: TextStyle(
        fontFamily: family,
        fontSize: fontSize,
        height: lineHeight / fontSize,
        letterSpacing: letterSpacing,
        color: _toneColor(tone),
      ).merge(style),
    );
  }
}

/// Large serif — the lifespan, the emotional anchors.
class Display extends QuietText {
  const Display(super.data, {super.key, super.tone, super.style, super.textAlign})
      : super(family: AppFonts.serif, fontSize: 52, lineHeight: 60, letterSpacing: -0.5);
}

/// Section-scale serif heading.
class Heading extends QuietText {
  const Heading(super.data, {super.key, super.tone, super.style, super.textAlign})
      : super(family: AppFonts.serif, fontSize: 26, lineHeight: 36, letterSpacing: -0.2);
}

/// Serif paragraph — eulogy and long-form reading.
class Serif extends QuietText {
  const Serif(super.data, {super.key, super.tone, super.style, super.textAlign})
      : super(family: AppFonts.serif, fontSize: 17, lineHeight: 31);
}

/// Serif paragraph in italic — the cause of passing.
class SerifItalic extends QuietText {
  SerifItalic(
    super.data, {
    super.key,
    super.tone,
    super.textAlign,
    TextStyle? style,
  }) : super(
          family: AppFonts.serif,
          fontSize: 17,
          lineHeight: 31,
          style: TextStyle(fontStyle: FontStyle.italic).merge(style),
        );
}

/// Quiet sans body.
class Body extends QuietText {
  const Body(super.data, {super.key, super.tone = Tone.dim, super.style, super.textAlign})
      : super(family: AppFonts.sans, fontSize: 16, lineHeight: 26, letterSpacing: 0.1);
}

/// Small letterspaced sans label.
class Label extends QuietText {
  const Label(super.data, {super.key, super.tone = Tone.faint, super.style, super.textAlign})
      : super(family: AppFonts.sans, fontSize: 11, lineHeight: 16, letterSpacing: 2.4);
}

/// The smallest readable sans — timestamps, credits.
class Tiny extends QuietText {
  const Tiny(super.data, {super.key, super.tone = Tone.faint, super.style, super.textAlign})
      : super(family: AppFonts.sans, fontSize: 12, lineHeight: 18, letterSpacing: 0.3);
}

/// Buttons and links, sans, unhurried.
class LinkText extends QuietText {
  const LinkText(super.data, {super.key, super.tone = Tone.dim, super.style, super.textAlign})
      : super(family: AppFonts.sans, fontSize: 15, lineHeight: 22, letterSpacing: 0.6);
}
