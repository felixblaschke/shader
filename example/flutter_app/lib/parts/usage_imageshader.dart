// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  // #begin
  final asset = await rootBundle.load("assets/image.jpg");
  final image = await decodeImageFromList(asset.buffer.asUint8List());

  /// Create ImageShader that will provide a GLSL sampler
  final ImageShader imageShader = ImageShader(
    image,
    // Specify how image repetition is handled for x and y dimension
    TileMode.repeated,
    TileMode.repeated,
    // Transformation matrix (identity matrix = no transformation)
    Matrix4.identity().storage,
  );
  // #end
}
