import 'package:flutter/material.dart';

import '../constants/qlyp_colors.dart';
import '../constants/qlyp_motion.dart';
import '../motion/qlyp_motion_accessibility.dart';

/// Tirer pour rafraichir avec logo QLYP dessine (accueil 10C).
class QlypLogoRefresh extends StatefulWidget {
  const QlypLogoRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  final Widget child;
  final Future<void> Function() onRefresh;

  @override
  State<QlypLogoRefresh> createState() => _QlypLogoRefreshState();
}

class _QlypLogoRefreshState extends State<QlypLogoRefresh>
    with TickerProviderStateMixin {
  double _dragOffset = 0;
  double _holdOffset = 0;
  bool _refreshing = false;
  bool _refreshTriggered = false;
  late AnimationController _logoController;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: kDurLogoStrokeDelay + kDurLogoStroke,
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  double get _displayOffset {
    if (_refreshing || _holdOffset > 0) {
      return _holdOffset;
    }
    return _dragOffset.clamp(0, QlypStyle.refreshPull);
  }

  Future<void> _runRefresh() async {
    if (_refreshTriggered || _refreshing) return;
    _refreshTriggered = true;
    setState(() {
      _refreshing = true;
      _holdOffset = QlypStyle.refreshPull;
    });
    if (!QlypMotionAccessibility.reduceMotionOf(context)) {
      await Future<void>.delayed(
        QlypMotionAccessibility.duration(context, kDurRefreshPull),
      );
    }
    _logoController.forward(from: 0);
    await widget.onRefresh();
    if (!mounted) return;
    setState(() {
      _refreshing = false;
      _holdOffset = 0;
      _dragOffset = 0;
    });
    _logoController.reset();
    _refreshTriggered = false;
  }

  bool _handleScroll(ScrollNotification notification) {
    if (_refreshing) return false;
    if (notification is OverscrollNotification &&
        notification.overscroll < 0 &&
        notification.metrics.pixels <= 0) {
      final pull = -notification.overscroll;
      setState(() => _dragOffset = pull);
      if (pull >= QlypStyle.refreshPull && !_refreshTriggered) {
        _runRefresh();
      }
    }
    if (notification is ScrollUpdateNotification &&
        notification.metrics.pixels <= 0) {
      final pull = -notification.metrics.pixels;
      setState(() => _dragOffset = pull);
      if (pull >= QlypStyle.refreshPull && !_refreshTriggered) {
        _runRefresh();
      }
    }
    if (notification is ScrollEndNotification && !_refreshing) {
      if (_dragOffset < QlypStyle.refreshPull) {
        setState(() => _dragOffset = 0);
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScroll,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Transform.translate(
            offset: Offset(0, _displayOffset),
            child: widget.child,
          ),
          if (_displayOffset > 0 || _refreshing)
            Positioned(
              top: 58,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: QlypColors.white,
                    shape: BoxShape.circle,
                    boxShadow: QlypStyle.floatingShadowLight,
                  ),
                  child: AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: _QlypLogoRefreshPainter(
                          progress: _logoController.value,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QlypLogoRefreshPainter extends CustomPainter {
  _QlypLogoRefreshPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const circleRadius = 14.0;
    const strokeWidth = 4.0;

    final totalMs = kDurLogoStrokeDelay.inMilliseconds +
        kDurLogoStroke.inMilliseconds;
    final drawEnd =
        (kDurLogoDraw.inMilliseconds / totalMs).clamp(0.001, 1.0);
    final circleSweep = (progress / drawEnd).clamp(0.0, 1.0);
    final circlePaint = Paint()
      ..color = QlypColors.emerald
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: circleRadius),
      -3.14 / 2,
      3.14 * 2 * circleSweep,
      false,
      circlePaint,
    );

    final strokeStart =
        (kDurLogoStrokeDelay.inMilliseconds / totalMs).clamp(0.0, 1.0);
    if (progress > strokeStart) {
      final local = ((progress - strokeStart) / (1 - strokeStart)).clamp(0.0, 1.0);
      final checkPaint = Paint()
        ..color = QlypColors.midnightQlyp
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      final path = Path()
        ..moveTo(center.dx - 6, center.dy + 1)
        ..lineTo(center.dx - 1, center.dy + 6)
        ..lineTo(center.dx + 8, center.dy - 5);
      final metrics = path.computeMetrics().first;
      final extract = metrics.extractPath(0, metrics.length * local);
      canvas.drawPath(extract, checkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _QlypLogoRefreshPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
