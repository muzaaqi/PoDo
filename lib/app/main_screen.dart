import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:podo/features/courses/screens/course_list_screen.dart';
import 'package:podo/features/dashboard/screens/home_screen.dart';
import 'package:podo/features/lecturers/screens/account_screen.dart';
import 'package:podo/features/schedule/screens/schedule_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    HomeScreen(),
    ScheduleScreen(),
    CourseListScreen(),
    AccountScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      footer: FBottomNavigationBar(
        index: _currentIndex,
        onChange: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          FBottomNavigationBarItem(
            icon: const Icon(FLucideIcons.house),
            label: const Text('Home'),
          ),
          FBottomNavigationBarItem(
            icon: const Icon(FLucideIcons.calendar),
            label: const Text('Jadwal'),
          ),
          FBottomNavigationBarItem(
            icon: const Icon(FLucideIcons.bookOpen),
            label: const Text('Mata Kuliah'),
          ),
          FBottomNavigationBarItem(
            icon: const Icon(FLucideIcons.user),
            label: const Text('Akun'),
          ),
        ],
      ),
      child: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
    );
  }
}
