import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image/image.dart' as External;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:voxel_space/cubit/map_load/map_load_cubit.dart';
import 'package:voxel_space/data_provider/map/map_app_repo.dart';
import 'package:voxel_space/data_provider/map/map_repo.dart';
import 'package:voxel_space/widgets/joystick_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Voxel Space Flutter App',
    home: VoxelSpaceFlutterApp(),
  ));
}

class VoxelSpaceFlutterApp extends StatelessWidget {
  const VoxelSpaceFlutterApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<MapRepo>(
        create: (_) => MapAppRepo(),
        child: Scaffold(
          backgroundColor: Colors.lightBlue,
          body: Builder(builder: (context) {
            return BlocProvider(
                create: (_) => MapLoadCubit(
                    mapRepo: RepositoryProvider.of<MapRepo>(context))
                  ..loadMap(),
                child: const HUDScreen(title: 'Voxel Space Engine'));
          }),
        ));
  }
}

class HUDScreen extends StatefulWidget {
  const HUDScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HUDScreen> createState() => _HUDScreenState();
}

class _HUDScreenState extends State<HUDScreen> with TickerProviderStateMixin {
  late AnimationController animationControllerPd;
  late AnimationController animationControllerHorizon;
  late AnimationController animationControllerTranslationY;
  late AnimationController animationControllerTranslationX;
  late AnimationController animationControllerCameraHeight;
  bool _isPressed = true;
  @override
  void initState() {
    super.initState();
    super.initState();
    animationControllerPd = AnimationController(
      vsync: this,
      lowerBound: 0,
      upperBound: 6.28,
      duration: const Duration(milliseconds: 5000),
    );
    animationControllerHorizon = AnimationController(
      vsync: this,
      lowerBound: -120,
      upperBound: 180,
      duration: const Duration(milliseconds: 5000),
    );
    animationControllerTranslationY = AnimationController(
      vsync: this,
      lowerBound: 0,
      upperBound: 1024,
      duration: const Duration(milliseconds: 5000),
    );
    animationControllerTranslationX = AnimationController(
      vsync: this,
      lowerBound: 0,
      upperBound: 1024,
      duration: const Duration(milliseconds: 5000),
    );
    animationControllerCameraHeight = AnimationController(
      vsync: this,
      lowerBound: 0,
      upperBound: 600,
      duration: const Duration(milliseconds: 5000),
    );
    animationControllerPd.value = 2.9;
    animationControllerHorizon.value = 120;
    animationControllerTranslationY.value = 500;
    animationControllerTranslationX.value = 800;
    animationControllerCameraHeight.value = 200;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    animationControllerPd.value += details.delta.dx / 400;
    if (animationControllerPd.value >= 6.28) {
      animationControllerPd.value %= 6.28;
    } else if (animationControllerPd.value <= 0) {
      animationControllerPd.value = 6.28;
    }

    animationControllerHorizon.value -= details.delta.dy;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onPanUpdate: _onPanUpdate,
          child: Frame(
            animationControllerCameraHeight: animationControllerCameraHeight,
            animationControllerTranslationY: animationControllerTranslationY,
            animationControllerAngle: animationControllerPd,
            animationControllerHorizon: animationControllerHorizon,
            animationControllerTranslationX: animationControllerTranslationX,
          ),
        ),
        Positioned(
          bottom: 100,
          left: 20,
          child: GestureDetector(
            onTapDown: (_) async {
              _isPressed = true;

              do {
                animationControllerTranslationY.value +=
                    4 * sin(animationControllerPd.value);
                animationControllerTranslationX.value +=
                    4 * cos(animationControllerPd.value);
                // for testing
                await Future.delayed(Duration(milliseconds: 24));
              } while (_isPressed);

              /*  animationControllerCameraHeight.value -=
                  10 * cos(animationControllerHorizon.value);
              print('camera height:${animationControllerCameraHeight.value}');*/
            },
            onTapUp: (_) => setState(() => _isPressed = false),
            child: const Icon(
              Icons.arrow_upward,
              size: 40,
              color: Colors.white,
            ),
          ),
        ),
        Positioned(
          bottom: 50,
          left: 20,
          child: GestureDetector(
            onTapDown: (_) async {
              _isPressed = true;

              do {
                animationControllerTranslationY.value -=
                    4 * sin(animationControllerPd.value);
                animationControllerTranslationX.value -=
                    4 * cos(animationControllerPd.value);
                // for testing
                await Future.delayed(Duration(milliseconds: 24));
              } while (_isPressed);

              /*  animationControllerCameraHeight.value -=
                  10 * cos(animationControllerHorizon.value);
              print('camera height:${animationControllerCameraHeight.value}');*/
            },
            onTapUp: (_) => setState(() => _isPressed = false),
            child: const Icon(
              Icons.arrow_downward,
              size: 40,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
    /*return Scaffold(
        backgroundColor: Colors.lightBlue,
        body:
            BlocBuilder<MapLoadCubit, MapLoadState>(builder: (context, state) {
          if (state is MapLoadedState) {
            /*  External.Image offscreen = External.Image.rgb(
            MediaQuery.of(context).size.width.toInt(),
            MediaQuery.of(context).size.height.toInt());

        int sx = 0;

        for (double angle = -0.5; angle < 3; angle += 0.0035) {
          int maxScreenHeight = MediaQuery.of(context).size.height.toInt();
          double s = cos(pd + angle);
          double c = sin(pd + angle);
          for (int depth = 10; depth < 600; depth += 1) {
            int hmx = (px + depth * s).toInt();
            int hmy = (py + depth * c).toInt();
            if (hmx < 0 ||
                hmy < 0 ||
                hmx > state.height.width - 1 ||
                hmy > state.height.height - 1) {
              continue;
            }
            int height = state.height.getPixel(hmx, hmy) & 255;
            int color = state.colour.getPixel(hmx, hmy);
            double sy = 240 * (300 - height) / depth;
            if (sy > maxScreenHeight) {
              continue;
            }
            for (int y = sy.toInt(); y <= maxScreenHeight; y++) {
              if (y < 0 ||
                  sx > offscreen.width - 1 ||
                  y > offscreen.height - 1) {
                continue;
              }
              offscreen.setPixel(sx, y, color);
            }
            maxScreenHeight = sy.toInt();
          }
          sx++;
        }*/
            return GestureDetector(
                onPanUpdate: (details) {
                  if (details.delta.dx > 0)
                    pd += 0.01;
                  else
                    pd -= 0.01;
                  // print('swiped!');

                  setState(() {});
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: CustomPaint(
                      painter: RenderFrame(
                        point: Offset(800, 500),
                        viewAngle: pd,
                        cameraHeight: 100,
                        horizon: 120,
                        scaleFactor: 240,
                        widthFactor: 3,
                        distance: 600,
                        textureMap: state.colour,
                        heightMap: state.height,
                      ),
                      size: Size(400, 300),
                    ),
                  ),
                ));
          }
          return const CircularProgressIndicator();
        })
        // This trailing comma makes auto-formatting nicer for build methods.
        );*/
  }
}

class Frame extends StatelessWidget {
  const Frame(
      {Key? key,
      required this.animationControllerAngle,
      required this.animationControllerHorizon,
      required this.animationControllerTranslationY,
      required this.animationControllerTranslationX,
      required this.animationControllerCameraHeight})
      : super(key: key);

  final AnimationController animationControllerAngle;
  final AnimationController animationControllerHorizon;
  final AnimationController animationControllerTranslationY;
  final AnimationController animationControllerTranslationX;
  final AnimationController animationControllerCameraHeight;
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
                    distance: 600,
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
        if (hmx < 0 ||
            hmy < 0 ||
            hmx > mapLoadCubit.heightCache![0].width - 1 ||
            hmy > mapLoadCubit.heightCache![0].height - 1) {
          continue;
        }
        int height = mapLoadCubit.heightCache![0].getPixel(hmx, hmy) & 255;
        int color = mapLoadCubit.textureCache![0].getPixel(hmx, hmy);

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
    /*int sx = 0;
    //print(size.width);
    for (double angle = -0.5; angle < widthFactor; angle += 0.0035) {
      int maxScreenHeight =
          size.height.toInt(); //MediaQuery.of(context).size.height.toInt();
      double s = cos(viewAngle + angle);
      double c = sin(viewAngle + angle);
      for (int depth = 10; depth < distance; depth += 1) {
        int hmx = (point.dx + depth * s).toInt();
        int hmy = (point.dy + depth * c).toInt();
        if (hmx < 0 ||
            hmy < 0 ||
            hmx > heightMap.width - 1 ||
            hmy > heightMap.height - 1) {
          continue;
        }

        int height = heightMap.getPixel(hmx, hmy) & 255;
        int color = textureMap.getPixel(hmx, hmy);
        double sy = scaleFactor * (cameraHeight - height) / depth + horizon;
        var tempVerticalLinePoints = <Offset>[];
        if (sy > maxScreenHeight) {
          continue;
        }
        //out of bounds checking
        for (int y = sy.toInt(); y <= maxScreenHeight; y++) {
          if (y < 0 || sx > size.width - 1 || y > size.height - 1) {
            continue;
          }
          // print('in here! ${sx.toDouble()} ${y.toDouble()}');

          tempVerticalLinePoints.add(Offset(sx.toDouble(), y.toDouble()));
          //offscreen.setPixel(sx, y, color);
        }
        canvas.drawPoints(
            ui.PointMode.polygon,
            tempVerticalLinePoints,
            new Paint()
              ..color = Color(abgrToArgb(color))
              ..strokeWidth = 1);
        /* canvas.drawLine(
            Offset(100, 100),
            Offset(100, 100),
            new Paint()
              ..color = Colors.red
              ..strokeWidth = 10);*/
        maxScreenHeight = sy.toInt();
      }
      sx++;
    }
    */
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
