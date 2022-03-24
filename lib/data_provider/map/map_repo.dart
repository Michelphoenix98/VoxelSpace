import 'dart:typed_data';

import 'package:voxel_space/data_provider/core/base_repo.dart';

abstract class MapRepo extends BaseRepository {
  Future<ByteData?> loadTexture();

  Future<ByteData?> loadHeight();
}
