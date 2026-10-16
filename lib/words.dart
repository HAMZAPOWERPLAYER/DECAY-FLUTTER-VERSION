/// Small number → words helpers, so counts read like prose instead of data.
///
/// Ported from `src/lib/words.ts`.
library;

const List<String> _ones = [
  'zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine',
  'ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen',
  'seventeen', 'eighteen', 'nineteen',
];

const List<String> _tens = [
  '', '', 'twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy', 'eighty', 'ninety',
];

const Map<String, String> _irregularOrdinals = {
  'one': 'first',
  'two': 'second',
  'three': 'third',
  'five': 'fifth',
  'eight': 'eighth',
  'nine': 'ninth',
  'twelve': 'twelfth',
};

String _underHundred(int n) {
  if (n < 20) return _ones[n];
  final tens = n ~/ 10;
  final ones = n % 10;
  return ones == 0 ? _tens[tens] : '${_tens[tens]}-${_ones[ones]}';
}

String _underThousand(int n) {
  if (n < 100) return _underHundred(n);
  final hundreds = n ~/ 100;
  final rest = n % 100;
  final head = '${_ones[hundreds]} hundred';
  return rest == 0 ? head : '$head ${_underHundred(rest)}';
}

/// 0 … 999,999. Falls back to digits beyond that.
String word(num n) {
  final v = n.round().clamp(0, 999999999);
  if (v == 0) return 'zero';
  if (v > 999999) return '$v';
  if (v < 1000) return _underThousand(v);
  final thousands = v ~/ 1000;
  final rest = v % 1000;
  final head = '${_underThousand(thousands)} thousand';
  return rest == 0 ? head : '$head ${_underThousand(rest)}';
}

/// "seventh", "twelfth", "forty-first"
String ordinal(num n) {
  final v = n.round().clamp(1, 999999999);
  if (v > 999999) return '${v}th';
  final cardinal = word(v);
  final irregular = _irregularOrdinals[cardinal];
  if (irregular != null) return irregular;
  if (cardinal.endsWith('y')) {
    return '${cardinal.substring(0, cardinal.length - 1)}ieth';
  }
  if (cardinal.endsWith('e')) return '${cardinal}th';
  final hyphen = cardinal.lastIndexOf('-');
  if (hyphen >= 0) {
    final head = cardinal.substring(0, hyphen + 1);
    final tail = int.parse(cardinal.substring(hyphen + 1));
    return '$head${ordinal(tail)}';
  }
  return '${cardinal}th';
}

/// "one day" / "forty-one days"
String daysPhrase(num n) {
  final v = n.round().clamp(0, 999999999);
  return v == 1 ? 'one day' : '${word(v)} days';
}

/// "the eleventh day" / "day one"
String dayPhrase(num n) {
  final v = n.round().clamp(0, 999999999);
  return v <= 1 ? 'the first day' : 'the ${ordinal(v)} day';
}

String cap(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}
