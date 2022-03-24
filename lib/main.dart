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

void main() {
  runApp(const VoxelSpaceFlutterApp());
}

class VoxelSpaceFlutterApp extends StatelessWidget {
  const VoxelSpaceFlutterApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Voxel Space Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RepositoryProvider<MapRepo>(
          create: (_) => MapAppRepo(),
          child: Builder(builder: (context) {
            return BlocProvider(
                create: (_) => MapLoadCubit(
                    mapRepo: RepositoryProvider.of<MapRepo>(context))
                  ..loadMap(),
                child: const HUDScreen(title: 'Voxel Space Engine'));
          })),
    );
  }
}

class HUDScreen extends StatefulWidget {
  const HUDScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HUDScreen> createState() => _HUDScreenState();
}

class RenderFrame extends CustomPainter {
  final External.Image textureMap;
  final External.Image heightMap;
  final Offset point; //view position
  final double viewAngle; //typically 90 degrees or pi/2
  final double cameraHeight; //the height of the observer
  final double horizon; // looking up and down
  final double scaleFactor;
  final double distance;
  final double widthFactor;
  RenderFrame({
    required this.textureMap,
    required this.heightMap,
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
    int sx = 0;
    //print(size.width);
    for (double angle = -0.5; angle < widthFactor; angle += 0.0035) {
      int maxScreenHeight =
          size.width.toInt(); //MediaQuery.of(context).size.height.toInt();
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
    return true;
  }
}

class _HUDScreenState extends State<HUDScreen> {
  double px = 800, py = 600, pd = 2.9;
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                child: CustomPaint(
                  painter: RenderFrame(
                    point: Offset(550, 300),
                    viewAngle: pd,
                    cameraHeight: 100,
                    horizon: 120,
                    scaleFactor: 240,
                    widthFactor: 3,
                    distance: 600,
                    textureMap: state.colour,
                    heightMap: state.height,
                  ),
                  size: MediaQuery.of(context).size,
                ));
          }
          return const CircularProgressIndicator();
        })
        // This trailing comma makes auto-formatting nicer for build methods.
        );
  }

  Future<Uint8List> _processImage(External.Image offscreen) async {
    return Uint8List.fromList(External.encodePng(offscreen));
  }
}
