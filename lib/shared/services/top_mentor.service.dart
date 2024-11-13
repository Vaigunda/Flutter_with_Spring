// lib/shared/services/top_mentor.service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mentor/shared/models/top_mentor.model.dart';

class TopMentorService {
  final String apiUrl = 'http://localhost:8080/api/mentors/top-mentor';

  // Method to fetch top mentors
  Future<List<TopMentorModel>> fetchTopMentors() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((mentorData) => TopMentorModel.fromJson(mentorData)).toList();
    } else {
      throw Exception('Failed to load top mentors');
    }
  }
}