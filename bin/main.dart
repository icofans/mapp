import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:mapp/src/commands/commands.dart';
import 'package:mapp/src/commands/generate_command.dart';

void main(List<String> arguments) {
  final runner = configureCommand(arguments);

  var hasCommand = runner.commands.keys.any((x) => arguments.contains(x));

  if (hasCommand) {
    executeCommand(runner, arguments);
  } else {
    var parser = ArgParser();
    parser = runner.argParser;
    var results = parser.parse(arguments);
    executeOptions(results, arguments, runner);
  }
}

void executeOptions(
    ArgResults results, List<String> arguments, CommandRunner runner) {
  if (results.wasParsed('help') || arguments.isEmpty) {
    print(runner.usage);
  }

  if (results.wasParsed('version')) {
    String version = '0.0.1';
    print('v$version');
  }
}

void executeCommand(CommandRunner runner, List<String> arguments) {
  runner.run(arguments).catchError((error) {
    if (error is! UsageException) throw error;
    print(error);
  });
}

CommandRunner configureCommand(List<String> arguments) {
  var runner = CommandRunner('mapp', 'CLI for Flutter.')
    ..addCommand(CreateCommand())
    ..addCommand(RenameCommand())
    ..addCommand(GenerateCommand());
  runner.argParser.addFlag('version', abbr: 'v', negatable: false);
  return runner;
}
