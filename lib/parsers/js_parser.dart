import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:bridge_cli/parsers/code_parser.dart';
import 'package:bridge_cli/parsers/generated_js_script.dart';

class JsParser implements CodeParser {
  @override
  String get languageId => 'javascript';

  @override
  Future<String?> parseFile(File file) async {
    final projectRoot = await _findProjectRoot(file);

    final tempFileName = 'temp_bridge_js_ast_${DateTime.now().millisecondsSinceEpoch}.cjs';
    final tempFile = File(p.join(projectRoot, tempFileName));

    try {
      await tempFile.writeAsString(jsParserScript, flush: true);

      // use file.absolute.path so Node knows exactly where to look regardless of workingDirectory.
      final result = await Process.run(
        'node',
        [tempFileName, file.absolute.path], // <--- HERE IS THE FIX
        workingDirectory: projectRoot,
      );

      // Clean up immediately
      if (await tempFile.exists()) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }

      if (result.exitCode != 0) {
        if (result.stderr.toString().contains('MODULE_NOT_FOUND') && result.stderr.toString().contains('typescript')) {
          print('⚠️  Skipping ${p.basename(file.path)}: "typescript" package not found in $projectRoot. Run "npm install typescript"');
          return null;
        }
        print('JS Parser error for ${file.path}: ${result.stderr}');
        return null;
      }

      final output = result.stdout.toString().trim();
      if (output.isEmpty) return null;

      final List<dynamic> findings = jsonDecode(output);
      if (findings.isNotEmpty) {
        final cleanPath = p.normalize(file.absolute.path);
        final visitor = _JsStructureVisitor();

        for (var item in findings) {
          if (item is Map<String, dynamic>) {
            String type = item['type'] ?? 'unknown';
            switch (type) {
              case 'import':
                visitor.visitImport(item['declaration'] ?? '');
                break;
              case 'class':
                visitor.visitClass(item);
                break;
              case 'function':
                visitor.visitFunction(item);
                break;
              case 'variable':
                visitor.visitVariable(item);
                break;
              case 'api_call':
              case 'route_definition':
                visitor.visitApiCall(item['description'] ?? '');
                break;
            }
          }
        }

        if (visitor.buffer.isNotEmpty) {
          return 'File: $cleanPath\n${visitor.buffer.toString()}';
        }
      }
      return null;
    } catch (e) {
      // Clean up in case of crash
      if (await tempFile.exists()) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }
      return null;
    }
  }

  Future<String> _findProjectRoot(File file) async {
    var currentDir = file.parent;
    while (currentDir.path != currentDir.parent.path) {
      final packageJson = File(p.join(currentDir.path, 'package.json'));
      if (await packageJson.exists()) {
        return currentDir.path;
      }
      currentDir = currentDir.parent;
    }
    return Directory.current.path;
  }
}

class _JsStructureVisitor {
  final StringBuffer buffer = StringBuffer();

  void visitImport(String declaration) {
    buffer.writeln(declaration);
  }

  void visitClass(Map<String, dynamic> classInfo) {
    String className = classInfo['name'] ?? 'anonymous';
    String superClass = classInfo['superClass'] != null ? ' extends ${classInfo['superClass']}' : '';
    buffer.write('class $className$superClass {');

    if (classInfo['methods'] != null && classInfo['methods'] is List) {
      for (var method in classInfo['methods']) {
        if (method is Map<String, dynamic>) {
          String methodName = method['name'] ?? '';
          String params = method['params'] ?? '()';
          String returnType = method['returnType'] ?? '';
          String staticModifier = method['isStatic'] == true ? 'static ' : '';
          String methodSignature = returnType.isNotEmpty && returnType != 'void' ? '${staticModifier}function $methodName$params: $returnType;' : '${staticModifier}function $methodName$params;';
          buffer.writeln('\n  $methodSignature');
        }
      }
    }

    if (classInfo['properties'] != null && classInfo['properties'] is List) {
      for (var prop in classInfo['properties']) {
        if (prop is Map<String, dynamic>) {
          String propName = prop['name'] ?? '';
          String type = prop['type'] ?? 'any';
          String staticModifier = prop['isStatic'] == true ? 'static ' : '';
          buffer.writeln('\n  $staticModifier$type $propName;');
        }
      }
    }
    buffer.writeln('\n}');
  }

  void visitFunction(Map<String, dynamic> funcInfo) {
    String returnType = funcInfo['returnType'] ?? 'void';
    String name = funcInfo['name'] ?? '';
    String params = funcInfo['params'] ?? '()';
    String functionSignature = returnType.isNotEmpty && returnType != 'void' ? '$name$params: $returnType;' : '$name$params;';
    buffer.writeln(functionSignature);
  }

  void visitVariable(Map<String, dynamic> varInfo) {
    String type = varInfo['type'] ?? 'any';
    String name = varInfo['name'] ?? '';
    String varType = varInfo['varType'] ?? 'var';
    buffer.writeln('$varType $name;');
  }

  void visitApiCall(String description) {
    buffer.writeln(description);
  }
}
