import 'dart:math';

import 'package:flutter/material.dart';

class ForwardControlWidget extends StatefulWidget {
  final AnimationController animationControllerTranslationY;
  final AnimationController animationControllerTranslationX;
  final AnimationController animationControllerAngle;
  const ForwardControlWidget(
      {Key? key,
      required this.animationControllerTranslationY,
      required this.animationControllerTranslationX,
      required this.animationControllerAngle})
      : super(key: key);
  @override
  _ForwardControlWidgetState createState() => _ForwardControlWidgetState();
}

class _ForwardControlWidgetState extends State<ForwardControlWidget> {
  bool _isPressedTranslation = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) async {
        _isPressedTranslation = true;

        do {
          widget.animationControllerTranslationY.value +=
              4 * sin(widget.animationControllerAngle.value);

          if (widget.animationControllerTranslationY.value >= 1024) {
            widget.animationControllerTranslationY.value =
                widget.animationControllerTranslationY.value % 1024;
          } else if (widget.animationControllerTranslationY.value <= 0) {
            widget.animationControllerTranslationY.value = 1024;
          }
          widget.animationControllerTranslationX.value +=
              4 * cos(widget.animationControllerAngle.value);
          if (widget.animationControllerTranslationX.value >= 1024) {
            widget.animationControllerTranslationX.value =
                widget.animationControllerTranslationX.value % 1024;
          } else if (widget.animationControllerTranslationX.value <= 0) {
            widget.animationControllerTranslationX.value = 1024;
          }

          // for testing
          await Future.delayed(Duration(milliseconds: 24));
        } while (_isPressedTranslation);
      },
      onTapUp: (_) => setState(() => _isPressedTranslation = false),
      child: const Icon(
        Icons.arrow_upward,
        size: 40,
        color: Colors.white,
      ),
    );
  }
}

class BackwardControlWidget extends StatefulWidget {
  final AnimationController animationControllerTranslationY;
  final AnimationController animationControllerTranslationX;
  final AnimationController animationControllerAngle;
  const BackwardControlWidget(
      {Key? key,
      required this.animationControllerTranslationY,
      required this.animationControllerTranslationX,
      required this.animationControllerAngle})
      : super(key: key);
  @override
  _BackwardControlWidgetState createState() => _BackwardControlWidgetState();
}

class _BackwardControlWidgetState extends State<BackwardControlWidget> {
  bool _isPressedTranslation = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) async {
        _isPressedTranslation = true;

        do {
          widget.animationControllerTranslationY.value -=
              4 * sin(widget.animationControllerAngle.value);

          if (widget.animationControllerTranslationY.value >= 1024) {
            widget.animationControllerTranslationY.value =
                widget.animationControllerTranslationY.value % 1024;
          } else if (widget.animationControllerTranslationY.value <= 0) {
            widget.animationControllerTranslationY.value = 1024;
          }
          widget.animationControllerTranslationX.value -=
              4 * cos(widget.animationControllerAngle.value);
          if (widget.animationControllerTranslationX.value >= 1024) {
            widget.animationControllerTranslationX.value =
                widget.animationControllerTranslationX.value % 1024;
          } else if (widget.animationControllerTranslationX.value <= 0) {
            widget.animationControllerTranslationX.value = 1024;
          }

          // for testing
          await Future.delayed(Duration(milliseconds: 24));
        } while (_isPressedTranslation);
      },
      onTapUp: (_) => setState(() => _isPressedTranslation = false),
      child: const Icon(
        Icons.arrow_downward,
        size: 40,
        color: Colors.white,
      ),
    );
  }
}

class AltitudeIncreaseWidget extends StatefulWidget {
  final AnimationController animationControllerCameraHeight;

  const AltitudeIncreaseWidget(
      {Key? key, required this.animationControllerCameraHeight})
      : super(key: key);
  @override
  _AltitudeIncreaseWidgetState createState() => _AltitudeIncreaseWidgetState();
}

class _AltitudeIncreaseWidgetState extends State<AltitudeIncreaseWidget> {
  bool _isPressedHeight = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) async {
        _isPressedHeight = true;

        do {
          widget.animationControllerCameraHeight.value += 5;
          // for testing
          await Future.delayed(Duration(milliseconds: 24));
        } while (_isPressedHeight);
      },
      onTapUp: (_) => setState(() => _isPressedHeight = false),
      child: const Icon(
        Icons.arrow_circle_up_rounded,
        size: 40,
        color: Colors.white,
      ),
    );
  }
}

class AltitudeDecreaseWidget extends StatefulWidget {
  final AnimationController animationControllerCameraHeight;

  const AltitudeDecreaseWidget(
      {Key? key, required this.animationControllerCameraHeight})
      : super(key: key);
  @override
  _AltitudeDecreaseWidgetState createState() => _AltitudeDecreaseWidgetState();
}

class _AltitudeDecreaseWidgetState extends State<AltitudeDecreaseWidget> {
  bool _isPressedHeight = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) async {
        _isPressedHeight = true;

        do {
          widget.animationControllerCameraHeight.value -= 5;
          // for testing
          await Future.delayed(Duration(milliseconds: 24));
        } while (_isPressedHeight);
      },
      onTapUp: (_) => setState(() => _isPressedHeight = false),
      child: const Icon(
        Icons.arrow_circle_up_rounded,
        size: 40,
        color: Colors.white,
      ),
    );
  }
}
