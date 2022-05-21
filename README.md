<!-- This file uses generated code. Visit https://pub.dev/packages/readme_helper for usage information. -->
# shader

Adds remote compilation to your Flutter application to test fragment shaders.

![flutter logo with glowing ring](https://github.com/felixblaschke/shader/raw/main/doc_files/ring.gif)

By default it uses a server hosted by me. But you can also setup a compilation webservice yourself: [https://github.com/felixblaschke/shaderc_webservice](https://github.com/felixblaschke/shaderc_webservice)

<!-- #toc -->
## Table of Contents

[**Usage**](#usage)
  - [Quick example](#quick-example)
  - [Full application example](#full-application-example)
  - [Glowing ring](#glowing-ring)

[**Other resources**](#other-resources)
<!-- // end of #toc -->

## Usage

Use the `GlslFragmentProgramWebserviceBuilder` widget to get your shader compiled.

**Note:** *Keep in mind that this widget uses a webservice to compile the GLSL code on-demand and therefore shouldn't be used for serious production apps.*

### Quick example

<!-- #code doc_files/compile_shader.dart -->
```dart
class ScreenUsingShader extends StatelessWidget {
  const ScreenUsingShader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: GlslFragmentProgramWebserviceBuilder(
          // GLSL shader code
          code: '''
#version 320 es

precision highp float;

layout(location = 0) out vec4 fragColor;

void main() {
    fragColor = vec4(1.0, 0.0, 0.0, 1.0);
}
''',
          builder: (context, shaderProgram) {
            if (shaderProgram == null) {
              // shader is compiling
              return const CircularProgressIndicator();
            }
            // shader is reader to use
            return DoSomethingWithShader(shaderProgram);
          },
        ),
      ),
    );
  }
}
```
<!-- // end of #code -->

### Full application example

<!-- #code example/example.dart -->
```dart
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
```
<!-- // end of #code -->


### Glowing ring

Based on [https://www.shadertoy.com/view/XdlSDs](https://www.shadertoy.com/view/XdlSDs):

<!-- #code example/glowing_ring.dart -->
```dart
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
      body: GlslFragmentProgramWebserviceBuilder(
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
```
<!-- // end of #code -->





## Other resources

- https://github.com/flutter/engine/tree/master/lib/spirv
- https://wolfenrain.medium.com/flutter-shaders-an-initial-look-d9eb98d3fd7a