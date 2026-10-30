import 'package:brix_app/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('no API: the app does not start and says how to fix it', () {
    final problem = AppConfig.problem(url: '', release: false);
    expect(problem, contains('API_URL'));
    expect(problem, contains('main_development.dart'));
  });

  test('a release build needs https', () {
    expect(
      AppConfig.problem(url: 'http://api.example.com/', release: true),
      contains('https'),
    );
    expect(
      AppConfig.problem(url: 'https://api.example.com/v1/', release: true),
      isNull,
    );
  });

  test('http is fine while developing (a local server)', () {
    expect(
      AppConfig.problem(url: 'http://10.0.2.2:3000/', release: false),
      isNull,
    );
  });

  test('a broken address is refused', () {
    expect(AppConfig.problem(url: 'not a url', release: false), isNotNull);
  });
}
