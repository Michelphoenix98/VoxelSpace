import 'dart:typed_data';

import 'package:voxel_space/data_provider/map/map_repo.dart';

import 'map_ls_repo.dart';

class MapAppRepo extends MapRepo {
  final _mapLSRepo = MapLSRepo();

  @override
  Future<ByteData?> loadTexture() {
    return _mapLSRepo.loadTexture();
  }

  @override
  Future<ByteData?> loadHeight() {
    return _mapLSRepo.loadHeight();
  }
}
