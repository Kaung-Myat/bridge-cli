import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:bridge_cli/parsers/code_parser.dart';

class DartParser implements CodeParser {
  @override
  String get languageId => 'dart';

  @override
  Future<String?> parseFile(File file) async {
    try {
      final content = await file.readAsString();
      final result = parseString(content: content);

      final visitor = _UniversalVisitor();
      result.unit.visitChildren(visitor);

      if (visitor.buffer.isNotEmpty) {
        final cleanPath = p.normalize(file.absolute.path);
        return 'File: $cleanPath\n${visitor.buffer.toString()}';
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}

class _UniversalVisitor extends GeneralizingAstVisitor<void> {
  final StringBuffer buffer = StringBuffer();

  @override
  void visitImportDirective(ImportDirective node) {
    buffer.writeln(node.toSource());
  }

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    buffer.write('class ${node.name.lexeme}');

    if (node.extendsClause != null) {
      buffer.write(' ${node.extendsClause!.toSource()}');
    }
    if (node.implementsClause != null) {
      buffer.write(' ${node.implementsClause!.toSource()}');
    }
    buffer.writeln(' {');

    for (var member in node.members) {
      if (member is MethodDeclaration) {
        if (!member.name.lexeme.startsWith('_')) {
          String returnType = member.returnType?.toSource() ?? 'dynamic';
          String name = member.name.lexeme;
          String params = member.parameters?.toSource() ?? '()';
          buffer.writeln('  $returnType $name$params;');
        }
      } else if (member is FieldDeclaration) {
        if (!member.fields.variables.first.name.lexeme.startsWith('_')) {
          String type = member.fields.type?.toSource() ?? 'var';
          String names = member.fields.variables.map((v) => v.name.lexeme).join(', ');
          String prefix = '';
          if (member.isStatic) prefix += 'static ';
          if (member.fields.keyword != null) prefix += '${member.fields.keyword!.lexeme} ';
          buffer.writeln('  $prefix$type $names;');
        }
      } else if (member is ConstructorDeclaration) {
        String className = node.name.lexeme;
        String namedConstructor = member.name?.lexeme != null ? '.${member.name!.lexeme}' : '';
        String params = member.parameters.toSource();
        String prefix = '';
        if (member.constKeyword != null) prefix += 'const ';
        if (member.factoryKeyword != null) prefix += 'factory ';
        buffer.writeln('  $prefix$className$namedConstructor$params;');
      }
    }
    buffer.writeln('}');
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    if (!node.name.lexeme.startsWith('_')) {
      String returnType = node.returnType?.toSource() ?? 'void';
      String name = node.name.lexeme;
      String params = node.functionExpression.parameters?.toSource() ?? '()';
      buffer.writeln('$returnType $name$params;');
    }
  }

  @override
  void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    String type = node.variables.type?.toSource() ?? 'var';
    String names = node.variables.variables.map((v) => v.name.lexeme).join(', ');
    String prefix = node.variables.keyword != null ? '${node.variables.keyword!.lexeme} ' : '';
    buffer.writeln('$prefix$type $names;');
  }
}
