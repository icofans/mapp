import 'package:mapp/src/commands/base_command.dart';
import 'package:mapp/mapp.dart';

class GenerateCommand extends BaseCommand {
  @override
  final name = 'generate';
  @override
  final description = 'Generate templates';
  @override
  final invocationSuffix = null;

  GenerateCommand() {}

  @override
  void run() {
    generate();
  }
}
