import 'dart:convert';
import 'dart:io';

import 'package:mapp/src/utils/console_selector.dart';
import 'package:mapp/src/utils/output_utils.dart';

/// 获取用户输入的内容
///
String input({
  String message = "",
  String defaultValue = "",
}) {
  stdout.write(blue(message) +
      white(defaultValue.isEmpty ? '' : '($defaultValue)') +
      ": ");
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
String select({
  String message,
  List options,
}) {
  print(blue(message) + white('(Use arrow keys))'));
  final menu = ConsoleSelector(options);
  final result = menu.choose();
  _answer(result.toString());
  return result.toString();
}

void _answer(String result) {
  print('answer: ' + green(result));
}
