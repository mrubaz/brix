// brix_storage in a few lines. Run inside a Flutter app (it uses
// shared_preferences and flutter_secure_storage).
import 'package:brix_storage/brix_storage.dart';
import 'package:flutter/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = BrixStorage(
    onError: (error, _) => debugPrint('storage problem: $error'),
  );

  await storage.write('locale', 'en');
  await storage.writeSecret('token', 'secret-token');

  debugPrint('locale: ${await storage.read('locale')}');
  debugPrint('token saved: ${await storage.readSecret('token') != null}');
}
