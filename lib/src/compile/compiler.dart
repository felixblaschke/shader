import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:shader/src/io_utils.dart';
import 'package:shader/src/terminal_colors.dart';

/// Abstract interface for a compiler
abstract class Compiler {
  /// Compiles GLSL code into SPR-V byte code
  Future<Uint8List> compile(String code);
}

/// Implementation for local compilation
class LocalCompiler extends Compiler {
  final String localCompilerPath;
  late String glslcPath;

  LocalCompiler(this.localCompilerPath) {
    _findCompilerExecutable();
  }

  void _findCompilerExecutable() {
    final glslcCandidates = FileSystemEntity.isDirectorySync(localCompilerPath)
        ? Directory(localCompilerPath)
            .listSync(recursive: true)
            .where((entity) => entity.isGlslcExecutable)
            .map((e) => e.path)
            .toList()
        : [if (localCompilerPath.endsWith('glslc')) localCompilerPath];

    if (glslcCandidates.isEmpty) {
      throw _CompileException(
          'Could not find compiler within path: $localCompilerPath');
    } else if (glslcCandidates.length > 1) {
      throw _CompileException(
          'Multiple candidates for glslc found: $glslcCandidates. Please narrow it down more.');
    }

    glslcPath = glslcCandidates[0];
    printBlue('Using compiler: $glslcPath');
  }

  @override
  Future<Uint8List> compile(String code) async {
    final input =
        File('${Directory.systemTemp.path}/input-${code.hashCode}.glsl');
    final output =
        File('${Directory.systemTemp.path}/output-${code.hashCode}.sprv');

    input.deleteIfExistsSync();
    output.deleteIfExistsSync();

    input.writeAsStringSync(code);

    final result = await Process.run(glslcPath, [
      '--target-env=opengl',
      '-fshader-stage=fragment',
      '-o${output.path}',
      input.path,
    ]);

    input.deleteIfExistsSync();

    if (result.exitCode == 0) {
      final bytes = output.readAsBytesSync();
      output.deleteIfExistsSync();
      return bytes;
    } else {
      final error =
          result.stderr.toString().replaceAll(input.path, 'code.glsl');
      throw _CompileException(error);
    }
  }
}

/// Implementation for remote compilation via webservice
class RemoteCompilerWebservice extends Compiler {
  final String remoteCompilerUrl;

  RemoteCompilerWebservice(this.remoteCompilerUrl) {
    printBlue('Using remote-compiler: $remoteCompilerUrl');
  }

  @override
  Future<Uint8List> compile(String code) async {
    final url = Uri.parse('$remoteCompilerUrl/compile');
    final response = await post(url, body: code);

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw ArgumentError(
          'Error compiling shader code via remote compiler webservice.\n${response.body}');
    }
  }
}

/// Exception for compiler related errors
class _CompileException implements Exception {
  final String message;

  _CompileException(this.message);

  @override
  String toString() => message;
}

extension DetectGlslExecutable on FileSystemEntity {
  /// Detects a glslc compiler executable
  bool get isGlslcExecutable {
    if (this is File) {
      final lowercasePath = path.toLowerCase();

      return lowercasePath.endsWith('glslc') ||
          lowercasePath.endsWith('glslc.exe');
    }
    return false;
  }
}
