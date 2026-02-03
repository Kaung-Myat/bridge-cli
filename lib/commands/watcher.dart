import 'dart:async';
import 'dart:io';
import 'package:bridge_cli/generator/context_generator.dart';
import 'package:path/path.dart' as p;
import 'package:watcher/watcher.dart';
import 'package:yaml/yaml.dart';

class BridgeWatcher {
  Timer? _debounceTimer;

  Future<void> startWatch() async {
    final configFile = File(p.join(Directory.current.path, 'bridge.yaml'));

    if (!configFile.existsSync()) {
      print('\x1B[31m❌ bridge.yaml not found. Run "bridge init" first.\x1B[0m');
      return;
    }

    print('\x1B[36m👀 Bridge Watcher: Listening for changes...\x1B[0m');

    final yamlString = await configFile.readAsString();
    final yamlMap = loadYaml(yamlString);
    final projects = yamlMap['projects'] as List;

    await _rebuild();

    for (var project in projects) {
      final path = project['path'];
      final watcher = DirectoryWatcher(path);

      print('   -> Watching: $path');

      watcher.events.listen((event) {
        _triggerRebuild();
      });
    }
  }

  void _triggerRebuild() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(Duration(milliseconds: 500), () {
      _rebuild();
    });
  }

  Future<void> _rebuild() async {
    print('\x1B[33m⚡ Changes detected. Rebuilding context...\x1B[0m');
    final generator = ContextGenerator();
    await generator.generateContext();
    print('\x1B[32m✅ Context updated at ${DateTime.now().toIso8601String().split('T')[1].split('.')[0]}\x1B[0m');
  }
}
