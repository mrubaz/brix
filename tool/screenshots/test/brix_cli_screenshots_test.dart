// flutter test test/brix_cli_screenshots_test.dart --update-goldens
import 'dart:io';

import 'package:brix_cli/brix_cli.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'support.dart';

const _out = '../../../packages/brix_cli/doc/screenshots';

/// `flutter create` without the SDK, so the real CLI output can be shown.
class _QuietRunner extends ProcessRunner {
  @override
  Future<ProcessResult> run(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
  }) async {
    if (arguments.first == 'create') {
      Directory(p.join(workingDirectory!, arguments.last)).createSync();
    }
    return ProcessResult(0, 0, '', '');
  }
}

/// One line of the folder tree.
typedef _Entry = ({int depth, String name, String note, bool folder});

const _tree = <_Entry>[
  (depth: 0, name: 'lib', note: '', folder: true),
  (
    depth: 1,
    name: 'main.dart',
    note: 'the real app, on your API',
    folder: false,
  ),
  (
    depth: 1,
    name: 'main_development.dart',
    note: 'the app on a local test backend',
    folder: false,
  ),
  (depth: 1, name: 'config', note: 'API address and services', folder: true),
  (depth: 1, name: 'routing', note: 'screens and where they go', folder: true),
  (depth: 1, name: 'domain', note: '', folder: true),
  (
    depth: 2,
    name: 'models',
    note: 'User, SignupRequest, ProfileUpdate',
    folder: true,
  ),
  (depth: 1, name: 'data', note: '', folder: true),
  (
    depth: 2,
    name: 'repositories',
    note: 'your API calls, and the local backend',
    folder: true,
  ),
  (
    depth: 2,
    name: 'services',
    note: 'where the local backend keeps its data',
    folder: true,
  ),
  (depth: 1, name: 'ui', note: '', folder: true),
  (depth: 2, name: 'core', note: 'theme and shared widgets', folder: true),
  (
    depth: 2,
    name: 'auth',
    note: 'login, signup, code, password reset',
    folder: true,
  ),
  (
    depth: 2,
    name: 'account',
    note: 'profile, change password, delete account',
    folder: true,
  ),
  (depth: 2, name: 'home', note: 'your first screen', folder: true),
  (depth: 0, name: 'test', note: 'the same folders as lib', folder: true),
  (
    depth: 0,
    name: 'brix.yaml',
    note: 'tells brix how the app is laid out',
    folder: false,
  ),
];

void main() {
  setUpAll(loadFonts);

  testWidgets('brix create in the terminal', (tester) async {
    final work = Directory.systemTemp.createTempSync('cli_shot');
    addTearDown(() => work.deleteSync(recursive: true));
    final lines = <String>[r'$ brix create my_app'];
    await tester.runAsync(
      () => BrixCli(
        runner: _QuietRunner(),
        template: Template(Directory('../../packages/brix_cli/templates/app')),
        out: lines.add,
        workingDirectory: work.path,
      ).run(['create', 'my_app']),
    );
    await shoot(
      tester,
      '$_out/terminal.png',
      Terminal(title: 'Terminal', lines: lines),
      size: const Size(720, 410),
    );
  });

  testWidgets('folders of a new app', (tester) async {
    await shoot(
      tester,
      '$_out/folders.png',
      Container(
        width: 640,
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'my_app',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1C1C1E),
              ),
            ),
            const SizedBox(height: 10),
            for (final entry in _tree)
              Padding(
                padding: EdgeInsets.only(left: 22.0 * entry.depth, top: 5),
                child: Row(
                  children: [
                    Icon(
                      entry.folder
                          ? Icons.folder_rounded
                          : Icons.description_outlined,
                      size: 19,
                      color: entry.folder
                          ? const Color(0xFF4A9EFF)
                          : const Color(0xFF8E8E93),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      entry.name,
                      style: const TextStyle(
                        fontFamily: mono,
                        fontSize: 14,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                    if (entry.note.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.note,
                          style: const TextStyle(
                            fontFamily: 'SF Pro',
                            fontSize: 14,
                            color: Color(0xFF8E8E93),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
      size: const Size(704, 600),
    );
  });
}
