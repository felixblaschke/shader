// ignore_for_file: unused_local_variable

import 'dart:ui';

class SomePainter {
  SomePainter(this.fragmentProgram, this.imageShader);

  final FragmentProgram fragmentProgram;
  final ImageShader imageShader;

  void paint(Canvas canvas, Size size) {
    // #begin
    final paint = Paint()
      ..shader = fragmentProgram.shader(
        samplerUniforms: [
          imageShader,
        ],
      );
    // #end
  }
}
