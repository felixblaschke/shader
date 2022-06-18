import 'package:args/args.dart';
import 'package:shader/src/compile/compile.dart';
import 'package:shader/src/output_templates.dart';

import 'src/constants.dart';

/// Runs the CLI applications
Future<void> runCliApplication(List<String> args) async {
  /// Get configured arguments parser
  final parser = _argumentsParser();

  try {
    final result = parser.parse(args);

    /// Display help
    if (result.wasParsed(argHelp) || result.arguments.isEmpty) {
      printHelp(parser.usage);
    }

    /// Prevent illegal arguments
    else if (result.failedPickingOne(
            argUseRemote, argUseLocal, 'Specify a compiler') ||
        result.failedPickingOne(
            argOutputDart, argOutputSprv, 'Select an output format') ||
        result.failedByIncompatibility(argOutputDart, argAssets) ||
        result.failedByIncompatibility(argUseLocal, argRemoteUrl)) {
      // noop (output already handled by extension method)
    } else {
      /// Valid configuration from here
      String? remoteCompilerUrl;
      String? localCompilerPath;

      /// Remote parsing
      if (result.wasParsed(argUseRemote)) {
        remoteCompilerUrl = result.wasParsed(argRemoteUrl)
            ? result[argRemoteUrl]
            : defaultWebserviceUrl;
      }

      /// Local parsing
      else if (result.wasParsed(argUseLocal)) {
        localCompilerPath = result[argUseLocal];
      }

      /// Delegate to compile function
      compile(
        CompileConfiguration(
          remoteCompilerUrl: remoteCompilerUrl,
          localCompilerPath: localCompilerPath,
          watch: result.wasParsed(argWatch),
          customPath: result.wasParsed(argPath) ? result[argPath] : null,
          putInAssets: result.wasParsed(argAssets),
          outputFormat: result.wasParsed(argOutputDart)
              ? OutputFormat.dart
              : OutputFormat.sprv,
        ),
      );
    }
  } on FormatException catch (e) {
    printError(e.message);
  }
}

/// Creates a parser for the shader cli
ArgParser _argumentsParser() {
  final parser = ArgParser();
  parser.addFlag(
    argUseRemote,
    negatable: false,
    abbr: 'r',
    help: _wrap(
        'Use a remote compiler to compile the local *.glsl files. By default the author\'s hosted one will be used. You change the remote compiler with --$argRemoteUrl'),
  );

  parser.addOption(
    argUseLocal,
    abbr: 'l',
    help: _wrap(
        'Use a local executable of the glslc compiler. Add a path where to find the compiler. It\'s enough to point to a parent directory containing the glslc compiler. You can download the compiler at https://github.com/google/shaderc.'),
  );

  parser.addFlag(
    argOutputDart,
    abbr: 'd',
    negatable: false,
    help: _wrap(
        'Compiles the shader into a .dart file for Flutter that contains the embedded SPR-V byte code along with a loading function.'),
  );

  parser.addFlag(
    argOutputSprv,
    abbr: 's',
    negatable: false,
    help: _wrap(
        'Compiles the shader into a .sprv file with the SPR-V byte code.'),
  );

  parser.addOption(
    argRemoteUrl,
    abbr: 'u',
    help: _wrap(
        'Configures the remote compiler used. You can download the remote compiler webservice at https://github.com/felixblaschke/shaderc_webservice.'),
  );

  parser.addFlag(
    argWatch,
    abbr: 'w',
    negatable: false,
    help: _wrap(
        'Watches for file system changes and automatically recompiles any shader files.'),
  );

  parser.addFlag(
    argAssets,
    abbr: 'a',
    negatable: false,
    help: _wrap(
        'Places the compiled .sprv files into this Flutter project\'s assets directory.'),
  );

  parser.addOption(
    argPath,
    abbr: 'p',
    help: _wrap(
      'Defines the project directory of your Flutter project to scan for files. By default it\'s the current working directory.',
    ),
  );

  parser.addFlag(
    argHelp,
    abbr: 'h',
    negatable: false,
    help: _wrap('Shows this help text.'),
  );

  return parser;
}

extension on ArgResults {
  /// Checks if [aArg] or [bArg] is set, but not both or none.
  bool failedPickingOne(String aArg, String bArg, String message) {
    final a = wasParsed(aArg);
    final b = wasParsed(bArg);
    if ((a && b) || (!a && !b)) {
      printError('$message. Pick either --$aArg or --$bArg.');
      return true;
    }
    return false;
  }

  /// Reports incompatibility of [aArg] and [bArg]
  bool failedByIncompatibility(String aArg, String bArg, [String? message]) {
    final a = wasParsed(aArg);
    final b = wasParsed(bArg);
    if (a && b) {
      printError(
          '${message != null ? '$message. ' : ''}Option --$aArg is incompatible with --$bArg.');
      return true;
    }
    return false;
  }
}

/// Wraps a stream after [charLimit] into multiple lines.
String _wrap(String line, {int charLimit = 60}) {
  final words = line.split(' ');
  final lines = <String>[];
  var currentLine = '';
  for (final word in words) {
    if (currentLine.length + ' '.length + word.length < charLimit) {
      currentLine += currentLine.isEmpty ? word : ' $word';
    } else {
      lines.add(currentLine);
      currentLine = word;
    }
  }
  lines.add(currentLine);

  return lines.join('\n');
}
