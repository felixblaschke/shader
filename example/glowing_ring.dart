import 'dart:math';
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
      body: GlslFragmentProgramBuilder(
        code: '''
#version 320 es
// based on: https://www.shadertoy.com/view/XdlSDs

precision highp float;

layout(location = 0) out vec4 fragColor;

layout(location = 0) uniform float timeElapsed;
layout(location = 1) uniform vec2 size;

void main() {
  vec2 p = (2.0*gl_FragCoord.xy-size.xy)/size.y;
  float tau = 3.1415926535*2.0;
  float a = atan(p.x,p.y);
  float r = length(p)*0.75;
  vec2 uv = vec2(a/tau,r);

  float xCol = (uv.x - (timeElapsed / 3.0)) * 3.0;
  xCol = mod(xCol, 3.0);
  vec3 horColour = vec3(0.25, 0.25, 0.25);

  if (xCol < 1.0) {
    horColour.r += 1.0 - xCol;
    horColour.g += xCol;
  } else if (xCol < 2.0) {
    
    xCol -= 1.0;
    horColour.g += 1.0 - xCol;
    horColour.b += xCol;
  }	else {
    
    xCol -= 2.0;
    horColour.b += 1.0 - xCol;
    horColour.r += xCol;
  }

	uv = (2.0 * uv) - 1.0;
	float beamWidth = (0.7 + 0.5 * cos(uv.x * 10.0 * tau * 0.15 * clamp(floor(5.0 + 10.0 * cos(timeElapsed)), 0.0, 10.0))) * abs(1.0 / (30.0 * uv.y));
	vec3 horBeam = vec3(beamWidth);
	fragColor = vec4(((horBeam) * horColour), 1.0);
}
''',
        builder: (context, shaderProgram) {
          if (shaderProgram == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return RebuildEachFrame(builder: (context) {
            return LayoutBuilder(builder: (context, constraints) {
              return SizedBox.expand(
                child: CustomPaint(
                  painter: ShaderPainter(shaderProgram),
                  child: Center(
                    child: SizedBox(
                        width: constraints.biggest.shortestSide * 0.4,
                        height: constraints.biggest.shortestSide * 0.4,
                        child: const FlutterLogo()),
                  ),
                ),
              );
            });
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
      floatUniforms: Float32List.fromList([
        (0.7 * pi) + (sin(pi * time) * (0.3 * pi)),
        size.width,
        size.height
      ]),
    );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
