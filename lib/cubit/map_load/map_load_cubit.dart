import 'package:image/image.dart' as External;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:voxel_space/data_provider/map/map_repo.dart';
import 'package:equatable/equatable.dart';
part 'map_load_state.dart';

class MapLoadCubit extends Cubit<MapLoadState> {
  final MapRepo mapRepo;
  List<External.Image> textureCache = [];
  List<External.Image> heightCache = [];
  MapLoadCubit({required this.mapRepo}) : super(MapLoadInitState());

  void loadMap() async {
    try {
      emit(MapLoadingState());

      var texture = External.decodeImage(
          (await mapRepo.loadTexture())!.buffer.asUint8List());
      textureCache.add(texture!);
      var height = External.decodeImage(
          (await mapRepo.loadHeight())!.buffer.asUint8List());
      heightCache.add(height!);
      emit(MapLoadedState());
    } on Exception catch (e) {
      emit(MapLoadingFailedState());
    }
  }
}
