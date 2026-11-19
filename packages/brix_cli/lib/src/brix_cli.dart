import 'create_command.dart';
import 'id_command.dart';

import 'dart:io';

import 'process_runner.dart';
import 'state_library.dart';
import 'template.dart';

/// brix_cli's version, shown by `brix --version`.
const brixCliVersion = '2.0.0';

/// The `brix` command.
class BrixCli {
  BrixCli({
    this.runner = const ProcessRunner(),
    this.template,
    void Function(String line)? out,
    String? Function()? readLine,
    bool? hasTerminal,
    this.workingDirectory,
  }) : out = out ?? print,
       readLine = readLine ?? stdin.readLineSync,
       hasTerminal = hasTerminal ?? stdin.hasTerminal;

  final ProcessRunner runner;

  /// The app to copy for every state library; default: the ones bundled
  /// with brix_cli.
  final Template? template;
  final void Function(String line) out;

  /// Reads the answer to the state library question.
  final String? Function() readLine;

  /// False for AI agents, scripts and CI: they must pass `--state`.
  final bool hasTerminal;
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
      StateLibrary? state;
      final stateAt = rest.indexOf('--state');
      if (stateAt != -1) {
        final value = stateAt + 1 < rest.length ? rest[stateAt + 1] : '';
        state = StateLibrary.parse(value);
        if (state == null) {
          out('Give --state one of: ${StateLibrary.choices}');
          return 64;
        }
        rest.removeRange(stateAt, stateAt + 2);
      }
      if (rest.length != 1) {
        out('Give the app a name: brix create my_app');
        return 64;
      }
      return CreateCommand(
        runner: runner,
        template: (state) async => template ?? await Template.bundled(state),
        out: out,
        readLine: readLine,
        hasTerminal: hasTerminal,
        workingDirectory: workingDirectory,
      ).run(rest.single, org: org ?? 'com.example', state: state);
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
    out('                         [--state ${StateLibrary.choices}]');
    out('      A new app with login, signup, email code, password reset,');
    out('      profile, theme, network and storage. Asks for the state');
    out('      library; --state is for AI agents and scripts.');
    out('  brix id <com.mycompany.app>');
    out('      Changes the app id on every platform. Run it in the app.');
    out('  brix --version');
    out('  brix --help');
  }
}
