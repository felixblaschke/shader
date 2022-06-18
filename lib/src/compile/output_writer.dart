import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart';
import 'package:shader/src/constants.dart';
import 'package:stringr/stringr.dart';

/// Abstract interface for the output format
abstract class OutputWriter {
  String get suffix;

  Future<void> write(File outputFile, Uint8List data);
}

/// Writer for SPR-V binary file
class SprvFileWriter extends OutputWriter {
  @override
  String get suffix => '.sprv';

  @override
  Future<void> write(File outputFile, Uint8List data) async {
    outputFile.createSync(recursive: true);
    outputFile.writeAsBytesSync(data);
  }
}

/// Writer for Dart output format
class DartFileWriter extends OutputWriter {
  @override
  String get suffix => '_sprv.dart';

  @override
  Future<void> write(File outputFile, Uint8List data) async {
    outputFile = File(outputFile.path.replaceAll('-', '_'));

    outputFile.createSync(recursive: true);

    var name = basename(outputFile.path);
    name = name.substring(0, name.length - suffix.length);
    name = name.latinize().camelCase();

    final bytesAsInts = data.map((byte) => byte.toString()).join(',');
    outputFile.writeAsStringSync('''
/// AUTOGENERATED - DO NOT MODIFY
/// 
/// This file was generated with https://pub.dev/packages/shader
/// using `--$argOutputDart` flag.

import 'dart:typed_data';
import 'dart:ui';

/// Compiles the shader $name into a usable [FragmentProgram].
Future<FragmentProgram> ${name}FragmentProgram() => 
FragmentProgram.compile(spirv: Uint8List.fromList(${name}Bytes).buffer);

/// Bytes of the compiled shader ($name) in SPR-V format 
const ${name}Bytes = [$bytesAsInts];
''');
    Process.runSync('dart', ['format', outputFile.path]);
  }
}
