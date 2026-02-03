import 'dart:io';
import 'package:path/path.dart' as p;

class ConfigManager {
  static const String configFileName = 'bridge.yaml';

  Future<void> createConfig(List<Directory> projects) async {
    final file = File(p.join(Directory.current.path, configFileName));

    return Stream.fromIterable(projects).map((dir) => _generateEntry(dir)).fold('projects:', (previous, current) => '$previous\n$current').then((content) => file.writeAsString(content)).then((_) => print('\x1B[32m✅ Created $configFileName successfully!\x1B[0m')).catchError((e) => print('\x1B[31m❌ Error creating config: $e\x1B[0m'));
  }

  Future<void> addProject(String rawPath) async {
    final file = File(p.join(Directory.current.path, configFileName));

    if (!file.existsSync()) {
      await file.writeAsString('projects:\n');
    }

    final targetDir = Directory(rawPath).absolute;

    if (!targetDir.existsSync()) {
      print('\x1B[31m❌ Error: Directory not found at $rawPath\x1B[0m');
      return;
    }

    final type = _guessType(targetDir);
    final relativePath = p.relative(targetDir.path, from: Directory.current.path);
    final normalizedPath = p.normalize(relativePath).replaceAll(r'\', '/');
    final currentContent = await file.readAsString();
    if (currentContent.contains(normalizedPath)) {
      print('\x1B[33m⚠️ Project is already in bridge.yaml\x1B[0m');
      return;
    }

    final entry = '\n  - path: ./$normalizedPath\n    type: $type\n    name: ${p.basename(targetDir.path)}';

    await file.writeAsString(entry, mode: FileMode.append);
    print('\x1B[32m✅ Linked external pr oject: ${p.basename(targetDir.path)}\x1B[0m');
  }

  String _generateEntry(Directory dir) {
    final relativePath = p.relative(dir.path, from: Directory.current.path);
    final normalizedPath = p.normalize(relativePath).replaceAll(r'\', '/');
    final type = _guessType(dir);
    return '  - path: ./$normalizedPath\n    type: $type\n    name: ${p.basename(dir.path)}';
  }

  String _guessType(Directory dir) {
    if (File(p.join(dir.path, 'pubspec.yaml')).existsSync()) return 'dart';
    if (File(p.join(dir.path, 'package.json')).existsSync()) return 'node';
    if (File(p.join(dir.path, 'go.mod')).existsSync()) return 'go';
    if (File(p.join(dir.path, 'requirements.txt')).existsSync()) return 'python';
    return 'unknown';
  }
}