// flutter test --update-goldens
import 'package:brix_network/brix_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

const _brix = '../../../packages/brix/doc/screenshots';
const _network = '../../../packages/brix_network/doc/screenshots';
const _storage = '../../../packages/brix_storage/doc/screenshots';

void main() {
  setUpAll(loadFonts);

  testWidgets('brix: BrixLogger console', (tester) async {
    final lines = <String>[];
    final log = BrixLogger(name: 'My App', enabled: true, output: lines.add);
    log.banner('My App', details: {'version': '1.0.0', 'env': 'staging'});
    log.debug('Cache ready in 12 ms');
    log.info('Opened item 42');
    log.success('Logged in');
    log.warning('Session ends in 2 minutes');
    log.error(
      'Saving failed',
      error: StateError('The item was changed on another device.'),
      stackTrace: StackTrace.fromString(
        '#0      SaveFlow.run (package:my_app/save_flow.dart:42:7)\n'
        '#1      SaveController.save (package:my_app/save_controller.dart:18:5)\n',
      ),
    );

    await shoot(
      tester,
      '$_brix/console.png',
      Terminal(title: 'Debug console – BrixLogger', lines: lines),
      size: const Size(720, 600),
    );
  });

  testWidgets('brix_network: PrettyNetworkLogger', (tester) async {
    final lines = <String>[];
    final logger = PrettyNetworkLogger(enabled: true, output: lines.add);
    final api = Uri.parse('https://api.example.com/v1/');

    logger.log(
      NetworkLogEntry(
        request: NetworkRequest(
          method: HttpMethod.post,
          url: api.resolve('auth/login'),
          body: {'email': 'ada@brix.dev', 'password': 'Secret@123'},
        ),
        took: const Duration(milliseconds: 312),
        response: const NetworkResponse(
          statusCode: 200,
          body: {
            'success': true,
            'message': 'Welcome back!',
            'data': {'token': 'eyJhbGciOiJIUzI1NiJ9', 'name': 'Ada'},
          },
        ),
      ),
    );
    logger.log(
      NetworkLogEntry(
        request: NetworkRequest(
          method: HttpMethod.post,
          url: api.resolve('auth/signup'),
          body: {'email': 'ada@brix.dev', 'password': 'Secret@123'},
        ),
        took: const Duration(milliseconds: 188),
        response: const NetworkResponse(
          statusCode: 422,
          body: {
            'message': 'Validation failed',
            'errors': {
              'email': ['This email is already taken.'],
            },
          },
        ),
        failure: ValidationFailure(messages: ['This email is already taken.']),
      ),
    );
    logger.log(
      NetworkLogEntry(
        request: NetworkRequest(
          method: HttpMethod.get,
          url: api.resolve('items?page=1&limit=5'),
        ),
        took: const Duration(milliseconds: 1200),
        failure: NetworkFailure(),
      ),
    );

    await shoot(
      tester,
      '$_network/network_log.png',
      Terminal(title: 'Debug console – PrettyNetworkLogger', lines: lines),
      size: const Size(720, 760),
    );
  });

  testWidgets('brix_storage: where things are kept', (tester) async {
    await shoot(
      tester,
      '$_storage/storage.png',
      const _StorageDiagram(),
      size: const Size(850, 400),
    );
  });
}

/// What `BrixStorage` does with each call – drawn with the real API names.
class _StorageDiagram extends StatelessWidget {
  const _StorageDiagram();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _box(
          title: 'Your code',
          color: const Color(0xFF1D1D1F),
          lines: const [
            "write('locale', 'en')",
            "writeJson('settings', {...})",
            "writeSecret('token', token)",
            "readSecret('token')",
            'clear()',
          ],
          mono: true,
        ),
        const _Arrow(),
        const SizedBox(
          width: 210,
          child: Column(
            children: [
              _Badge('BrixStorage'),
              SizedBox(height: 12),
              _Note(
                Icons.cleaning_services_outlined,
                'Fresh install: old Keychain secrets wiped',
              ),
              _Note(
                Icons.shield_outlined,
                'Broken Keystore: null, never a crash',
              ),
              _Note(Icons.move_up, 'Old plain-text secrets moved once'),
              _Note(Icons.bolt_outlined, 'Secrets cached in memory'),
            ],
          ),
        ),
        const _Arrow(),
        Column(
          children: [
            _box(
              title: 'Values',
              subtitle: 'shared_preferences',
              color: const Color(0xFF007AFF),
              lines: const ['locale', 'settings (JSON)'],
            ),
            const SizedBox(height: 16),
            _box(
              title: 'Secrets',
              subtitle: 'Keychain · Keystore',
              color: const Color(0xFF34A853),
              lines: const ['token', 'refresh token', 'remembered password'],
              icon: Icons.lock_outline,
            ),
          ],
        ),
      ],
    );
  }

  Widget _box({
    required String title,
    String? subtitle,
    required Color color,
    required List<String> lines,
    bool mono = false,
    IconData? icon,
  }) {
    return Container(
      width: mono ? 250 : 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 6),
              ],
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 12,
                color: Color(0xFF6C6C70),
              ),
            ),
          const SizedBox(height: 10),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                line,
                style: TextStyle(
                  fontFamily: mono ? 'SFMono' : 'Roboto',
                  fontSize: mono ? 12 : 13.5,
                  color: const Color(0xFF1C1C1E),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(10, 70, 10, 0),
      child: Icon(Icons.arrow_forward_rounded, color: Color(0xFF8E8E93)),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF5F00), Color(0xFFFF8A3D)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Text(
        'BrixStorage',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: const Color(0xFFFF5F00)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 13,
                height: 1.3,
                color: Color(0xFF3A3A3C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
