import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:podo/core/theme/app_theme.dart';

class PoDoApp extends StatelessWidget {
  const PoDoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PoDo',
      debugShowCheckedModeBanner: false,
      builder: (context, child) => FTheme(
        data: AppTheme.lightTheme,
        child: child ?? const SizedBox.shrink(),
      ),
      home: const Scaffold(
        body: Center(
          child: Text('PoDo (Portal Dosen)'),
        ),
      ),
    );
  }
}
