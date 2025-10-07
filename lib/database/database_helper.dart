import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:project/models/user.dart';
import 'package:project/models/applied_job.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = join(await getDatabasesPath(), 'job_portal.db');
    print('Database path: $dbPath');

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    print('Creating tables...');
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE applied_jobs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        jobId TEXT NOT NULL,
        jobTitle TEXT,
        companyName TEXT,
        jobLocation TEXT,
        salary TEXT,
        appliedDate TEXT,
        imageUrl TEXT,
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE saved_jobs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        jobId TEXT NOT NULL,
        jobTitle TEXT,
        companyName TEXT,
        jobLocation TEXT,
        salary TEXT,
        imageUrl TEXT,
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    print('Tables created successfully.');
  }

  Future<int> insertUser(User user) async {
    final db = await database;
    try {
      final existing = await db.query(
        'users',
        where: 'email = ? OR username = ?',
        whereArgs: [user.email, user.username],
      );
      if (existing.isNotEmpty) {
        print('User already exists with same email or username.');
        return 0;
      }
      return await db.insert('users', {
        'username': user.username,
        'email': user.email,
        'password': user.password,
      });
    } catch (e) {
      print('Error inserting user: $e');
      return -1;
    }
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    try {
      final maps = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );
      if (maps.isNotEmpty) {
        return User.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Error getting user by email: $e');
      return null;
    }
  }

  Future<User?> loginUser(String emailOrUsername, String password) async {
    final db = await database;
    try {
      final maps = await db.query(
        'users',
        where: '(email = ? OR username = ?) AND password = ?',
        whereArgs: [emailOrUsername, emailOrUsername, password],
      );
      if (maps.isNotEmpty) {
        return User.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Error logging in user: $e');
      return null;
    }
  }

  Future<int> insertAppliedJob(AppliedJob job) async {
    final db = await database;
    try {
      final existing = await db.query(
        'applied_jobs',
        where: 'userId = ? AND jobId = ?',
        whereArgs: [job.userId, job.jobId],
      );
      if (existing.isNotEmpty) return 0;
      return await db.insert('applied_jobs', job.toMap());
    } catch (e) {
      print('Error inserting applied job: $e');
      return -1;
    }
  }

  Future<List<AppliedJob>> getAppliedJobs(int userId) async {
    final db = await database;
    try {
      final maps = await db.query(
        'applied_jobs',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'appliedDate DESC',
      );
      return List.generate(maps.length, (i) => AppliedJob.fromMap(maps[i]));
    } catch (e) {
      print('Error getting applied jobs: $e');
      return [];
    }
  }

  Future<int> insertSavedJob(Map<String, dynamic> jobData) async {
    final db = await database;
    try {
      final existing = await db.query(
        'saved_jobs',
        where: 'userId = ? AND jobId = ?',
        whereArgs: [jobData['userId'], jobData['jobId']],
      );
      if (existing.isNotEmpty) return 0;
      return await db.insert('saved_jobs', jobData);
    } catch (e) {
      print('Error inserting saved job: $e');
      return -1;
    }
  }

  Future<List<Map<String, dynamic>>> getSavedJobs(int userId) async {
    final db = await database;
    try {
      return await db.query(
        'saved_jobs',
        where: 'userId = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      print('Error getting saved jobs: $e');
      return [];
    }
  }

  Future<int> deleteSavedJob(int userId, String jobId) async {
    final db = await database;
    try {
      return await db.delete(
        'saved_jobs',
        where: 'userId = ? AND jobId = ?',
        whereArgs: [userId, jobId],
      );
    } catch (e) {
      print('Error deleting saved job: $e');
      return 0;
    }
  }

  Future<bool> isJobSaved(int userId, String jobId) async {
    final db = await database;
    try {
      final maps = await db.query(
        'saved_jobs',
        where: 'userId = ? AND jobId = ?',
        whereArgs: [userId, jobId],
      );
      return maps.isNotEmpty;
    } catch (e) {
      print('Error checking if job is saved: $e');
      return false;
    }
  }

  Future<bool> isJobApplied(int userId, String jobId) async {
    final db = await database;
    try {
      final maps = await db.query(
        'applied_jobs',
        where: 'userId = ? AND jobId = ?',
        whereArgs: [userId, jobId],
      );
      return maps.isNotEmpty;
    } catch (e) {
      print('Error checking if job is applied: $e');
      return false;
    }
  }
}
