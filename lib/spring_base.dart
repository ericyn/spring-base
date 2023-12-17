library spring_base;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Adds a spring effect motion to the widget that's passed in [child]
/// when the user taps on it.
///
/// Example usage:
/// ```dart
/// SpringBase(
///   hapticFeedback: true,
///   function: () {
///     print('Hello World!');
///   }
///   child: const Text('A Widget you want to apply the spring effect to'),
/// )
/// ```
class SpringBase extends StatefulWidget {
  /// The value that will determine how much the [child] widget will scale.
  ///
  /// For example, if the [upperBound] is 0.02, the effect will be subtle
  /// but if the [upperBound] is 0.4, the effect will be more noticeable.
  final double upperBound;

  /// Whether the [child] widget will upscale or downscale.
  ///
  /// Defaults to false, because downscaling is more common when it comes to buttons.
  final bool upscale;

  /// The widget that will be wrapped with the spring effect.
  final Widget child;

  /// What will happen when the user taps on the [child] widget.
  final VoidCallback? function;

  /// Whether the [child] widget will have a different
  /// function on long press.
  final bool longPressFunctionality;
  final VoidCallback? longPressFunction;

  /// The duration of the spring effect.
  final Duration scaleDuration;

  /// The curve of the spring effect.
  final Curve curve;

  /// Whether the [child] widget will have a haptic feedback.
  final bool hapticFeedback;

  const SpringBase({
    super.key,
    this.upperBound = 0.02,
    this.upscale = false,
    this.function,
    this.longPressFunctionality = false,
    this.longPressFunction,
    required this.child,
    this.scaleDuration = const Duration(milliseconds: 100),
    this.curve = Curves.elasticOut,
    this.hapticFeedback = false,
  }) : assert(!longPressFunctionality || longPressFunction != null,
            'If you want to use the long press functionality, you must provide a function for it.');

  @override
  State<SpringBase> createState() => _SpringBaseState();
}

class _SpringBaseState extends State<SpringBase>
    with SingleTickerProviderStateMixin {
  /// The scale value that will be used to scale the [child] widget.
  late double _scale;

  /// The [AnimationController] used to create the spring effect.
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: widget.scaleDuration,
      lowerBound: 0.0,
      upperBound: widget.upperBound,
    );

    // Initialize the animation
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: widget.curve,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.hapticFeedback) {
      HapticFeedback.lightImpact();
    }
    _animationController.forward().then((_) {
      _animationController.reverse().then((_) => widget.function);
    });
  }

  void _handleLongPress() {
    if (widget.hapticFeedback) {
      HapticFeedback.mediumImpact();
    }
    _animationController.forward().then((_) {
      _animationController.reverse().then((_) {
        if (widget.longPressFunctionality) {
          widget.longPressFunction?.call();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    /// Set the scale value, based on the animation controller value.
    ///
    /// If [upscale] is true, the scale value will increase, otherwise it will decrease.
    _scale = widget.upscale
        ? 1 + _animationController.value
        : 1 - _animationController.value;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _handleTap,
      onLongPress: widget.longPressFunctionality ? _handleLongPress : null,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) => Transform.scale(
          scale: _scale,
          child: widget.child,
        ),
      ),
    );
  }
}
