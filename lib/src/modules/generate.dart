import 'package:mapp/src/utils/utils.dart';

void generate() {
  String type = select(
    message: 'Please choose which one you want to generate',
    options: ['single page', 'list page', 'model'],
  );

  if (type == 'single page') {}
  if (type == 'list page') {}
  if (type == 'model') {}
  // if (type == 'name') {
  //   appName = input(
  //     message: 'Please enter the name you want to modify',
  //     defaultValue: '',
  //   );
  // }
  // if (type == 'org') {
  //   packageName = input(
  //     message:
  //         'Please enter the org(bundle identifier && package name) you want to modify',
  //     defaultValue: '',
  //   );
  // }
  // // 选择平台
  // String p = select(
  //   message: 'Please choose which paltform you want to modify',
  //   options: ['all', 'ios', 'android'],
  // );
  // if (p == 'ios') {
  //   platform = ModifyPlatform.ios;
  // }
  // if (p == 'android') {
  //   platform = ModifyPlatform.android;
  // }

  // if (appName != null) {
  //   modifyName(appName, platform);
  // }
  // if (packageName != null) {
  //   modifyPackageName(packageName, platform);
  // }
}
