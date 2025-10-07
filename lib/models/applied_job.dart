class AppliedJob {
  int? id;
  final int userId;
  final String jobId;
  final String jobTitle;
  final String companyName;
  final String jobLocation;
  final String salary;
  final String appliedDate;
  final String? imageUrl;

  AppliedJob({
    this.id,
    required this.userId,
    required this.jobId,
    required this.jobTitle,
    required this.companyName,
    required this.jobLocation,
    required this.salary,
    required this.appliedDate,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'jobId': jobId,
      'jobTitle': jobTitle,
      'companyName': companyName,
      'jobLocation': jobLocation,
      'salary': salary,
      'appliedDate': appliedDate,
      'imageUrl': imageUrl,
    };
  }

  factory AppliedJob.fromMap(Map<String, dynamic> map) {
    return AppliedJob(
      id: map['id'],
      userId: map['userId'],
      jobId: map['jobId'],
      jobTitle: map['jobTitle'],
      companyName: map['companyName'],
      jobLocation: map['jobLocation'],
      salary: map['salary'],
      appliedDate: map['appliedDate'],
      imageUrl: map['imageUrl'],
    );
  }
}