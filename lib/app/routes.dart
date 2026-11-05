import 'package:flutter/widgets.dart';
import 'package:podo/app/main_screen.dart';
import 'package:podo/features/auth/screens/login_screen.dart';
import 'package:podo/features/splash/screens/splash_screen.dart';
import 'package:podo/features/students/models/student.dart';
import 'package:podo/features/students/screens/student_biodata_form_screen.dart';
import 'package:podo/features/students/screens/student_list_screen.dart';

class AppRoutes {
  const AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String main = '/main';
  static const String studentList = '/students';
  static const String studentBiodataForm = '/students/form';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    main: (context) => const MainScreen(),
    studentList: (context) => const StudentListScreen(),
    studentBiodataForm: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      return StudentBiodataFormScreen(
        student: args is Student ? args : null,
      );
    },
  };
}
