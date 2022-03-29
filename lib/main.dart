import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:voxel_space/cubit/map_load/map_load_cubit.dart';
import 'package:voxel_space/data_provider/map/map_app_repo.dart';
import 'package:voxel_space/data_provider/map/map_repo.dart';

import 'screens/hud_screen.dart';

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
