import 'package:flutter/material.dart';

import 'ui/nav_home_page.dart';

void main() {
  runApp(const NishtarNavApp());
}

class NishtarNavApp extends StatelessWidget {
  const NishtarNavApp({super.key});

  @override
  Widget build(BuildContext context) {
    final seed = const Color(0xFF0B5F59);
    return MaterialApp(
      title: 'Nishtar Navigator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(centerTitle: false),
      ),
      home: const NavHomePage(),
    );
  }
}
