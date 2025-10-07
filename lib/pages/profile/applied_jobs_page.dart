import 'package:flutter/material.dart';
import 'package:project/services/shared_preference_service.dart';
import 'package:project/models/applied_job.dart';
import 'package:project/pages/job_details/job_details_page.dart';
import 'package:project/widgets/profile_list_item.dart';

class AppliedJobsPage extends StatefulWidget {
  final int userId;
  const AppliedJobsPage({super.key, required this.userId});

  @override
  State<AppliedJobsPage> createState() => _AppliedJobsPageState();
}

class _AppliedJobsPageState extends State<AppliedJobsPage> {
  late Future<List<AppliedJob>> _appliedJobsFuture;
  final SharedPreferenceService _prefsService = SharedPreferenceService();

  @override
  void initState() {
    super.initState();
    _loadAppliedJobs();
  }

  void _loadAppliedJobs() {
    setState(() {
      _appliedJobsFuture = _prefsService.getAppliedJobs(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Applied Jobs'),
      ),
      body: FutureBuilder<List<AppliedJob>>(
        future: _appliedJobsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'You have not applied for any jobs yet.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          } else {
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final appliedJob = snapshot.data![index];
                return Card(
                  elevation: 2.0,
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  child: ProfileListItem(
                    title: appliedJob.jobTitle ?? 'No Title Provided',
                    subtitle: '${appliedJob.companyName ?? 'N/A'} - Applied on ${appliedJob.appliedDate}',
                    imageUrl: appliedJob.imageUrl ?? 'https://via.placeholder.com/150?text=No+Image',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => JobDetailsPage(jobId: int.parse(appliedJob.jobId)),
                        ),
                      );
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
