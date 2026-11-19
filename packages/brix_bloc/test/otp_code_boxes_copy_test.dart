@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// `OtpCodeBoxes` is copied into each state package (no shared Flutter
/// package). This fails when a copy changes and the others do not.
void main() {
  test('OtpCodeBoxes is the same as in brix_getx', () {
    const own = 'lib/src/otp_code_boxes.dart';
    const getx = '../brix_getx/lib/src/otp_code_boxes.dart';

    expect(File(own).readAsStringSync(), File(getx).readAsStringSync());
  });
}
