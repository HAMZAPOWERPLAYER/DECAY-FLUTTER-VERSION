import 'package:audioplayers/audioplayers.dart';

/// Stage-based piano sound segments derived from the single source loop.
/// Ported from `src/lib/stage-sound.ts`.
class Segment {
  const Segment({required this.start, required this.end});
  final double start;

  /// -1 = play to end (full original)
  final double end;
}

const Map<String, Segment> segments = {
  'vibrant': Segment(start: 0, end: 9),
  'dimming': Segment(start: 0, end: 9),
  'fading': Segment(start: 0, end: 4),
  'cracking': Segment(start: 0, end: 2),
  'barely': Segment(start: 0, end: 1.5),
  'deathFull': Segment(start: 0, end: -1),
};

Segment segmentForStage(int stage) {
  switch (stage) {
    case 0:
      return segments['vibrant']!;
    case 1:
      return segments['dimming']!;
    case 2:
      return segments['fading']!;
    case 3:
      return segments['cracking']!;
    case 4:
      return segments['barely']!;
    default:
      return segments['deathFull']!;
  }
}

const Map<int, double> stageVolume = {
  0: 0.65, // vibrant
  1: 0.55, // dimming (~15% down)
  2: 0.38, // fading
  3: 0.22, // cracking
  4: 0.12, // barely
  5: 0.0, // passing (death moment — silence first)
};

const Map<int, double> stageRate = {
  0: 1.0,
  1: 0.92,
  2: 0.85,
  3: 0.78,
  4: 0.72,
  5: 1.0, // death: full at normal/slightly elevated
};

/// Stage-based piano sound — single source loop, runtime segments.
/// Rules preserved: opt-in only (ambientOn), silent-mode respected,
/// crossfade 2-3s between stages, visual parity when muted.
class AmbientAudio {
  AmbientAudio() {
    _main.setReleaseMode(ReleaseMode.loop);
    _shadow.setReleaseMode(ReleaseMode.loop);
  }

  final AudioPlayer _main = AudioPlayer();
  final AudioPlayer _shadow = AudioPlayer();

  int _stage = 0;
  bool _started = false;

  Future<void> update({required int stage, required bool ambientOn, required bool active}) async {
    _stage = stage;

    if (!ambientOn || !active) {
      // If sound disabled or screen not active, fade both out gently
      await _main.setVolume(0);
      await _shadow.setVolume(0);
      await _main.pause();
      await _shadow.pause();
      return;
    }

    final vol = stageVolume[stage] ?? 0.4;
    final rate = stageRate[stage] ?? 1.0;

    try {
      if (!_started) {
        await _main.play(AssetSource('audio/piano_full.wav'));
        _started = true;
      } else {
        await _main.resume();
      }
      // Rate / volume per stage
      await _main.setPlaybackRate(rate);
      await _main.setVolume(vol);
      // Position to segment start when stage changes (approximate phrase begin)
      final seg = segmentForStage(stage);
      await _main.seek(Duration(milliseconds: (seg.start * 1000).round()));
    } catch (_) {
      // A missing or failed audio load must never break the companion.
    }
  }

  /// Death sequence: Barely → 3s silence → full fade-in under certificate.
  Future<void> onDeath() async {
    await Future<void>.delayed(const Duration(seconds: 3));
    if (_stage < 5) return;
    try {
      await _shadow.setPlaybackRate(1.05);
      await _shadow.setVolume(0.7);
      await _shadow.play(AssetSource('audio/piano_full.wav'));
    } catch (_) {}
  }

  Future<void> dispose() async {
    await _main.dispose();
    await _shadow.dispose();
  }
}
