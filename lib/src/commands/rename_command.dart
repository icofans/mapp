import 'package:mapp/src/commands/base_command.dart';
import 'package:mapp/mapp.dart';

class RenameCommand extends BaseCommand {
  @override
  final name = 'rename';
  @override
  final description = 'Rename flutter project display name/packageName/icon';
  @override
  final invocationSuffix = null;

  RenameCommand() {
    argParser
      ..addOption(
        'name',
        abbr: 'n',
        help: 'modify display name of app',
      )
      ..addOption(
        'org',
        abbr: 'o',
        help:
            'The organization responsible for your new Flutter project, in reverse domain name notation. This string is used in Java package names and as prefix in the iOS bundle identifier.(defaults to \"com.example\")',
      );
  }

  @override
  void run() {
    rename(
      argResults['name'],
      argResults['org'],
    );
  }
}
