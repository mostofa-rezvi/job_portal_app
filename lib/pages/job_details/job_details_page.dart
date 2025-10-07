import 'package:flutter/material.dart';
import 'package:project/api/job_api_service.dart';
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
  final SharedPreferenceService _prefsService = SharedPreferenceService();

  bool _isJobSaved = false;
  int? _currentUserId;
  bool _isApplied = false;
  bool _isLoadingStatus = true;

  @override
  void initState() {
    super.initState();
    _jobDetailsFuture = _jobApiService.fetchJobDetails(widget.jobId);
    _loadUserIdAndCheckStatus();
  }

  Future<void> _loadUserIdAndCheckStatus() async {
    _currentUserId = await _prefsService.getCurrentUserId();
    if (_currentUserId != null) {
      _isJobSaved = await _prefsService.isJobSaved(_currentUserId!, widget.jobId.toString());
      _isApplied = await _prefsService.isJobApplied(_currentUserId!, widget.jobId.toString());
    }
    setState(() { _isLoadingStatus = false; });
  }

  Future<void> _applyForJob(Job job) async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to apply for jobs.')),
      );
      return;
    }

    if (_isApplied) return;

    AppliedJob appliedJob = AppliedJob(
      userId: _currentUserId!,
      jobId: job.id.toString(),
      jobTitle: job.title,
      companyName: job.companyName,
      jobLocation: job.location,
      salary: job.salary,
      appliedDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      imageUrl: job.imageUrl,
    );

    await _prefsService.applyForJob(_currentUserId!, appliedJob);
    setState(() => _isApplied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Job applied successfully!')),
    );
  }

  Future<void> _toggleSaveJob(Job job) async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to save jobs.')),
      );
      return;
    }

    if (_isJobSaved) {
      await _prefsService.unsaveJob(_currentUserId!, job.id.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job unsaved.')),
      );
    } else {
      await _prefsService.saveJob(_currentUserId!, job);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job saved successfully!')),
      );
    }
    setState(() => _isJobSaved = !_isJobSaved);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        actions: [
          if (!_isLoadingStatus)
            FutureBuilder<Job>(
              future: _jobDetailsFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return IconButton(
                    icon: Icon(
                      _isJobSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: _isJobSaved ? Colors.amber : null,
                    ),
                    onPressed: () => _toggleSaveJob(snapshot.data!),
                  );
                }
                return const SizedBox.shrink();
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
                        job.imageUrl,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 180),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(job.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(job.companyName, style: TextStyle(fontSize: 18, color: Colors.grey[700])),
                  const Divider(height: 32),
                  const Text('Job Description', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(job.description, style: const TextStyle(fontSize: 16, height: 1.5)),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isApplied || _isLoadingStatus ? null : () => _applyForJob(job),
                      icon: _isApplied ? const Icon(Icons.check_circle) : const Icon(Icons.send),
                      label: Text(_isApplied ? 'Applied' : 'Apply Now'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: Colors.white,
                        backgroundColor: _isApplied ? Colors.grey : Theme.of(context).primaryColor,
                        disabledForegroundColor: Colors.white70,
                        disabledBackgroundColor: Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
