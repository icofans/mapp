import 'dart:convert';
import 'dart:io';

import 'package:mapp/src/utils/utils.dart';

// app 模版的远程仓库地址
const appTemplateUrl =
    'http://gitlab.hive-intel.com/wangjiaqiang/app_template.git';

const templateNmae = 'app_template';

const regName = 'name: app_template';
const regDescription = 'description: A new Flutter project.';
const regVersion = 'version: 1.0.0+1';

String replaceDescription = '';
String replaceVersion = '';

/// 创建项目
///
void create(
  String projectName,
  String packageName,
) {
  _create(projectName, packageName);
}

/// 创建flutter项目
///
///
void _create(
  String projectName,
  String packageName,
) {
  Directory current = Directory.current;
  Directory targetDir = Directory(current.path + '/' + projectName);

  if (targetDir.existsSync()) {
    String action = _select(
      message: 'Target directory ${targetDir.path} already exists. you can:',
      options: ['overwrite', 'cancel'],
    );
    if (action == 'overwrite') {
      print('\nRemoving ${yellow(targetDir)}...\n');
      targetDir.deleteSync(recursive: true);
    } else {
      return;
    }
  }
  // 设置
  if (packageName == null) {
    packageName = _input(
      message:
          '1、The organization responsible for your new Flutter project, in reverse domain name notation. This string is used in Java package names and as prefix in the iOS bundle identifier.',
      defaultValue: 'com.example.$projectName',
    );
  }

  String iosLanguage = _select(
    message: '2、Please select ios programming language',
    options: ['objc', 'swift'],
  );
  String androidLanguage = _select(
    message: '3、Please select android programming language',
    options: ['java', 'kotlin'],
  );
  String description = _input(
    message: '4、Please input your project description',
    defaultValue: 'A new Flutter project. Created by mapp',
  );
  String version = _input(
    message: '5、Please input project version',
    defaultValue: '1.0.0',
  );

  replaceDescription = description;
  replaceVersion = version;

  final flutterArgs = createFlutterArgs(
      projectName, packageName, androidLanguage, iosLanguage, description);

  print('\n✨ Creating project in ' + yellow(targetDir.path));
  Process.start('flutter', flutterArgs, runInShell: true).then((process) {
    stdout.addStream(process.stdout);
    stderr.addStream(process.stderr);
    process.exitCode.then((exit) {
      if (exit == 0) {
        _fetchTemplate(projectName, targetDir);
      }
    });
  });
}

/// 下载远程模版
///
///
void _fetchTemplate(String projectName, Directory targetDir) {
  print(green('✨ Download template from git repository... \n'));
  Process.start('git', ['clone', appTemplateUrl, templateNmae],
          workingDirectory: targetDir.path)
      .then((process) {
    stdout.addStream(process.stdout);
    stderr.addStream(process.stderr);
    process.exitCode.then((exit) {
      if (exit == 0) {
        _generateTargetFiles(
          projectName: projectName,
          filePath: targetDir.path + '/' + templateNmae,
        );
        _updateTargetFiles(
          projectName: projectName,
          targetDir: targetDir.path,
        );
      }
    });
  });
}

/// 模版生成文件
///
///
void _generateTargetFiles({String projectName, String filePath}) {
  List<FileSystemEntity> files = Directory(filePath).listSync();
  for (FileSystemEntity entity in files) {
    FileSystemEntityType type = entity.statSync().type;
    // print('parent = ${entity.parent.path}');
    String path = entity.path.split('/').last;
    // print('path = ${path}');
    if (path.startsWith('.')) {
      // 删除隐藏文件
      File(entity.path).deleteSync(recursive: true);
    } else {
      if (type == FileSystemEntityType.file) {
        print('generate ${entity.path}');
        if (entity.path.endsWith(".dart")) {
          _replace(
            regex: templateNmae,
            replacement: projectName,
            path: entity.path,
          );
        }
        if (path == 'pubspec.yaml') {
          _replace(
            regex: regName,
            replacement: 'name: ${projectName}',
            path: entity.path,
          );
          _replace(
            regex: regDescription,
            replacement: 'description: ${replaceDescription}',
            path: entity.path,
          );
          _replace(
            regex: regVersion,
            replacement: 'version: ${replaceVersion}+1',
            path: entity.path,
          );
        }
      } else if (type == FileSystemEntityType.directory) {
        _generateTargetFiles(projectName: projectName, filePath: entity.path);
      }
    }
  }
}

///
///
///
void _updateTargetFiles({
  String projectName,
  String targetDir,
}) {
// shell.rm('-rf', `${targetDir}/lib`)
// 	shell.rm('-f', `${targetDir}/pubspec.yaml`)
// 	shell.mv(`${targetDir}/${COMMON}/lib`, `${targetDir}`)
// 	shell.mv(`${targetDir}/${COMMON}/assets`, `${targetDir}`)
// 	shell.mv(`${targetDir}/${COMMON}/pubspec.yaml`, `${targetDir}`)

  Process.runSync('rm', ['-rf', '$targetDir/lib']);
  Process.runSync('rm', ['-f', '$targetDir/pubspec.yaml']);
  Process.runSync('mv', ['$targetDir/$templateNmae/lib', '$targetDir']);
  Process.runSync('mv', ['$targetDir/$templateNmae/assets', '$targetDir']);
  Process.runSync(
      'mv', ['$targetDir/$templateNmae/pubspec.yaml', '$targetDir']);

  Process.runSync('rm', ['-rf', '$targetDir/$templateNmae']);

  print('\n');

  Process.start('flutter', ['pub', 'get']).then((process) {
    stdout.addStream(process.stdout);
    stderr.addStream(process.stderr);
    process.exitCode.then((exit) {
      if (exit == 0) {
        print(
            green('\n🎉  Successfully created project ') + yellow(projectName));
        print(white('👉  Get started with the following commands:\n'));
        print('\$ ' + green('cd $projectName'));
        print('\$ ' + green('flutter run\n\n'));
        print(white('enjoy it ~'));
      }
    });
  });
}

void _replace({
  String regex,
  String replacement,
  String path,
}) {
  File file = File(path);
  if (file.existsSync()) {
    var data = file.readAsLinesSync();
    var containsUpdate = false;
    var newData = data.map((line) {
      if (line.contains(regex)) {
        containsUpdate = true;
        return line.replaceAll(regex, replacement);
      } else {
        return line;
      }
    }).toList();
    if (containsUpdate) {
      file.writeAsStringSync("${newData.join('\n')}\n");
      // print('file ${file.path} updated');
    }
  }
}

/// 获取用户输入的内容
///
String _input({
  String message = "",
  String defaultValue = "",
}) {
  stdout.write(yellow(message) + white('($defaultValue)') + ": ");
  var line = stdin.readLineSync(encoding: Encoding.getByName("utf-8"));
  if (line.trim() == null || line.trim().isEmpty) {
    _answer(defaultValue);
    return defaultValue;
  } else {
    _answer(line.trim());
    return line.trim();
  }
}

/// 获取用户选择的内容
///
String _select({
  String message,
  List options,
}) {
  print(yellow(message) + white('(Use arrow keys))'));
  final menu = ConsoleSelector(options);
  final result = menu.choose();
  _answer(result.toString());
  return result.toString();
}

void _answer(String result) {
  print('answer: ' + green(result));
}

List<String> createFlutterArgs(
  String projectName,
  String packageName,
  String androidLanguage,
  String iosLanguage,
  String description,
) {
  var flutterArgs = ['create'];
  flutterArgs.add('--no-pub');

  flutterArgs.add('--org');
  flutterArgs.add(packageName);

  flutterArgs.add('-a');
  flutterArgs.add(androidLanguage);

  flutterArgs.add('-i');
  flutterArgs.add(iosLanguage);

  flutterArgs.add('--description');
  flutterArgs.add(description);

  flutterArgs.add(projectName);
  return flutterArgs;
}
