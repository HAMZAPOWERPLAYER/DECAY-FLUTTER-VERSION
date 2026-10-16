import 'decay.dart';

/// Ported from `src/lib/analysis.ts`.

enum Pattern {
  never,
  oneVisit,
  burstThenSilence,
  frequentThenSilence,
  sparse,
  steady,
}

class Life {
  const Life({
    required this.lifespanDays,
    required this.visits,
    required this.opens,
    required this.longestGapDays,
    required this.finalGapDays,
    required this.longestVisitMs,
    required this.longestVisitDay,
    required this.firstVisitDay,
    required this.firstVisitAt,
    required this.pattern,
  });

  final double lifespanDays;

  /// visits where the visitor actually stayed
  final int visits;

  /// every recorded open, present or not
  final int opens;
  final double longestGapDays;

  /// the gap between the last real visit and the passing
  final double finalGapDays;
  final int longestVisitMs;
  final int? longestVisitDay;
  final int? firstVisitDay;
  final int? firstVisitAt;
  final Pattern pattern;
}

Life analyzeLife(int plantedAt, List<Visit> visits, int passedAt) {
  final lifespanDays = [0.0, (passedAt - plantedAt) / msDay].reduce((a, b) => a > b ? a : b);
  final real = visits.where((v) => v.present).toList()
    ..sort((a, b) => a.t.compareTo(b.t));
  final opens = visits.length;

  final gaps = <double>[];
  int cursor = plantedAt;
  for (final visit in real) {
    gaps.add((visit.t - cursor) / msDay);
    cursor = visit.t;
  }
  final finalGapDays = [0.0, (passedAt - cursor) / msDay].reduce((a, b) => a > b ? a : b);
  if (real.isNotEmpty) gaps.add(finalGapDays);

  final longestGapDays =
      gaps.isNotEmpty ? gaps.reduce((a, b) => a > b ? a : b) : lifespanDays;

  int longestVisitMs = 0;
  int? longestVisitDay;
  for (final visit in real) {
    if (visit.ms > longestVisitMs) {
      longestVisitMs = visit.ms;
      longestVisitDay = ((visit.t - plantedAt) / msDay).floor() + 1;
    }
  }

  final firstVisitDay =
      real.isNotEmpty ? ((real.first.t - plantedAt) / msDay).floor() + 1 : null;
  final firstVisitAt = real.isNotEmpty ? real.first.t : null;

  final density = lifespanDays > 0 ? real.length / lifespanDays : 0.0;
  final tailIsSilent = lifespanDays > 0 && finalGapDays / lifespanDays >= 0.4;
  final half = plantedAt + (passedAt - plantedAt) / 2;
  final earlyShare =
      real.isNotEmpty ? real.where((v) => v.t <= half).length / real.length : 0.0;

  final Pattern pattern;
  if (real.isEmpty) {
    pattern = Pattern.never;
  } else if (real.length == 1) {
    pattern = Pattern.oneVisit;
  } else if (tailIsSilent && earlyShare >= 0.65 && real.length >= 3) {
    pattern = Pattern.burstThenSilence;
  } else if (tailIsSilent && real.length >= 3) {
    pattern = Pattern.frequentThenSilence;
  } else if (density < 0.12) {
    pattern = Pattern.sparse;
  } else {
    pattern = Pattern.steady;
  }

  return Life(
    lifespanDays: lifespanDays,
    visits: real.length,
    opens: opens,
    longestGapDays: longestGapDays,
    finalGapDays: finalGapDays,
    longestVisitMs: longestVisitMs,
    longestVisitDay: longestVisitDay,
    firstVisitDay: firstVisitDay,
    firstVisitAt: firstVisitAt,
    pattern: pattern,
  );
}
