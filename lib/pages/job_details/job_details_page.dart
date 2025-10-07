import 'package:flutter/material.dart';
import 'package:project/api/job_api_service.dart';
import 'package:project/database/database_helper.dart';
import 'package:project/models/applied_job.dart';
import 'package:project/models/job.dart';
import 'package:project/services/shared_preference_service.dart';
import 'package:intl/intl.dart';

class JobDetailsPage extends StatefulWidget {
  final int jobId;

  const JobDetailsPage({super.key, required this.jobId});

  @override
  State<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  late Future<Job> _jobDetailsFuture;
  final JobApiService _jobApiService = JobApiService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final SharedPreferenceService _prefsService = SharedPreferenceService();

  bool _isJobSaved = false;
  int? _currentUserId;
  bool _isApplied = false;

  @override
  void initState() {
    super.initState();
    _jobDetailsFuture = _jobApiService.fetchJobDetails(widget.jobId);
    _loadUserIdAndCheckStatus();
  }

  Future<void> _loadUserIdAndCheckStatus() async {
    _currentUserId = await _prefsService.getCurrentUserId();
    if (_currentUserId != null) {
      _isJobSaved = await _dbHelper.isJobSaved(_currentUserId!, widget.jobId.toString());
      _isApplied = await _dbHelper.isJobApplied(_currentUserId!, widget.jobId.toString());
    }
    setState(() {}); // Rebuild to update button states
  }

  Future<void> _applyForJob(Job job) async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to apply for jobs.')),
      );
      return;
    }

    if (_isApplied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have already applied for this job.')),
      );
      return;
    }

    AppliedJob appliedJob = AppliedJob(
      userId: _currentUserId!,
      jobId: job.id.toString(), // Store as string
      jobTitle: job.title,
      companyName: job.companyName,
      jobLocation: job.location,
      salary: job.salary,
      appliedDate: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
      imageUrl: job.imageUrl,
    );

    try {
      int result = await _dbHelper.insertAppliedJob(appliedJob);
      if (result > 0) {
        setState(() {
          _isApplied = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job applied successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to apply. You might have already applied.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error applying for job: $e')),
      );
    }
  }

  Future<void> _toggleSaveJob(Job job) async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to save jobs.')),
      );
      return;
    }

    try {
      if (_isJobSaved) {
        // Unsave job
        await _dbHelper.deleteSavedJob(_currentUserId!, job.id.toString());
        setState(() {
          _isJobSaved = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job unsaved.')),
        );
      } else {
        // Save job
        int result = await _dbHelper.insertSavedJob(job.toSavedJobMap(_currentUserId!));
        if (result > 0) {
          setState(() {
            _isJobSaved = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Job saved successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Job already saved.')),
          );
        }

      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving/unsaving job: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        actions: [
          FutureBuilder<Job>(
            future: _jobDetailsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                return IconButton(
                  icon: Icon(
                    _isJobSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: _isJobSaved ? Colors.yellow[700] : null,
                  ),
                  onPressed: () => _toggleSaveJob(snapshot.data!),
                );
              }
              return Container(); // Or a disabled icon
            },
          ),
        ],
      ),
      body: FutureBuilder<Job>(
        future: _jobDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Job details not found.'));
          } else {
            Job job = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        job.imageUrl, // Now `imageUrl` is defined
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 180),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    job.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job.companyName,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 20, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          job.location,
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Icon(Icons.monetization_on, size: 20, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          job.salary,
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  const Text(
                    'Job Description',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    job.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isApplied ? null : () => _applyForJob(job),
                      icon: _isApplied ? const Icon(Icons.check_circle_outline) : const Icon(Icons.send),
                      label: Text(_isApplied ? 'Applied' : 'Apply Now', style: const TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: _isApplied ? Colors.grey : Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}