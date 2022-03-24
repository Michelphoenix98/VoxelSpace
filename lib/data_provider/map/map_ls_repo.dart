import 'dart:typed_data';

import 'package:flutter/services.dart';

class MapLSRepo {
  final List<String> _colourMapResourceLinks =
      List.generate(1, (index) => 'assets/colour/C${index + 1}W.png');
  final List<String> _heightMapResourceLinks =
      List.generate(1, (index) => 'assets/height/D${index + 1}.png');

  Future<ByteData?> loadTexture() {
    return rootBundle.load(_colourMapResourceLinks[0]);
  }

  Future<ByteData?> loadHeight() {
    return rootBundle.load(_heightMapResourceLinks[0]);
  }
}
