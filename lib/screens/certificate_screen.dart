import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../analysis.dart';
import '../archive.dart';
import '../components/controls.dart';
import '../components/quiet_text.dart';
import '../components/screen.dart';
import '../companion.dart';
import '../eulogy.dart';
import '../format.dart';
import '../theme.dart';
import '../words.dart';

/// Death Certificate — ported from `src/app/certificate.tsx`.
///
/// Full-screen, no chrome, elegant card with lifespan / cause / eulogy /
/// timestamp. Save / Share at 1080×1920 (9:16 story ratio). No restart button.
class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key, required this.controller, this.archiveId});

  final CompanionController controller;
  final String? archiveId;

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  final GlobalKey _shotKey = GlobalKey();
  CertificateEntry? _archivedEntry;
  bool _busy = false;
  bool _saved = false;
  bool _kept = false;

  @override
  void initState() {
    super.initState();
    _loadArchiveState();
  }

  Future<void> _loadArchiveState() async {
    final archiveId = widget.archiveId;
    final entries = await loadArchive();
    if (!mounted) return;
    setState(() {
      if (archiveId != null) {
        _archivedEntry =
            entries.cast<CertificateEntry?>().firstWhere((e) => e?.id == archiveId, orElse: () => null);
      } else {
        _archivedEntry = null;
      }
      _kept = archiveId != null ||
          entries.any((entry) => entry.passedAt == _passedAt);
    });
  }

  int get _passedAt =>
      _certificate?.passedAt ?? widget.controller.state.passedAt ?? widget.controller.now;

  Certificate? get _certificate {
    final archived = _archivedEntry;
    if (archived != null) {
      return Certificate(
        lifespanDays: archived.lifespanDays,
        lifespanText: daysPhrase(archived.lifespanDays.round()),
        cause: archived.cause,
        sentences: archived.sentences,
        passedAt: archived.passedAt,
      );
    }
    final state = widget.controller.state;
    final plantedAt = state.plantedAt;
    if (plantedAt == null) return null;
    return composeCertificate(
      plantedAt,
      state.visits,
      state.passedAt ?? widget.controller.now,
      state.seed,
    );
  }

  /// Export the certificate card as a 1080×1920 PNG story-ratio image.
  Future<String?> _exportImage() async {
    try {
      final boundary =
          _shotKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      const targetWidth = 1080.0;
      final cardWidth = boundary.size.width;
      final pixelRatio = targetWidth / cardWidth;
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/decay-certificate-${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(byteData.buffer.asUint8List());
      return file.path;
    } catch (_) {
      return null;
    }
  }

  Future<void> _share() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final uri = await _exportImage();
      if (uri == null) return;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(uri, mimeType: 'image/png')],
          subject: 'Keep the certificate',
        ),
      );
      if (mounted) setState(() => _saved = true);
      Future<void>.delayed(const Duration(milliseconds: 3600), () {
        if (mounted) setState(() => _saved = false);
      });
    } catch (_) {
      // A cancelled share sheet is not an error worth surfacing.
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _keep() async {
    final certificate = _certificate;
    final state = widget.controller.state;
    if (_busy || _kept || certificate == null || widget.archiveId != null) return;
    final plantedAt = state.plantedAt;
    if (plantedAt == null) return;
    setState(() => _busy = true);
    try {
      final imageUri = await _exportImage();
      final life = analyzeLife(plantedAt, state.visits, _passedAt);
      await addToArchive(CertificateEntry(
        id: '$_passedAt-${state.seed}',
        plantedAt: plantedAt,
        realVisits: life.visits,
        longestVisitMs: life.longestVisitMs,
        longestVisitDay: life.longestVisitDay,
        lifespanDays: certificate.lifespanDays,
        cause: certificate.cause,
        sentences: certificate.sentences,
        passedAt: _passedAt,
        certificateImageUri: imageUri,
      ));
      if (mounted) setState(() => _kept = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    if (!controller.ready) return const Screen(child: SizedBox.expand());
    final certificate = _certificate;
    if (widget.archiveId != null && _archivedEntry == null) {
      return const Screen(child: SizedBox.expand());
    }
    if (controller.state.plantedAt == null || certificate == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pushReplacementNamed('/onboarding');
      });
      return const Screen(child: SizedBox.expand());
    }

    final padding = useScreenPadding(context);
    final windowWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = windowWidth - 32 < 420 ? windowWidth - 32 : 420.0;

    return Screen(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: padding.top + AppSpacing.lg,
          bottom: padding.bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 2600),
              curve: Curves.easeIn,
              builder: (context, value, _) => Opacity(
                opacity: value,
                child: RepaintBoundary(
                  key: _shotKey,
                  child: Container(
                    width: cardWidth,
                    height: cardWidth * 16 / 9,
                    color: AppColors.voidTop,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 34,
                      vertical: 52,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const _Flourish(),
                        const SizedBox(height: AppSpacing.md),
                        const Label(
                          'LIVED FOR',
                          style: TextStyle(fontSize: 10, letterSpacing: 3),
                        ),
                        Display(
                          certificate.lifespanText,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const Label(
                          'CAUSE OF PASSING',
                          style: TextStyle(fontSize: 10, letterSpacing: 3),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SerifItalic(
                          certificate.cause,
                          tone: Tone.dim,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 17, height: 30 / 17),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Serif(
                          certificate.sentences.join(' '),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 17, height: 32 / 17),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const _Flourish(),
                        const SizedBox(height: AppSpacing.sm),
                        const Label(
                          'DECAY',
                          tone: Tone.gold,
                          style: TextStyle(fontSize: 12, letterSpacing: 2.4),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Tiny(
                          'passed quietly · ${formatStamp(_passedAt)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11, letterSpacing: 0.6),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              height: 44,
              child: _busy
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.inkFaint,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.archiveId == null)
                          QuietPressable(
                            onPressed: _keep,
                            label: 'Keep the certificate in the Quiet Archive',
                            style: const EdgeInsets.symmetric(
                              vertical: AppSpacing.sm,
                              horizontal: AppSpacing.md,
                            ),
                            child: Label(
                              _kept ? 'KEPT' : 'KEEP',
                              tone: _kept ? Tone.gold : Tone.faint,
                              style: const TextStyle(fontSize: 11, letterSpacing: 3),
                            ),
                          ),
                        QuietPressable(
                          onPressed: _share,
                          label: 'Save or share the certificate',
                          style: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm,
                            horizontal: AppSpacing.md,
                          ),
                          child: Label(
                            _saved ? 'SHARED' : 'SAVE / SHARE',
                            tone: _saved ? Tone.gold : Tone.faint,
                            style: const TextStyle(fontSize: 11, letterSpacing: 3),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The small gold flourish — a line, two dots, and a leaf diamond.
class _Flourish extends StatelessWidget {
  const _Flourish();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: const Size(260, 24),
        painter: _FlourishPainter(),
      ),
    );
  }
}

class _FlourishPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const gold = Color(0x57E8C888); // 0.34
    const goldDot = Color(0x8CE8C888); // 0.55
    const goldLeaf = Color(0xCCE8C888); // 0.8
    final mid = size.width / 2;
    final paint = Paint()
      ..color = gold
      ..strokeWidth = 0.75;
    canvas.drawLine(Offset(0, 12), Offset(mid - 28, 12), paint);
    canvas.drawLine(Offset(mid + 28, 12), Offset(size.width, 12), paint);

    final dotPaint = Paint()..color = goldDot;
    canvas.drawCircle(Offset(mid - 24, 12), 1.4, dotPaint);
    canvas.drawCircle(Offset(mid + 24, 12), 1.4, dotPaint);

    final leaf = Path()
      ..moveTo(mid, 3)
      ..cubicTo(mid + 1.3, 8.4, mid + 5.2, 10.6, mid + 9.5, 12)
      ..cubicTo(mid + 5.2, 13.4, mid + 1.3, 15.6, mid, 21)
      ..cubicTo(mid - 1.3, 15.6, mid - 5.2, 13.4, mid - 9.5, 12)
      ..cubicTo(mid - 5.2, 10.6, mid - 1.3, 8.4, mid, 3)
      ..close();
    canvas.drawPath(leaf, Paint()..color = goldLeaf);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
