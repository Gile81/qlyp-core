import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// Lets pinch/pan reach an embedded MapWidget when nested in a ScrollView.
///
/// Without this, the parent scroll view wins the gesture arena and the map
/// feels frozen. Wrap only the map layer; keep overlays as siblings so they
/// stay tappable.
class QlypMapGestureWrapper extends StatelessWidget {
  const QlypMapGestureWrapper({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      behavior: HitTestBehavior.opaque,
      gestures: <Type, GestureRecognizerFactory>{
        EagerGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<EagerGestureRecognizer>(
          EagerGestureRecognizer.new,
          (_) {},
        ),
      },
      child: child,
    );
  }
}