import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader(
        title: const Text('Jadwal Mengajar'),
      ),
      child: const Center(
        child: Text('Schedule Screen Content'),
      ),
    );
  }
}
