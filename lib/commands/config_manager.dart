import 'dart:io';
import 'package:path/path.dart' as p;

class ConfigManager {
  static const String configFileName = 'bridge.yaml';

  Future<void> createConfig(List<Directory> projects) async {
    final file = File(p.join(Directory.current.path, configFileName));

    String content = 'projects:\n';

    for (var dir in projects) {
      content += '${_generateEntry(dir)}\n';
    }

    return file.writeAsString(content).then((_) {
      print('\x1B[32m✅ Created $configFileName with ${projects.length} project(s)!\x1B[0m');
    });
  }

  String _generateEntry(Directory dir) {
    final relativePath = p.relative(dir.path, from: Directory.current.path);
    final normalizedPath = p.normalize(relativePath).replaceAll(r'\', '/');
    final type = _guessType(dir);
    return '  - path: ./$normalizedPath\n    type: $type\n    name: ${p.basename(dir.path)}';
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
    String finalPathForConfig = relativePath;

    // 🔥 AUTOMATIC SYMLINK MAGIC (Cross-Platform) 🔥
    if (relativePath.startsWith('..')) {
      print('\x1B[36m🔄 External project detected: $relativePath\x1B[0m');

      final linkName = 'link_${p.basename(targetDir.path)}';
      final link = Link(p.join(Directory.current.path, linkName));

      try {
        if (await link.exists()) {
          await link.delete();
        }
        await link.create(targetDir.path);

        // Success! Use the link path
        finalPathForConfig = './$linkName';
        print('\x1B[32m✅ Symlink created: ./$linkName -> ${targetDir.path}\x1B[0m');
      } catch (e) {
        // ⚠️ Windows Specific Error Handling
        if (Platform.isWindows && e.toString().contains('privilege')) {
          print('\x1B[31m⚠️ Windows Permission Error: Cannot create Symlink.\x1B[0m');
          print('\x1B[33m👉 Solution: Run your terminal as "Administrator" or enable "Developer Mode" in Windows Settings.\x1B[0m');
          print('Falling back to direct path (AI might have read-only access).');
        } else {
          print('\x1B[31m⚠️ Failed to create symlink: $e\x1B[0m');
        }
        // Fallback: Just use the original path, don't crash the tool
        finalPathForConfig = relativePath;
      }
    }

    final normalizedPath = p.normalize(finalPathForConfig).replaceAll(r'\', '/');

    final currentContent = await file.readAsString();
    if (currentContent.contains(normalizedPath)) {
      print('\x1B[33m⚠️ Project is already in bridge.yaml\x1B[0m');
      return;
    }

    final entry = '  - path: $normalizedPath\n    type: $type\n    name: ${p.basename(targetDir.path)}\n';

    await file.writeAsString(entry, mode: FileMode.append);
    print('\x1B[32m✅ Linked project: ${p.basename(targetDir.path)}\x1B[0m');
  }

  String _guessType(Directory dir) {
    if (File(p.join(dir.path, 'pubspec.yaml')).existsSync()) return 'dart';
    if (File(p.join(dir.path, 'package.json')).existsSync()) return 'node';
    if (File(p.join(dir.path, 'go.mod')).existsSync()) return 'go';
    if (File(p.join(dir.path, 'requirements.txt')).existsSync()) return 'python';
    return 'unknown';
  }
}
