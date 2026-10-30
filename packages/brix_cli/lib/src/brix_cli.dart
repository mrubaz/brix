import 'create_command.dart';
import 'id_command.dart';
import 'process_runner.dart';
import 'template.dart';

/// brix_cli's version, shown by `brix --version`.
const brixCliVersion = '1.1.0';

/// The `brix` command.
class BrixCli {
  BrixCli({
    this.runner = const ProcessRunner(),
    this.template,
    void Function(String line)? out,
    this.workingDirectory,
  }) : out = out ?? print;

  final ProcessRunner runner;

  /// The app to copy; default: the one bundled with brix_cli.
  final Template? template;
  final void Function(String line) out;
  final String? workingDirectory;

  /// Runs `brix` with [arguments]; returns the exit code.
  Future<int> run(List<String> arguments) async {
    if (arguments.isEmpty ||
        arguments.first == '--help' ||
        arguments.first == '-h' ||
        arguments.first == 'help') {
      _help();
      return 0;
    }
    if (arguments.first == '--version' || arguments.first == '-v') {
      out('brix_cli $brixCliVersion');
      return 0;
    }
    if (arguments.first == 'create') {
      final rest = arguments.skip(1).toList();
      String? org;
      final orgAt = rest.indexOf('--org');
      if (orgAt != -1) {
        if (orgAt + 1 >= rest.length) {
          out('Give --org a value: brix create my_app --org com.mycompany');
          return 64;
        }
        org = rest[orgAt + 1];
        rest.removeRange(orgAt, orgAt + 2);
      }
      if (rest.length != 1) {
        out('Give the app a name: brix create my_app');
        return 64;
      }
      return CreateCommand(
        runner: runner,
        template: template ?? await Template.bundled(),
        out: out,
        workingDirectory: workingDirectory,
      ).run(rest.single, org: org ?? 'com.example');
    }
    if (arguments.first == 'id') {
      if (arguments.length != 2) {
        out('Give the new id: brix id com.mycompany.my_app');
        return 64;
      }
      return IdCommand(
        out: out,
        workingDirectory: workingDirectory,
      ).run(arguments[1]);
    }
    out('Unknown command "${arguments.first}".');
    _help();
    return 64;
  }

  void _help() {
    out('brix: Flutter apps on brix.');
    out('');
    out('Usage:');
    out('  brix create <app_name> [--org com.mycompany]');
    out('      A new app with login, signup, email code, password reset,');
    out('      profile, theme, network and storage.');
    out('  brix id <com.mycompany.app>');
    out('      Changes the app id on every platform. Run it in the app.');
    out('  brix --version');
    out('  brix --help');
  }
}
