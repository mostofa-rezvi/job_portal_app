import 'package:flutter/material.dart';
import 'package:project/database/database_helper.dart';
import 'package:project/pages/profile/applied_jobs_page.dart';
import 'package:project/pages/profile/saved_jobs_page.dart';
import 'package:project/services/shared_preference_service.dart';
import 'package:project/pages/auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _username = 'Loading...';
  String _email = 'Loading...';
  int? _userId;

  final SharedPreferenceService _prefsService = SharedPreferenceService();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    _username = await _prefsService.getCurrentUsername() ?? 'N/A';
    _email = await _prefsService.getCurrentUserEmail() ?? 'N/A';
    _userId = await _prefsService.getCurrentUserId();
    setState(() {});
  }

  void _logout() async {
    await _prefsService.clearUserData();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, size: 70, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              _username,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _email,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const Divider(height: 40, thickness: 1),
            ListTile(
              leading: const Icon(Icons.bookmark, color: Colors.blueAccent),
              title: const Text('Saved Jobs', style: TextStyle(fontSize: 18)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                if (_userId != null) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => SavedJobsPage(userId: _userId!),
                  ));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User not logged in.')));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.cases_rounded, color: Colors.green),
              title: const Text('Applied Jobs', style: TextStyle(fontSize: 18)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                if (_userId != null) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AppliedJobsPage(userId: _userId!),
                  ));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User not logged in.')));
                }
              },
            ),
            // Add more profile options if needed
          ],
        ),
      ),
    );
  }
}