import 'dart:ui';

import 'package:flutter/material.dart';

/// Import file generated by cli
import 'package:flutter_app/shader/red_shader_sprv.dart';

void main() {
  runApp(const MaterialApp(home: Page()));
}

class Page extends StatelessWidget {
  const Page({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<FragmentProgram>(

          /// Use the generated loader function here
          future: redShaderFragmentProgram(),
          builder: ((context, snapshot) {
            if (!snapshot.hasData) {
              /// Shader is loading
              return const CircularProgressIndicator();
            }

            /// Shader is ready to use
            return SizedBox.expand(
              child: CustomPaint(
                painter: RedShaderPainter(snapshot.data!),
              ),
            );
          })),
    );
  }
}

/// Customer painter that makes use of the shader
class RedShaderPainter extends CustomPainter {
  RedShaderPainter(this.fragmentProgram);

  final FragmentProgram fragmentProgram;

  @override
  void paint(Canvas canvas, Size size) {
    /// Create paint using a shader
    final paint = Paint()..shader = fragmentProgram.shader();

    /// Draw a rectangle with the shader-paint
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is RedShaderPainter &&
        oldDelegate.fragmentProgram == fragmentProgram) {
      /// Do not repaint when painter has same set of properties
      return false;
    }
    return true;
  }
}
