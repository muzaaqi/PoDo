import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:podo/core/database/database_helper.dart';
import 'package:podo/features/auth/repositories/auth_repository.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    final helper = DatabaseHelper.instance;
    await helper.initDatabase(
      path: inMemoryDatabasePath,
      factory: databaseFactoryFfi,
    );
    AuthRepository.instance.logout();
  });

  tearDown(() async {
    await DatabaseHelper.instance.close();
  });

  group('AuthRepository', () {
    test('login with valid demo credentials sets activeLecturerId and returns lecturer_id', () async {
      final repo = AuthRepository.instance;

      expect(repo.isAuthenticated, isFalse);
      expect(repo.activeLecturerId, isNull);

      final result = await repo.login('dosen@kampus.id', 'password123');

      expect(result, 'L001');
      expect(repo.isAuthenticated, isTrue);
      expect(repo.activeLecturerId, 'L001');
    });

    test('login with second demo account returns L002', () async {
      final repo = AuthRepository.instance;

      final result = await repo.login('siti@kampus.id', 'password123');

      expect(result, 'L002');
      expect(repo.isAuthenticated, isTrue);
      expect(repo.activeLecturerId, 'L002');
    });

    test('login with invalid credentials returns null and leaves session unauthenticated', () async {
      final repo = AuthRepository.instance;

      final result = await repo.login('wrong@kampus.id', 'wrongpass');

      expect(result, isNull);
      expect(repo.isAuthenticated, isFalse);
      expect(repo.activeLecturerId, isNull);
    });

    test('logout clears active session', () async {
      final repo = AuthRepository.instance;
      await repo.login('dosen@kampus.id', 'password123');
      expect(repo.isAuthenticated, isTrue);

      await repo.logout();

      expect(repo.isAuthenticated, isFalse);
      expect(repo.activeLecturerId, isNull);
    });
  });
}
