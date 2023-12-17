library spring_base;

import 'package:flutter/material.dart';

/// Adds a spring effect motion to the widget that's passed in [child]
/// when the user taps on it.
///
/// ```dart
/// SpringBase(
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
  final Function function;

  /// Whether the [child] widget will have a different
  /// function on long press.
  final bool longPressFunctionality;
  final Function? longPressFunction;

  const SpringBase(
      {super.key,
      this.upperBound = 0.02,
      this.upscale = false,
      required this.function,
      this.longPressFunctionality = false,
      this.longPressFunction,
      required this.child});

  @override
  State<SpringBase> createState() => _SpringBaseState();
}

class _SpringBaseState extends State<SpringBase>
    with SingleTickerProviderStateMixin {
  /// The scale value that will be used to scale the [child] widget.
  late double _scale;

  /// The [AnimationController] used to create the spring effect.
  late AnimationController _animationController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 100,
      ),
      lowerBound: 0.0,
      upperBound: widget.upperBound,
    )..addListener(() {
        setState(() {});
      });

    // Initialize the animation
    animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
      onTap: () {
        _animationController.forward();

        Future.delayed(const Duration(milliseconds: 100), (() {
          _animationController.reverse();
        })).then((value) => {widget.function()});
      },
      onLongPress: () => _animationController.forward(),
      onLongPressEnd: (details) {
        _animationController.reverse().then((value) => {
              widget.longPressFunctionality
                  ? widget.longPressFunction!()
                  : widget.function()
            });
      },
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) => Transform.scale(
          filterQuality: FilterQuality.high,
          scale: _scale,
          child: widget.child,
        ),
      ),
    );
  }
}