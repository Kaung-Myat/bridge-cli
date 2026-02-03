import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:rxdart/rxdart.dart';

class ProjectScanner {
  final Map<String, String> markers = {'pubspec.yaml': 'Dart/Flutter', 'package.json': 'Node/JS/TS', 'go.mod': 'Go', 'requirements.txt': 'Python'};

  Future<List<Directory>> findProjectRoots(Directory startDir) {
    return startDir
        .list(recursive: true, followLinks: false)
        .whereType<File>()
        .where((file) => markers.containsKey(p.basename(file.path)))
        .where((file) => !_isInExcludedDirectory(file.path))
        .doOnData((file) {
          final type = markers[p.basename(file.path)];
          print('Found $type at: ${file.parent.path}');
        })
        .map((file) => file.parent)
        .toList();
  }

  bool _isInExcludedDirectory(String filePath) {
    final normalizedPath = p.normalize(filePath);
    final pathSegments = p.split(normalizedPath);
    return pathSegments.any((segment) => segment == 'node_modules' ||
                                   segment == '.git' ||
                                   segment == '.dart_tool' ||
                                   segment == 'build' ||
                                   segment == 'dist' ||
                                   segment == 'target');
  }
}
