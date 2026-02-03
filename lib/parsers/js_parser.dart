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
    // Find the project root directory to ensure TypeScript is available
    final projectRoot = await _findProjectRoot(file);

    // Create the temporary script file in the project root directory
    final tempFile = File(p.join(projectRoot, 'temp_bridge_js_ast_${DateTime.now().millisecondsSinceEpoch}.cjs'));

    try {
      await tempFile.writeAsString(jsParserScript);

      // Run the node command from the project root directory
      final result = await Process.run('node', [tempFile.path, file.path], workingDirectory: projectRoot);

      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      if (result.exitCode != 0) {
        print('JS Parser error: ${result.stderr}');
        return null;
      }

      final output = result.stdout.toString().trim();
      if (output.isEmpty) {
        print('JS Parser: Empty output');
        return null;
      }

      final List<dynamic> findings = jsonDecode(output);
      if (findings.isNotEmpty) {
        final cleanPath = p.normalize(file.absolute.path);
        final visitor = _JsStructureVisitor();

        // Process the findings through the visitor to build the output
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
      } else {
        print('JS Parser: No findings in output');
      }
      return null;
    } catch (e, stackTrace) {
      print('JS Parser exception: $e');
      print('Stack trace: $stackTrace');
      if (await tempFile.exists()) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }
      return null;
    }
  }

  /// Find the project root directory that contains package.json
  Future<String> _findProjectRoot(File file) async {
    var currentDir = file.parent;
    while (currentDir.path != '/' && currentDir.path != '.') {
      final packageJson = File(p.join(currentDir.path, 'package.json'));
      if (await packageJson.exists()) {
        return currentDir.path;
      }
      currentDir = currentDir.parent;
    }
    // If no package.json found, return the current working directory
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
          // Only add return type annotation if it exists and is not 'void'
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
    // Only add return type annotation if it exists and is not 'void'
    String functionSignature = returnType.isNotEmpty && returnType != 'void' ? '$name$params: $returnType;' : '$name$params;';
    buffer.writeln(functionSignature);
  }

  void visitVariable(Map<String, dynamic> varInfo) {
    String type = varInfo['type'] ?? 'any';
    String name = varInfo['name'] ?? '';
    String varType = varInfo['varType'] ?? 'var'; // let, const, var
    buffer.writeln('$varType $name;');
  }

  void visitApiCall(String description) {
    buffer.writeln(description);
  }
}
