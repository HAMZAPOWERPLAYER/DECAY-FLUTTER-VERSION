/// Decay model — ported from `src/lib/decay.ts`.
///
/// Two pressures act on the companion at once:
///
///  1. Neglect — measured from the last *real* visit (one where you actually
///     stayed), and it is what drives the visible day-by-day fading.
///  2. Impermanence — a slow horizon that no amount of care can outrun, so that
///     nothing lives forever.
///
/// A real visit buys back roughly twelve days of neglect: enough to step back
/// a stage, never enough to erase a long absence in one go.
library;

const int msDay = 86400000;

const List<String> stageNames = [
  'Vibrant',
  'Dimming',
  'Fading',
  'Cracking',
  'Barely Holding On',
  'Passing',
];

class Visit {
  const Visit({required this.t, required this.present, required this.ms});

  /// epoch ms
  final int t;

  /// true only when the visitor stayed long enough to count as presence
  final bool present;

  /// how long the screen was held, in ms
  final int ms;

  Map<String, dynamic> toJson() => {'t': t, 'present': present, 'ms': ms};

  static Visit? fromJson(Object? value) {
    if (value is! Map) return null;
    final t = value['t'];
    final present = value['present'];
    final ms = value['ms'];
    if (t is! int || present is! bool || ms is! int) return null;
    return Visit(t: t, present: present, ms: ms);
  }
}

const List<int> _stageDoorways = [3, 7, 14, 26, 46];

/// Days of neglect purchased back by a single real visit.
const int _healPerVisit = 12;

/// Horizon at zero visits, extra day per visit, and the cap on that bonus.
const int _horizonBase = 170;
const int _horizonPerVisit = 1;
const int _horizonMaxVisits = 100;

/// How hard the horizon bites late in life. Higher = gentler at first.
const int _horizonCurvature = 4;

class DecayInput {
  const DecayInput({required this.plantedAt, required this.visits, required this.now});

  final int plantedAt;
  final List<Visit> visits;
  final int now;
}

class DecayState {
  const DecayState({
    required this.ageDays,
    required this.neglectDays,
    required this.horizonDays,
    required this.stage,
    required this.dead,
  });

  final double ageDays;
  final double neglectDays;
  final double horizonDays;
  final int stage;
  final bool dead;
}

int stageFromNeglectDays(double days) {
  if (days < _stageDoorways[0]) return 0;
  if (days < _stageDoorways[1]) return 1;
  if (days < _stageDoorways[2]) return 2;
  if (days < _stageDoorways[3]) return 3;
  if (days < _stageDoorways[4]) return 4;
  return 5;
}

/// Replays the visit history so the result is deterministic: the same state at
/// the same moment always produces the same stage, no matter how often it is
/// recomputed or whether the device clock moved.
double neglectDays(DecayInput input) {
  final real = input.visits.where((v) => v.present).toList()
    ..sort((a, b) => a.t.compareTo(b.t));
  double score = 0;
  int cursor = [input.plantedAt, input.now].reduce((a, b) => a < b ? a : b);
  for (final visit in real) {
    final int t = visit.t.clamp(cursor, input.now);
    score += (t - cursor) / msDay;
    score = [0.0, score - _healPerVisit].reduce((a, b) => a > b ? a : b);
    cursor = t;
  }
  score += (input.now - cursor) / msDay;
  return score;
}

DecayState computeDecay(DecayInput input) {
  final clampedNow = [input.now, input.plantedAt].reduce((a, b) => a > b ? a : b);
  final ageDays = (clampedNow - input.plantedAt) / msDay;

  final neglect = neglectDays(
    DecayInput(plantedAt: input.plantedAt, visits: input.visits, now: clampedNow),
  );
  final realVisits = input.visits.where((v) => v.present).length;

  final horizonDays =
      _horizonBase + [realVisits, _horizonMaxVisits].reduce((a, b) => a < b ? a : b) * _horizonPerVisit;
  final horizonRatio = [0.0, ageDays / [horizonDays, 1].reduce((a, b) => a > b ? a : b).toDouble()]
      .reduce((a, b) => a > b ? a : b);
  final horizonAsNeglect = _pow(horizonRatio, _horizonCurvature) * _stageDoorways[4];

  final stage = [
    stageFromNeglectDays(neglect),
    stageFromNeglectDays(horizonAsNeglect),
  ].reduce((a, b) => a > b ? a : b);

  return DecayState(
    ageDays: ageDays,
    neglectDays: neglect,
    horizonDays: horizonDays.toDouble(),
    stage: stage,
    dead: stage >= 5,
  );
}

int stageOfDayBoundary(int stage) {
  return _stageDoorways[[stage, _stageDoorways.length - 1].reduce((a, b) => a < b ? a : b)];
}

double _pow(double base, int exp) {
  double result = 1;
  for (int i = 0; i < exp; i++) {
    result *= base;
  }
  return result;
}
