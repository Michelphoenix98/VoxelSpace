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

class _HUDScreenState extends State<HUDScreen> {
  double px = 100, py = 25, pd = 2.6;
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
    return Scaffold(body:
            BlocBuilder<MapLoadCubit, MapLoadState>(builder: (context, state) {
      if (state is MapLoadedState) {
        print('hello!');
        External.Image offscreen = External.Image.rgb(
            MediaQuery.of(context).size.width.toInt(),
            MediaQuery.of(context).size.height.toInt());

        int sx = 0;

        for (double angle = -0.5; angle < 3; angle += 0.0035) {
          int maxScreenHeight = MediaQuery.of(context).size.height.toInt();
          double s = cos(pd + angle);
          double c = sin(pd + angle);
          for (int depth = 10; depth < 1000; depth += 1) {
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
            double sy = 50 * (100 - height) / depth;
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
        }
        return GestureDetector(
          onPanUpdate: (details) {
            if (details.delta.dx > 0)
              pd += 0.1;
            else
              pd -= 0.1;

            setState(() {});
          },
          child: FutureBuilder(
            future: _processImage(offscreen),
            builder: (_, AsyncSnapshot<Uint8List> snapshot) {
              return snapshot.hasData
                  ? Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: Image.memory(
                        snapshot.data!,
                      ).image)),
                    )
                  : CircularProgressIndicator();
            },
          ),
        );
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
