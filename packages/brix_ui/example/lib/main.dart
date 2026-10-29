import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';

import 'brands.dart';
import 'gallery_screen.dart';

/// Every brix_ui widget on one screen. Switch light / dark and three brands
/// live – the widgets never change, only the theme.
void main() => runApp(const BrixUiExampleApp());

class BrixUiExampleApp extends StatefulWidget {
  const BrixUiExampleApp({super.key});

  @override
  State<BrixUiExampleApp> createState() => _BrixUiExampleAppState();
}

class _BrixUiExampleAppState extends State<BrixUiExampleApp> {
  Brand _brand = Brand.standard;
  bool _dark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'brix_ui',
      debugShowCheckedModeBanner: false,
      // Lets alerts and toasts open without a BuildContext.
      navigatorKey: BrixUi.navigatorKey ??= GlobalKey<NavigatorState>(),
      theme: _brand.theme(Brightness.light).toThemeData(),
      darkTheme: _brand.theme(Brightness.dark).toThemeData(),
      themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
      home: GalleryScreen(
        brand: _brand,
        dark: _dark,
        onBrand: (brand) => setState(() => _brand = brand),
        onDark: (dark) => setState(() => _dark = dark),
      ),
    );
  }
}
