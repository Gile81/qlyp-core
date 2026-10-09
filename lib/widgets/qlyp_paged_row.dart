import 'package:flutter/material.dart';

import '../constants/qlyp_colors.dart';
import '../constants/qlyp_motion.dart';
import '../motion/qlyp_motion_accessibility.dart';

/// Ligne paginee : exactement [itemsPerPage] elements visibles (accueil 10C : 3).
class QlypPagedRow extends StatefulWidget {
  const QlypPagedRow({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.itemsPerPage = 3,
    this.pageController,
    this.hint = false,
    this.onPageChanged,
  });

  final int itemCount;
  final int itemsPerPage;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final PageController? pageController;
  final bool hint;
  final ValueChanged<int>? onPageChanged;

  @visibleForTesting
  static double contentWidthForScreen(double screenWidth) {
    return screenWidth - QlypStyle.pagedRowHorizontalInset * 2;
  }

  @visibleForTesting
  static double pageWidthForScreen(double screenWidth) {
    return contentWidthForScreen(screenWidth) + QlypStyle.pagedRowGap;
  }

  @visibleForTesting
  static double itemWidthForScreen(double screenWidth, int itemsPerPage) {
    final content = contentWidthForScreen(screenWidth);
    final gaps = QlypStyle.pagedRowGap * (itemsPerPage - 1);
    return (content - gaps) / itemsPerPage;
  }

  /// Hauteur du conteneur rangée pour une tuile de [itemHeight] sans couper l'ombre.
  static double outerHeightForItemHeight(double itemHeight) {
    return itemHeight +
        QlypStyle.floatingShadowClipTop +
        QlypStyle.floatingShadowClipBottom;
  }

  @override
  State<QlypPagedRow> createState() => _QlypPagedRowState();
}

class _QlypPagedRowState extends State<QlypPagedRow>
    with SingleTickerProviderStateMixin {
  PageController? _ownedController;
  AnimationController? _hintController;
  bool _hintPlayed = false;
  double? _layoutWidth;

  PageController get _controller => widget.pageController ?? _ownedController!;

  int get _pageCount {
    if (widget.itemCount == 0) return 0;
    return (widget.itemCount + widget.itemsPerPage - 1) ~/ widget.itemsPerPage;
  }

  void _ensureController(double width) {
    if (widget.pageController != null) return;
    if (_ownedController != null && _layoutWidth == width) return;
    _ownedController?.dispose();
    _layoutWidth = width;
    final viewportFraction = QlypPagedRow.pageWidthForScreen(width) / width;
    _ownedController = PageController(viewportFraction: viewportFraction);
  }

  @override
  void initState() {
    super.initState();
    if (widget.hint) {
      _hintController = AnimationController(vsync: this, duration: kDurHint);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future<void>.delayed(kDurHintDelay, () {
          if (!mounted || _hintPlayed) return;
          if (QlypMotionAccessibility.reduceMotionOf(context)) return;
          _hintPlayed = true;
          _hintController!.forward(from: 0);
        });
      });
    }
  }

  @override
  void dispose() {
    _ownedController?.dispose();
    _hintController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (!width.isFinite || width <= 0) {
          return const SizedBox.shrink();
        }
        _ensureController(width);
        if (widget.pageController == null && _ownedController == null) {
          return const SizedBox.shrink();
        }

        final itemWidth = QlypPagedRow.itemWidthForScreen(
          width,
          widget.itemsPerPage,
        );

        Widget pageView = PageView.builder(
          controller: _controller,
          itemCount: _pageCount,
          onPageChanged: widget.onPageChanged,
          itemBuilder: (context, pageIndex) {
            return Row(
              children: [
                for (var i = 0; i < widget.itemsPerPage; i++)
                  _buildSlot(pageIndex, i, itemWidth),
              ],
            );
          },
        );

        if (_hintController != null) {
          pageView = AnimatedBuilder(
            animation: CurvedAnimation(
              parent: _hintController!,
              curve: QlypMotionAccessibility.curve(context, kQlypSpring),
            ),
            builder: (context, child) {
              final t = _hintController!.value;
              final dx = t < 0.5
                  ? -QlypStyle.hintOffset * (t * 2)
                  : -QlypStyle.hintOffset * (2 - t * 2);
              return Transform.translate(offset: Offset(dx, 0), child: child);
            },
            child: pageView,
          );
        }

        return SizedBox(
          width: width,
          child: ClipRect(
            child: Padding(
              padding: const EdgeInsets.only(
                top: QlypStyle.floatingShadowClipTop,
                bottom: QlypStyle.floatingShadowClipBottom,
              ),
              child: pageView,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSlot(int pageIndex, int slot, double itemWidth) {
    final index = pageIndex * widget.itemsPerPage + slot;
    if (index >= widget.itemCount) {
      return SizedBox(width: itemWidth);
    }
    return Padding(
      padding: EdgeInsets.only(
        right: slot < widget.itemsPerPage - 1 ? QlypStyle.pagedRowGap : 0,
      ),
      child: SizedBox(
        width: itemWidth,
        child: widget.itemBuilder(context, index),
      ),
    );
  }
}

class QlypPageDots extends StatelessWidget {
  const QlypPageDots({
    super.key,
    required this.pageCount,
    required this.controller,
  });

  final int pageCount;
  final PageController controller;

  @override
  Widget build(BuildContext context) {
    if (pageCount <= 1) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final page = controller.hasClients
            ? (controller.page ?? controller.initialPage.toDouble())
            : 0.0;
        final slide = page.clamp(0.0, (pageCount - 1).toDouble()) *
            QlypStyle.pageDotSlideSpan;
        const trackWidth = QlypStyle.pageDotSize +
            QlypStyle.pageDotSlideSpan +
            QlypStyle.pageDotSize;

        return SizedBox(
          width: trackWidth,
          height: QlypStyle.pageDotActiveHeight,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dot(),
                  SizedBox(width: QlypStyle.pageDotSlideSpan),
                  _dot(),
                ],
              ),
              Positioned(
                left: slide,
                child: Container(
                  width: QlypStyle.pageDotActiveWidth,
                  height: QlypStyle.pageDotActiveHeight,
                  decoration: BoxDecoration(
                    color: QlypColors.midnightQlyp,
                    borderRadius: BorderRadius.circular(
                      QlypStyle.pageDotActiveHeight / 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dot() {
    return Container(
      width: QlypStyle.pageDotSize,
      height: QlypStyle.pageDotSize,
      decoration: const BoxDecoration(
        color: QlypColors.grayDisabled,
        shape: BoxShape.circle,
      ),
    );
  }
}
