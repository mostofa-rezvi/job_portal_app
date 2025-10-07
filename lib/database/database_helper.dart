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
    String path = await getDatabasesPath();
    String dbPath = join(path, 'job_portal.db');
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL, -- Added NOT NULL for robustness
        email TEXT UNIQUE NOT NULL,    -- Added NOT NULL for robustness
        password TEXT NOT NULL         -- Added NOT NULL for robustness
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
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE -- Added ON DELETE CASCADE
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
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE -- Added ON DELETE CASCADE
      )
    ''');
  }

  // --- User Operations ---
  Future<int> insertUser(User user) async {
    Database db = await database;
    try {
      Map<String, dynamic> userMap = user.toMap();
      userMap.remove('id'); // Remove id for insertion
      return await db.insert('users', userMap);
    } catch (e) {
      print('Error inserting user: $e');
      return -1; // Indicate failure
    }
  }

  Future<User?> getUserByEmail(String email) async {
    Database db = await database;
    try {
      List<Map<String, dynamic>> maps = await db.query(
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

  Future<User?> getUserByUsername(String username) async {
    Database db = await database;
    try {
      List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );
      if (maps.isNotEmpty) {
        return User.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Error getting user by username: $e');
      return null;
    }
  }

  Future<User?> loginUser(String email, String password) async {
    Database db = await database;
    try {
      List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
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

  // --- Applied Jobs Operations ---
  Future<int> insertAppliedJob(AppliedJob job) async {
    Database db = await database;
    try {
      // Check if the job is already applied by this user to prevent duplicate entries
      List<Map<String, dynamic>> existing = await db.query(
        'applied_jobs',
        where: 'userId = ? AND jobId = ?',
        whereArgs: [job.userId, job.jobId],
      );
      if (existing.isNotEmpty) {
        return 0; // Indicate that it was not inserted (already exists)
      }
      return await db.insert('applied_jobs', job.toMap());
    } catch (e) {
      print('Error inserting applied job: $e');
      return -1;
    }
  }

  Future<List<AppliedJob>> getAppliedJobs(int userId) async {
    Database db = await database;
    try {
      List<Map<String, dynamic>> maps = await db.query(
          'applied_jobs',
          where: 'userId = ?',
          whereArgs: [userId],
          orderBy: 'appliedDate DESC'
      );
      return List.generate(maps.length, (i) {
        return AppliedJob.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error getting applied jobs: $e');
      return [];
    }
  }

  Future<bool> isJobApplied(int userId, String jobId) async {
    Database db = await database;
    try {
      List<Map<String, dynamic>> maps = await db.query(
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

  // --- Saved Jobs Operations ---
  Future<int> insertSavedJob(Map<String, dynamic> jobData) async {
    Database db = await database;
    try {
      // Check if the job is already saved by this user
      List<Map<String, dynamic>> existing = await db.query(
        'saved_jobs',
        where: 'userId = ? AND jobId = ?',
        whereArgs: [jobData['userId'], jobData['jobId']],
      );
      if (existing.isNotEmpty) {
        return 0; // Indicate that it was not inserted (already exists)
      }
      return await db.insert('saved_jobs', jobData);
    } catch (e) {
      print('Error inserting saved job: $e');
      return -1;
    }
  }

  Future<List<Map<String, dynamic>>> getSavedJobs(int userId) async {
    Database db = await database;
    try {
      List<Map<String, dynamic>> maps = await db.query(
        'saved_jobs',
        where: 'userId = ?',
        whereArgs: [userId],
      );
      return maps;
    } catch (e) {
      print('Error getting saved jobs: $e');
      return [];
    }
  }

  Future<bool> isJobSaved(int userId, String jobId) async {
    Database db = await database;
    try {
      List<Map<String, dynamic>> maps = await db.query(
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

  Future<int> deleteSavedJob(int userId, String jobId) async {
    Database db = await database;
    try {
      return await db.delete(
        'saved_jobs',
        where: 'userId = ? AND jobId = ?',
        whereArgs: [userId, jobId],
      );
    } catch (e) {
      print('Error deleting saved job: $e');
      return 0; // Indicate failure
    }
  }
}