import 'dart:io';

import 'package:brix_app/data/services/local_accounts_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory dir;
  setUp(() => dir = Directory.systemTemp.createTempSync('local_backend'));
  tearDown(() => dir.deleteSync(recursive: true));

  File device(String name) => File('${dir.path}/$name.json');

  test('starts with the demo account', () async {
    final account = await LocalAccountsService(device('a'))
        .find(LocalAccountsService.demoEmail);
    expect(account?.password, LocalAccountsService.demoPassword);
    expect(account?.verified, isTrue);
  });

  test('changes on one device never reach another', () async {
    final a = LocalAccountsService(device('a'));
    final b = LocalAccountsService(device('b'));
    const email = LocalAccountsService.demoEmail;

    final demo = (await b.find(email))!;
    await b.put(
      email,
      demo.copyWith(name: 'Changed by B', password: 'B@12345x'),
    );
    await b.remove('nobody@x.dev');

    final onA = await a.find(email);
    expect(onA?.name, 'Demo');
    expect(onA?.password, LocalAccountsService.demoPassword);
    expect((await b.find(email))?.name, 'Changed by B');
  });

  test('a deleted account stays deleted after the app restarts', () async {
    await LocalAccountsService(device('a'))
        .remove(LocalAccountsService.demoEmail);
    final restarted = LocalAccountsService(device('a'));
    expect(await restarted.find(LocalAccountsService.demoEmail), isNull);
  });

  test('signups are kept after a restart', () async {
    await LocalAccountsService(device('a')).put(
      'ada@brix.dev',
      const LocalAccount(name: 'Ada', password: 'Strong@123', verified: true),
    );
    final restarted = LocalAccountsService(device('a'));
    expect((await restarted.find('ada@brix.dev'))?.name, 'Ada');
  });

  test('reset brings back only the demo account', () async {
    final a = LocalAccountsService(device('a'));
    await a.remove(LocalAccountsService.demoEmail);
    await a.put(
      'ada@brix.dev',
      const LocalAccount(name: 'Ada', password: 'x', verified: true),
    );
    await a.reset();
    final restarted = LocalAccountsService(device('a'));
    expect(await restarted.find(LocalAccountsService.demoEmail), isNotNull);
    expect(await restarted.find('ada@brix.dev'), isNull);
  });

  test('a broken file starts over instead of crashing', () async {
    device('a').writeAsStringSync('{not json');
    final account = await LocalAccountsService(device('a'))
        .find(LocalAccountsService.demoEmail);
    expect(account, isNotNull);
  });
}
