/// Date stamp formatting — ported from `src/lib/format.ts`.
///
/// "25 September 2026 · 3:42 pm" — no locale tables required.
library;

const List<String> _months = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

String formatStamp(int timestamp) {
  final d = DateTime.fromMillisecondsSinceEpoch(timestamp);
  final day = d.day;
  final month = _months[d.month - 1];
  final year = d.year;
  var hours = d.hour;
  final minutes = d.minute;
  final suffix = hours >= 12 ? 'pm' : 'am';
  hours %= 12;
  if (hours == 0) hours = 12;
  final minuteText = minutes < 10 ? '0$minutes' : '$minutes';
  return '$day $month $year · $hours:$minuteText $suffix';
}
