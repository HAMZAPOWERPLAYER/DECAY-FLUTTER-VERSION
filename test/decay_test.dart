import 'package:flutter_test/flutter_test.dart';

import 'package:decay/decay.dart';
import 'package:decay/eulogy.dart';
import 'package:decay/words.dart';

void main() {
  test('a freshly planted companion is vibrant', () {
    final now = DateTime.now().millisecondsSinceEpoch;
    final decay = computeDecay(DecayInput(plantedAt: now, visits: const [], now: now));
    expect(decay.stage, 0);
    expect(decay.dead, false);
  });

  test('neglect alone darkens the companion over time', () {
    final planted = DateTime.now().millisecondsSinceEpoch - 30 * 86400000;
    final now = DateTime.now().millisecondsSinceEpoch;
    final decay = computeDecay(DecayInput(plantedAt: planted, visits: const [], now: now));
    expect(decay.stage, greaterThanOrEqualTo(4));
  });

  test('real visits buy back neglect but never fully reset', () {
    final now = DateTime.now().millisecondsSinceEpoch;
    final planted = now - 10 * 86400000;
    final visits = [
      Visit(t: now - 1000, present: true, ms: 15000),
    ];
    final decay = computeDecay(DecayInput(plantedAt: planted, visits: visits, now: now));
    // One visit heals ~12 days of a ~10-day neglect, but the horizon stays.
    expect(decay.neglectDays, lessThan(10));
    expect(decay.stage, lessThanOrEqualTo(2));
  });

  test('the impermanence horizon eventually ends every companion', () {
    final planted = DateTime.now().millisecondsSinceEpoch - 400 * 86400000;
    final now = DateTime.now().millisecondsSinceEpoch;
    // Daily real visits for the whole life: neglect stays near zero, but the
    // horizon still bites.
    final visits = List.generate(
      100,
      (i) => Visit(t: planted + i * 86400000 + 1000, present: true, ms: 20000),
    );
    final decay = computeDecay(DecayInput(plantedAt: planted, visits: visits, now: now));
    expect(decay.dead, true);
  });

  test('words and phrases read like prose', () {
    expect(word(0), 'zero');
    expect(word(21), 'twenty-one');
    expect(word(105), 'one hundred five');
    expect(ordinal(12), 'twelfth');
    expect(daysPhrase(1), 'one day');
    expect(daysPhrase(42), 'forty-two days');
  });

  test('the certificate is deterministic for the same seed', () {
    final planted = 1755000000000;
    final passed = planted + 20 * 86400000;
    final visits = [
      Visit(t: planted + 86400000, present: true, ms: 20000),
      Visit(t: planted + 5 * 86400000, present: true, ms: 60000),
    ];
    final a = composeCertificate(planted, visits, passed, 12345);
    final b = composeCertificate(planted, visits, passed, 12345);
    expect(a.cause, b.cause);
    expect(a.sentences, b.sentences);
    expect(a.lifespanText, 'twenty days');
    expect(a.sentences, isNotEmpty);
  });
}
