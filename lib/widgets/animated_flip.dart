import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// Swaps faces at the edge of a perspective rotation, keeping text readable.
class AnimatedFlip extends StatefulWidget {
  const AnimatedFlip({
    super.key,
    required this.flipped,
    required this.front,
    required this.back,
  });

  final bool flipped;
  final Widget front;
  final Widget back;

  @override
  State<AnimatedFlip> createState() => _AnimatedFlipState();
}

class _AnimatedFlipState extends State<AnimatedFlip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotation;
  bool _disableAnimations = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
      value: widget.flipped ? 1 : 0,
    );
    _rotation = _controller.drive(CurveTween(curve: Curves.easeInOutCubic));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disabled = MediaQuery.disableAnimationsOf(context);
    if (disabled != _disableAnimations) {
      _disableAnimations = disabled;
      _updateTarget();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedFlip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.flipped != widget.flipped) _updateTarget();
  }

  void _updateTarget() {
    if (_disableAnimations) {
      _controller.value = widget.flipped ? 1 : 0;
    } else if (widget.flipped) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_disableAnimations) return widget.flipped ? widget.back : widget.front;
    return AnimatedBuilder(
      animation: _rotation,
      builder: (context, _) {
        final angle = _rotation.value * math.pi;
        final showBack = angle >= math.pi / 2;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, .0015)
            ..rotateY(showBack ? angle - math.pi : angle),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: KeyedSubtree(
              key: ValueKey(showBack),
              child: showBack ? widget.back : widget.front,
            ),
          ),
        );
      },
    );
  }
}
