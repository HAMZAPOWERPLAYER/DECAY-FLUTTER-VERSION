import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'companion.dart';
import 'decay.dart';

/// How long you have to simply stay on the companion screen before it counts
/// as a real visit. Opening and leaving is not presence.
const int presenceMs = 12000;

/// Anything shorter than this is a mis-tap, not a visit worth recording.
const int _minimumMs = 600;

/// Presence Ritual — ported from `src/hooks/use-presence.ts`.
///
/// Detects face-down / screen-dimmed via accelerometer when available
/// (z <= -7, |x| < 3, |y| < 3). Fallback: always rely on time-based timer;
/// never block visit due to missing sensors.
class PresenceTracker extends ChangeNotifier {
  PresenceTracker(this._controller) {
    _startSensor();
  }

  final CompanionController _controller;

  int? _start;
  bool _recorded = false;
  Timer? _timer;
  bool _active = false;
  bool stayed = false;
  StreamSubscription<AccelerometerEvent>? _accel;

  void _startSensor() {
    try {
      _accel = accelerometerEventStream().listen((event) {
        // Face-down roughly: z near -9.8, x/y near 0; screen facing down
        final zGrav = event.z.round();
        if (zGrav <= -7 && event.x.abs() < 3 && event.y.abs() < 3) {
          _sensorConfirm = true;
        }
      }, onError: (_) {
        // sensors unavailable — graceful fallback to timer only
      });
    } catch (_) {
      // sensors unavailable — graceful fallback to timer only
    }
  }

  bool _sensorConfirm = false;

  void setActive(bool active) {
    if (active == _active) return;
    _active = active;
    if (active) {
      begin();
    } else {
      end();
    }
  }

  void begin() {
    if (_start != null) return;
    final start = DateTime.now().millisecondsSinceEpoch;
    _start = start;
    _recorded = false;
    _sensorConfirm = false;
    stayed = false;
    notifyListeners();
    _timer = Timer(const Duration(milliseconds: presenceMs), () {
      if (_start == null) return;
      _recorded = true;
      _controller.registerVisit(Visit(
        t: start,
        present: true,
        ms: DateTime.now().millisecondsSinceEpoch - start,
      ));
      stayed = true;
      HapticFeedback.lightImpact();
      notifyListeners();
    });
  }

  void end() {
    final start = _start;
    if (start == null) return;
    final elapsed = DateTime.now().millisecondsSinceEpoch - start;
    _start = null;
    _timer?.cancel();
    _timer = null;
    if (elapsed < _minimumMs) return;
    // Face-down / dimmed presence still counts, even if the timer never fired.
    _controller.registerVisit(
      Visit(t: start, present: _recorded || _sensorConfirm, ms: elapsed),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _accel?.cancel();
    end();
    super.dispose();
  }
}
