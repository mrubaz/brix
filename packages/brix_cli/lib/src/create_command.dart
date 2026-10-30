import 'dart:io';

import 'package:path/path.dart' as p;

import 'app_id.dart';
import 'app_name.dart';
import 'process_runner.dart';
import 'template.dart';

/// `brix create <name>`: a new Flutter app on brix that runs at once.
class CreateCommand {
  CreateCommand({
    required this.runner,
    required this.template,
    required this.out,
    String? workingDirectory,
  }) : workingDirectory = workingDirectory ?? Directory.current.path;

  final ProcessRunner runner;
  final Template template;
  final void Function(String line) out;
  final String workingDirectory;

  /// Creates the app; returns the exit code (0 on success).
  Future<int> run(String name, {String org = 'com.example'}) async {
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

    await template.copyTo(target, name);
    out('  ✓ Login, signup, theme, network and storage');

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

  int _failed(String step, ProcessResult result) {
    out('$step failed:');
    final text = '${result.stderr}'.trim().isEmpty
        ? '${result.stdout}'.trim()
        : '${result.stderr}'.trim();
    if (text.isNotEmpty) out(text);
    return result.exitCode == 0 ? 1 : result.exitCode;
  }
}
