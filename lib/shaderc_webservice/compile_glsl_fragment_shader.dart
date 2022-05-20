import 'package:http/http.dart' as http;

import 'dart:typed_data';

Future<Uint8List> compileGlslFragmentShader({
  required String shadercWebserviceBaseUrl,
  required String code,
}) async {
  final url = Uri.parse('$shadercWebserviceBaseUrl/compile');
  final response = await http.post(url, body: code);

  if (response.statusCode == 200) {
    return response.bodyBytes;
  } else {
    throw ArgumentError(
        'Error compiling shader code via shaderc_webservice.\n${response.body}');
  }
}
