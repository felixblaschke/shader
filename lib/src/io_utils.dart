import 'dart:io';

extension DeleteIfExistsFile on File {
  void deleteIfExistsSync() {
    if (existsSync()) {
      deleteSync();
    }
  }
}
