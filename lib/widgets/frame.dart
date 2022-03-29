import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voxel_space/cubit/map_load/map_load_cubit.dart';

import 'dart:math';
import 'dart:ui' as ui;
class Frame extends StatelessWidget {
  const Frame(
      {Key? key,
        required this.animationControllerAngle,
        required this.animationControllerHorizon,
        required this.animationControllerTranslationY,
        required this.animationControllerTranslationX,
        required this.animationControllerCameraHeight,
        required this.distance})
      : super(key: key);

  final AnimationController animationControllerAngle;
  final AnimationController animationControllerHorizon;
  final AnimationController animationControllerTranslationY;
  final AnimationController animationControllerTranslationX;
  final AnimationController animationControllerCameraHeight;
  final double distance;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapLoadCubit, MapLoadState>(builder: (context, state) {
      if (state is MapLoadedState) {
        return AnimatedBuilder(
          animation: Listenable.merge([
            animationControllerAngle,
            animationControllerHorizon,
            animationControllerTranslationY,
            animationControllerTranslationX,
            animationControllerCameraHeight
          ]),
          builder: (context, child) {
            return SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: FittedBox(
                fit: BoxFit.cover,
                child: CustomPaint(
                  key: GlobalKey(),
                  painter: RenderFrame(
                    mapLoadCubit: BlocProvider.of<MapLoadCubit>(context),
                    viewAngle: animationControllerAngle.value,
                    point: Offset(animationControllerTranslationX.value,
                        animationControllerTranslationY.value),
                    // viewAngle: pd,
                    cameraHeight: animationControllerCameraHeight.value,
                    horizon: animationControllerHorizon.value,
                    scaleFactor: 180,
                    widthFactor: 3,
                    distance: distance,
                  ),
                  size: const Size(300, 200),
                ),
              ),
            );
          },
        );
      }
      return const Center(child: CircularProgressIndicator());
    });
  }
}
class RenderFrame extends CustomPainter {
  final MapLoadCubit mapLoadCubit;
  final Offset point; //view position
  final double viewAngle; //typically 90 degrees or pi/2
  final double cameraHeight; //the height of the observer
  final double horizon; // looking up and down
  final double scaleFactor;
  final double distance;
  final double widthFactor;
  RenderFrame({
    required this.mapLoadCubit,
    required this.point,
    required this.viewAngle,
    required this.cameraHeight,
    required this.horizon,
    required this.scaleFactor,
    required this.distance,
    required this.widthFactor,
  });
  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    double sx = 0;
    for (double angle = -0.5; angle < widthFactor; angle += 0.0035) {
      double maxScreenHeight = size.height;
      double s = cos(viewAngle + angle);
      double c = sin(viewAngle + angle);
      for (double depth = 10; depth < distance; depth += 3) {
        int hmx = (point.dx + depth * s).toInt();
        int hmy = (point.dy + depth * c).toInt();

        if (hmx < 0) hmx = (mapLoadCubit.heightCache[0].width - 1) + hmx;

        if (hmy < 0) hmy = (mapLoadCubit.heightCache[0].height - 1) + hmy;

        if (hmx > (mapLoadCubit.heightCache[0].width - 1))
          hmx = hmx % (mapLoadCubit.heightCache[0].width - 1);
        if (hmy > (mapLoadCubit.heightCache[0].height - 1))
          hmy = hmy % (mapLoadCubit.heightCache[0].height - 1);

        int height = mapLoadCubit.heightCache[0].getPixel(hmx, hmy) & 255;
        int color = mapLoadCubit.textureCache[0].getPixel(hmx, hmy);

        // draw 3D vertical terrain line / circular projection
        double sy = scaleFactor * (cameraHeight - height) / depth + horizon;
        if (sy > maxScreenHeight) {
          continue;
        }
        if (sx > size.width - 1) continue;
        double yStart = max(sy, 0);
        double yEnd = min(maxScreenHeight, size.height);
        canvas.drawLine(
            Offset(sx, yStart - 1),
            Offset(sx, yEnd + 1),
            Paint()
              ..color = Color(abgrToArgb(color))
              ..strokeWidth = 1.5);
        maxScreenHeight = sy;
      }
      sx += 1;
    }
  }

  int addFog(int color, int depth) {
    int r = (color >> 16) & 255;
    int g = (color >> 8) & 255;
    int b = color & 255;
    double p = depth > 100 ? (depth - 100) / 500.0 : 0;
    r = (r + (Colors.lightBlue.red - r) * p).toInt();
    g = (g + (Colors.lightBlue.green - g) * p).toInt();
    b = (b + (Colors.lightBlue.blue - b) * p).toInt();
    return (r << 16) + (g << 8) + b;
  }

  int abgrToArgb(int argbColor) {
    //print("abgrToArgb");
    int r = (argbColor >> 16) & 0xFF;
    int b = argbColor & 0xFF;
    return (argbColor & 0xFF00FF00) | (b << 16) | r;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}