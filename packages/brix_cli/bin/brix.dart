import 'dart:io';

import 'package:brix_cli/brix_cli.dart';

Future<void> main(List<String> arguments) async {
  exitCode = await BrixCli().run(arguments);
}
