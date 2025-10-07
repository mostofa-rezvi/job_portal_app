import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project/models/job.dart';

class JobApiService {
  final String _baseUrl = 'https://dummyjson.com/products';

  Future<List<Job>> fetchJobs() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl?limit=20')); // Limiting for demo

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> productsJson = data['products'];
        return productsJson.map((json) => Job.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load jobs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching jobs: $e');
    }
  }

  Future<Job> fetchJobDetails(int id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$id'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Job.fromJson(data);
      } else {
        throw Exception('Failed to load job details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching job details: $e');
    }
  }
}