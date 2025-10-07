class Job {
  final int id;
  final String title;
  final String companyName;
  final String location;
  final String salary;
  final String description;
  final String imageUrl; // Added imageUrl

  Job({
    required this.id,
    required this.title,
    required this.companyName,
    required this.location,
    required this.salary,
    required this.description,
    required this.imageUrl, // Required in constructor
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'],
      title: json['title'],
      companyName: json['brand'] ?? 'Unknown Company',
      location: 'Remote', // Placeholder
      salary: '\$${json['price'].toString()}k - \$${(json['price'] * 1.5).toStringAsFixed(0)}k/year',
      description: json['description'],
      // Safely get the first image or use a placeholder if 'images' is not available or empty
      imageUrl: (json['images'] != null && json['images'] is List && json['images'].isNotEmpty)
          ? json['images'][0]
          : 'https://via.placeholder.com/150', // Placeholder image URL
    );
  }

  // For saving to SQLite (Saved Jobs)
  Map<String, dynamic> toSavedJobMap(int userId) {
    return {
      'userId': userId,
      'jobId': id.toString(),
      'jobTitle': title,
      'companyName': companyName,
      'jobLocation': location,
      'salary': salary,
      'imageUrl': imageUrl, // Include imageUrl here
    };
  }
}