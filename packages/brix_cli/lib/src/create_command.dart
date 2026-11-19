import 'dart:io';

import 'package:path/path.dart' as p;

import 'app_id.dart';
import 'app_name.dart';
import 'process_runner.dart';
import 'state_library.dart';
import 'template.dart';

/// `brix create <name>`: a new Flutter app on brix that runs at once.
class CreateCommand {
  CreateCommand({
    required this.runner,
    required this.template,
    required this.out,
    required this.readLine,
    required this.hasTerminal,
    String? workingDirectory,
  }) : workingDirectory = workingDirectory ?? Directory.current.path;

  final ProcessRunner runner;

  /// The app to copy for the chosen state library.
  final Future<Template> Function(StateLibrary state) template;

  /// One line typed by the user, or null when input ended.
  final String? Function() readLine;

  /// Whether a person can answer the state library question.
  final bool hasTerminal;
  final void Function(String line) out;
  final String workingDirectory;

  /// Creates the app on [state]; without it, asks which library. Returns
  /// the exit code (0 on success).
  Future<int> run(
    String name, {
    String org = 'com.example',
    StateLibrary? state,
  }) async {
    final problem = AppName.problem(name);
    if (problem != null) {
      out('Cannot use "$name" as the app name. $problem');
      return 64;
    }
    final orgProblem = AppId.orgProblem(org);
    if (orgProblem != null) {
      out('Cannot use "$org" for --org. $orgProblem');
      return 64;
    }
    final target = Directory(p.join(workingDirectory, name));
    if (target.existsSync()) {
      out('A folder named "$name" is already here. Pick another name.');
      return 73;
    }
    final chosen = state ?? _askState();
    if (chosen == null) return 64;

    out('Creating $name ...');
    final created = await runner.run('flutter', [
      'create',
      '--org',
      org,
      '--project-name',
      name,
      name,
    ], workingDirectory: workingDirectory);
    if (created.exitCode != 0) {
      return _failed('flutter create', created);
    }
    out('  ✓ Flutter project');

    await (await template(chosen)).copyTo(target, name);
    // Later brix commands read which library the app is on.
    final brixYaml = File(p.join(target.path, 'brix.yaml'));
    final yaml = brixYaml.readAsStringSync();
    final lineBreak = yaml.isEmpty || yaml.endsWith('\n') ? '' : '\n';
    brixYaml.writeAsStringSync('$yaml${lineBreak}state: ${chosen.name}\n');
    out('  ✓ Login, signup, theme, network and storage on ${chosen.title}');

    final got = await runner.run('flutter', [
      'pub',
      'get',
    ], workingDirectory: target.path);
    if (got.exitCode != 0) {
      out('  ! Packages: run "flutter pub get" in $name yourself.');
    } else {
      out('  ✓ Packages');
    }

    out('');
    out('Done. Run it:');
    out('  cd $name');
    out('  flutter run');
    out('');
    out('Until you add your API, debug runs use a test backend on the device.');
    out('  Login: demo@brix.dev / Demo@1234, every code 123456');
    out('Your API goes in lib/config/app_config.dart.');
    out('App id: $org.$name (change it any time with "brix id").');
    return 0;
  }

  /// Asks for the state library until a valid answer. No default: an app
  /// is never made on a library nobody chose.
  StateLibrary? _askState() {
    if (!hasTerminal) return _noAnswer();
    out('Which state management?');
    for (final (index, state) in StateLibrary.values.indexed) {
      out('  ${index + 1}. ${state.title}');
    }
    final count = StateLibrary.values.length;
    while (true) {
      out('Pick 1-$count:');
      final answer = readLine();
      if (answer == null) return _noAnswer();
      final number = int.tryParse(answer.trim());
      if (number != null && number >= 1 && number <= count) {
        return StateLibrary.values[number - 1];
      }
      final named = StateLibrary.parse(answer);
      if (named != null) return named;
    }
  }

  StateLibrary? _noAnswer() {
    out('Which state management? Add --state ${StateLibrary.choices}.');
    out('AI agents and scripts: ask the user which one, never pick it.');
    return null;
  }

  int _failed(String step, ProcessResult result) {
    out('$step failed:');
    final text = '${result.stderr}'.trim().isEmpty
        ? '${result.stdout}'.trim()
        : '${result.stderr}'.trim();
    if (text.isNotEmpty) out(text);
    return result.exitCode == 0 ? 1 : result.exitCode;
  }
}
