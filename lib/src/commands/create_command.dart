import 'package:args/command_runner.dart';
import 'package:mapp/src/commands/base_command.dart';
import 'package:mapp/mapp.dart';

class CreateCommand extends BaseCommand {
  @override
  final name = 'create';
  @override
  final description = 'Create a Flutter project with basic structure';
  @override
  final invocationSuffix = '<project name>';

  CreateCommand() {
    argParser.addOption('org',
        abbr: 'o',
        help:
            'The organization responsible for your new Flutter project, in reverse domain name notation. This string is used in Java package names and as prefix in the iOS bundle identifier. (defaults to \"com.example\")');
  }

  @override
  void run() {
    if (argResults.rest.isEmpty) {
      throw UsageException(
          'project name not passed for a create command', usage);
    } else {
      create(
        argResults.rest.first,
        argResults['org'],
      );
    }
  }
}
