import 'dart:io';

import 'package:path/path.dart';
import 'package:shader/src/compile/compiler.dart';
import 'package:shader/src/compile/output_writer.dart';
import 'package:shader/src/output_templates.dart';
import 'package:shader/src/terminal_colors.dart';
import 'package:watcher/watcher.dart';

/// Executes the compilation process
Future<void> compile(CompileConfiguration config) async {
  try {
    /// Determine the project directory
    final directory = config.customPath != null
        ? Directory(config.customPath!)
        : Directory.current;

    /// Pick compiler and writer
    Compiler compiler = _pickCompiler(config);
    OutputWriter writer = _pickOutputWriter(config);

    /// General single pass
    for (final file in directory.allGlslFiles) {
      await _compileFile(file, directory, config, compiler, writer);
    }

    /// If file system watching
    if (config.watch) {
      printBlue('Now watching for changes...');
      final watcher = DirectoryWatcher(directory.path);

      /// Infinite loop
      await for (final event in watcher.events) {
        if ([ChangeType.ADD, ChangeType.MODIFY].contains(event.type)) {
          if (event.path.endsWith('.glsl')) {
            final file = File(event.path);
            await _compileFile(file, directory, config, compiler, writer);
          }
        }
      }
    }
  } catch (e) {
    printError(e.toString());
  }
}

/// Returns the correct writer for the given configuration
OutputWriter _pickOutputWriter(CompileConfiguration config) {
  late OutputWriter writer;

  if (config.outputFormat == OutputFormat.sprv) {
    writer = SprvFileWriter();
  }
  if (config.outputFormat == OutputFormat.dart) {
    writer = DartFileWriter();
  }
  return writer;
}

/// Return the correct compiler for the given configuration
Compiler _pickCompiler(CompileConfiguration config) {
  late Compiler compiler;

  if (config.remoteCompilerUrl != null) {
    compiler = RemoteCompilerWebservice(config.remoteCompilerUrl!);
  }

  if (config.localCompilerPath != null) {
    compiler = LocalCompiler(config.localCompilerPath!);
  }
  return compiler;
}

/// Compiles a single file
Future<void> _compileFile(File file, Directory directory,
    CompileConfiguration config, Compiler compiler, OutputWriter writer) async {
  var outputPath = file.absolute.path;

  /// Remove .glsl file extension
  if (outputPath.endsWith('.glsl')) {
    outputPath = (outputPath.split('.')..removeLast()).join('.');
  }

  /// Apply writer's suffix
  outputPath += writer.suffix;

  /// Compute relative path
  var relativeOutputPath = relative(outputPath, from: directory.absolute.path);

  /// Add assets in front of relative path if selected
  if (config.putInAssets) {
    relativeOutputPath = 'assets/$relativeOutputPath';
  }

  try {
    /// Try compile
    final output = await compiler.compile(file.readAsStringSync());

    /// Write to disk
    final outputFile = File('${directory.path}/$relativeOutputPath');
    await writer.write(outputFile, output);

    printGreen(
        'Compiled ${file.path.substring(directory.absolute.path.length + 1)}');
  } catch (e) {
    printRed('Error while compiling: $relativeOutputPath');

    /// Print out .glsl file to easier see the line number with
    /// the error in the output.
    var i = 0;
    file.readAsStringSync().split('\n').forEach(
        (line) => printYellow('${(++i).toString().padLeft(3)}: $line'));
    printRed(e.toString());
  }
}

extension FindGlslFiles on Directory {
  /// Returns recursively all .glsl files
  List<File> get allGlslFiles => listSync(recursive: true)
      .where((entity) => entity is File && entity.path.endsWith('.glsl'))
      .map((e) => e as File)
      .toList();
}

/// Configuration for the compile() method
class CompileConfiguration {
  /// Use remote compiler if set
  final String? remoteCompilerUrl;

  /// Use local compiler if set
  final String? localCompilerPath;

  /// Use a custom project path
  final String? customPath;

  /// Should watch for file system changes?
  final bool watch;

  /// Should put output files into assets directory?
  final bool putInAssets;

  /// Desired output format
  final OutputFormat outputFormat;

  CompileConfiguration({
    this.remoteCompilerUrl,
    this.localCompilerPath,
    this.watch = false,
    this.customPath,
    this.putInAssets = false,
    required this.outputFormat,
  }) : assert((remoteCompilerUrl != null && localCompilerPath == null) ||
            (remoteCompilerUrl == null && localCompilerPath != null));
}

/// Defines the output format for the compilation process
enum OutputFormat {
  /// Create .sprv files
  sprv,

  /// Create .dart files with embedded SPR-V byte code and loader functions
  dart
}
