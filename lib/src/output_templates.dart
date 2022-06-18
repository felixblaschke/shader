import 'package:shader/src/constants.dart';
import 'package:shader/src/terminal_colors.dart';

void printHelp(String usage) {
  printBlue(''' 
     _               _ 
 ___| |__   __ _  __| | ___ _ __
/ __| '_ \\ / _` |/ _` |/ _ \\ '__|
\\__ \\ | | | (_| | (_| |  __/ |
|___/_| |_|\\__,_|\\__,_|\\___|_|
  ''');
  print('''

// compiles your GLSL shader files into SPIR-V format //


Examples:

| > ${tintYellow('$appExcutable --$argUseRemote --$argOutputDart')}
|
| Compile your .glsl shaders into directly usable dart code.

| > ${tintYellow('$appExcutable --$argUseLocal /path/to/shaderc --$argOutputSprv')}
|
| Use local compiler to compile .glsl shaders into .sprv byte code files.

| > ${tintYellow('$appExcutable --$argUseRemote --$argOutputDart --watch')}
|
| Use file system watcher to continuously recompile your shaders.


${tintYellow('Discover all your options:')}
$usage

Updates and more information: $packageUrl
''');
}

void printError(String message) {
  printRed('shader failed: $message');
  print('If you need help run: $appExcutable --$argHelp');
}
