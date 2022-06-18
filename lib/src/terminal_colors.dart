void printYellow(String text) {
  print('\x1B[33m$text\x1B[0m');
}

void printRed(String text) {
  print('\x1B[31m$text\x1B[0m');
}

void printGreen(String text) {
  print('\x1B[32m$text\x1B[0m');
}

void printBlue(String text) {
  print('\x1B[34m$text\x1B[0m');
}

String tintYellow(String text) {
  return '\x1B[33m$text\x1B[0m';
}
