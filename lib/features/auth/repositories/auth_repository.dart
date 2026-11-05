import 'package:podo/core/database/database_helper.dart';

class AuthRepository {
  static final AuthRepository instance = AuthRepository._internal();

  AuthRepository._internal();

  String? _activeLecturerId;

  String? get activeLecturerId => _activeLecturerId;
  bool get isAuthenticated => _activeLecturerId != null;

  static const Map<String, ({String password, String lecturerId})> _demoAccounts = {
    'dosen@kampus.id': (password: 'password123', lecturerId: 'L001'),
    'dosen': (password: 'password123', lecturerId: 'L001'),
    'siti@kampus.id': (password: 'password123', lecturerId: 'L002'),
    'siti': (password: 'password123', lecturerId: 'L002'),
  };

  Future<String?> login(String emailOrUsername, String password) async {
    final account = _demoAccounts[emailOrUsername.trim().toLowerCase()];
    if (account == null || account.password != password) {
      return null;
    }

    final db = await DatabaseHelper.instance.database;
    final records = await db.query(
      'lecturers',
      where: 'lecturer_id = ?',
      whereArgs: [account.lecturerId],
    );

    if (records.isEmpty) {
      return null;
    }

    _activeLecturerId = account.lecturerId;
    return _activeLecturerId;
  }

  Future<void> logout() async {
    _activeLecturerId = null;
  }
}
