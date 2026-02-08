import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:bridge_cli/commands/config_manager.dart';
import 'package:bridge_cli/commands/watcher.dart';
import 'package:bridge_cli/scanner/project_scanner.dart';
import 'package:bridge_cli/generator/context_generator.dart';

void main(List<String> arguments) async {
  final parser = ArgParser();
  parser.addCommand('init');
  parser.addCommand('watch');
  parser.addCommand('add');

  var buildCommand = parser.addCommand("build");
  buildCommand.addOption('focus', abbr: 'f', help: 'Path to the specific file you want full context for.');

  parser.addFlag('help', abbr: 'h', negatable: false);

  ArgResults argResults;
  try {
    argResults = parser.parse(arguments);
  } catch (e) {
    print('Error: $e');
    exit(1);
  }

  if (argResults['help'] as bool) {
    _printUsage();
    return;
  }

  final command = argResults.command;

  switch (command?.name) {
    case 'init':
      await _handleInitCommand(command!.rest);
      break;
    case 'build':
      final focusPath = command?['focus'];
      await _handleBuildCommand(focusPath);
      break;
    case 'watch':
      await _handleWatchCommand();
      break;
    case 'add':
      await _handleAddCommand(command!.rest);
      break;
    default:
      _printUsage();
  }
}

Future<void> _handleInitCommand(List<String> paths) async {
  final configManager = ConfigManager();
  final scanner = ProjectScanner();
  final configFile = File('bridge.yaml');

  if (paths.isEmpty || !configFile.existsSync()) {
    if (paths.isNotEmpty) {
      print('\x1B[36m📦 Initializing local project first...\x1B[0m');
    } else {
      print('\x1B[36m🔍 Bridge CLI: Starting Smart Scan...\x1B[0m');
    }

    try {
      final projects = await scanner.findProjectRoots(Directory.current);
      if (projects.isEmpty) {
        print('\x1B[33m⚠️  No projects found in current directory.\x1B[0m');
        if (!configFile.existsSync()) {
          await configFile.writeAsString('projects:\n');
        }
      } else {
        print('\x1B[32m✅ Found ${projects.length} local project(s).\x1B[0m');
        await configManager.createConfig(projects);
      }
    } catch (e) {
      print('\x1B[31m❌ Error scanning directory: $e\x1B[0m');
    }
  }

  if (paths.isNotEmpty) {
    final targetPath = paths.first;
    print('\x1B[36m🔗 Linking external project: $targetPath...\x1B[0m');
    await configManager.addProject(targetPath);
  } else {
    if (configFile.existsSync()) {
      print('Run "bridge build" to generate AI context.');
    }
  }
}

Future<void> _handleAddCommand(List<String> args) async {
  if (args.isEmpty) {
    print('\x1B[31m❌ Please provide a path. Usage: bridge add <path>\x1B[0m');
    exit(1);
  }

  final targetPath = args.first;
  final configManager = ConfigManager();

  print('\x1B[36m🔗 Linking project: $targetPath...\x1B[0m');
  await configManager.addProject(targetPath);
}

Future<void> _handleBuildCommand(String? focusPath) async {
  final generator = ContextGenerator();
  print(focusPath != null ? '\x1B[36m🎯 Focus Mode Active: Full code for "$focusPath"\x1B[0m' : '\x1B[36m🦴 Skeleton Mode: Generating lightweight context...\x1B[0m');

  await generator.generateContext(focusPath: focusPath);
}

Future<void> _handleWatchCommand() async {
  final watcher = BridgeWatcher();
  await watcher.startWatch();

  await Completer().future;
}

void _printUsage() {
  print('Bridge CLI Tool v1.2.0');
  print('Usage: bridge <command>');
  print('\nCommands:');
  print('  init           Scan and create bridge.yaml');
  print('  add <path>     Link external project');
  print('  build          Generate .ai-bridge.md (Skeleton Mode by default)');
  print('  build -f <path> Focus on a specific file (Full Code Mode)');
  print('  watch          Live sync');
}
