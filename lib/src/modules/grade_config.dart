import 'dart:io';

import 'package:mapp/src/templates/templates.dart';
import 'package:mapp/src/utils/utils.dart';

/// 生成config.grade
///
///
void generateConfigGradle(String targetDir, String projectName) {
// 生成安卓的一些配置
  Directory directory = Directory(targetDir + '/android');
  String androidConfigPath = directory.path + '/config.gradle';
  File androidConfigFile = File(androidConfigPath);
  if (!androidConfigFile.existsSync()) {
    androidConfigFile.createSync();
  }
  androidConfigFile.writeAsStringSync(gradleExtTemplate(projectName));
}

/// 修改Build.grade
/// 引入config.grade, 修改grade镜像
///
///
void modifyBuildGradle(String targetDir) {
  Directory directory = Directory(targetDir + '/android');
  // 引入config.grade
  String projectBuildConfigPath = directory.path + '/build.gradle';
  File projectBuildConfigFile = File(projectBuildConfigPath);
  try {
    String content = projectBuildConfigFile.readAsStringSync();
    content = 'apply from: \"config.gradle\"\n' + content;
    projectBuildConfigFile.writeAsStringSync(content);
  } catch (e) {
    print("Failed to writing android configuration");
  }
  // 修改grade镜像
  try {
    List lines = projectBuildConfigFile.readAsStringSync().split('\n');
    for (var i = lines.length - 1; i >= 0; i--) {
      String line = lines[i];
      // 修改compileSdkVersion
      // release
      if (line.contains("repositories {")) {
        lines.insert(i + 1, '''
        maven { url 'https://maven.aliyun.com/repository/google' }
        maven { url 'https://maven.aliyun.com/repository/jcenter' }
        maven { url 'http://maven.aliyun.com/nexus/content/groups/public' }
        ''');
      }
    }
    projectBuildConfigFile.writeAsStringSync(lines.join('\n'));
  } catch (e) {
    print("Failed to modify repositories");
  }
}

/// 修改app原有build方式
///
///
void modifyAppBuildGrade(String targetDir, {bool enableProguard = false}) {
  Directory appDirectory = Directory(targetDir + '/android/app');
  String appConfigPath = appDirectory.path + '/build.gradle';
  File appConfigFile = File(appConfigPath);
  // TODO: 优化实现方式
  try {
    List lines = appConfigFile.readAsStringSync().split('\n');
    if (enableProguard) {
      for (int i = lines.length - 1; i >= 0; i--) {
        String line = lines[i];
        if (line.contains("signingConfig signingConfigs.release")) {
          lines.insert(i + 1, '''
            // 混淆配置
            minifyEnabled true
            useProguard true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro\'''');
        }
      }
    } else {
      lines.add('''
dependencies rootProject.ext.dependencies
    ''');
      for (int i = lines.length - 1; i >= 0; i--) {
        String line = lines[i];
        if (enableProguard) {
          if (line.contains("signingConfig signingConfigs.release")) {
            lines.insert(i + 1, '''
            // 混淆配置
            minifyEnabled true
            useProguard true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro\'''');
          }
        } else {
// 修改compileSdkVersion
          // release
          if (line.contains("signingConfig ")) {
            lines[i] = '''
            signingConfig signingConfigs.release''';
          }
          // debug
          if (line.contains("buildTypes {")) {
            lines.insert(i + 1, '''
        debug {
            signingConfig signingConfigs.debug
        }\n''');
          }
          // signConfig
          if (line.contains("versionName flutterVersionName")) {
            lines.insert(i + 2, '''\n
    signingConfigs {
        debug rootProject.ext.signingConfigs.debug
        release rootProject.ext.signingConfigs.release
    }''');
            lines.insert(i + 1, '''
        ndk rootProject.ext.android.ndk
        manifestPlaceholders rootProject.ext.manifestPlaceholders
        ''');
          }
          if (line.contains("targetSdkVersion")) {
            lines[i] = '''
        targetSdkVersion rootProject.ext.android.targetSdkVersion''';
          }
          if (line.contains("minSdkVersion")) {
            lines[i] = '''
        minSdkVersion rootProject.ext.android.minSdkVersion''';
          }
          if (line.contains("compileSdkVersion")) {
            lines[i] = '''
    compileSdkVersion rootProject.ext.android.compileSdkVersion''';
          }
        }
      }
      print('\n✨ Successfully modify android configuration \n');
    }

    appConfigFile.writeAsStringSync(lines.join('\n'));
  } catch (e) {
    print(red('Failed to modify build.config file'));
  }
}

/// 开启混淆
///
///
void enableProguard(String targetDir, String projectName) {
  modifyAppBuildGrade(targetDir, enableProguard: true);
  Directory proguardDir = Directory(targetDir + '/android/app');
  String proguardPath = proguardDir.path + '/proguard-rules.pro';
  File proguardFile = File(proguardPath);
  if (!proguardFile.existsSync()) {
    proguardFile.createSync();
  }
  proguardFile.writeAsStringSync(proguardTemplate(projectName));
}
