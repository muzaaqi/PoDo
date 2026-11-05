import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:podo/features/courses/models/course_offering.dart';

class CourseDetailScreen extends StatelessWidget {
  final CourseOffering? offering;

  const CourseDetailScreen({super.key, this.offering});

  @override
  Widget build(BuildContext context) {
    final routeOffering = ModalRoute.of(context)?.settings.arguments as CourseOffering?;
    final targetOffering = offering ?? routeOffering;

    return FScaffold(
      header: FHeader.nested(
        title: Text(targetOffering?.courseName ?? 'Detail Mata Kuliah'),
        prefixes: [
          FHeaderAction.back(onPress: () => Navigator.of(context).maybePop()),
        ],
      ),
      child: Center(
        child: Text(
          targetOffering != null
              ? '${targetOffering.courseCode} - ${targetOffering.className}'
              : 'Detail Perkuliahan',
        ),
      ),
    );
  }
}
