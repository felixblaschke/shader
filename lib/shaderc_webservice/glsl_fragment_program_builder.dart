import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:shader/shaderc_webservice/compile_glsl_fragment_shader.dart';

/// Uses a web service to compile the GLSL shader [code]
/// into SPIR-V bytecode. This widget meant for testing
/// proposes. Don't use it for productive apps.
///
/// Make sure to permit web request on your target platform.
class GlslFragmentProgramBuilder extends StatefulWidget {
  final String code;
  final Widget Function(BuildContext context, FragmentProgram? shaderProgram)
      builder;
  final String shadercWebserviceBaseUrl;

  const GlslFragmentProgramBuilder({
    /// GLSL code
    required this.code,

    /// Builder function with `shaderProgram` parameter being
    /// not null if shader is compiled.
    required this.builder,

    /// Base url of the webservice
    this.shadercWebserviceBaseUrl = "https://shaderc.felix-blaschke.de",
    Key? key,
  }) : super(key: key);

  @override
  State<GlslFragmentProgramBuilder> createState() =>
      _GlslFragmentProgramBuilderState();
}

class _GlslFragmentProgramBuilderState
    extends State<GlslFragmentProgramBuilder> {
  FragmentProgram? shaderProgram;

  @override
  void initState() {
    _compileShader();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant GlslFragmentProgramBuilder oldWidget) {
    if (oldWidget.code != widget.code) {
      _compileShader();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, shaderProgram);
  }

  Future<void> _compileShader() async {
    final byteCode = await compileGlslFragmentShader(
      code: widget.code,
      shadercWebserviceBaseUrl: widget.shadercWebserviceBaseUrl,
    );

    final program = await FragmentProgram.compile(spirv: byteCode.buffer);
    setState(() => shaderProgram = program);
  }
}
