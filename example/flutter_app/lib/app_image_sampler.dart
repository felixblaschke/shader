import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/shader/image_scale_shader_sprv.dart';

void main() {
  runApp(const MaterialApp(home: Page()));
}

/// Will combine loading multiple things
class PainterNeeds {
  final ImageShader imageShader;
  final FragmentProgram fragmentProgram;

  PainterNeeds(this.imageShader, this.fragmentProgram);
}

/// Loads JPEG image and the [FragmentProgram]
Future<PainterNeeds> loadPainterNeeds() async {
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

  return PainterNeeds(imageShader, await imageScaleShaderFragmentProgram());
}

class Page extends StatelessWidget {
  const Page({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<PainterNeeds>(

          /// Use the generated loader function here
          future: loadPainterNeeds(),
          builder: ((context, snapshot) {
            if (!snapshot.hasData) {
              /// Shader is loading
              return const CircularProgressIndicator();
            }

            /// Shader is ready to use
            return SizedBox.expand(
              child: CustomPaint(
                painter: ImageScaleShaderPainter(snapshot.data!),
              ),
            );
          })),
    );
  }
}

/// Customer painter that makes use of the shader
class ImageScaleShaderPainter extends CustomPainter {
  ImageScaleShaderPainter(this.painterNeeds);

  final PainterNeeds painterNeeds;

  @override
  void paint(Canvas canvas, Size size) {
    /// Create paint using a shader
    final paint = Paint()
      ..shader = painterNeeds.fragmentProgram.shader(
        floatUniforms: Float32List.fromList([
          // scale uniform
          0.1,
        ]),
        samplerUniforms: [
          painterNeeds.imageShader,
        ],
      );

    /// Draw a rectangle with the shader-paint
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is ImageScaleShaderPainter &&
        oldDelegate.painterNeeds == painterNeeds) {
      /// Do not repaint when painter has same set of properties
      return false;
    }
    return true;
  }
}
