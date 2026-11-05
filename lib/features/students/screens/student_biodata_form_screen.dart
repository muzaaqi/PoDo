import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class StudentBiodataFormScreen extends StatelessWidget {
  const StudentBiodataFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader.nested(
        title: const Text('Biodata Mahasiswa'),
        prefixes: [
          FHeaderAction.back(onPress: () => Navigator.of(context).maybePop()),
        ],
      ),
      child: const Center(
        child: Text('Halaman Biodata Mahasiswa'),
      ),
    );
  }
}
