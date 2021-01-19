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

    // argParser.addOption('provider-system',
    //     abbr: 'p',
    //     allowed: ['flutter_modular', 'bloc_pattern'],
    //     help: 'Create a flutter project using an specified provider system.');

    // argParser.addOption('state-management',
    //     abbr: 'm',
    //     allowed: ['mobx', 'flutter_bloc', 'rxdart'],
    //     help: 'Create a flutter project using an specified state management.');
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
