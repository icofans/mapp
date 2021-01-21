import 'dart:io';
import 'package:mapp/src/utils/utils.dart';

enum ModifyPlatform { all, ios, android }

/// 创建项目
///
void rename(String appName, String packageName) {
  // rename
  ModifyPlatform platform = ModifyPlatform.all;

  // 未输入参数
  if (appName == null && packageName == null) {
    String type = select(
      message: 'Please choose which one you want to modify',
      options: ['name', 'org'],
    );
    if (type == 'name') {
      appName = input(
        message: 'Please enter the name you want to modify',
        defaultValue: '',
      );
    }
    if (type == 'org') {
      packageName = input(
        message:
            'Please enter the org(bundle identifier && package name) you want to modify',
        defaultValue: '',
      );
    }
  }
  // 选择平台
  String p = select(
    message: 'Please choose which paltform you want to modify',
    options: ['all', 'ios', 'android'],
  );
  if (p == 'ios') {
    platform = ModifyPlatform.ios;
  }
  if (p == 'android') {
    platform = ModifyPlatform.android;
  }

  if (appName != null) {
    modifyName(appName, platform);
  }
  if (packageName != null) {
    modifyPackageName(packageName, platform);
  }
}

// 修改App名称
void modifyName(String appName, ModifyPlatform platform,
    {Directory targetDir}) {
  targetDir = targetDir ?? Directory.current;
  print('Modify app name --> ${green(appName)}\n');
  switch (platform) {
    case ModifyPlatform.all:
      _modifyIosAppName(appName, targetDir);
      _modifyAndroidAppName(appName, targetDir);
      break;
    case ModifyPlatform.ios:
      _modifyIosAppName(appName, targetDir);
      break;
    case ModifyPlatform.android:
      _modifyAndroidAppName(appName, targetDir);
      break;
    default:
  }
}

void _modifyIosAppName(String appName, Directory targetDir) {
  // 修改Info.plist文件
  Directory directory = Directory(targetDir.path + '/ios/Runner');
  String filePath = directory.path + '/Info.plist';
  File file = File(filePath);
  if (file.existsSync()) {
    try {
      List lines = file.readAsStringSync().split('\n');
      for (int i = 0; i < lines.length; i++) {
        String line = lines[i];
        if (line.contains("<key>CFBundleName</key>")) {
          lines[i + 1] = "\t<string>${appName}</string>\r";
          break;
        }
      }
      print('✨ Successfully modify iOS app name \n');
      file.writeAsStringSync(lines.join('\n'));
    } catch (e) {
      print(red('Failed to read Info.plist file'));
    }
  } else {
    print(red('Info.plist not found.'));
  }
}

void _modifyAndroidAppName(String appName, Directory targetDir) {
  Directory directory = Directory(targetDir.path + '/android/app/src/main');
  String filePath = directory.path + '/AndroidManifest.xml';
  File file = File(filePath);
  if (file.existsSync()) {
    try {
      List lines = file.readAsStringSync().split('\n');
      for (int i = 0; i < lines.length; i++) {
        String line = lines[i];
        if (line.contains("android:label")) {
          lines[i] = "        android:label=\"${appName}\"";
          break;
        }
      }
      print('✨ Successfully modify android app name \n');
      file.writeAsStringSync(lines.join('\n'));
    } catch (e) {
      print(red('Failed to read AndroidManifest.xml file'));
    }
  } else {
    print(red('AndroidManifest.xml not found.'));
  }
}

// 修改App包名
void modifyPackageName(
  String packageName,
  ModifyPlatform platform,
) {
  switch (platform) {
    case ModifyPlatform.all:
      _modifyIosPackageName(packageName);
      _modifyAndroidPackageName(packageName);
      break;
    case ModifyPlatform.ios:
      _modifyIosPackageName(packageName);
      break;
    case ModifyPlatform.android:
      _modifyAndroidPackageName(packageName);
      break;
    default:
  }
}

void _modifyIosPackageName(String packageName) {
  Directory targetDir =
      Directory(Directory.current.path + '/ios/Runner.xcodeproj');
  String filePath = targetDir.path + '/project.pbxproj';
  File file = File(filePath);
  if (file.existsSync()) {
    try {
      List lines = file.readAsStringSync().split('\n');
      for (int i = 0; i < lines.length; i++) {
        String line = lines[i];
        if (line.contains("PRODUCT_BUNDLE_IDENTIFIER")) {
          lines[i] = "				PRODUCT_BUNDLE_IDENTIFIER = $packageName;";
          continue;
        }
      }
      print('\n✨ Successfully modify iOS bundle identifier \n');
      file.writeAsStringSync(lines.join('\n'));
    } catch (e) {
      print(red('Failed to read Info.plist file'));
    }
  } else {
    print(red('Info.plist not found.'));
  }
}

void _modifyAndroidPackageName(String packageName) {
  // Android包名需要修改的文件较多,容易出错,暂不支持修改.建议手动修改或在创建项目时指定
  print('\n❌ android not support !!!!!\n');
}
