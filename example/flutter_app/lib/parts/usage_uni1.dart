import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';

class ShaderPainterWithUniforms extends CustomPainter {
  ShaderPainterWithUniforms(this.fragmentProgram);

  final FragmentProgram fragmentProgram;
  // #begin
  @override
  void paint(Canvas canvas, Size size) {
    /// Inputs
    Color color1 = Colors.blue;
    Color color2 = Colors.green;
    double someValue = 0.5;

    /// Create paint using a shader
    final paint = Paint()
      ..shader = fragmentProgram.shader(

          /// Specify input parameter (uniforms)
          floatUniforms: Float32List.fromList([
        /// color1 takes 3 floats and will be mapped to `vec3`
        color1.red / 255.0,
        color1.green / 255.0,
        color1.blue / 255.0,

        /// color2 also takes 3 floats and will be mapped to `vec3`
        color2.red / 255.0,
        color2.green / 255.0,
        color2.blue / 255.0,

        /// someValue takes 1 float and will be mapped to `float`
        someValue,

        /// size takes 2 floats and will be mapped to `vec2`
        size.width,
        size.height,
      ]));

    /// Draw a rectangle with the shader-paint
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }
  // #end

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is ShaderPainterWithUniforms &&
        oldDelegate.fragmentProgram == fragmentProgram) {
      /// Do not repaint when painter has same set of properties
      return false;
    }
    return true;
  }
}
