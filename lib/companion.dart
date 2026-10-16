import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';

import 'ambient_audio.dart';
import 'decay.dart';
import 'notification_service.dart';
import 'store.dart';
import 'widget_sync.dart';

/// Companion state — ported from `src/state/companion.tsx` + `src/lib/storage.ts`.
class CompanionState {
  CompanionState({
    this.plantedAt,
    this.passedAt,
    this.ambientOn = false,
    this.gentleReminderOn = false,
    this.onboarded = false,
    this.seed = 0,
    this.visits = const [],
  });

  int? plantedAt;
  int? passedAt;
  bool ambientOn;
  bool gentleReminderOn;
  bool onboarded;
  int seed;
  List<Visit> visits;

  static CompanionState empty() => CompanionState();

  factory CompanionState.fromRow(CompanionRow row) => CompanionState(
        plantedAt: row.plantedAt,
        passedAt: row.passedAt,
        ambientOn: row.ambientOn,
        gentleReminderOn: row.gentleReminderOn,
        onboarded: row.onboarded,
        seed: row.seed,
        visits: row.visits,
      );

  CompanionRow toRow() => CompanionRow()
    ..plantedAt = plantedAt
    ..passedAt = passedAt
    ..ambientOn = ambientOn
    ..gentleReminderOn = gentleReminderOn
    ..onboarded = onboarded
    ..seed = seed
    ..visits = visits;
}

const DecayState idleDecay = DecayState(
  ageDays: 0,
  neglectDays: 0,
  horizonDays: 170,
  stage: 0,
  dead: false,
);

class CompanionController extends ChangeNotifier {
  CompanionController._(this._audio) {
    _load();
    // The world keeps turning while the app, too.
    _tick = Timer.periodic(const Duration(seconds: 30), (_) => _setNow());
    _lifecycleObserver = _PresenceLifecycle(this);
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
  }

  /// Created once in main(); owns the ambient audio players.
  static CompanionController create() =>
      CompanionController._(AmbientAudio());

  final AmbientAudio _audio;

  CompanionState _state = CompanionState.empty();
  bool _ready = false;
  int _now = DateTime.now().millisecondsSinceEpoch;
  Timer? _tick;
  late final _PresenceLifecycle _lifecycleObserver;

  CompanionState get state => _state;
  bool get ready => _ready;
  int get now => _now;

  DecayState get decay {
    final plantedAt = _state.plantedAt;
    if (plantedAt == null || !_ready) return idleDecay;
    return computeDecay(DecayInput(
      plantedAt: plantedAt,
      visits: _state.visits,
      now: _now,
    ));
  }

  Future<void> _load() async {
    final row = await DecayStore.instance.loadCompanionState();
    _state = CompanionState.fromRow(row);
    _now = DateTime.now().millisecondsSinceEpoch;
    _ready = true;
    _syncReminder();
    _syncWidget();
    notifyListeners();
  }

  void _setNow() {
    _now = DateTime.now().millisecondsSinceEpoch;
    _checkPassing();
    notifyListeners();
  }

  void onResumed() => _setNow();

  Future<void> _persist() async {
    try {
      await DecayStore.instance.saveCompanionState(_state.toRow());
    } catch (_) {
      // A failed write simply means the next read wins.
    }
  }

  void _syncReminder() {
    final realVisits = _state.visits.where((v) => v.present).toList();
    final lastVisitAt = realVisits.isNotEmpty ? realVisits.last.t : _state.plantedAt;
    final active = _state.gentleReminderOn && _state.passedAt == null && lastVisitAt != null;
    if (!active) {
      NotificationService.instance.cancelGentleReminder().catchError((_) {});
      return;
    }
    NotificationService.instance.scheduleGentleReminder(lastVisitAt).catchError((_) {});
  }

  /// The home screen widget always mirrors what the app last saw.
  void _syncWidget() {
    if (_state.plantedAt == null) return;
    WidgetSync.syncStage(decay.stage);
  }

  /// The passing is recorded the first moment it is noticed.
  void _checkPassing() {
    if (_state.plantedAt == null) return;
    if (_state.passedAt != null) return;
    if (!decay.dead) return;
    _state.passedAt = _now;
    _persist();
  }

  void plant() {
    final at = DateTime.now().millisecondsSinceEpoch;
    _now = at;
    _state.onboarded = true;
    _state.plantedAt ??= at;
    _state.passedAt = null;
    if (_state.seed == 0) {
      var n = Random().nextInt(0xFFFFFFFF);
      if (n == 0) n = 1;
      _state.seed = n;
    }
    _persist();
    _syncWidget();
    notifyListeners();
  }

  void registerVisit(Visit visit) {
    if (_state.plantedAt == null) return;
    if (_state.passedAt != null) return;
    final visits = _state.visits.where((v) => v.t != visit.t).toList()
      ..add(visit)
      ..sort((a, b) => a.t.compareTo(b.t));
    _state.visits = visits;
    _now = DateTime.now().millisecondsSinceEpoch;
    _persist();
    _syncWidget();
    notifyListeners();
  }

  void setAmbient(bool on) {
    _state.ambientOn = on;
    _persist();
    notifyListeners();
  }

  void setGentleReminder(bool on) {
    _state.gentleReminderOn = on;
    _persist();
    _syncReminder();
    notifyListeners();
  }

  void updateAudio({required bool active}) {
    _audio.update(stage: decay.stage, ambientOn: _state.ambientOn, active: active);
  }

  void onDeathSequence() {
    _audio.onDeath();
  }

  @override
  void dispose() {
    _tick?.cancel();
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    _audio.dispose();
    super.dispose();
  }
}

class _PresenceLifecycle with WidgetsBindingObserver {
  _PresenceLifecycle(this.controller);
  final CompanionController controller;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) controller.onResumed();
  }
}
