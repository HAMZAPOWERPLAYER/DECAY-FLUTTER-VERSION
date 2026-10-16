import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Quiet Archive persistence — ported from `src/lib/archive.ts`.
///
/// Boundary (intentional design choice): archive is kept locally; a reinstall
/// wipes it unless the user explicitly exports a JSON backup. We never
/// auto-restore from a file — the user must open it.
const String _key = '@decay/archive';

class CertificateEntry {
  CertificateEntry({
    required this.id,
    this.plantedAt,
    this.realVisits,
    this.longestVisitMs,
    this.longestVisitDay,
    required this.lifespanDays,
    required this.cause,
    required this.sentences,
    required this.passedAt,
    this.certificateImageUri,
  });

  final String id;
  final int? plantedAt;
  final int? realVisits;
  final int? longestVisitMs;
  final int? longestVisitDay;
  final double lifespanDays;
  final String cause;
  final List<String> sentences;
  final int passedAt;

  /// exported PNG path (optional)
  final String? certificateImageUri;

  Map<String, dynamic> toJson() => {
        'id': id,
        'plantedAt': plantedAt,
        'realVisits': realVisits,
        'longestVisitMs': longestVisitMs,
        'longestVisitDay': longestVisitDay,
        'lifespanDays': lifespanDays,
        'cause': cause,
        'sentences': sentences,
        'passedAt': passedAt,
        'certificateImageUri': certificateImageUri,
      };

  static CertificateEntry? fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final lifespanDays = json['lifespanDays'];
    final cause = json['cause'];
    final sentences = json['sentences'];
    final passedAt = json['passedAt'];
    if (id is! String || lifespanDays is! num || cause is! String || passedAt is! int) {
      return null;
    }
    return CertificateEntry(
      id: id,
      plantedAt: json['plantedAt'] is int ? json['plantedAt'] as int : null,
      realVisits: json['realVisits'] is int ? json['realVisits'] as int : null,
      longestVisitMs:
          json['longestVisitMs'] is int ? json['longestVisitMs'] as int : null,
      longestVisitDay:
          json['longestVisitDay'] is int ? json['longestVisitDay'] as int : null,
      lifespanDays: lifespanDays.toDouble(),
      cause: cause,
      sentences: sentences is List ? sentences.whereType<String>().toList() : const [],
      passedAt: passedAt,
      certificateImageUri: json['certificateImageUri'] is String
          ? json['certificateImageUri'] as String
          : null,
    );
  }
}

Future<List<CertificateEntry>> loadArchive() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final parsed = jsonDecode(raw);
    if (parsed is! List) return [];
    return parsed
        .whereType<Map<String, dynamic>>()
        .map(CertificateEntry.fromJson)
        .whereType<CertificateEntry>()
        .toList();
  } catch (_) {
    return [];
  }
}

Future<void> saveArchive(List<CertificateEntry> list) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(list.map((e) => e.toJson()).toList()));
  } catch (_) {
    // The app is fully offline; a failed write simply means the next read wins.
  }
}

Future<void> addToArchive(CertificateEntry entry) async {
  final list = await loadArchive();
  if (list.any((existing) => existing.passedAt == entry.passedAt)) return;
  // no counts, no achievements — just keep it quietly
  list.add(entry);
  await saveArchive(list);
}

Future<String> exportArchiveJson() async {
  final list = await loadArchive();
  const encoder = JsonEncoder.withIndent('  ');
  return encoder.convert({
    'exportedAt': DateTime.now().millisecondsSinceEpoch,
    'entries': list.map((e) => e.toJson()).toList(),
  });
}
