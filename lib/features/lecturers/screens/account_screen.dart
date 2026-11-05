import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader(
        title: const Text('Akun Dosen'),
      ),
      child: const Center(
        child: Text('Account Screen Content'),
      ),
    );
  }
}
