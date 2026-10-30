import 'dart:io';

/// Runs the tools `brix create` needs (`flutter create`, `flutter pub get`).
/// Tests pass a fake.
class ProcessRunner {
  const ProcessRunner();

  /// Runs [executable] and waits for it to finish.
  Future<ProcessResult> run(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
  }) => Process.run(
    executable,
    arguments,
    workingDirectory: workingDirectory,
    runInShell: Platform.isWindows,
  );
}
