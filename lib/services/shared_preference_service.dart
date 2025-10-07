import 'package:project/models/applied_job.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:project/models/user.dart';
import 'package:project/models/job.dart';

class SharedPreferenceService {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _currentUserIdKey = 'currentUserId';
  static const String _currentUserEmailKey = 'currentUserEmail';
  static const String _currentUsernameKey = 'currentUsername';
  static const String _userDataPrefix = 'user_data_';

  static const String _savedJobsKeyPrefix = 'saved_jobs_';
  static const String _appliedJobsKeyPrefix = 'applied_jobs_';

  Future<void> saveNewUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userKey = '$_userDataPrefix${user.username}';

    final userData = user.toMap();
    await prefs.setString(userKey, jsonEncode(userData));

    await prefs.setString('email_map_${user.email}', user.username);
  }

  Future<bool> checkIfUserExists(String username, String email) async {
    final prefs = await SharedPreferences.getInstance();
    final userKey = '$_userDataPrefix$username';
    final emailMapKey = 'email_map_$email';

    return prefs.containsKey(userKey) || prefs.containsKey(emailMapKey);
  }

  Future<User?> getUserByLogin(String emailOrUsername) async {
    final prefs = await SharedPreferences.getInstance();
    String? username = emailOrUsername;

    if (emailOrUsername.contains('@')) {
      username = prefs.getString('email_map_$emailOrUsername');
    }

    if (username == null) return null;

    final userKey = '$_userDataPrefix$username';
    final userDataString = prefs.getString(userKey);

    if (userDataString != null) {
      return User.fromMap(jsonDecode(userDataString));
    }
    return null;
  }

  Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, value);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<void> setCurrentUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_currentUserIdKey, userId);
  }

  Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_currentUserIdKey);
  }

  Future<void> setCurrentUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserEmailKey, email);
  }

  Future<String?> getCurrentUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserEmailKey);
  }

  Future<void> setCurrentUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUsernameKey, username);
  }

  Future<String?> getCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUsernameKey);
  }

  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_currentUserIdKey);
    await prefs.remove(_currentUserEmailKey);
    await prefs.remove(_currentUsernameKey);
  }

  Future<void> applyForJob(int userId, AppliedJob appliedJob) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_appliedJobsKeyPrefix$userId';
    final appliedJobs = await getAppliedJobs(userId);

    if (!appliedJobs.any((job) => job.jobId == appliedJob.jobId)) {
      appliedJobs.add(appliedJob);
      final List<Map<String, dynamic>> jobMaps = appliedJobs.map((job) => job.toMap()).toList();
      await prefs.setString(key, jsonEncode(jobMaps));
    }
  }

  Future<List<AppliedJob>> getAppliedJobs(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_appliedJobsKeyPrefix$userId';
    final jobsString = prefs.getString(key);

    if (jobsString != null) {
      final List<dynamic> decodedList = jsonDecode(jobsString);
      return decodedList.map((json) => AppliedJob.fromMap(json)).toList();
    }
    return [];
  }

  Future<bool> isJobApplied(int userId, String jobId) async {
    final appliedJobs = await getAppliedJobs(userId);
    return appliedJobs.any((job) => job.jobId == jobId);
  }

  Future<void> saveJob(int userId, Job job) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_savedJobsKeyPrefix$userId';
    final savedJobs = await getSavedJobs(userId);
    if (!savedJobs.any((savedJob) => savedJob['jobId'] == job.id.toString())) {
      savedJobs.add(job.toSavedJobMap(userId));
      await prefs.setString(key, jsonEncode(savedJobs));
    }
  }

  Future<void> unsaveJob(int userId, String jobId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_savedJobsKeyPrefix$userId';
    List<Map<String, dynamic>> savedJobs = await getSavedJobs(userId);
    savedJobs.removeWhere((job) => job['jobId'] == jobId);
    await prefs.setString(key, jsonEncode(savedJobs));
  }

  Future<List<Map<String, dynamic>>> getSavedJobs(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_savedJobsKeyPrefix$userId';
    final jobsString = prefs.getString(key);
    if (jobsString != null) {
      final List<dynamic> decodedList = jsonDecode(jobsString);
      return decodedList.cast<Map<String, dynamic>>().toList();
    }
    return [];
  }

  Future<bool> isJobSaved(int userId, String jobId) async {
    final savedJobs = await getSavedJobs(userId);
    return savedJobs.any((job) => job['jobId'] == jobId);
  }
}