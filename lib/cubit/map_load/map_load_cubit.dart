import 'dart:typed_data';
import 'package:image/image.dart' as External;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image/image.dart';
import 'package:voxel_space/data_provider/map/map_repo.dart';
import 'package:equatable/equatable.dart';
part 'map_load_state.dart';

class MapLoadCubit extends Cubit<MapLoadState> {
  final MapRepo mapRepo;

  MapLoadCubit({required this.mapRepo}) : super(MapLoadInitState());

  void loadMap() async {
    try {
      emit(MapLoadingState());
      print((await mapRepo.loadTexture())!.buffer.asByteData().lengthInBytes);
      var colour = External.decodeImage(
          (await mapRepo.loadTexture())!.buffer.asUint8List());
      print(colour);
      var height = External.decodeImage(
          (await mapRepo.loadHeight())!.buffer.asUint8List());
      emit(MapLoadedState(colour: colour!, height: height!));
    } on Exception catch (e) {
      emit(MapLoadingFailedState());
    }
  }
}
