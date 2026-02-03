# Project ရှင်းလင်းချက်

ဤ `Explain.md` ဖိုင်သည် `bridge_cli` project ၏ code များအားလုံးကို မြန်မာဘာသာဖြင့် တစ်ကြောင်းချင်းစီ ရှင်းလင်းတင်ပြထားသော ဖိုင်ဖြစ်ပါသည်။

---
## File: `lib/parsers/dart_parser.dart`

| Code | ရှင်းလင်းချက် |
| :--- | :--- |
| `import 'dart:io';` | Dart ၏ file system နှင့်အလုပ်လုပ်ရန်အတွက် `dart:io` library ကို import လုပ်ပါသည်။ |
| `import 'package:analyzer/dart/analysis/utilities.dart';` | Dart code ကိုခွဲခြမ်းစိတ်ဖြာရန် `analyzer` package မှ `utilities` ကို import လုပ်ပါသည်။ |
| `import 'package:analyzer/dart/ast/ast.dart';` | Dart code ၏ Abstract Syntax Tree (AST) နှင့်အလုပ်လုပ်ရန် `analyzer` package မှ `ast` ကို import လုပ်ပါသည်။ |
| `import 'package:analyzer/dart/ast/visitor.dart';` | AST nodes များကိုဖြတ်သန်းသွားလာရန် `analyzer` package မှ `visitor` ကို import လုပ်ပါသည်။ |
| `import 'package:bridge_cli/parsers/code_parser.dart';` | `CodeParser` abstract class ကို import လုပ်ပါသည်။ |
| `class DartParser implements CodeParser {` | `CodeParser` ကို implement လုပ်ထားသော `DartParser` class ကိုကြေညာပါသည်။ |
| `  @override` | `CodeParser` class မှ method ကို override လုပ်မည်ဟုကြေညာပါသည်။ |
| `  String get languageId => 'dart';` | ဤ parser သည် 'dart' language အတွက်ဖြစ်ကြောင်း သတ်မှတ်ပါသည်။ |
| `  @override` | `CodeParser` class မှ method ကို override လုပ်မည်ဟုကြေညာပါသည်။ |
| `  Future<String?> parseFile(File file) async {` | file တစ်ခုကို parse လုပ်ရန် asynchronous `parseFile` method ကိုကြေညာပါသည်။ |
| `    try {` | Error handling အတွက် `try` block ကိုစတင်ပါသည်။ |
| `      final content = await file.readAsString();` | File ၏ content ကို string အဖြစ် asynchronous ভাবে ဖတ်ပါသည်။ |
| `      final result = parseString(content: content);` | ဖတ်ထားသော content ကို `parseString` function သုံးပြီး parse လုပ်ပါသည်။ |
| `      final visitor = _UniversalVisitor();` | AST ကိုဖြတ်သန်းရန် `_UniversalVisitor` instance ကို တည်ဆောက်ပါသည်။ |
| `      result.unit.visitChildren(visitor);` | Parsed result ၏ AST tree ကို visitor ဖြင့်စတင်စစ်ဆေးပါသည်။ |
| `      if (visitor.buffer.isNotEmpty) {` | Visitor ၏ buffer ထဲတွင် content ရှိမရှိစစ်ဆေးပါသည်။ |
| `        return 'File: ${file.uri.pathSegments.last}\n${visitor.buffer.toString()}';` | Buffer content ရှိလျှင် file name နှင့်အတူ content ကို return ပြန်ပါသည်။ |
| `      }` | `if` block အဆုံးသတ်။ |
| `    } catch (e) {` | Error ဖြစ်ပွားပါက `catch` block မှဖမ်းယူပါမည်။ |
| `      return null;` | Error ဖြစ်ပွားပါက `null` ကို return ပြန်ပါသည်။ |
| `    }` | `try-catch` block အဆုံးသတ်။ |
| `    return null;` | `try` block အောင်မြင်သော်လည်း buffer ထဲတွင် content မရှိပါက `null` ကို return ပြန်ပါသည်။ |
| `  }` | `parseFile` method အဆုံးသတ်။ |
| `}` | `DartParser` class အဆုံးသတ်။ |
| `class _UniversalVisitor extends GeneralizingAstVisitor<void> {` | `GeneralizingAstVisitor` ကို extend လုပ်ထားသော `_UniversalVisitor` class ကိုကြေညာပါသည်။ |
| `  final StringBuffer buffer = StringBuffer();` | String များကိုထိရောက်စွာဆက်ရန် `StringBuffer` instance ကိုကြေညာပါသည်။ |
| `  @override` | Superclass မှ method ကို override လုပ်မည်ဟုကြေညာပါသည်။ |
| `  void visitImportDirective(ImportDirective node) {` | `import` directive node ကိုတွေ့သောအခါခေါ်ใช้မည့် method ဖြစ်ပါသည်။ |
| `    buffer.writeln(node.toSource());` | Import statement ၏ source code ကို buffer ထဲသို့ထည့်ပါသည်။ |
| `  }` | `visitImportDirective` method အဆုံးသတ်။ |
| `  @override` | Superclass မှ method ကို override လုပ်မည်ဟုကြေညာပါသည်။ |
| `  void visitClassDeclaration(ClassDeclaration node) {` | `class` declaration node ကိုတွေ့သောအခါခေါ်ใช้မည့် method ဖြစ်ပါသည်။ |
| `    buffer.write('class ${node.name.lexeme}');` | `class` နှင့် class name ကို buffer ထဲသို့ထည့်ပါသည်။ |
| `    if (node.extendsClause != null) {` | Class သည် အခြား class ကို extend လုပ်ထားခြင်းရှိမရှိ စစ်ဆေးပါသည်။ |
| `      buffer.write(' ${node.extendsClause!.toSource()}');` | Extend လုပ်ထားသော class ၏ source code ကို buffer ထဲသို့ထည့်ပါသည်။ |
| `    }` | `if` block အဆုံးသတ်။ |
| `    if (node.implementsClause != null) {` | Class သည် interface ကို implement လုပ်ထားခြင်းရှိမရှိ စစ်ဆေးပါသည်။ |
| `      buffer.write(' ${node.implementsClause!.toSource()}');` | Implement လုပ်ထားသော interface ၏ source code ကို buffer ထဲသို့ထည့်ပါသည်။ |
| `    }` | `if` block အဆုံးသတ်။ |
| `    buffer.writeln(' {');` | Class body ကိုစတင်ရန် `{` ကို buffer ထဲသို့ထည့်ပါသည်။ |
| `    for (var member in node.members) {` | Class ၏ member (method, field, constructor) တစ်ခုချင်းစီကို loop ပတ်ပါသည်။ |
| `      if (member is MethodDeclaration) {` | Member သည် method ဖြစ်မဖြစ်စစ်ဆေးပါသည်။ |
| `        if (!member.name.lexeme.startsWith('_')) {` | Method name သည် `_` (private) ဖြင့်မစတင်လျှင် public method ဖြစ်သည်ဟုယူဆပါသည်။ |
| `          String returnType = member.returnType?.toSource() ?? 'dynamic';` | Method ၏ return type ကိုရယူပါသည်။ မရှိပါက `dynamic` ဟုသတ်မှတ်ပါသည်။ |
| `          String name = member.name.lexeme;` | Method ၏ name ကိုရယူပါသည်။ |
| `          String params = member.parameters?.toSource() ?? '()';` | Method ၏ parameters များကိုရယူပါသည်။ မရှိပါက `()` ဟုသတ်မှတ်ပါသည်။ |
| `          buffer.writeln('  $returnType $name$params;');` | Method signature ကို format လုပ်ပြီး buffer ထဲသို့ထည့်ပါသည်။ |
| `        }` | `if` block အဆုံးသတ်။ |
| `      }` | `if` block အဆုံးသတ်။ |
| `      else if (member is FieldDeclaration) {` | Member သည် field (variable) ဖြစ်မဖြစ်စစ်ဆေးပါသည်။ |
| `        if (!member.fields.variables.first.name.lexeme.startsWith('_')) {` | Field name သည် `_` (private) ဖြင့်မစတင်လျှင် public field ဖြစ်သည်ဟုယူဆပါသည်။ |
| `          String type = member.fields.type?.toSource() ?? 'var';` | Field ၏ data type ကိုရယူပါသည်။ မရှိပါက `var` ဟုသတ်မှတ်ပါသည်။ |
| `          String names = member.fields.variables.map((v) => v.name.lexeme).join(', ');` | Field name များကိုရယူပြီး `,` ဖြင့်ဆက်ပါသည်။ |
| `          String prefix = '';` | Prefix အတွက် string variable ကိုကြေညာပါသည်။ |
| `          if (member.isStatic) prefix += 'static ';` | Field သည် static ဖြစ်ပါက `static` ဟု prefix ထည့်ပါသည်။ |
| `          if (member.fields.keyword != null) prefix += '${member.fields.keyword!.lexeme} ';` | Field တွင် `final` သို့မဟုတ် `const` keyword ပါပါက prefix ထည့်ပါသည်။ |
| `          buffer.writeln('  $prefix$type $names;');` | Field declaration ကို format လုပ်ပြီး buffer ထဲသို့ထည့်ပါသည်။ |
| `        }` | `if` block အဆုံးသတ်။ |
| `      }` | `else if` block အဆုံးသတ်။ |
| `      else if (member is ConstructorDeclaration) {` | Member သည် constructor ဖြစ်မဖြစ်စစ်ဆေးပါသည်။ |
| `        String className = node.name.lexeme;` | Class name ကိုရယူပါသည်။ |
| `        String namedConstructor = member.name?.lexeme != null ? '.${member.name!.lexeme}' : '';` | Named constructor ဖြစ်ပါက constructor name ကိုရယူပါသည်။ |
| `        String params = member.parameters.toSource();` | Constructor ၏ parameters များကိုရယူပါသည်။ |
| `        String prefix = '';` | Prefix အတွက် string variable ကိုကြေညာပါသည်။ |
| `        if (member.constKeyword != null) prefix += 'const ';` | Constructor သည် `const` ဖြစ်ပါက `const` ဟု prefix ထည့်ပါသည်။ |
| `        if (member.factoryKeyword != null) prefix += 'factory ';` | Constructor သည် `factory` ဖြစ်ပါက `factory` ဟု prefix ထည့်ပါသည်။ |
| `        buffer.writeln('  $prefix$className$namedConstructor$params;');` | Constructor signature ကို format လုပ်ပြီး buffer ထဲသို့ထည့်ပါသည်။ |
| `      }` | `else if` block အဆုံးသတ်။ |
| `    }` | `for` loop အဆုံးသတ်။ |
| `    buffer.writeln('}');` | Class body ကိုပိတ်ရန် `}` ကို buffer ထဲသို့ထည့်ပါသည်။ |
| `  }` | `visitClassDeclaration` method အဆုံးသတ်။ |
| `  @override` | Superclass မှ method ကို override လုပ်မည်ဟုကြေညာပါသည်။ |
| `  void visitFunctionDeclaration(FunctionDeclaration node) {` | Top-level function declaration node ကိုတွေ့သောအခါခေါ်ใช้မည့် method ဖြစ်ပါသည်။ |
| `    if (!node.name.lexeme.startsWith('_')) {` | Function name သည် `_` (private) ဖြင့်မစတင်လျှင် public function ဖြစ်သည်ဟုယူဆပါသည်။ |
| `      String returnType = node.returnType?.toSource() ?? 'void';` | Function ၏ return type ကိုရယူပါသည်။ မရှိပါက `void` ဟုသတ်မှတ်ပါသည်။ |
| `      String name = node.name.lexeme;` | Function ၏ name ကိုရယူပါသည်။ |
| `      String params = node.functionExpression.parameters?.toSource() ?? '()';` | Function ၏ parameters များကိုရယူပါသည်။ မရှိပါက `()` ဟုသတ်မှတ်ပါသည်။ |
| `      buffer.writeln('$returnType $name$params;');` | Function signature ကို format လုပ်ပြီး buffer ထဲသို့ထည့်ပါသည်။ |
| `    }` | `if` block အဆုံးသတ်။ |
| `  }` | `visitFunctionDeclaration` method အဆုံးသတ်။ |
| `  @override` | Superclass မှ method ကို override လုပ်မည်ဟုကြေညာပါသည်။ |
| `  void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {` | Top-level variable declaration node ကိုတွေ့သောအခါခေါ်ใช้မည့် method ဖြစ်ပါသည်။ |
| `    String type = node.variables.type?.toSource() ?? 'var';` | Variable ၏ data type ကိုရယူပါသည်။ မရှိပါက `var` ဟုသတ်မှတ်ပါသည်။ |
| `    String names = node.variables.variables.map((v) => v.name.lexeme).join(', ');` | Variable name များကိုရယူပြီး `,` ဖြင့်ဆက်ပါသည်။ |
| `    String prefix = node.variables.keyword != null ? '${node.variables.keyword!.lexeme} ' : '';` | Variable တွင် `final` သို့မဟုတ် `const` keyword ပါပါက prefix ထည့်ပါသည်။ |
| `    buffer.writeln('$prefix$type $names;');` | Variable declaration ကို format လုပ်ပြီး buffer ထဲသို့ထည့်ပါသည်။ |
| `  }` | `visitTopLevelVariableDeclaration` method အဆုံးသတ်။ |
| `}` | `_UniversalVisitor` class အဆုံးသတ်။ |
---
## File: `lib/commands/config_manager.dart`

| Code | ရှင်းလင်းချက် |
| :--- | :--- |
| `import 'dart:io';` | Dart ၏ file system နှင့်အလုပ်လုပ်ရန်အတွက် `dart:io` library ကို import လုပ်ပါသည်။ |
| `import 'package:path/path.dart' as p;` | File path များကိုလွယ်ကူစွာကိုင်တွယ်ရန် `path` package ကို `p` ဟူသော alias ဖြင့် import လုပ်ပါသည်။ |
| `class ConfigManager {` | Configuration များကိုစီမံခန့်ခွဲရန် `ConfigManager` class ကိုကြေညာပါသည်။ |
| `  static const String configFileName = 'bridge.yaml';` | Configuration file ၏အမည်ကို `configFileName` constant variable တွင် `bridge.yaml` ဟုသတ်မှတ်ပါသည်။ |
| `  Future<void> createConfig(List<Directory> projects) async {` | `bridge.yaml` file ကိုတည်ဆောက်ရန် asynchronous `createConfig` method ကိုကြေညာပါသည်။ |
| `    final file = File(p.join(Directory.current.path, configFileName));` | လက်ရှိ directory တွင် `bridge.yaml` file object ကိုတည်ဆောက်ပါသည်။ |
| `    return Stream.fromIterable(projects).map((dir) => _generateEntry(dir)).fold('projects:', (previous, current) => '$previous\n$current').then((content) => file.writeAsString(content)).then((_) => print('\x1B[32m✅ Created $configFileName successfully!\x1B[0m')).catchError((e) => print('\x1B[31m❌ Error creating config: $e\x1B[0m'));` | Project list မှ stream બનાવી၊ entry တစ်ခုချင်းစီကို generate လုပ်၊ `projects:` header နှင့်ပေါင်းပြီး file ထဲသို့ရေးပါသည်။ အောင်မြင်လျှင် message ပြပြီး၊ error ဖြစ်လျှင် error message ပြပါသည်။ |
| `  }` | `createConfig` method အဆုံးသတ်။ |
| `  Future<void> addProject(String rawPath) async {` | Project အသစ်တစ်ခုကို `bridge.yaml` ထဲသို့ထည့်ရန် asynchronous `addProject` method ကိုကြေညာပါသည်။ |
| `    final file = File(p.join(Directory.current.path, configFileName));` | လက်ရှိ directory တွင် `bridge.yaml` file object ကိုတည်ဆောက်ပါသည်။ |
| `    if (!file.existsSync()) {` | `bridge.yaml` file ရှိမရှိစစ်ဆေးပါသည်။ |
| `      await file.writeAsString('projects:\n');` | File မရှိပါက `projects:` ဟူသောစာသားဖြင့် file အသစ်တစ်ခုတည်ဆောက်ပါသည်။ |
| `    }` | `if` block အဆုံးသတ်။ |
| `    final targetDir = Directory(rawPath).absolute;` | ပေးထားသော path ကို absolute path အဖြစ်ပြောင်းပြီး directory object တည်ဆောက်ပါသည်။ |
| `    if (!targetDir.existsSync()) {` | Directory ရှိမရှိစစ်ဆေးပါသည်။ |
| `      print('\x1B[31m❌ Error: Directory not found at $rawPath\x1B[0m');` | Directory မရှိပါက error message ပြပါသည်။ |
| `      return;` | Directory မရှိပါက ဆက်မလုပ်တော့ဘဲထွက်ပါသည်။ |
| `    }` | `if` block အဆုံးသတ်။ |
| `    final type = _guessType(targetDir);` | Directory path ကိုသုံးပြီး project type ကိုခန့်မှန်းပါသည်။ |
| `    final relativePath = p.relative(targetDir.path, from: Directory.current.path);` | လက်ရှိ directory နှင့် project directory ကြား relative path ကိုတွက်ချက်ပါသည်။ |
| `    final normalizedPath = p.normalize(relativePath).replaceAll(r'\', '/');` | Path ကို normalize လုပ်ပြီး backslash `\` များကို forward slash `/` ဖြင့်အစားထိုးပါသည်။ |
| `    final currentContent = await file.readAsString();` | `bridge.yaml` file ၏ content ကိုဖတ်ပါသည်။ |
| `    if (currentContent.contains(normalizedPath)) {` | File content ထဲတွင် project path ရှိနှင့်ပြီးဖြစ်မဖြစ်စစ်ဆေးပါသည်။ |
| `      print('\x1B[33m⚠️ Project is already in bridge.yaml\x1B[0m');` | Project ရှိနှင့်ပြီးဖြစ်ပါက warning message ပြပါသည်။ |
| `      return;` | Project ရှိနှင့်ပြီးဖြစ်ပါက ဆက်မလုပ်တော့ဘဲထွက်ပါသည်။ |
| `    }` | `if` block အဆုံးသတ်။ |
| `    final entry = '\n  - path: ./$normalizedPath\n    type: $type\n    name: ${p.basename(targetDir.path)}';` | `bridge.yaml` ထဲသို့ထည့်မည့် entry စာသားကိုတည်ဆောက်ပါသည်။ |
| `    await file.writeAsString(entry, mode: FileMode.append);` | တည်ဆောက်ထားသော entry ကို file ၏အဆုံးတွင်ထည့်ပါသည်။ |
| `    print('\x1B[32m✅ Linked external pr oject: ${p.basename(targetDir.path)}\x1B[0m');` | အောင်မြင်ကြောင်း message ပြပါသည်။ |
| `  }` | `addProject` method အဆုံးသတ်။ |
| `  String _generateEntry(Directory dir) {` | YAML entry တစ်ခုကို generate လုပ်ရန် `_generateEntry` private method ကိုကြေညာပါသည်။ |
| `    final relativePath = p.relative(dir.path, from: Directory.current.path);` | လက်ရှိ directory နှင့် project directory ကြား relative path ကိုတွက်ချက်ပါသည်။ |
| `    final normalizedPath = p.normalize(relativePath).replaceAll(r'\', '/');` | Path ကို normalize လုပ်ပြီး backslash `\` များကို forward slash `/` ဖြင့်အစားထိုးပါသည်။ |
| `    final type = _guessType(dir);` | Directory path ကိုသုံးပြီး project type ကိုခန့်မှန်းပါသည်။ |
| `    return '  - path: ./$normalizedPath\n    type: $type\n    name: ${p.basename(dir.path)}';` | YAML entry format အတိုင်းစာသားကိုတည်ဆောက်ပြီး return ပြန်ပါသည်။ |
| `  }` | `_generateEntry` method အဆုံးသတ်။ |
| `  String _guessType(Directory dir) {` | Project type ကိုခန့်မှန်းရန် `_guessType` private method ကိုကြေညာပါသည်။ |
| `    if (File(p.join(dir.path, 'pubspec.yaml')).existsSync()) return 'dart';` | `pubspec.yaml` file ရှိပါက `dart` ဟု return ပြန်ပါသည်။ |
| `    if (File(p.join(dir.path, 'package.json')).existsSync()) return 'node';` | `package.json` file ရှိပါက `node` ဟု return ပြန်ပါသည်။ |
| `    if (File(p.join(dir.path, 'go.mod')).existsSync()) return 'go';` | `go.mod` file ရှိပါက `go` ဟု return ပြန်ပါသည်။ |
| `    if (File(p.join(dir.path, 'requirements.txt')).existsSync()) return 'python';` | `requirements.txt` file ရှိပါက `python` ဟု return ပြန်ပါသည်။ |
| `    return 'unknown';` | အထက်ပါ file များမရှိပါက `unknown` ဟု return ပြန်ပါသည်။ |
| `  }` | `_guessType` method အဆုံးသတ်။ |
| `}` | `ConfigManager` class အဆုံးသတ်။ |
---
## File: `bin/bridge_cli.dart`

| Code | ရှင်းလင်းချက် |
| :--- | :--- |
| `import 'dart:async';` | Asynchronous programming အတွက် `dart:async` library ကို import လုပ်ပါသည်။ |
| `import 'dart:io';` | File system နှင့် process များ နှင့်အလုပ်လုပ်ရန် `dart:io` library ကို import လုပ်ပါသည်။ |
| `import 'package:args/args.dart';` | Command-line arguments များကို parse လုပ်ရန် `args` package ကို import လုပ်ပါသည်။ |
| `import 'package:bridge_cli/commands/config_manager.dart';` | `ConfigManager` class ကို import လုပ်ပါသည်။ |
| `import 'package:bridge_cli/commands/watcher.dart';` | `BridgeWatcher` class ကို import လုပ်ပါသည်။ |
| `import 'package:bridge_cli/scanner/project_scanner.dart';` | `ProjectScanner` class ကို import လုပ်ပါသည်။ |
| `import 'package:bridge_cli/generator/context_generator.dart';` | `ContextGenerator` class ကို import လုပ်ပါသည်။ |
| `void main(List<String> arguments) async {` | Application ၏ entry point ဖြစ်သော `main` function ကိုကြေညာပါသည်။ |
| `  final parser = ArgParser();` | Argument parser instance ကိုတည်ဆောက်ပါသည်။ |
| `  parser.addCommand('init');` | `init` command ကို parser ထဲသို့ထည့်ပါသည်။ |
| `  parser.addCommand('build');` | `build` command ကို parser ထဲသို့ထည့်ပါသည်။ |
| `  parser.addCommand('watch');` | `watch` command ကို parser ထဲသို့ထည့်ပါသည်။ |
| `  parser.addFlag('help', abbr: 'h', negatable: false);` | `--help` သို့မဟုတ် `-h` flag ကို parser ထဲသို့ထည့်ပါသည်။ |
| `  ArgResults argResults;` | Parse လုပ်ထားသော argument result များကိုเก็บရန် `argResults` variable ကိုကြေညာပါသည်။ |
| `  try {` | Error handling အတွက် `try` block ကိုစတင်ပါသည်။ |
| `    argResults = parser.parse(arguments);` | Command-line arguments များကို parse လုပ်ပါသည်။ |
| `  } catch (e) {` | Error ဖြစ်ပွားပါက `catch` block မှဖမ်းယူပါမည်။ |
| `    print('Error: $e');` | Error message ကို print ထုတ်ပါသည်။ |
| `    exit(1);` | Error code 1 ဖြင့် application ကိုရပ်ပါသည်။ |
| `  }` | `try-catch` block အဆုံးသတ်။ |
| `  if (argResults['help'] as bool) {` | `--help` flag ပါလာသလားစစ်ဆေးပါသည်။ |
| `    _printUsage();` | `_printUsage` function ကိုခေါ်ပြီး အသုံးပြုပုံကို print ထုတ်ပါသည်။ |
| `    return;` | `--help` flag ပါပါက ဆက်မလုပ်တော့ဘဲထွက်ပါသည်။ |
| `  }` | `if` block အဆုံးသတ်။ |
| `  final command = argResults.command;` | Parse လုပ်ထားသော command ကို `command` variable ထဲသို့ထည့်ပါသည်။ |
| `  switch (command?.name) {` | Command name ကို `switch` statement ဖြင့်စစ်ဆေးပါသည်။ |
| `    case 'init':` | Command သည် `init` ဖြစ်ပါက |
| `      await _handleInitCommand(command!.rest);` | `_handleInitCommand` ကိုခေါ်ပါသည်။ |
| `      break;` | `switch` statement မှထွက်ပါသည်။ |
| `    case 'build':` | Command သည် `build` ဖြစ်ပါက |
| `      await _handleBuildCommand();` | `_handleBuildCommand` ကိုခေါ်ပါသည်။ |
| `      break;` | `switch` statement မှထွက်ပါသည်။ |
| `    case 'watch':` | Command သည် `watch` ဖြစ်ပါက |
| `      await _handleWatchCommand();` | `_handleWatchCommand` ကိုခေါ်ပါသည်။ |
| `      break;` | `switch` statement မှထွက်ပါသည်။ |
| `    default:` | အထက်ပါ command များမှလွဲ၍ အခြား command ဖြစ်ပါက |
| `      _printUsage();` | `_printUsage` function ကိုခေါ်ပြီး အသုံးပြုပုံကို print ထုတ်ပါသည်။ |
| `  }` | `switch` statement အဆုံးသတ်။ |
| `}` | `main` function အဆုံးသတ်။ |
| `Future<void> _handleInitCommand(List<String> paths) async {` | `init` command ကိုကိုင်တွယ်ရန် asynchronous `_handleInitCommand` private function ကိုကြေညာပါသည်။ |
| `  final configManager = ConfigManager();` | `ConfigManager` instance ကိုတည်ဆောက်ပါသည်။ |
| `  final scanner = ProjectScanner();` | `ProjectScanner` instance ကိုတည်ဆောက်ပါသည်။ |
| `  final configFile = File('bridge.yaml');` | `bridge.yaml` file object ကိုတည်ဆောက်ပါသည်။ |
| `  if (paths.isEmpty || !configFile.existsSync()) {` | Argument path မပါ거나 `bridge.yaml` file မရှိလျှင် |
| `    if (paths.isNotEmpty) {` | Argument path ပါလျှင် |
| `      print('\x1B[36m📦 Initializing local project first...\x1B[0m');` | Local project ကိုအရင် initialize လုပ်ကြောင်း message ပြပါသည်။ |
| `    } else {` | Argument path မပါလျှင် |
| `      print('\x1B[36m🔍 Bridge CLI: Starting Smart Scan...\x1B[0m');` | Smart scan စတင်ကြောင်း message ပြပါသည်။ |
| `    }` | `if-else` block အဆုံးသတ်။ |
| `    try {` | Error handling အတွက် `try` block ကိုစတင်ပါသည်။ |
| `      final projects = await scanner.findProjectRoots(Directory.current);` | လက်ရှိ directory ထဲတွင် project များကို `ProjectScanner` ဖြင့်ရှာပါသည်။ |
| `      if (projects.isEmpty) {` | Project မတွေ့ရှိပါက |
| `        print('\x1B[33m⚠️  No projects found in current directory.\x1B[0m');` | Project မတွေ့ကြောင်း warning message ပြပါသည်။ |
| `        if (!configFile.existsSync()) {` | `bridge.yaml` file မရှိပါက |
| `          await configFile.writeAsString('projects:\n');` | `bridge.yaml` file အလွတ်တစ်ခုတည်ဆောက်ပါသည်။ |
| `        }` | `if` block အဆုံးသတ်။ |
| `      } else {` | Project တွေ့ရှိပါက |
| `        print('\x1B[32m✅ Found ${projects.length} local project(s).\x1B[0m');` | Project အရေအတွက်နှင့်တကွ message ပြပါသည်။ |
| `        await configManager.createConfig(projects);` | `ConfigManager` ကိုသုံးပြီး `bridge.yaml` file ကိုတည်ဆောက်ပါသည်။ |
| `      }` | `if-else` block အဆုံးသတ်။ |
| `    } catch (e) {` | Error ဖြစ်ပွားပါက `catch` block မှဖမ်းယူပါမည်။ |
| `      print('\x1B[31m❌ Error scanning directory: $e\x1B[0m');` | Error message ကို print ထုတ်ပါသည်။ |
| `    }` | `try-catch` block အဆုံးသတ်။ |
| `  }` | `if` block အဆုံးသတ်။ |
| `  if (paths.isNotEmpty) {` | Argument path ပါလာလျှင် |
| `    final targetPath = paths.first;` | ပထမဆုံး path ကို `targetPath` အဖြစ်ရယူပါသည်။ |
| `    print('\x1B[36m🔗 Linking external project: $targetPath...\x1B[0m');` | External project ကို link လုပ်နေကြောင်း message ပြပါသည်။ |
| `    await configManager.addProject(targetPath);` | `ConfigManager` ကိုသုံးပြီး project အသစ်ကို `bridge.yaml` ထဲသို့ထည့်ပါသည်။ |
| `  } else {` | Argument path မပါလျှင် |
| `    if (configFile.existsSync()) {` | `bridge.yaml` file ရှိပါက |
| `      print('Run "bridge build" to generate AI context.');` | `bridge build` command ကို run ရန် message ပြပါသည်။ |
| `    }` | `if` block အဆုံးသတ်။ |
| `  }` | `if-else` block အဆုံးသတ်။ |
| `}` | `_handleInitCommand` function အဆုံးသတ်။ |
| `Future<void> _handleBuildCommand() async {` | `build` command ကိုကိုင်တွယ်ရန် asynchronous `_handleBuildCommand` private function ကိုကြေညာပါသည်။ |
| `  final generator = ContextGenerator();` | `ContextGenerator` instance ကိုတည်ဆောက်ပါသည်။ |
| `  await generator.generateContext();` | `ContextGenerator` ကိုသုံးပြီး AI context ကို generate လုပ်ပါသည်။ |
| `}` | `_handleBuildCommand` function အဆုံးသတ်။ |
| `Future<void> _handleWatchCommand() async {` | `watch` command ကိုကိုင်တွယ်ရန် asynchronous `_handleWatchCommand` private function ကိုကြေညာပါသည်။ |
| `  final watcher = BridgeWatcher();` | `BridgeWatcher` instance ကိုတည်ဆောက်ပါသည်။ |
| `  await watcher.startWatch();` | `BridgeWatcher` ကိုသုံးပြီး file change များကိုစောင့်ကြည့်ပါသည်။ |
| `  await Completer().future;` | Process ကိုမပြီးဆုံးစေရန် `Completer` ကိုသုံးပြီး အဆုံးမရှိစောင့်ဆိုင်းနေပါသည်။ |
| `}` | `_handleWatchCommand` function အဆုံးသတ်။ |
| `void _printUsage() {` | အသုံးပြုပုံကို print ထုတ်ရန် `_printUsage` private function ကိုကြေညာပါသည်။ |
| `  print('Bridge CLI Tool v0.0.1');` | Tool ၏ version ကို print ထုတ်ပါသည်။ |
| `  print('Usage: bridge <command>');` | အသုံးပြုပုံကို print ထုတ်ပါသည်။ |
| `  print('
Commands:');` | Command များ၏ header ကို print ထုတ်ပါသည်။ |
| `  print('  init    Scan and create bridge.yaml config.');` | `init` command ၏ရှင်းလင်းချက်ကို print ထုတ်ပါသည်။ |
| `  print('  build   Generate .ai-bridge.md once.');` | `build` command ၏ရှင်းလင်းချက်ကို print ထုတ်ပါသည်။ |
| `  print('  watch   Live sync .ai-bridge.md on file changes.');` | `watch` command ၏ရှင်းလင်းချက်ကို print ထုတ်ပါသည်။ |
| `}` | `_printUsage` function အဆုံးသတ်။ |