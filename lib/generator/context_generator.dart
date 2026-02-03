import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:bridge_cli/parsers/code_parser.dart';
import 'package:bridge_cli/parsers/dart_parser.dart';
import 'package:bridge_cli/parsers/js_parser.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yaml/yaml.dart';

class ContextGenerator {
  final Map<String, CodeParser> _parsers = {'dart': DartParser(), 'node': JsParser()};
  Future<void> generateContext() async {
    final configFile = File(p.join(Directory.current.path, 'bridge.yaml'));
    if (!configFile.existsSync()) {
      print('\x1B[31m❌ bridge.yaml not found. Please run "bridge init" first.\x1B[0m');
      return;
    }

    print('\x1B[36m🏗️  Building AI Context...\x1B[0m');

    final yamlString = await configFile.readAsString();
    final yamlMap = loadYaml(yamlString);
    final projects = yamlMap['projects'] as List;

    final contextContent = await Stream.fromIterable(projects)
        .doOnData((project) => print('Processing ${project['type']} project at ${project['path']}...'))
        .flatMap((project) {
          final dir = Directory(project['path']);
          final type = project['type'];
          if (!dir.existsSync()) return Stream.empty();
          return dir
              .list(recursive: true)
              .whereType<File>()
              .map((file) => (file: file, type: type as String));
        })
        .where((data) => _shouldParse(data.file.path, data.type))
        .asyncMap((data) async {
          final parser = _parsers[data.type];
          return await parser?.parseFile(data.file);
        })
        .whereType<String>()
        .scan((accumulated, current, index) => '$accumulated\n$current\n---', '# AI Bridge Context\nGenerated at: ${DateTime.now()}\n')
        .last;

    final outputFile = File('.ai-bridge.md');
    await outputFile.writeAsString(contextContent);

    print('\x1B[32m✅ AI Context generated successfully at .ai-bridge.md\x1B[0m');
    print('You can now drag and drop this file into Gemini/ChatGPT!');
  }

  bool _shouldParse(String path, String type) {
    if (path.contains('node_modules') || path.contains('.dart_tool') || path.contains('.git')) return false;
    if (type == 'dart') return path.endsWith('.dart');
    if (type == 'node') return path.endsWith('.js') || path.endsWith('.ts') || path.endsWith('.jsx') || path.endsWith('.tsx');
    return false;
  }
}