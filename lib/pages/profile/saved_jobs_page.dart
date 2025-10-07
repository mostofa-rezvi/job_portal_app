import 'package:flutter/material.dart';
import 'package:project/database/database_helper.dart';
import 'package:project/pages/job_details/job_details_page.dart';
import 'package:project/widgets/profile_list_item.dart';

class SavedJobsPage extends StatefulWidget {
  final int userId;

  const SavedJobsPage({super.key, required this.userId});

  @override
  State<SavedJobsPage> createState() => _SavedJobsPageState();
}

class _SavedJobsPageState extends State<SavedJobsPage> {
  late Future<List<Map<String, dynamic>>> _savedJobsFuture;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadSavedJobs();
  }

  void _loadSavedJobs() {
    setState(() {
      _savedJobsFuture = _dbHelper.getSavedJobs(widget.userId);
    });
  }

  void _unSaveJob(String jobId) async {
    await _dbHelper.deleteSavedJob(widget.userId, jobId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Job unsaved.')),
    );
    _loadSavedJobs(); // Refresh the list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Jobs'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _savedJobsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No saved jobs found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final job = snapshot.data![index];
                return Dismissible(
                  key: Key(job['jobId'].toString()), // Unique key for Dismissible
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _unSaveJob(job['jobId'].toString());
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ProfileListItem(
                    title: job['jobTitle'],
                    subtitle: '${job['companyName']} - ${job['location']} - ${job['salary']}',
                    imageUrl: job['imageUrl'] ?? 'https://via.placeholder.com/150', // Use stored image or placeholder
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => JobDetailsPage(jobId: int.parse(job['jobId'])),
                        ),
                      ).then((_) => _loadSavedJobs()); // Refresh when returning
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}