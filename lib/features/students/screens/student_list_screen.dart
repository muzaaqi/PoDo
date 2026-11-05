import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class StudentListScreen extends StatelessWidget {
  const StudentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader.nested(
        title: const Text('Daftar Mahasiswa'),
        prefixes: [
          FHeaderAction.back(onPress: () => Navigator.of(context).maybePop()),
        ],
      ),
      child: const Center(
        child: Text('Halaman Daftar Mahasiswa'),
      ),
    );
  }
}
