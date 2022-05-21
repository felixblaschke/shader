import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shader/shader.dart';

void main() {
  runApp(const MaterialApp(home: ScreenUsingShader()));
}

class ScreenUsingShader extends StatelessWidget {
  const ScreenUsingShader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlslFragmentProgramWebserviceBuilder(
        code: '''
#version 320 es

precision highp float;

layout(location = 0) out vec4 fragColor;

layout(location = 0) uniform float timeElapsed;
layout(location = 1) uniform vec2 size;

void main() {
    float time = fract(timeElapsed);
    vec3 color = vec3(time, gl_FragCoord.xy / size.xy);
    fragColor = vec4(color, 1.0);
}
''',
        builder: (context, shaderProgram) {
          if (shaderProgram == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return RebuildEachFrame(builder: (context) {
            return SizedBox.expand(
              child: CustomPaint(painter: ShaderPainter(shaderProgram)),
            );
          });
        },
      ),
    );
  }
}

/// Will paint an area with our beautiful fragment shader
class ShaderPainter extends CustomPainter {
  final FragmentProgram shaderProgram;

  ShaderPainter(this.shaderProgram);

  @override
  void paint(Canvas canvas, Size size) {
    var time = (DateTime.now().millisecondsSinceEpoch % 3000) / 3000.0;

    final shader = shaderProgram.shader(
      floatUniforms: Float32List.fromList([time, size.width, size.height]),
    );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
