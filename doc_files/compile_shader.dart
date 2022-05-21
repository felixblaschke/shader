// ignore_for_file: avoid_unnecessary_containers

import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shader/shader.dart';

void main() {
  runApp(const MaterialApp(home: ScreenUsingShader()));
}

// #begin
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
// #end

class DoSomethingWithShader extends StatelessWidget {
  const DoSomethingWithShader(FragmentProgram shaderProgram, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
