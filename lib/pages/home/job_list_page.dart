import 'package:flutter/material.dart';
import 'package:project/api/job_api_service.dart';
import 'package:project/models/job.dart';
import 'package:project/pages/profile/profile_page.dart';
import 'package:project/services/shared_preference_service.dart';
import 'package:project/widgets/job_card.dart';
import 'package:project/pages/auth/login_page.dart';

class JobListPage extends StatefulWidget {
  const JobListPage({super.key});

  @override
  State<JobListPage> createState() => _JobListPageState();
}

class _JobListPageState extends State<JobListPage> {
  late Future<List<Job>> _jobsFuture;
  final JobApiService _jobApiService = JobApiService();
  final SharedPreferenceService _prefsService = SharedPreferenceService();

  @override
  void initState() {
    super.initState();
    _jobsFuture = _jobApiService.fetchJobs();
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
        title: const Text('Job List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => Center(child: const ProfilePage())),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final prefs = SharedPreferenceService();
              await prefs.clearUserData();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Job>>(
        future: _jobsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No jobs found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return JobCard(job: snapshot.data![index]);
              },
            );
          }
        },
      ),
    );
  }
}