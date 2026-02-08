import 'dart:io';

abstract class CodeParser {
  String get languageId;
  Future<String?> parseFile(File file, {bool isFocused = false});
}
