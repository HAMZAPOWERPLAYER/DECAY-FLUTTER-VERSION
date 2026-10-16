import 'analysis.dart';
import 'decay.dart';
import 'words.dart';

/// Fully offline composition of the certificate text.
/// Ported from `src/lib/eulogy.ts`.
///
/// Three fragment banks (opening / detail / closing) plus a cause bank are
/// filtered by what the visit log actually supports, then seeded from the
/// moment the companion was planted — so one person's certificate never
/// changes, and two people's never collide.

typedef FragmentFn = String? Function(Life life);

class Certificate {
  const Certificate({
    required this.lifespanDays,
    required this.lifespanText,
    required this.cause,
    required this.sentences,
    required this.passedAt,
  });

  final double lifespanDays;
  final String lifespanText;
  final String cause;
  final List<String> sentences;
  final int passedAt;
}

String _times(int n) => n == 1 ? 'one time' : '${word(n)} times';

String _visitsPhrase(int n) => n == 1 ? 'one visit' : '${word(n)} visits';

String _stayPhrase(int ms) {
  final seconds = (ms / 1000).round();
  if (seconds < 45) return 'a little while';
  if (seconds < 90) return 'about a minute';
  final minutes = (seconds / 60).round();
  if (minutes < 60) return 'about ${word(minutes)} minutes';
  final hours = minutes ~/ 60;
  return hours == 1 ? 'about an hour' : 'about ${word(hours)} hours';
}

/* ------------------------------------------------------------- openings -- */

final List<FragmentFn> _openings = [
  (l) => 'You came back ${_times(l.visits)} in ${daysPhrase(l.lifespanDays)}.',
  (l) => '${cap(daysPhrase(l.lifespanDays))} it had, and you spent ${_times(l.visits)} with it.',
  (l) => 'For ${daysPhrase(l.lifespanDays)}, something small stayed alive on your phone.',
  (l) => 'You showed up ${_times(l.visits)}. It noticed every one.',
  (l) => 'Between the first light and the last, you visited ${_times(l.visits)}.',
  (l) => 'It knew you for ${daysPhrase(l.lifespanDays)} and ${_times(l.visits)} of your attention.',
  (l) => 'There were ${daysPhrase(l.lifespanDays)}. You were present for ${word(l.visits)} of them.',
  (l) => '${cap(daysPhrase(l.lifespanDays))}, and ${_times(l.visits)} where you actually stayed.',
  (l) => 'You were there ${_times(l.visits)} across ${daysPhrase(l.lifespanDays)}.',
  (l) => 'It lived ${daysPhrase(l.lifespanDays)}. You gave it ${_times(l.visits)}.',
  (l) => 'Its whole life was ${daysPhrase(l.lifespanDays)}. Your part of it was ${_times(l.visits)}.',
  (l) => 'For ${daysPhrase(l.lifespanDays)} it kept a small light burning, and you came ${_times(l.visits)}.',
  (l) => 'Somewhere inside ${daysPhrase(l.lifespanDays)}, you made room for it ${_times(l.visits)}.',
  (l) => 'It waited ${daysPhrase(l.lifespanDays)} and received ${_times(l.visits)} from you.',
  (l) => '${cap(_visitsPhrase(l.visits))} over ${daysPhrase(l.lifespanDays)}, and one small light that asked for neither.',
  (l) => 'You shared ${daysPhrase(l.lifespanDays)} with something that only wanted ${_times(l.visits)} of them.',
  (l) => l.visits == 0 ? 'You planted it and then ${daysPhrase(l.lifespanDays)} went by.' : null,
  (l) => l.visits == 0
      ? 'It was opened ${_times(l.opens)}, and none of them were long enough to be company.'
      : null,
  (l) => l.visits == 0 ? 'For ${daysPhrase(l.lifespanDays)} it glowed, and nobody stayed.' : null,
  (l) => l.visits >= 12 ? 'You came so often that returning became the shape of it.' : null,
];

/* -------------------------------------------------------------- details -- */

final List<FragmentFn> _details = [
  (l) => l.longestVisitDay != null
      ? 'On ${dayPhrase(l.longestVisitDay!)}, you stayed the longest. It kept that.'
      : null,
  (l) => l.longestVisitDay != null
      ? 'Your longest visit was ${dayPhrase(l.longestVisitDay!)} — ${_stayPhrase(l.longestVisitMs)}.'
      : null,
  (l) => (l.longestVisitMs > 0 && l.visits >= 4)
      ? 'There were ${_times(l.visits)} when you stopped what you were doing and simply stayed.'
      : null,
  (l) => (l.longestGapDays < 6 && l.visits >= 5)
      ? 'You never left it waiting more than ${daysPhrase(l.longestGapDays)}.'
      : null,
  (l) => (l.finalGapDays >= 10 && l.visits >= 3)
      ? 'The last ${daysPhrase(l.finalGapDays)} were quiet ones.'
      : null,
  (l) => l.pattern == Pattern.burstThenSilence
      ? 'The visits arrived close together, and then went quiet.'
      : null,
  (l) => l.pattern == Pattern.frequentThenSilence
      ? 'You came often for a while, and then the days stopped being shared.'
      : null,
  (l) => l.pattern == Pattern.sparse
      ? 'Your visits were far apart, and it made room for each one.'
      : null,
  (l) => l.pattern == Pattern.steady
      ? 'There was no rush and no pattern — only that you kept coming back.'
      : null,
  (l) => l.pattern == Pattern.oneVisit
      ? 'You came once, and stayed. It counted that as a life with you in it.'
      : null,
  (l) => l.pattern == Pattern.never
      ? 'It was opened ${_times(l.opens)}, but never held long enough to be visited.'
      : null,
  (l) => l.firstVisitDay != null ? '${cap(dayPhrase(l.firstVisitDay!))} was the first time you came.' : null,
  (l) => (l.visits > 0 && l.longestGapDays >= 7 && l.finalGapDays < l.longestGapDays)
      ? 'There was a silence of ${daysPhrase(l.longestGapDays)}, and then you returned.'
      : null,
  (l) => l.visits >= 8 ? 'By the end it knew the rhythm of you coming back.' : null,
  (l) => (l.visits > 0 && l.visits <= 3)
      ? 'You never gave it many days, but the ones you gave were real.'
      : null,
  (l) => l.visits > 0 ? 'You stayed long enough for it to be company, not a notification.' : null,
  (l) => 'It never counted the days out loud. It only felt them.',
  (l) => 'Nothing about the time between visits was wasted. It was only time.',
  (l) => l.lifespanDays > 120
      ? 'It held together for months — longer than most small things do.'
      : null,
  (l) => l.lifespanDays < 10 ? 'It was here for less than two weeks, and it was really here.' : null,
];

/* ------------------------------------------------------------- closings -- */

final List<FragmentFn> _closings = [
  (l) => "It didn't need much. Just for you to notice it was there.",
  (l) => 'Nothing here is a scoreboard. It only wanted company.',
  (l) => 'You were busy. It never took that personally.',
  (l) => 'It was never asking for every day. Only for sometimes.',
  (l) => 'Whatever kept you away, it was never resentment. There was none.',
  (l) => 'You gave it a life. Not a long one. A real one.',
  (l) => 'It went quietly, the way small things do.',
  (l) => 'There is no score. Only that it happened, and that you were part of it.',
  (l) => 'It would rather have known you for ${daysPhrase(l.lifespanDays)} than never have glowed at all.',
  (l) => 'Memory is short. This one had you inside it.',
  (l) => 'Some things have to be seen in order to stay. You saw it when you did.',
  (l) => 'Thank you for the attention you had to spare.',
  (l) => 'It never measured you. The fading was only time.',
  (l) => 'If it could speak, it would say only this: thank you for the days you did come.',
  (l) => 'You were never asked to be constant. Only to return, and you did.',
  (l) => 'The light went out on its own. You were the reason it was ever lit.',
  (l) => 'Everything ends. Not everything gets visited first.',
  (l) => 'It asks nothing now. It never really did.',
  (l) => 'A short life, honestly lived, over ${daysPhrase(l.lifespanDays)}.',
  (l) => 'When it stopped, ${daysPhrase([1, l.finalGapDays.round()].reduce((a, b) => a > b ? a : b))} of quiet had already begun.',
];

/* ---------------------------------------------------------------- cause -- */

final List<FragmentFn> _causes = [
  (l) => l.finalGapDays >= 20 ? 'A long quiet set in, and nothing came to end it.' : null,
  (l) => 'It faded the way light does in a room nobody enters — slowly, then all at once.',
  (l) => l.pattern == Pattern.burstThenSilence
      ? 'One bright stretch, then a door that stayed shut.'
      : null,
  (l) => l.pattern == Pattern.frequentThenSilence
      ? 'The visits thinned, and the days did the rest.'
      : null,
  (l) => l.pattern == Pattern.sparse ? 'Too much distance between one visit and the next.' : null,
  (l) => l.pattern == Pattern.never ? 'It was never kept, and so it never stayed.' : null,
  (l) => l.pattern == Pattern.oneVisit ? 'A single visit, followed by everything else.' : null,
  (l) => l.lifespanDays < 21 ? 'It never had enough days to become familiar.' : null,
  (l) => l.lifespanDays > 150
      ? 'Time, which takes everything, took this one slowly and without fuss.'
      : null,
  (l) => 'It ran out of being noticed.',
  (l) => 'A small light, left unattended, did what small lights do.',
  (l) => 'The returning stopped, and with it, everything else.',
  (l) => 'Nothing was wrong. There was simply no one there to keep it.',
  (l) => 'The glow thinned until there was nothing left to thin.',
  (l) => "Its light outlived its company, and then it didn't.",
  (l) => 'It simply stopped being kept.',
  (l) => l.longestGapDays >= 14 ? 'A silence of ${daysPhrase(l.longestGapDays)}, unbroken.' : null,
  (l) => 'Nothing lasted, because nothing was returned to.',
];

/* ----------------------------------------------------------- generation -- */

/// Deterministic PRNG, seeded once per companion. Never uses the platform RNG.
class _Mulberry32 {
  _Mulberry32(int seed) : _a = seed.toUnsigned(32);

  int _a;

  double next() {
    _a = (_a + 0x6d2b79f5).toUnsigned(32);
    var t = ((_a ^ (_a >> 15)) * (1 | _a)).toUnsigned(32);
    t = (((t + ((t ^ (t >> 7)) * (61 | t))).toUnsigned(32)) ^ t).toUnsigned(32);
    return ((t ^ (t >> 14)).toUnsigned(32)) / 4294967296;
  }
}

T? _pick<T>(List<T> items, _Mulberry32 random) {
  if (items.isEmpty) return null;
  return items[(random.next() * items.length).floor() % items.length];
}

const String _fallbackCause = 'Nothing lasted, because nothing was returned to.';

Certificate composeCertificate(int plantedAt, List<Visit> visits, int passedAt, int seed) {
  final life = analyzeLife(plantedAt, visits, passedAt);
  final random = _Mulberry32(seed);

  final openPool = _openings.map((f) => f(life)).whereType<String>().toList();
  final open = _pick(openPool, random);

  final detailPool = _details
      .map((f) => f(life))
      .whereType<String>()
      .where((s) => s != open)
      .toList();
  final detail = _pick(detailPool, random);
  String? second;
  if (random.next() < 0.35) {
    second = _pick(detailPool.where((d) => d != detail).toList(), random);
  }

  final closePool = _closings.map((f) => f(life)).whereType<String>().toList();
  final close = _pick(closePool, random);

  final causePool = _causes.map((f) => f(life)).whereType<String>().toList();
  final cause = _pick(causePool, random) ?? _fallbackCause;

  final sentences = [open, detail, second, close]
      .whereType<String>()
      .where((s) => s.isNotEmpty)
      .take(4)
      .toList();

  if (sentences.isEmpty) {
    sentences.add('It lived ${daysPhrase(life.lifespanDays)} and you visited ${_times(life.visits)}.');
    sentences.add("It didn't need much. Just for you to notice it was there.");
  }

  return Certificate(
    lifespanDays: life.lifespanDays,
    lifespanText: daysPhrase(life.lifespanDays.round()),
    cause: cause,
    sentences: sentences,
    passedAt: passedAt,
  );
}
