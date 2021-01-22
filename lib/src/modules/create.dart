import 'dart:io';

import 'package:mapp/mapp.dart';
import 'package:mapp/src/modules/grade_config.dart';
import 'package:mapp/src/templates/flutterw_template.dart';
import 'package:mapp/src/utils/utils.dart';

// app 模版的远程仓库地址
const appTemplateUrl = 'https://github.com/icofans/app_template.git';

const templateNmae = 'app_template';

const regName = 'name: app_template';
const regDescription = 'description: A new Flutter project.';
const regVersion = 'version: 1.0.0+1';

String replaceDescription = '';
String replaceVersion = '';
String replaceAppName = '';

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
    String action = select(
      message: 'Target directory ${targetDir.path} already exists. you can:',
      options: ['overwrite', 'cancel'],
    );
    if (action == 'overwrite') {
      print('\nRemoving ${blue(targetDir)}...\n');
      targetDir.deleteSync(recursive: true);
    } else {
      return;
    }
  }
  // 设置
  if (packageName == null) {
    packageName = input(
      message:
          '1、The organization responsible for your new Flutter project, in reverse domain name notation. This string is used in Java package names and as prefix in the iOS bundle identifier.',
      defaultValue: 'com.example',
    );
  }

  String iosLanguage = select(
    message: '2、Please select ios programming language',
    options: ['objc', 'swift'],
  );
  String androidLanguage = select(
    message: '3、Please select android programming language',
    options: ['java', 'kotlin'],
  );
  String description = input(
    message: '4、Please input your project description',
    defaultValue: 'A new Flutter project. Created by mapp',
  );
  String version = input(
    message: '5、Please input project version',
    defaultValue: '1.0.0',
  );
  String appName = input(
    message: '6、Please input App display name',
    defaultValue: projectName,
  );

  // 需要修改的内容
  replaceDescription = description;
  replaceVersion = version;
  replaceAppName = appName;

  final flutterArgs = createFlutterArgs(
      projectName, packageName, androidLanguage, iosLanguage, description);

  print('\n👉  Creating project in ' + blue(targetDir.path) + '\n');
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
  print(green('\n👉  Download template from git repository... \n'));
  Process.start('git', ['clone', appTemplateUrl, templateNmae],
          workingDirectory: targetDir.path)
      .then((process) {
    stdout.addStream(process.stdout);
    stderr.addStream(process.stderr);
    process.exitCode.then((exit) {
      if (exit == 0) {
        print(green('\n👉  Generate template... \n'));
        _generateTargetFiles(
          projectName: projectName,
          filePath: targetDir.path + '/' + templateNmae,
        );
        _modifyTargetFiles(
          projectName: projectName,
          targetDir: targetDir.path,
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

/// 配置文件
///
///
void _modifyTargetFiles({
  String projectName,
  String targetDir,
}) {
  print(green('\n👉  Generate android configuration \n'));
  // 修改App名称
  if (replaceAppName != projectName) {
    modifyName(replaceAppName, ModifyPlatform.all,
        targetDir: Directory(targetDir));
  }
  // 开启ext
  generateConfigGradle(targetDir, projectName);
  modifyBuildGradle(targetDir);
  // 修改build gradle
  modifyAppBuildGrade(targetDir);
  // 开启混淆
  enableProguard(targetDir, projectName);

  _generateFlutterw(targetDir);
}

/// 生成flutter版本控制
_generateFlutterw(String targetDir) {
  Directory directory = Directory(targetDir);
  // 引入config.grade
  String path = directory.path + '/flutterw';
  File file = File(path);
  file.writeAsStringSync(flutterwTemplate());

  // 赋予可执行
  Process.runSync('chmod', ['a+x', 'flutterw'], workingDirectory: targetDir);
  // 添加gitignore
  String ignorePath = directory.path + '/.gitignore';
  File ignoreFile = File(ignorePath);
  try {
    String contents = ignoreFile.readAsStringSync();
    contents = contents +
        '''\n
# mapp 
.flutter/
    ''';
    ignoreFile.writeAsStringSync(contents);
  } catch (e) {}
}

/// 更新文件
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

  print(green('\n👉  Install dependencies...... \n'));

  Process.start('flutter', ['pub', 'get'], workingDirectory: '$targetDir')
      .then((process) {
    stdout.addStream(process.stdout);
    stderr.addStream(process.stderr);
    process.exitCode.then((exit) {
      if (exit == 0) {
        print(green('\n🎉  Successfully created project ') + blue(projectName));
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

/// flutter 命令参数
///
///
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
