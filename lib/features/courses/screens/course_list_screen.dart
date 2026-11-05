import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class CourseListScreen extends StatelessWidget {
  const CourseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader(
        title: const Text('Mata Kuliah'),
      ),
      child: const Center(
        child: Text('Course List Content'),
      ),
    );
  }
}
