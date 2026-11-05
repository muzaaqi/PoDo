import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader(
        title: const Text('Home'),
      ),
      child: const Center(
        child: Text('Home Screen Content'),
      ),
    );
  }
}
