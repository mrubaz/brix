import 'package:brix_getx/brix_getx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends GetView<BrixSessionController<String>> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You are logged in.',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            Obx(
              () => FilledButton.tonal(
                onPressed: controller.isLoggingOut.value
                    ? null
                    : controller.logout,
                child: const Text('Log out'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
